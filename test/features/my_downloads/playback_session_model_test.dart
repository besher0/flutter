import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/models/secure_video_models.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/video_access_service.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/video_device_key_service.dart';
import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:coursaty_student_and_teacher/core/storage/prefs_repository_impl.dart';
import 'package:coursaty_student_and_teacher/core/common/constant/configuration/prefs_key.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('guest playback response uses the backend access header', () {
    final session = PlaybackSessionResponse.fromJson({
      'playbackSessionId': 'session-1',
      'playbackUrl': 'https://edge.example/video/master.m3u8',
      'accessToken': 'edge-token',
      'accessHeader': 'X-Coursaty-Playback-Session',
      'expiresAt': '2026-10-08T10:00:00Z',
      'videoId': 'video-1',
      'bunnyVideoId': 'bunny-1',
    });

    expect(session.playbackHeaders, {
      'X-Coursaty-Playback-Session': 'edge-token',
    });
  });

  test('playback response without a token sends no Bunny header', () {
    final session = PlaybackSessionResponse.fromJson({
      'playbackSessionId': 'session-1',
      'playbackUrl': 'https://edge.example/video/master.m3u8',
      'expiresAt': '2026-10-08T10:00:00Z',
      'videoId': 'video-1',
      'bunnyVideoId': 'bunny-1',
    });

    expect(session.playbackHeaders, isEmpty);
  });

  test(
    'guest session is public and guest download is rejected before HTTP',
    () async {
      SharedPreferences.setMockInitialValues({});
      final adapter = _RecordingAdapter();
      final client = Dio()..httpClientAdapter = adapter;
      final service = VideoAccessService(
        client,
        _FakePrefs(isGuest: true),
        await SharedPreferences.getInstance(),
      );

      final session = await service.createGuestPlaybackSession(
        videoId: 'video-1',
      );

      expect(
        adapter.request?.path,
        endsWith('/videos/video-1/guest-playback-session'),
      );
      // Guest calls override Authorization with null so a stale default on the
      // shared Dio cannot leak; Dio's IO adapter does not send null headers.
      expect(adapter.request?.headers['Authorization'], isNull);
      expect(session.playbackHeaders, {
        'X-Coursaty-Playback-Session': 'edge-token',
      });
      expect(
        () => service.createDownloadSession(
          videoId: 'video-1',
          preferredResolution: '720p',
        ),
        throwsStateError,
      );
      expect(adapter.requestCount, 1);
    },
  );

  test(
    'student playback registers through the secure playback endpoint',
    () async {
      SharedPreferences.setMockInitialValues({});
      final adapter = _RecordingAdapter();
      final service = VideoAccessService(
        Dio()..httpClientAdapter = adapter,
        _FakePrefs(isGuest: false, isStudent: true, token: 'student-token'),
        await SharedPreferences.getInstance(),
      );

      await service.createPlaybackSession(
        videoId: 'video-1',
        preferredResolution: '720p',
      );

      expect(
        adapter.request?.path,
        endsWith('/videos/video-1/playback-session'),
      );
      expect(
        adapter.request?.data,
        containsPair('preferredResolution', '720p'),
      );
    },
  );

  test(
    'teacher playback sends a stable device id without device registration',
    () async {
      SharedPreferences.setMockInitialValues({});
      final adapter = _RecordingAdapter();
      final service = VideoAccessService(
        Dio()..httpClientAdapter = adapter,
        _FakePrefs(isGuest: false, isTeacher: true, token: 'teacher-token'),
        await SharedPreferences.getInstance(),
      );

      await service.createTeacherPlaybackSession(
        videoId: 'video-1',
        preferredResolution: '720p',
      );

      expect(
        adapter.request?.path,
        endsWith('/videos/video-1/playback-session'),
      );
      expect(
        adapter.request?.data,
        containsPair('deviceId', 'AAAA-BBBB-99CC-36EE'),
      );
      expect(adapter.request?.path, isNot(contains('playback-challenge')));
    },
  );

  test('teacher refresh sends the same stable device id', () async {
    SharedPreferences.setMockInitialValues({});
    final adapter = _RecordingAdapter();
    final service = VideoAccessService(
      Dio()..httpClientAdapter = adapter,
      _FakePrefs(isGuest: false, isTeacher: true, token: 'teacher-token'),
      await SharedPreferences.getInstance(),
    );

    await service.refreshPlaybackSession(
      videoId: 'video-1',
      playbackSessionId: 'session-1',
      preferredResolution: '720p',
    );

    expect(
      adapter.request?.path,
      endsWith('/videos/video-1/playback-session/session-1/refresh'),
    );
    expect(
      adapter.request?.data,
      containsPair('deviceId', 'AAAA-BBBB-99CC-36EE'),
    );
  });

  test('replacement error is represented by a typed replacement state', () {
    final error = DioException(
      requestOptions: RequestOptions(),
      response: Response(
        requestOptions: RequestOptions(),
        statusCode: 409,
        data: {'errorCode': 'VIDEO_DEVICE_LIMIT_EXCEEDED_REPLACEMENT_REQUIRED'},
      ),
    );

    expect(DeviceReplacementRequiredException.matches(error), isTrue);
    expect(const DeviceReplacementRequiredException(), isA<Exception>());
  });

  test('logout preserves the installation device id', () async {
    const key = 'coursaty_installation_device_id_v2';
    SharedPreferences.setMockInitialValues({
      key: 'installation-1',
      'auth-token': 'token',
    });
    final prefs = PrefsRepositoryImpl(await SharedPreferences.getInstance());

    await prefs.clearUser();

    expect(
      (await SharedPreferences.getInstance()).getString(key),
      'installation-1',
    );
  });

  test('guest remains in the student-facing app role', () async {
    SharedPreferences.setMockInitialValues({PrefsKey.isGuest: true});
    final prefs = PrefsRepositoryImpl(await SharedPreferences.getInstance());

    expect(prefs.isGuest, isTrue);
    expect(prefs.isStudent, isTrue);
    expect(prefs.isTeacher, isFalse);
  });
}

class _RecordingAdapter implements HttpClientAdapter {
  RequestOptions? request;
  var requestCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    requestCount++;
    return ResponseBody.fromString(
      jsonEncode({
        'playbackSessionId': 'session-1',
        'playbackUrl': 'https://edge.example/video/master.m3u8',
        'accessToken': 'edge-token',
        'accessHeader': 'X-Coursaty-Playback-Session',
        'expiresAt': '2026-10-08T10:00:00Z',
        'videoId': 'video-1',
        'bunnyVideoId': 'bunny-1',
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _FakePrefs implements PrefsRepository {
  _FakePrefs({
    required this.isGuest,
    this.isStudent = false,
    this.isTeacher = false,
    this.token,
  });

  @override
  final bool isGuest;

  @override
  final bool isStudent;

  @override
  final bool isTeacher;

  @override
  final String? token;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
