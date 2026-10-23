import 'dart:io';

import 'package:coursaty_student_and_teacher/features/course_content_management/data/services/resumable_video_upload.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/presentation/widgets/percent_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:tusc/tusc.dart' hide Headers;

/// One scripted attempt: what the TUS client does when started.
enum _Attempt {
  /// Sends bytes, then the connection drops.
  dropWhileSending,

  /// The connection is not back yet: the first request fails.
  networkError,

  /// The server still locks the upload of the interrupted request.
  locked,
  timeout,
  expiredSignature,
  complete,
}

class _FakeHttpClient extends http.BaseClient {
  bool closed = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      throw UnimplementedError();

  @override
  void close() => closed = true;
}

class _FakeTusClient implements TusBaseClient {
  _FakeTusClient(this.behaviour, this.receivedUploadUrl, this.receivedHeaders);

  final _Attempt behaviour;
  final String? receivedUploadUrl;
  final Map<String, String> receivedHeaders;
  TusUploadState _state = TusUploadState.notStarted;

  @override
  final _FakeHttpClient httpClient = _FakeHttpClient();

  @override
  String get uploadUrl =>
      receivedUploadUrl ?? 'https://video.bunnycdn.com/tusupload/abc';

  @override
  TusUploadState get state => _state;

  @override
  Future<void> startUpload({
    ProgressCallback? onProgress,
    CompleteCallback? onComplete,
    ErrorCallback? onError,
    Function()? onTimeout,
  }) async {
    switch (behaviour) {
      case _Attempt.dropWhileSending:
        onProgress?.call(300, 1000, null);
        onProgress?.call(400, 1000, null);
        _state = TusUploadState.error;
        throw const SocketException('Network is unreachable');
      case _Attempt.networkError:
        _state = TusUploadState.error;
        throw const SocketException('Failed host lookup');
      case _Attempt.locked:
        _state = TusUploadState.error;
        onError?.call(ProtocolException('locked', http.Response('', 409)));
      case _Attempt.timeout:
        _state = TusUploadState.error;
        onError?.call(ProtocolException('timeout', http.Response('', 408)));
      case _Attempt.expiredSignature:
        _state = TusUploadState.error;
        onError?.call(ProtocolException('expired', http.Response('', 401)));
      case _Attempt.complete:
        onProgress?.call(400, 1000, null);
        onProgress?.call(1000, 1000, null);
        _state = TusUploadState.completed;
        onComplete?.call(http.Response('', 204));
    }
  }

  @override
  Future? cancelUpload() async => _state = TusUploadState.cancelled;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late List<_FakeTusClient> clients;

  ResumableVideoUpload upload(
    List<_Attempt> script, {
    Future<Map<String, String>?> Function()? refresh,
    List<Duration> retryDelays = const [
      Duration.zero,
      Duration.zero,
      Duration.zero,
    ],
  }) {
    clients = [];
    return ResumableVideoUpload(
      headers: const {'AuthorizationSignature': 'old'},
      refreshHeaders: refresh ?? () async => null,
      resumeRetryDelays: retryDelays,
      createClient: ({required uploadUrl, required headers}) {
        final client = _FakeTusClient(
          script[clients.length.clamp(0, script.length - 1)],
          uploadUrl,
          headers,
        );
        clients.add(client);
        return client;
      },
    );
  }

  test('a drop while sending pauses at once, without retrying', () async {
    final progress = <double>[];
    final task = upload([_Attempt.dropWhileSending, _Attempt.complete]);

    expect(await task.run(onProgress: progress.add), VideoUploadOutcome.failed);
    expect(clients, hasLength(1));
    expect(progress.last, 40);
    // The dropped attempt's sockets are closed so the server frees the upload.
    expect(clients.single.httpClient.closed, isTrue);
  });

  test(
    'resume waits for the network and the server lock instead of failing',
    () async {
      final progress = <double>[];
      final task = upload([
        _Attempt.dropWhileSending,
        _Attempt.networkError,
        _Attempt.locked,
        _Attempt.timeout,
        _Attempt.complete,
      ]);

      expect(
        await task.run(onProgress: progress.add),
        VideoUploadOutcome.failed,
      );
      // The teacher presses resume once.
      expect(
        await task.run(onProgress: progress.add),
        VideoUploadOutcome.completed,
      );
      expect(clients, hasLength(5));
      // Every attempt continues the first upload instead of creating a new one.
      for (final client in clients.skip(1)) {
        expect(client.receivedUploadUrl, clients.first.uploadUrl);
      }
      expect(progress.last, 100);
    },
  );

  test('resume gives up when the connection does not come back', () async {
    final outcome = await upload([
      _Attempt.networkError,
    ]).run(onProgress: (_) {});

    expect(outcome, VideoUploadOutcome.failed);
    // The first attempt plus one per retry delay.
    expect(clients, hasLength(4));
  });

  test('renews an expired Bunny signature and carries on', () async {
    var refreshes = 0;
    final outcome = await upload(
      [_Attempt.expiredSignature, _Attempt.complete],
      refresh: () async {
        refreshes++;
        return {'AuthorizationSignature': 'new'};
      },
    ).run(onProgress: (_) {});

    expect(outcome, VideoUploadOutcome.completed);
    expect(refreshes, 1);
    expect(clients.last.receivedHeaders['AuthorizationSignature'], 'new');
  });

  test('fails when an expired signature cannot be renewed', () async {
    final outcome = await upload([
      _Attempt.expiredSignature,
    ]).run(onProgress: (_) {});

    expect(outcome, VideoUploadOutcome.failed);
    expect(clients, hasLength(1));
  });

  test('cancel stops a resume that is waiting for the network', () async {
    final task = upload(
      [_Attempt.networkError],
      retryDelays: const [Duration(seconds: 30)],
    );
    final result = task.run(onProgress: (_) {});
    await Future<void>.delayed(const Duration(milliseconds: 50));
    task.cancel();

    expect(
      await result.timeout(const Duration(seconds: 2)),
      VideoUploadOutcome.cancelled,
    );
    expect(clients, hasLength(1));
  });

  test('a cancelled upload does not start again', () async {
    final task = upload([_Attempt.networkError])..cancel();

    expect(await task.run(onProgress: (_) {}), VideoUploadOutcome.cancelled);
    expect(clients, isEmpty);
  });

  testWidgets('upload percentage shows one decimal place', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProgressIndicatorWidget(
          percent: 37.46,
          textColor: Colors.black,
          fractionDigits: 1,
        ),
      ),
    );

    expect(find.text('37.5%'), findsOneWidget);
  });

  testWidgets('shows a spinner, not 0%, until the real progress is known', (tester) async {
    for (final unknown in [null, -1.0]) {
      await tester.pumpWidget(
        MaterialApp(
          home: ProgressIndicatorWidget(percent: unknown, textColor: Colors.black),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.textContaining('%'), findsNothing);
    }
  });
}
