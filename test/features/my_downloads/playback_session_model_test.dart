import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/models/secure_video_models.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/video_access_service.dart';
import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
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
      expect(adapter.request?.headers.containsKey('Authorization'), isFalse);
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
  _FakePrefs({required this.isGuest});

  @override
  final bool isGuest;

  @override
  String? get token => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
d