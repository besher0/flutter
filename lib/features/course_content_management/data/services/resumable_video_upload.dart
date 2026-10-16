import 'dart:async';

import 'package:tusc/tusc.dart' hide Headers;

enum VideoUploadOutcome { completed, cancelled, failed }

typedef TusClientFactory =
    TusBaseClient Function({
      required String? uploadUrl,
      required Map<String, String> headers,
    });

/// A TUS video upload that can be resumed after a lost connection.
///
/// A dropped connection stops [run] with [VideoUploadOutcome.failed]; nothing
/// is retried automatically. Calling [run] again (the teacher pressing
/// "resume") uses a new client that continues the same upload URL from the
/// server's offset, so the upload never restarts from zero. An expired Bunny
/// signature (401/403) is renewed through [refreshHeaders] and a dropped
/// upload (404/410) is recreated, both at once; [cancel] stops it at any point.
class ResumableVideoUpload {
  ResumableVideoUpload({
    required this.createClient,
    required this.refreshHeaders,
    required Map<String, String> headers,
  }) : _headers = headers;

  final TusClientFactory createClient;

  /// Fresh signed TUS headers, or null when they cannot be renewed.
  final Future<Map<String, String>?> Function() refreshHeaders;

  /// Attempts per [run]: the first one plus one per recoverable server answer.
  static const _maxAttempts = 3;

  Map<String, String> _headers;
  String? _uploadUrl;
  TusBaseClient? _client;
  bool _cancelled = false;

  bool get isCancelled => _cancelled;

  Future<VideoUploadOutcome> run({
    required void Function(double percent) onProgress,
  }) async {
    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
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
          },
          onComplete: (_) => completed = true,
          onError: (error) => protocolError = error,
        );
      } catch (_) {
        // No connection, socket closed, DNS... the teacher resumes by hand.
      }
      if (client.uploadUrl.isNotEmpty) _uploadUrl = client.uploadUrl;

      if (completed) return VideoUploadOutcome.completed;
      if (_cancelled || client.state == TusUploadState.cancelled) {
        return VideoUploadOutcome.cancelled;
      }

      final status = protocolError?.response.statusCode;
      if (status == 401 || status == 403) {
        // The signed upload headers expired while the upload was paused.
        Map<String, String>? fresh;
        try {
          fresh = await refreshHeaders();
        } catch (_) {
          fresh = null;
        }
        if (fresh == null) return VideoUploadOutcome.failed;
        _headers = fresh;
      } else if (status == 404 || status == 410) {
        // The server dropped this upload: start a new one for the video.
        _uploadUrl = null;
      } else {
        return VideoUploadOutcome.failed;
      }
    }
    return VideoUploadOutcome.failed;
  }

  /// Stops the upload: the request in flight is dropped.
  void cancel() {
    _cancelled = true;
    _client?.cancelUpload();
  }
}
