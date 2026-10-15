import 'dart:async';

import 'package:tusc/tusc.dart' hide Headers;

enum VideoUploadOutcome { completed, cancelled, failed }

typedef TusClientFactory =
    TusBaseClient Function({
      required String? uploadUrl,
      required Map<String, String> headers,
    });

/// A TUS video upload that survives a lost connection.
///
/// Every attempt uses a new client that continues the same upload URL from the
/// server's offset, so a dropped or stale connection never restarts the upload
/// and never makes "resume" fail at once. Network failures are retried with a
/// growing delay; an expired Bunny signature (401/403) is renewed through
/// [refreshHeaders]; [cancel] stops it at any point.
class ResumableVideoUpload {
  ResumableVideoUpload({
    required this.createClient,
    required this.refreshHeaders,
    required Map<String, String> headers,
    this.maxAttempts = 40,
    Duration Function(int attempt)? retryDelay,
  }) : _headers = headers,
       _retryDelay = retryDelay ?? _defaultRetryDelay;

  final TusClientFactory createClient;

  /// Fresh signed TUS headers, or null when they cannot be renewed.
  final Future<Map<String, String>?> Function() refreshHeaders;

  /// About 15 minutes of retries in total before giving up.
  final int maxAttempts;
  final Duration Function(int attempt) _retryDelay;

  Map<String, String> _headers;
  String? _uploadUrl;
  TusBaseClient? _client;
  bool _cancelled = false;

  static Duration _defaultRetryDelay(int attempt) => Duration(
    seconds: const [2, 4, 8, 15, 30][(attempt - 1).clamp(0, 4)],
  );

  bool get isCancelled => _cancelled;

  Future<VideoUploadOutcome> run({
    required void Function(double percent) onProgress,
    void Function(String? message)? onStatus,
  }) async {
    for (var attempt = 1; ; attempt++) {
      if (_cancelled) return VideoUploadOutcome.cancelled;

      final client = createClient(uploadUrl: _uploadUrl, headers: _headers);
      _client = client;
      var completed = false;
      ProtocolException? protocolError;
      try {
        await client.startUpload(
          onProgress: (count, total, _) {
            if (total <= 0) return;
            onProgress(count * 100 / total);
            onStatus?.call(null);
          },
          onComplete: (_) => completed = true,
          onError: (error) => protocolError = error,
        );
      } catch (_) {
        // No connection, socket closed, DNS... retried below.
      }
      if (client.uploadUrl.isNotEmpty) _uploadUrl = client.uploadUrl;

      if (completed) {
        onStatus?.call(null);
        return VideoUploadOutcome.completed;
      }
      if (_cancelled || client.state == TusUploadState.cancelled) {
        return VideoUploadOutcome.cancelled;
      }

      final status = protocolError?.response.statusCode;
      if (status == 401 || status == 403) {
        // The signed upload headers expired during a long interruption.
        Map<String, String>? fresh;
        try {
          fresh = await refreshHeaders();
        } catch (_) {
          fresh = null;
        }
        if (fresh != null) {
          _headers = fresh;
        } else if (attempt >= maxAttempts) {
          return VideoUploadOutcome.failed;
        }
      } else if (status == 404 || status == 410) {
        // The server dropped this upload: start a new one for the video.
        _uploadUrl = null;
      }

      if (attempt >= maxAttempts) return VideoUploadOutcome.failed;
      onStatus?.call('انقطع الاتصال، سيُستكمل الرفع تلقائياً عند عودته…');
      if (!await _wait(_retryDelay(attempt))) {
        return VideoUploadOutcome.cancelled;
      }
    }
  }

  /// Stops the upload: the request in flight is dropped and no retry follows.
  void cancel() {
    _cancelled = true;
    _client?.cancelUpload();
  }

  /// Waits [delay], returning false as soon as the upload is cancelled.
  Future<bool> _wait(Duration delay) async {
    final end = DateTime.now().add(delay);
    while (DateTime.now().isBefore(end)) {
      if (_cancelled) return false;
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    return !_cancelled;
  }
}
