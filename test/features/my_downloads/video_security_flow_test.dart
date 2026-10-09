import 'dart:convert';
import 'dart:io';

import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/upsert_video_usecase.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/lecture_details_model.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/models/secure_video_models.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/models/video_security_errors.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/offline_license_service.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/play_integrity_service.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/video_access_service.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/video_device_key_service.dart';
import 'package:cryptography/cryptography.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _deviceId = 'AAAA-BBBB-99CC-36EE'; // DeviceInfoService default in tests
const _videoId = 'video-1';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('student secure playback', () {
    test('requests a challenge, signs the canonical payload, sends the proof', () async {
      final adapter = _ScriptedAdapter()
        ..on('playback-challenge', 201, _challengeBody('challenge-A', 1700))
        ..on('playback-session', 201, _sessionBody());
      final keys = _FakeKeyService();
      final service = await _service(adapter, _studentPrefs(), keys);

      final session = await service.createPlaybackSession(
        videoId: _videoId,
        preferredResolution: '720p',
      );

      expect(adapter.paths, [
        '/videos/$_videoId/playback-challenge',
        '/videos/$_videoId/playback-session',
      ]);
      expect(keys.registrations, 1);
      expect(keys.signedPayloads.single, [
        'action=video_playback',
        'videoId=$_videoId',
        'deviceId=$_deviceId',
        'timestamp=1700',
        'challenge=challenge-A',
      ].join('\n'));
      final body = adapter.bodies.last;
      expect(body['challengeId'], 'challenge-A-id');
      expect(body['challengeTimestamp'], 1700);
      expect(body['deviceSignature'], 'sig-1');
      expect(body.containsKey('userId'), isFalse);
      expect(body.containsKey('studentId'), isFalse);
      expect(body.containsKey('integrityToken'), isFalse); // unavailable -> omitted
      expect(session.playbackHeaders, {
        'X-Coursaty-Playback-Session': 'edge-token',
      });
    });

    test('retries exactly once with a fresh challenge when the first is stale', () async {
      final adapter = _ScriptedAdapter()
        ..on('playback-challenge', 201, _challengeBody('c1', 1))
        ..on('playback-challenge', 201, _challengeBody('c2', 2))
        ..on('playback-session', 403, _error(VideoErrorCodes.challengeInvalid))
        ..on('playback-session', 201, _sessionBody());
      final service = await _service(adapter, _studentPrefs(), _FakeKeyService());

      await service.createPlaybackSession(
        videoId: _videoId,
        preferredResolution: '720p',
      );

      expect(
        adapter.paths.where((p) => p.endsWith('playback-session')).length,
        2,
      );
      expect(adapter.bodies.last['challengeId'], 'c2-id');
    });

    test('a missing Keystore bridge still sends the challenge, never a fake signature', () async {
      final adapter = _ScriptedAdapter()
        ..on('playback-challenge', 201, _challengeBody('c1', 1))
        ..on('playback-session', 201, _sessionBody());
      final keys = _FakeKeyService(signError: const VideoDeviceSecurityUnsupportedException());
      final service = await _service(adapter, _studentPrefs(), keys);

      await service.createPlaybackSession(
        videoId: _videoId,
        preferredResolution: '720p',
      );

      expect(adapter.bodies.last['challengeId'], 'c1-id');
      expect(adapter.bodies.last.containsKey('deviceSignature'), isFalse);
    });

    test('unsupported platforms skip the proof entirely and let the server decide', () async {
      final adapter = _ScriptedAdapter()..on('playback-session', 201, _sessionBody());
      final service = await _service(
        adapter,
        _studentPrefs(),
        _FakeKeyService(supported: false),
      );

      await service.createPlaybackSession(
        videoId: _videoId,
        preferredResolution: '720p',
      );

      expect(adapter.paths, ['/videos/$_videoId/playback-session']);
    });
  });

  group('device replacement contract', () {
    test('matches the current backend shape (code in errorCode)', () async {
      final adapter = _ScriptedAdapter()
        ..on('playback-challenge', 201, _challengeBody('c1', 1))
        ..on(
          'playback-session',
          403,
          _error(VideoErrorCodes.deviceLimitReplacementRequired),
        );
      final service = await _service(adapter, _studentPrefs(), _FakeKeyService());

      final error = await service
          .createPlaybackSession(videoId: _videoId, preferredResolution: '720p')
          .then<Object>((_) => 'no error', onError: (Object e) => e);

      expect(error, isA<DeviceReplacementRequiredException>());
      expect(
        (error as DeviceReplacementRequiredException).reason,
        DeviceReplacementReason.deviceLimit,
      );
    });

    test('matches the previously deployed backend shape (code in message)', () {
      final error = _dioError(403, {
        'errorCode': 'Forbidden',
        'message': 'VIDEO_DEVICE_LIMIT_EXCEEDED_REPLACEMENT_REQUIRED',
      });

      expect(DeviceReplacementRequiredException.matches(error), isTrue);
    });

    test('a key mismatch is a replacement with its own reason', () {
      final error = _dioError(409, _error(VideoErrorCodes.deviceKeyMismatchReplacementRequired));

      expect(
        DeviceReplacementRequiredException.fromError(error)?.reason,
        DeviceReplacementReason.keyMismatch,
      );
    });

    test('other 403s are not mistaken for replacement', () {
      final error = _dioError(403, _error(VideoErrorCodes.subscriptionRequired));

      expect(DeviceReplacementRequiredException.matches(error), isFalse);
      expect(
        videoPlaybackErrorMessage(error, isTeacher: false),
        contains('اشترك'),
      );
    });

    test('replacement is authenticated and identifies only the installation', () async {
      SharedPreferences.setMockInitialValues({});
      final calls = <String>[];
      _mockKeystoreChannel(calls);
      final adapter = _ScriptedAdapter()..on('video-key/replace', 201, {'replaced': true});
      final keys = VideoDeviceKeyService(
        Dio()..httpClientAdapter = adapter,
        _studentPrefs(),
        isSupported: true,
      );

      await keys.replaceDevice();

      expect(adapter.paths, ['/devices/video-key/replace']);
      expect(adapter.headers.last[HttpHeaders.authorizationHeader], 'Bearer student-token');
      expect(adapter.bodies.last, {
        'deviceId': _deviceId,
        'publicKey': 'spki-public-key',
        'algorithm': 'ECDSA_P256_SHA256',
      });
      expect(calls, ['ensureVideoDeviceKey', 'getVideoDevicePublicKey']);
    });

    test('registration surfaces the replacement code from the key endpoint', () async {
      SharedPreferences.setMockInitialValues({});
      _mockKeystoreChannel([]);
      final adapter = _ScriptedAdapter()
        ..on('devices/video-key', 403, _error(VideoErrorCodes.deviceLimitReplacementRequired));
      final keys = VideoDeviceKeyService(
        Dio()..httpClientAdapter = adapter,
        _studentPrefs(),
        isSupported: true,
      );

      await expectLater(
        keys.ensureAndRegister(),
        throwsA(isA<DeviceReplacementRequiredException>()),
      );
    });

    test('iOS (no native bridge) fails closed with a clear message', () async {
      final keys = VideoDeviceKeyService(
        Dio(),
        _studentPrefs(),
        isSupported: false,
      );

      await expectLater(
        keys.replaceDevice(),
        throwsA(isA<VideoDeviceSecurityUnsupportedException>()),
      );
      await keys.ensureAndRegister(); // no-op, server decides
      expect(
        videoPlaybackErrorMessage(
          const VideoDeviceSecurityUnsupportedException(),
          isTeacher: false,
        ),
        contains('غير مدعوم'),
      );
    });
  });

  group('role isolation', () {
    test('guest session never carries a stale JWT from shared Dio defaults', () async {
      final adapter = _ScriptedAdapter()..on('guest-playback-session', 201, _sessionBody());
      final dio = Dio()
        ..httpClientAdapter = adapter
        ..options.headers[HttpHeaders.authorizationHeader] = 'Bearer stale';
      SharedPreferences.setMockInitialValues({});
      final service = VideoAccessService(
        dio,
        _FakePrefs(isGuest: true, isStudent: true),
        await SharedPreferences.getInstance(),
        deviceKeyService: _FakeKeyService(),
        playIntegrityService: _UnavailableIntegrity(),
      );

      await service.createGuestPlaybackSession(videoId: _videoId);

      expect(adapter.headers.last[HttpHeaders.authorizationHeader], isNull);
    });

    test('teachers skip device registration, challenges and signatures', () async {
      final adapter = _ScriptedAdapter()..on('playback-session', 201, _sessionBody());
      final keys = _FakeKeyService();
      final service = await _service(
        adapter,
        _FakePrefs(isGuest: false, isTeacher: true, token: 'teacher-token'),
        keys,
      );

      await service.createTeacherPlaybackSession(
        videoId: _videoId,
        preferredResolution: '480p',
      );

      expect(adapter.paths, ['/videos/$_videoId/playback-session']);
      expect(keys.registrations, 0);
      expect(adapter.bodies.last, {'deviceId': _deviceId, 'preferredResolution': '480p'});
    });

    test('teachers cannot use the student download endpoint', () async {
      final adapter = _ScriptedAdapter();
      final service = await _service(
        adapter,
        _FakePrefs(isGuest: false, isTeacher: true, token: 'teacher-token'),
        _FakeKeyService(),
      );

      expect(
        () => service.createDownloadSession(videoId: _videoId, preferredResolution: '720p'),
        throwsStateError,
      );
      expect(adapter.paths, isEmpty);
    });

    test('downloads sign a proof bound to the download action', () async {
      final adapter = _ScriptedAdapter()
        ..on('playback-challenge', 201, _challengeBody('d1', 9))
        ..on('download-session', 201, _downloadBody());
      final keys = _FakeKeyService();
      final service = await _service(adapter, _studentPrefs(), keys);

      await service.createDownloadSession(videoId: _videoId, preferredResolution: '720p');

      expect(keys.signedPayloads.single, startsWith('action=video_download\n'));
      expect(adapter.bodies.last['deviceSignature'], 'sig-1');
    });
  });

  group('HLS variant selection', () {
    const master = '#EXTM3U\n'
        '#EXT-X-STREAM-INF:BANDWIDTH=800000,RESOLUTION=640x360\n360p/video.m3u8\n'
        '#EXT-X-STREAM-INF:BANDWIDTH=1400000,RESOLUTION=854x480\n480p/video.m3u8\n'
        '#EXT-X-STREAM-INF:BANDWIDTH=2800000,RESOLUTION=1280x720\n720p/video.m3u8\n';
    final base = Uri.parse('https://gw.example/guid/playlist.m3u8');

    test('picks the requested height', () {
      expect(
        selectHlsVariant(master, base, '480p').toString(),
        'https://gw.example/guid/480p/video.m3u8',
      );
    });

    test('falls back to the first variant for an unknown height', () {
      expect(
        selectHlsVariant(master, base, '1080p').toString(),
        'https://gw.example/guid/360p/video.m3u8',
      );
    });

    test('keeps a Bunny path token for absolute variant paths', () {
      final signed = Uri.parse(
        'https://vz.b-cdn.net/bcdn_token=abc&expires=1&token_path=%2Fguid%2F/guid/playlist.m3u8',
      );
      final variant = selectHlsVariant(
        '#EXTM3U\n#EXT-X-STREAM-INF:RESOLUTION=1280x720\n/guid/720p/video.m3u8\n',
        signed,
        '720p',
      );
      expect(variant!.pathSegments.first, startsWith('bcdn_token='));
    });
  });

  group('upload and metadata contract', () {
    test('metadata-only edit never sends a videoUrl (no nullplay_)', () {
      final params = UpsertVideoParams(
        lectureId: 'lecture-1',
        videoId: _videoId,
        videoName: 'Renamed',
        isFree: false,
      );

      final data = params.data();
      expect(data.containsKey('videoUrl'), isFalse);
      expect(jsonEncode(data), isNot(contains('nullplay_')));
    });

    test('new upload sends the stable play URL unmodified', () {
      const stable =
          'https://video.bunnycdn.com/play/123/11111111-1111-4111-8111-111111111111';
      final params = UpsertVideoParams(
        lectureId: 'lecture-1',
        videoName: 'New',
        isFree: true,
        videoUrl: stable,
        duration: 61,
      );

      expect(params.data()['videoUrl'], stable);
      expect(params.data()['duration'], 61);
    });

    test('lecture video duration is read from the backend "duration" field', () {
      expect(Video.fromJson({'id': 'v', 'duration': 754}).durationSeconds, 754);
      expect(
        Video.fromJson({'id': 'v', 'durationSeconds': 30}).durationSeconds,
        30,
        reason: 'locally cached lecture JSON still uses the old key',
      );
      expect(Video.fromJson({'id': 'v'}).durationSeconds, isNull);
    });

    test('lecture metadata without videoUrl still parses', () {
      final video = Video.fromJson({
        'id': 'v',
        'videoName': 'n',
        'bunnyVideoId': 'guid',
        'contentVersion': 3,
        'offlineDownloadEnabled': false,
        'isFree': true,
      });
      expect(video.videoUrl, isNull);
      expect(video.contentVersion, 3);
      expect(video.offlineDownloadEnabled, isFalse);
    });
  });

  group('offline license trusted time', () {
    late SimpleKeyPair keyPair;
    late OfflineLicense license;

    setUp(() async {
      keyPair = await Ed25519().newKeyPair();
      license = await _signedLicense(
        keyPair,
        expiresAt: DateTime.now().toUtc().add(const Duration(days: 7)),
      );
    });

    Future<OfflineLicenseService> licenseService(Map<String, Object> prefs) async {
      final publicKey = await keyPair.extractPublicKey();
      SharedPreferences.setMockInitialValues({
        'offline_public_key_k1': jsonEncode({
          'keyId': 'k1',
          'algorithm': 'Ed25519',
          'publicKey': base64Url.encode(publicKey.bytes),
        }),
        ...prefs,
      });
      final shared = await SharedPreferences.getInstance();
      return OfflineLicenseService(
        VideoAccessService(Dio(), _studentPrefs(), shared),
        _studentPrefs(),
        shared,
      );
    }

    test('accepts a valid license with trusted time', () async {
      final now = DateTime.now().toUtc().toIso8601String();
      final service = await licenseService({
        'trustedServerTime': now,
        'trustedLocalRecordedTime': now,
      });

      final result = await service.validate(
        license: license,
        videoId: _videoId,
        contentVersion: 1,
      );
      expect(result.isValid, isTrue, reason: result.message);
    });

    test('a device clock set back below the high-water mark requires going online', () async {
      final now = DateTime.now().toUtc();
      final service = await licenseService({
        'trustedServerTime': now.subtract(const Duration(days: 1)).toIso8601String(),
        'trustedLocalRecordedTime': now.subtract(const Duration(days: 1)).toIso8601String(),
        OfflineLicenseService.clockHighWaterKey:
            now.add(const Duration(days: 6)).toIso8601String(),
      });

      final result = await service.validate(
        license: license,
        videoId: _videoId,
        contentVersion: 1,
      );
      expect(result.isValid, isFalse);
      expect(result.reason, OfflineLicenseInvalidReason.trustedTimeUnavailable);
    });

    test('rejects another account and a changed content version', () async {
      final now = DateTime.now().toUtc().toIso8601String();
      final service = await licenseService({
        'trustedServerTime': now,
        'trustedLocalRecordedTime': now,
      });
      final otherUser = await _signedLicense(
        keyPair,
        userId: 'someone-else',
        expiresAt: DateTime.now().toUtc().add(const Duration(days: 1)),
      );

      expect(
        (await service.validate(license: otherUser, videoId: _videoId, contentVersion: 1)).reason,
        OfflineLicenseInvalidReason.userMismatch,
      );
      expect(
        (await service.validate(license: license, videoId: _videoId, contentVersion: 2)).reason,
        OfflineLicenseInvalidReason.contentVersionMismatch,
      );
    });
  });

  group('download error messages', () {
    test('out of space is explained', () {
      final error = FileSystemException(
        'write failed',
        '/data/x',
        const OSError('No space left on device', 28),
      );
      expect(videoDownloadErrorMessage(error), contains('مساحة'));
    });

    test('a device conflict during download is only explained', () {
      final message = videoDownloadErrorMessage(
        _dioError(403, _error(VideoErrorCodes.deviceLimitReplacementRequired)),
      );
      expect(message, contains('مرتبط بجهاز آخر'));
      expect(message, contains('تحميل'));
      // Replacement is suspended: no hint to confirm or switch devices.
      expect(message, isNot(contains('شغّل الفيديو أولاً')));
    });

    test('device replacement stays suspended in the app', () {
      expect(videoDeviceReplacementEnabled, isFalse);
    });

    test('a device conflict during playback is explained per cause', () {
      final limit = videoPlaybackErrorMessage(
        const DeviceReplacementRequiredException(),
        isTeacher: false,
      );
      final keyChanged = videoPlaybackErrorMessage(
        const DeviceReplacementRequiredException(
          DeviceReplacementReason.keyMismatch,
        ),
        isTeacher: false,
      );
      final fromServer = videoPlaybackErrorMessage(
        _dioError(
          409,
          _error(VideoErrorCodes.deviceKeyMismatchReplacementRequired),
        ),
        isTeacher: false,
      );

      expect(limit, contains('مرتبط بجهاز آخر'));
      expect(limit, contains('تشغيل'));
      expect(keyChanged, contains('مفتاح الأمان'));
      expect(fromServer, keyChanged);
      for (final message in [limit, keyChanged]) {
        expect(message, isNot(contains('أعد المحاولة لتأكيد')));
        expect(message, isNot(contains('بدلاً منه')));
      }
    });

    test('network interruption suggests resuming', () {
      expect(
        videoDownloadErrorMessage(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.connectionError,
          ),
        ),
        contains('أعد المحاولة'),
      );
    });
  });
}

// ---------------------------------------------------------------------------

Future<VideoAccessService> _service(
  _ScriptedAdapter adapter,
  PrefsRepository prefs,
  VideoDeviceKeyService keys,
) async {
  SharedPreferences.setMockInitialValues({});
  return VideoAccessService(
    Dio()..httpClientAdapter = adapter,
    prefs,
    await SharedPreferences.getInstance(),
    deviceKeyService: keys,
    playIntegrityService: _UnavailableIntegrity(),
  );
}

_FakePrefs _studentPrefs() => _FakePrefs(
  isGuest: false,
  isStudent: true,
  token: 'student-token',
  userId: 'user-1',
);

Map<String, dynamic> _challengeBody(String id, int timestamp) => {
  'challengeId': '$id-id',
  'challenge': id,
  'challengeTimestamp': timestamp,
  'expiresAt': '2030-01-01T00:00:00.000Z',
};

Map<String, dynamic> _sessionBody() => {
  'playbackSessionId': 'session-1',
  'playbackUrl': 'https://gw.example/guid/playlist.m3u8',
  'accessToken': 'edge-token',
  'accessHeader': 'X-Coursaty-Playback-Session',
  'expiresAt': '2030-01-01T00:00:00.000Z',
  'videoId': _videoId,
  'bunnyVideoId': 'guid',
};

Map<String, dynamic> _downloadBody() => {
  'downloadUrl': 'https://vz.b-cdn.net/bcdn_token=x/guid/playlist.m3u8',
  'downloadSessionId': 'dl-1',
  'videoId': _videoId,
  'bunnyVideoId': 'guid',
  'contentVersion': 1,
  'fileSize': null,
  'checksum': null,
  'offlineLicense': {
    'algorithm': 'Ed25519',
    'keyId': 'k1',
    'signedPayload': base64Url.encode(utf8.encode('{}')),
    'payload': {
      'licenseId': 'l',
      'userId': 'user-1',
      'deviceId': _deviceId,
      'courseId': 'c',
      'lectureId': 'lec',
      'videoId': _videoId,
      'contentVersion': 1,
      'issuedAt': '2030-01-01T00:00:00.000Z',
      'expiresAt': '2030-01-02T00:00:00.000Z',
    },
    'signature': 'sig',
  },
};

Map<String, dynamic> _error(String code) => {
  'errorCode': code,
  'message': 'رسالة',
  'details': {'error': code, 'code': code},
};

DioException _dioError(int status, Map<String, dynamic> data) => DioException(
  requestOptions: RequestOptions(),
  response: Response(requestOptions: RequestOptions(), statusCode: status, data: data),
);

Future<OfflineLicense> _signedLicense(
  SimpleKeyPair keyPair, {
  required DateTime expiresAt,
  String userId = 'user-1',
}) async {
  final payload = {
    'licenseId': 'license-1',
    'userId': userId,
    'deviceId': _deviceId,
    'courseId': 'course-1',
    'lectureId': 'lecture-1',
    'videoId': _videoId,
    'contentVersion': 1,
    'issuedAt': DateTime.now().toUtc().toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
  };
  final bytes = utf8.encode(jsonEncode(payload));
  final signature = await Ed25519().sign(bytes, keyPair: keyPair);
  return OfflineLicense.fromJson({
    'algorithm': 'Ed25519',
    'keyId': 'k1',
    'payload': payload,
    'signedPayload': base64Url.encode(bytes),
    'signature': base64Url.encode(signature.bytes),
  });
}

void _mockKeystoreChannel(List<String> calls) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(const MethodChannel('coursaty/video_security'), (
        call,
      ) async {
        calls.add(call.method);
        switch (call.method) {
          case 'getVideoDevicePublicKey':
            return 'spki-public-key';
          default:
            return null;
        }
      });
}

class _FakeKeyService extends VideoDeviceKeyService {
  _FakeKeyService({bool supported = true, this.signError})
    : super(Dio(), _studentPrefs(), isSupported: supported);

  final Object? signError;
  int registrations = 0;
  final signedPayloads = <String>[];

  @override
  Future<void> ensureAndRegister() async {
    if (isSupported) registrations++;
  }

  @override
  Future<String> sign(String payload) async {
    if (signError != null) throw signError!;
    signedPayloads.add(payload);
    return 'sig-${signedPayloads.length}';
  }
}

class _UnavailableIntegrity extends PlayIntegrityService {
  @override
  Future<void> prepare() async {
    throw PlatformException(code: 'missing_project_number');
  }
}

class _ScriptedAdapter implements HttpClientAdapter {
  final _scripts = <String, List<(int, Object)>>{};
  final paths = <String>[];
  final bodies = <Map<String, dynamic>>[];
  final headers = <Map<String, dynamic>>[];

  void on(String pathSuffix, int status, Object body) {
    (_scripts[pathSuffix] ??= []).add((status, body));
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    paths.add(options.uri.path);
    headers.add(Map.of(options.headers));
    final data = options.data;
    bodies.add(data is Map ? Map<String, dynamic>.from(data) : {});
    final key = _scripts.keys
        .where((suffix) => options.uri.path.endsWith(suffix))
        .fold<String?>(
          null,
          (best, suffix) =>
              best == null || suffix.length > best.length ? suffix : best,
        );
    final queue = key == null ? null : _scripts[key];
    if (queue == null || queue.isEmpty) {
      return ResponseBody.fromString('{}', 404, headers: _json);
    }
    final (status, body) = queue.length > 1 ? queue.removeAt(0) : queue.first;
    return ResponseBody.fromString(jsonEncode(body), status, headers: _json);
  }

  static final _json = {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  };

  @override
  void close({bool force = false}) {}
}

class _FakePrefs implements PrefsRepository {
  _FakePrefs({
    required this.isGuest,
    this.isStudent = false,
    this.isTeacher = false,
    this.token,
    this.userId,
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
  final String? userId;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
