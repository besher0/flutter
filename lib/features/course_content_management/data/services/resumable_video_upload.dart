import 'dart:async';
import 'dart:developer';

import 'package:tusc/tusc.dart' hide Headers;

enum VideoUploadOutcome { completed, cancelled, failed }

typedef TusClientFactory =
    TusBaseClient Function({
      required String? uploadUrl,
      required Map<String, String> headers,
    });

/// A TUS video upload that can be resumed after a lost connection.
///
/// A connection lost while bytes are being sent stops [run] with
/// [VideoUploadOutcome.failed]; the upload is not retried in the background.
/// Calling [run] again (the teacher pressing "resume") uses a new client that
/// continues the same upload URL from the server's offset, so the upload never
/// restarts from zero.
///
/// The first requests of a resume often fail even though the connection is
/// back: the network is still settling, or the server still holds the lock of
/// the request the drop interrupted (409/423) until it notices the dead
/// connection. Until this run has sent its first bytes such failures are
/// retried for about half a minute ([resumeRetryDelays]) instead of failing
/// at once. An expired Bunny signature (401/403) is renewed through
/// [refreshHeaders] and a dropped upload (404/410) is recreated; [cancel]
/// stops it at any point.
class ResumableVideoUpload {
  ResumableVideoUpload({
    required this.createClient,
    required this.refreshHeaders,
    required Map<String, String> headers,
    List<Duration>? resumeRetryDelays,
  }) : _headers = headers,
       resumeRetryDelays = resumeRetryDelays ?? _defaultResumeRetryDelays;

  final TusClientFactory createClient;

  /// Fresh signed TUS headers, or null when they cannot be renewed.
  final Future<Map<String, String>?> Function() refreshHeaders;

  /// Waits between attempts while a run has not sent any bytes yet.
  final List<Duration> resumeRetryDelays;

  static const _defaultResumeRetryDelays = [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
    Duration(seconds: 8),
    Duration(seconds: 15),
  ];

  /// Signature renewals and upload recreations allowed per run.
  static const _maxServerRecoveries = 3;

  Map<String, String> _headers;
  String? _uploadUrl;
  TusBaseClient? _client;
  bool _cancelled = false;

  bool get isCancelled => _cancelled;

  Future<VideoUploadOutcome> run({
    required void Function(double percent) onProgress,
  }) async {
    var settleRetries = 0;
    var serverRecoveries = 0;
    var sentBytes = false;

    while (true) {
      if (_cancelled) return VideoUploadOutcome.cancelled;

      final client = createClient(uploadUrl: _uploadUrl, headers: _headers);
      _client = client;
      var completed = false;
      int? startOffset;
      ProtocolException? protocolError;
      Object? networkError;
      try {
        await client.startUpload(
          onProgress: (count, total, _) {
            startOffset ??= count;
            if (count > startOffset!) sentBytes = true;
            if (total <= 0) return;
            onProgress(count * 100 / total);
          },
          onComplete: (_) => completed = true,
          onError: (error) => protocolError = error,
        );
      } catch (error) {
        // No connection, socket closed, DNS...
        networkError = error;
      }
      if (client.uploadUrl.isNotEmpty) _uploadUrl = client.uploadUrl;

      if (completed) return VideoUploadOutcome.completed;
      if (_cancelled || client.state == TusUploadState.cancelled) {
        return VideoUploadOutcome.cancelled;
      }
      // tusc gives up on a timed-out request without closing it: drop the
      // socket so the server releases the upload sooner.
      _close(client);

      final status = protocolError?.response.statusCode;
      log(
        'video upload attempt failed: '
        '${protocolError?.message ?? networkError} (status $status)',
        name: 'ResumableVideoUpload',
      );

      if (status == 401 || status == 403) {
        // The signed upload headers expired while the upload was paused.
        if (++serverRecoveries > _maxServerRecoveries) {
          return VideoUploadOutcome.failed;
        }
        Map<String, String>? fresh;
        try {
          fresh = await refreshHeaders();
        } catch (_) {
          fresh = null;
        }
        if (fresh == null) return VideoUploadOutcome.failed;
        _headers = fresh;
        continue;
      }
      if (status == 404 || status == 410) {
        // The server dropped this upload: start a new one for the video.
        if (++serverRecoveries > _maxServerRecoveries) {
          return VideoUploadOutcome.failed;
        }
        _uploadUrl = null;
        continue;
      }

      final transient =
          networkError != null ||
          status == null ||
          status == 408 ||
          status == 409 ||
          status == 423 ||
          status == 429 ||
          status >= 500 ||
          // An offset that does not match: ask the server for it again.
          (status >= 200 && status < 300);
      if (!transient) return VideoUploadOutcome.failed;

      // Bytes were flowing and the connection dropped: pause until the
      // teacher resumes.
      if (sentBytes) return VideoUploadOutcome.failed;
      if (settleRetries >= resumeRetryDelays.length) {
        return VideoUploadOutcome.failed;
      }
      if (!await _wait(resumeRetryDelays[settleRetries++])) {
        return VideoUploadOutcome.cancelled;
      }
    }
  }

  /// Stops the upload: the request in flight is dropped.
  void cancel() {
    _cancelled = true;
    final client = _client;
    if (client == null) return;
    client.cancelUpload();
    _close(client);
  }

  void _close(TusBaseClient client) {
    try {
      client.httpClient.close();
    } catch (_) {
      // Already closed.
    }
  }

  /// Waits [delay], returning false as soon as the upload is cancelled.
  Future<bool> _wait(Duration delay) async {
    final end = DateTime.now().add(delay);
    while (DateTime.now().isBefore(end)) {
      if (_cancelled) return false;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    return !_cancelled;
  }
}
