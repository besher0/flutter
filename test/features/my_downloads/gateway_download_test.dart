import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/models/secure_video_models.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/models/video_security_errors.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/encrypted_hls_download_service.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/offline_license_service.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/video_access_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// Gateway-only downloads: media is fetched from the edge gateway with the
/// download session header on every request, never from Bunny directly, and
/// the token never reaches disk.
const _guid = '11111111-1111-4111-8111-111111111111';
const _gateway = 'https://gw.coursaty.test';
const _header = 'X-Coursaty-Playback-Session';

const _master =
    '#EXTM3U\n'
    '#EXT-X-STREAM-INF:BANDWIDTH=800000,RESOLUTION=640x360\n'
    '360p/video.m3u8\n'
    '#EXT-X-STREAM-INF:BANDWIDTH=2800000,RESOLUTION=1280x720\n'
    '$_gateway/$_guid/720p/video.m3u8\n';

const _media =
    '#EXTM3U\n'
    '#EXT-X-VERSION:3\n'
    '#EXT-X-TARGETDURATION:6\n'
    '#EXT-X-KEY:METHOD=AES-128,URI="key.key"\n'
    '#EXTINF:6.0,\n'
    'video0.ts\n'
    '#EXTINF:6.0,\n'
    '/$_guid/720p/video1.ts\n'
    '#EXT-X-ENDLIST\n';

final _segmentBytes = {
  '/$_guid/720p/key.key': List<int>.generate(16, (i) => i),
  '/$_guid/720p/video0.ts': List<int>.generate(4096, (i) => i % 251),
  '/$_guid/720p/video1.ts': List<int>.generate(2048, (i) => (i * 7) % 253),
};

void main() {
  late Directory root;

  setUp(() => root = Directory.systemTemp.createTempSync('gateway_download'));
  tearDown(() => root.deleteSync(recursive: true));

  _Harness harness({
    String? mediaPlaylist,
    String masterPlaylist = _master,
    List<DownloadSessionResponse>? sessions,
    bool Function(RequestOptions request, String path)? deny,
  }) {
    final gateway = _FakeGateway(
      master: masterPlaylist,
      media: mediaPlaylist ?? _media,
      deny: deny,
    );
    // The shared API client carries the app JWT; it must never reach media.
    final client = Dio(
      BaseOptions(headers: {'Authorization': 'Bearer app-jwt'}),
    )..httpClientAdapter = gateway;
    final access = _FakeAccessService(
      sessions ?? [_session('token-1'), _session('token-2')],
      gateway,
    );
    final storage = _MemorySecureStorage();
    final service = EncryptedHlsDownloadService(
      client,
      access,
      _ValidLicenses(),
      _Prefs(),
      secureStorage: storage,
      storageRoot: () async => root,
      isSecureDevice: () async => true,
    );
    return _Harness(service, gateway, access, storage);
  }

  Future<DownloadedVideoManifest> download(_Harness h) => h.service.download(
    videoId: 'video-1',
    courseId: 'course-1',
    lectureId: 'lecture-1',
    preferredResolution: '720',
    onProgress: (_) {},
  );

  test('sends the session header on every gateway request', () async {
    final h = harness();

    await download(h);

    expect(h.gateway.paths, [
      '/$_guid/playlist.m3u8',
      '/$_guid/720p/video.m3u8',
      '/$_guid/720p/key.key',
      '/$_guid/720p/video0.ts',
      '/$_guid/720p/video1.ts',
    ]);
    for (final request in h.gateway.requests) {
      expect(request.uri.host, 'gw.coursaty.test');
      expect(request.headers[_header], 'token-1');
      expect(request.headers.containsKey('Authorization'), isFalse);
      expect(request.uri.query, isEmpty); // token never in the URL
      expect(request.followRedirects, isFalse);
    }
  });

  test('resolves relative and root-relative references under the gateway', () async {
    final h = harness();

    await download(h);

    expect(
      h.gateway.requests.map((r) => r.uri.toString()).skip(2),
      everyElement(startsWith('$_gateway/$_guid/720p/')),
    );
  });

  test('stores segments encrypted and keeps the token off disk', () async {
    final h = harness();

    final manifest = await download(h);

    expect(manifest.status, SecureVideoDownloadStatus.completed);
    for (final segment in manifest.segments) {
      final original = _segmentBytes.values.elementAt(segment.index);
      final onDisk = File(
        '${root.path}/secure_videos/video-1/${segment.localName}',
      ).readAsBytesSync();
      expect(onDisk, isNot(orderedEquals(original)));
      expect(
        await h.service.decryptSegment(manifest, segment),
        orderedEquals(original),
      );
    }

    final persisted = File(
      '${root.path}/secure_videos/video-1/manifest.json',
    ).readAsStringSync();
    expect(persisted, isNot(contains('token-1')));
    expect(persisted, isNot(contains(_header)));
    expect(h.storage.values.values, isNot(contains('token-1')));
    final everything = root
        .listSync(recursive: true)
        .whereType<File>()
        .map((f) => latin1.decode(f.readAsBytesSync()))
        .join();
    expect(everything, isNot(contains('token-1')));
  });

  test('refuses a playlist entry on another host and never sends it the header', () async {
    final h = harness(
      mediaPlaylist:
          '#EXTM3U\n#EXTINF:6.0,\nhttps://cdn.elsewhere.test/$_guid/720p/video0.ts\n',
    );

    final error = await download(h).then<Object?>((_) => null, onError: (e) => e);

    expect(error, isA<SecureDownloadException>());
    expect(
      (error as SecureDownloadException).failure,
      SecureDownloadFailure.untrustedMediaHost,
    );
    expect(
      h.gateway.requests.where((r) => r.uri.host != 'gw.coursaty.test'),
      isEmpty,
    );
  });

  test('never falls back to a direct link when the backend issues no gateway token', () async {
    final h = harness(
      sessions: [
        _session(
          null,
          downloadUrl: 'https://media.example.test/$_guid/playlist.m3u8',
        ),
      ],
    );

    final error = await download(h).then<Object?>((_) => null, onError: (e) => e);

    expect(
      (error as SecureDownloadException).failure,
      SecureDownloadFailure.gatewaySessionMissing,
    );
    expect(h.gateway.requests, isEmpty);
  });

  test('renews an expired session and continues with the new header', () async {
    // token-1 stops working after the first segment, like a TTL expiring.
    final h = harness(
      deny: (request, path) =>
          request.headers[_header] == 'token-1' &&
          path == '/$_guid/720p/video0.ts',
    );

    final manifest = await download(h);

    expect(manifest.status, SecureVideoDownloadStatus.completed);
    expect(h.access.created, 2);
    final afterRenewal = h.gateway.requests.skipWhile(
      (r) => r.headers[_header] == 'token-1',
    );
    expect(afterRenewal, isNotEmpty);
    expect(afterRenewal.map((r) => r.headers[_header]), everyElement('token-2'));
  });

  test('stops with a session error when a fresh session is denied too', () async {
    final h = harness(deny: (_, path) => path.endsWith('.ts'));

    final error = await download(h).then<Object?>((_) => null, onError: (e) => e);

    expect(
      (error as SecureDownloadException).failure,
      SecureDownloadFailure.gatewayAccessDenied,
    );
    expect(h.access.created, 2);
  });

  test('rejects a response that is not an HLS playlist', () async {
    final h = harness(masterPlaylist: '<html>Forbidden</html>');

    final error = await download(h).then<Object?>((_) => null, onError: (e) => e);

    expect(
      (error as SecureDownloadException).failure,
      SecureDownloadFailure.invalidPlaylist,
    );
  });

  test('does not download on an insecure device', () async {
    final h = harness();
    final service = EncryptedHlsDownloadService(
      Dio()..httpClientAdapter = h.gateway,
      h.access,
      _ValidLicenses(),
      _Prefs(),
      secureStorage: h.storage,
      storageRoot: () async => root,
      isSecureDevice: () async => false,
    );

    final error = await service
        .download(
          videoId: 'video-1',
          courseId: 'course-1',
          lectureId: 'lecture-1',
          preferredResolution: '720',
          onProgress: (_) {},
        )
        .then<Object?>((_) => null, onError: (e) => e);

    expect(
      (error as SecureDownloadException).failure,
      SecureDownloadFailure.insecureDevice,
    );
    expect(h.access.created, 0);
  });

  group('DownloadSessionResponse', () {
    test('reads the gateway session fields', () {
      final session = DownloadSessionResponse.fromJson({
        ..._sessionJson('abc'),
        'accessHeader': 'X-Custom-Session',
        'expiresAt': '2026-10-09T12:00:00.000Z',
      });

      expect(session.accessToken, 'abc');
      expect(session.downloadHeaders, {'X-Custom-Session': 'abc'});
      expect(session.expiresAt, DateTime.utc(2026, 10, 9, 12));
    });

    test('defaults the header name and has no headers without a token', () {
      final session = DownloadSessionResponse.fromJson(_sessionJson(null));

      expect(session.accessHeader, _header);
      expect(session.downloadHeaders, isEmpty);
    });
  });

  test('download code never references Bunny CDN hosts', () {
    for (final path in [
      'lib/features/my_downloads/data/services/encrypted_hls_download_service.dart',
      'lib/features/my_downloads/data/models/secure_video_models.dart',
    ]) {
      expect(
        File(path).readAsStringSync(),
        isNot(matches(RegExp(r'b-cdn\.net|bunnycdn\.com'))),
        reason: path,
      );
    }
  });

  group('download error messages', () {
    test('distinguish gateway, playlist, license and device failures', () {
      final messages = SecureDownloadFailure.values
          .map((f) => videoDownloadErrorMessage(SecureDownloadException(f)))
          .toSet();
      expect(messages.length, greaterThanOrEqualTo(5));
      expect(messages, isNot(contains('حدثت مشكلة أثناء التحميل')));
    });

    test('distinguish a timeout from a lost connection', () {
      final timeout = videoDownloadErrorMessage(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.receiveTimeout,
        ),
      );
      final offline = videoDownloadErrorMessage(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.connectionError,
        ),
      );
      expect(timeout, contains('مهلة'));
      expect(offline, contains('انقطع'));
    });
  });
}

class _Harness {
  _Harness(this.service, this.gateway, this.access, this.storage);

  final EncryptedHlsDownloadService service;
  final _FakeGateway gateway;
  final _FakeAccessService access;
  final _MemorySecureStorage storage;
}

Map<String, dynamic> _sessionJson(String? token, {String? downloadUrl}) => {
  'downloadUrl': downloadUrl ?? '$_gateway/$_guid/playlist.m3u8',
  'downloadSessionId': 'session-${token ?? 'none'}',
  'accessToken': ?token,
  'videoId': 'video-1',
  'bunnyVideoId': _guid,
  'contentVersion': 1,
  'fileSize': null,
  'checksum': null,
  'offlineLicense': {
    'algorithm': 'Ed25519',
    'keyId': 'k1',
    'payload': _licensePayload,
    // Signature checks are faked here (_ValidLicenses).
    'signedPayload': base64Url.encode(utf8.encode(jsonEncode(_licensePayload))),
    'signature': 'c2ln',
  },
};

const _licensePayload = {
  'licenseId': 'license-1',
  'userId': 'user-1',
  'deviceId': 'device-1',
  'courseId': 'course-1',
  'lectureId': 'lecture-1',
  'videoId': 'video-1',
  'contentVersion': 1,
  'issuedAt': '2026-10-09T00:00:00.000Z',
  'expiresAt': '2026-10-16T00:00:00.000Z',
};

DownloadSessionResponse _session(String? token, {String? downloadUrl}) =>
    DownloadSessionResponse.fromJson(
      _sessionJson(token, downloadUrl: downloadUrl),
    );

/// Edge gateway stand-in: serves media only to the currently valid tokens.
class _FakeGateway implements HttpClientAdapter {
  _FakeGateway({required this.master, required this.media, this.deny});

  final String master;
  final String media;
  final bool Function(RequestOptions request, String path)? deny;
  final validTokens = <String>{};
  final requests = <RequestOptions>[];

  List<String> get paths => requests.map((r) => r.uri.path).toList();

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final path = options.uri.path;
    final token = options.headers[_header];
    if (options.uri.host != 'gw.coursaty.test' ||
        !validTokens.contains(token) ||
        (deny?.call(options, path) ?? false)) {
      return ResponseBody.fromString('Forbidden', 403);
    }
    if (path == '/$_guid/playlist.m3u8') {
      return ResponseBody.fromString(master, 200);
    }
    if (path == '/$_guid/720p/video.m3u8') {
      return ResponseBody.fromString(media, 200);
    }
    final bytes = _segmentBytes[path];
    if (bytes == null) return ResponseBody.fromString('Not found', 404);
    return ResponseBody.fromBytes(Uint8List.fromList(bytes), 200);
  }

  @override
  void close({bool force = false}) {}
}

class _FakeAccessService implements VideoAccessService {
  _FakeAccessService(this.sessions, this.gateway);

  final List<DownloadSessionResponse> sessions;
  final _FakeGateway gateway;
  int created = 0;

  @override
  Future<DownloadSessionResponse> createDownloadSession({
    required String videoId,
    required String preferredResolution,
  }) async {
    final session = sessions[created.clamp(0, sessions.length - 1)];
    created++;
    final token = session.accessToken;
    if (token != null) gateway.validTokens.add(token);
    return session;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ValidLicenses implements OfflineLicenseService {
  @override
  Future<OfflineLicenseValidationResult> validate({
    required OfflineLicense license,
    required String videoId,
    required int contentVersion,
  }) async => const OfflineLicenseValidationResult.valid();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Prefs implements PrefsRepository {
  @override
  String? get userId => 'user-1';

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MemorySecureStorage implements FlutterSecureStorage {
  final values = <String, String>{};

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final key = invocation.namedArguments[#key] as String?;
    switch (invocation.memberName) {
      case #read:
        return Future<String?>.value(values[key]);
      case #write:
        final value = invocation.namedArguments[#value] as String?;
        if (value == null) {
          values.remove(key);
        } else {
          values[key!] = value;
        }
        return Future<void>.value();
      case #delete:
        values.remove(key);
        return Future<void>.value();
    }
    return super.noSuchMethod(invocation);
  }
}
