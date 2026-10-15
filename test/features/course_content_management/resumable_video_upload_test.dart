import 'dart:io';

import 'package:coursaty_student_and_teacher/features/course_content_management/data/services/resumable_video_upload.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/presentation/widgets/percent_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:tusc/tusc.dart' hide Headers;

/// One scripted attempt: what the TUS client does when started.
enum _Attempt { networkError, timeout, expiredSignature, complete }

class _FakeTusClient implements TusBaseClient {
  _FakeTusClient(this.behaviour, this.receivedUploadUrl, this.receivedHeaders);

  final _Attempt behaviour;
  final String? receivedUploadUrl;
  final Map<String, String> receivedHeaders;
  TusUploadState _state = TusUploadState.notStarted;

  @override
  String get uploadUrl => receivedUploadUrl ?? 'https://video.bunnycdn.com/tusupload/abc';

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
      case _Attempt.networkError:
        onProgress?.call(400, 1000, null);
        _state = TusUploadState.error;
        throw const SocketException('Network is unreachable');
      case _Attempt.timeout:
        _state = TusUploadState.error;
        onError?.call(ProtocolException('timeout', http.Response('', 408)));
      case _Attempt.expiredSignature:
        _state = TusUploadState.error;
        onError?.call(ProtocolException('expired', http.Response('', 401)));
      case _Attempt.complete:
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
    int maxAttempts = 10,
    Duration delay = Duration.zero,
  }) {
    clients = [];
    return ResumableVideoUpload(
      headers: const {'AuthorizationSignature': 'old'},
      refreshHeaders: refresh ?? () async => null,
      maxAttempts: maxAttempts,
      retryDelay: (_) => delay,
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

  test('continues the same upload after the connection drops', () async {
    final progress = <double>[];
    final statuses = <String?>[];

    final outcome = await upload([
      _Attempt.networkError,
      _Attempt.timeout,
      _Attempt.complete,
    ]).run(onProgress: progress.add, onStatus: statuses.add);

    expect(outcome, VideoUploadOutcome.completed);
    expect(clients, hasLength(3));
    // Each retry resumes the first upload's URL instead of creating a new one.
    expect(clients[1].receivedUploadUrl, clients[0].uploadUrl);
    expect(clients[2].receivedUploadUrl, clients[0].uploadUrl);
    expect(progress.last, 100);
    expect(statuses, contains(isA<String>())); // "waiting for the connection"
    expect(statuses.last, isNull);
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

  test('gives up after the last attempt', () async {
    final outcome = await upload(
      [_Attempt.networkError],
      maxAttempts: 3,
    ).run(onProgress: (_) {});

    expect(outcome, VideoUploadOutcome.failed);
    expect(clients, hasLength(3));
  });

  test('cancel stops while waiting for the connection', () async {
    final task = upload(
      [_Attempt.networkError],
      delay: const Duration(seconds: 30),
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
