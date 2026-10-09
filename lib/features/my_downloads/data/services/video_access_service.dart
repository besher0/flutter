import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:coursaty_student_and_teacher/core/common/constant/configuration/url_routes.dart';
import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/models/secure_video_models.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/models/video_security_errors.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/play_integrity_service.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/video_device_key_service.dart';
import 'package:coursaty_student_and_teacher/services/device_info_service.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/api/detect_server.dart';

/// Which backend action a device proof is bound to. Must match the backend's
/// `DeviceProofAction` strings.
enum VideoProofAction {
  playback('video_playback'),
  download('video_download');

  const VideoProofAction(this.wireName);

  final String wireName;
}

/// Canonical bytes signed by the device key and hashed for Play Integrity.
///
/// Must stay byte-identical to `buildDeviceProofPayload` in the backend
/// `videos.service.ts` (UTF-8, `\n` separated, no trailing newline).
@visibleForTesting
String videoDeviceProofPayload({
  required VideoProofAction action,
  required String videoId,
  required String deviceId,
  required int timestamp,
  required String challenge,
}) {
  return [
    'action=${action.wireName}',
    'videoId=$videoId',
    'deviceId=$deviceId',
    'timestamp=$timestamp',
    'challenge=$challenge',
  ].join('\n');
}

@lazySingleton
class VideoAccessService {
  VideoAccessService(
    this._client,
    this._prefs,
    this._sharedPreferences, {
    @ignoreParam VideoDeviceKeyService? deviceKeyService,
    @ignoreParam PlayIntegrityService? playIntegrityService,
  }) : _videoDeviceKeyService =
           deviceKeyService ?? VideoDeviceKeyService(_client, _prefs),
       _playIntegrityService = playIntegrityService ?? PlayIntegrityService();

  final Dio _client;
  final PrefsRepository _prefs;
  final SharedPreferences _sharedPreferences;
  final PlayIntegrityService _playIntegrityService;
  final VideoDeviceKeyService _videoDeviceKeyService;

  /// Server time minus device time, learned from the last response `Date`.
  Duration _serverClockOffset = Duration.zero;

  /// Best estimate of the backend clock, for scheduling session renewal
  /// against server-issued `expiresAt` values on devices with a wrong clock.
  DateTime get serverNow => DateTime.now().toUtc().add(_serverClockOffset);

  /// Student playback: register key -> challenge -> sign -> session.
  /// Teachers go straight to the session endpoint with their stable device id.
  Future<PlaybackSessionResponse> createPlaybackSession({
    required String videoId,
    required String preferredResolution,
  }) async {
    final isTeacher = _prefs.isTeacher;
    if (!isTeacher) {
      _ensureAuthenticatedStudent();
      await _ensureRegistered(stage: 'playback-session');
    }

    Future<PlaybackSessionResponse> attempt() async {
      final body = <String, dynamic>{
        'deviceId': DeviceInfoService.getSecureVideoDeviceId(),
        'preferredResolution': preferredResolution,
      };
      if (!isTeacher) {
        body.addAll(
          await _buildDeviceProof(
            videoId: videoId,
            action: VideoProofAction.playback,
          ),
        );
      }
      final response = await _client.postUri(
        _uri(EndPoints.createPlaybackSession(videoId: videoId)),
        data: body,
        options: _options(),
      );
      _recordTrustedTime(response);
      return PlaybackSessionResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    }

    try {
      final session = await _retryOnStaleChallenge(attempt);
      _log('playback session success videoId=$videoId');
      return session;
    } catch (error, stackTrace) {
      _log(
        'playback session failure videoId=$videoId errorType=${error.runtimeType}',
        error: error,
        stackTrace: stackTrace,
      );
      throw DeviceReplacementRequiredException.fromError(error) ?? error;
    }
  }

  /// Public free-video playback. Never sends a JWT, even if one is stored.
  Future<PlaybackSessionResponse> createGuestPlaybackSession({
    required String videoId,
  }) async {
    _log('guest playback session started videoId=$videoId');
    try {
      final response = await _client.postUri(
        _uri(EndPoints.createGuestPlaybackSession(videoId: videoId)),
        options: _guestOptions(),
      );
      _recordTrustedTime(response);
      _log('guest playback session succeeded videoId=$videoId');
      return PlaybackSessionResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } catch (error, stackTrace) {
      final status = error is DioException ? error.response?.statusCode : null;
      _log(
        'guest playback session failed videoId=$videoId status=$status '
        'errorType=${error.runtimeType}',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<PlaybackSessionResponse> createTeacherPlaybackSession({
    required String videoId,
    required String preferredResolution,
  }) {
    if (!_prefs.isTeacher) {
      throw StateError('Only teachers can create a teacher playback session');
    }
    return createPlaybackSession(
      videoId: videoId,
      preferredResolution: preferredResolution,
    );
  }

  Future<void> replaceVideoDevice() => _videoDeviceKeyService.replaceDevice();

  /// Extends an existing gateway session. Renewal never registers or replaces
  /// a device; if the session is no longer valid the caller starts a new one.
  Future<PlaybackSessionResponse> refreshPlaybackSession({
    required String videoId,
    required String playbackSessionId,
    required String preferredResolution,
  }) async {
    try {
      final response = await _client.postUri(
        _uri(
          EndPoints.refreshPlaybackSession(
            videoId: videoId,
            sessionId: playbackSessionId,
          ),
        ),
        data: {
          'deviceId': DeviceInfoService.getSecureVideoDeviceId(),
          'preferredResolution': preferredResolution,
        },
        options: _options(),
      );
      _recordTrustedTime(response);
      _log('playback session refresh success videoId=$videoId');
      return PlaybackSessionResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } catch (error, stackTrace) {
      _log(
        'playback session refresh failure videoId=$videoId '
        'errorType=${error.runtimeType}',
        error: error,
        stackTrace: stackTrace,
      );
      throw DeviceReplacementRequiredException.fromError(error) ?? error;
    }
  }

  /// Picks the HLS variant closest to [preferredResolution].
  ///
  /// [headers] must be the session's playback headers for gateway sessions so
  /// the master playlist request is authorized like every other media request.
  /// Falls back to the master playlist (adaptive) if the read fails.
  Future<String> resolvePlayableHlsUrl({
    required String playbackUrl,
    required String preferredResolution,
    Map<String, String> headers = const {},
  }) async {
    final masterUri = Uri.parse(playbackUrl);
    try {
      final masterText = await _readHlsText(masterUri, headers);
      final variant = selectHlsVariant(
        masterText,
        masterUri,
        preferredResolution,
      );
      return (variant ?? masterUri).toString();
    } catch (error) {
      _log('variant selection skipped errorType=${error.runtimeType}');
      return masterUri.toString();
    }
  }

  Future<DownloadSessionResponse> createDownloadSession({
    required String videoId,
    required String preferredResolution,
  }) async {
    _ensureAuthenticatedForDownload();
    await _ensureRegistered(stage: 'download-session');

    Future<DownloadSessionResponse> attempt() async {
      final body = <String, dynamic>{
        'deviceId': DeviceInfoService.getSecureVideoDeviceId(),
        'preferredResolution': preferredResolution,
        ...await _buildDeviceProof(
          videoId: videoId,
          action: VideoProofAction.download,
        ),
      };
      final response = await _client.postUri(
        _uri(EndPoints.createDownloadSession(videoId: videoId)),
        data: body,
        options: _options(),
      );
      _recordTrustedTime(response);
      return DownloadSessionResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    }

    try {
      final session = await _retryOnStaleChallenge(attempt);
      _log('download session success videoId=$videoId');
      return session;
    } catch (error, stackTrace) {
      _log(
        'download session failure videoId=$videoId errorType=${error.runtimeType}',
        error: error,
        stackTrace: stackTrace,
      );
      throw DeviceReplacementRequiredException.fromError(error) ?? error;
    }
  }

  Future<OfflineLicense> renewOfflineLicense({
    required String videoId,
    required String preferredResolution,
  }) async {
    _ensureAuthenticatedForDownload();
    await _ensureRegistered(stage: 'offline-license-renew');
    try {
      final response = await _client.postUri(
        _uri(EndPoints.renewOfflineLicense(videoId: videoId)),
        data: {
          'deviceId': DeviceInfoService.getSecureVideoDeviceId(),
          'preferredResolution': preferredResolution,
        },
        options: _options(),
      );
      _recordTrustedTime(response);
      final data = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{};
      _log('offline license success videoId=$videoId');
      return OfflineLicense.fromJson(
        Map<String, dynamic>.from((data['offlineLicense'] ?? data) as Map),
      );
    } catch (error, stackTrace) {
      _log(
        'offline license failure videoId=$videoId errorType=${error.runtimeType}',
        error: error,
        stackTrace: stackTrace,
      );
      throw DeviceReplacementRequiredException.fromError(error) ?? error;
    }
  }

  Future<List<OfflinePublicKey>> getOfflineLicensePublicKeys() async {
    final response = await _client.getUri(
      _uri(EndPoints.getOfflineLicensePublicKey()),
      options: _options(),
    );
    _recordTrustedTime(response);
    final data = response.data;
    if (data is List) {
      return data
          .map(
            (item) => OfflinePublicKey.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }
    if (data is Map<String, dynamic> && data['keys'] is List) {
      return (data['keys'] as List)
          .map(
            (item) => OfflinePublicKey.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }
    return [OfflinePublicKey.fromJson(data as Map<String, dynamic>)];
  }

  /// A challenge can expire or be consumed between issue and use (slow
  /// network, double submit). Retry once with a fresh one; any other error
  /// surfaces unchanged.
  Future<T> _retryOnStaleChallenge<T>(Future<T> Function() attempt) async {
    try {
      return await attempt();
    } catch (error) {
      if (videoErrorCodeOf(error) != VideoErrorCodes.challengeInvalid) rethrow;
      _log('stale playback challenge, retrying once');
      return attempt();
    }
  }

  /// Builds `challengeId`, `challengeTimestamp`, `deviceSignature` and (when
  /// available) `integrityToken`. Every step is best effort: the backend is the
  /// authority and rejects missing proof only when enforcement is enabled.
  Future<Map<String, dynamic>> _buildDeviceProof({
    required String videoId,
    required VideoProofAction action,
  }) async {
    if (!_videoDeviceKeyService.isSupported) return const {};

    final deviceId = DeviceInfoService.getSecureVideoDeviceId();
    final Map<String, dynamic> data;
    try {
      final challengeResponse = await _client.postUri(
        _uri(EndPoints.createPlaybackChallenge(videoId: videoId)),
        data: {'deviceId': deviceId},
        options: _options(),
      );
      data = Map<String, dynamic>.from(challengeResponse.data as Map);
    } catch (error, stackTrace) {
      _log(
        'playback challenge unavailable videoId=$videoId '
        'errorType=${error.runtimeType}',
        error: error,
        stackTrace: stackTrace,
      );
      return const {};
    }

    final challengeId = data['challengeId'] as String;
    final challenge = data['challenge'] as String;
    final challengeTimestamp = (data['challengeTimestamp'] as num).toInt();
    final payload = videoDeviceProofPayload(
      action: action,
      videoId: videoId,
      deviceId: deviceId,
      timestamp: challengeTimestamp,
      challenge: challenge,
    );
    final proof = <String, dynamic>{
      'challengeId': challengeId,
      'challengeTimestamp': challengeTimestamp,
    };

    try {
      proof['deviceSignature'] = await _videoDeviceKeyService.sign(payload);
    } catch (error, stackTrace) {
      _log(
        'device signature unavailable videoId=$videoId '
        'errorType=${error.runtimeType}',
        error: error,
        stackTrace: stackTrace,
      );
    }

    if (action == VideoProofAction.playback) {
      try {
        await _playIntegrityService.prepare();
        proof['integrityToken'] = await _playIntegrityService.requestToken(
          requestHash: videoPlaybackRequestHash(payload),
        );
        _log('integrity available videoId=$videoId');
      } catch (error) {
        _log(
          'integrity unavailable videoId=$videoId '
          'errorType=${error.runtimeType}',
        );
        if (kDebugMode) debugPrint('Play Integrity audit flow skipped: $error');
      }
    }
    return proof;
  }

  Uri _uri(String endpoint) {
    final baseUri = getBaseUriForSpecificServer(ServerName.master);
    return Uri(
      host: baseUri.host,
      scheme: baseUri.scheme,
      path: endpoint,
      port: MasterUrlRoutes.port,
    );
  }

  Future<void> _ensureRegistered({required String stage}) async {
    try {
      await _videoDeviceKeyService.ensureAndRegister();
    } catch (error, stackTrace) {
      _log(
        'device registration failed stage=$stage '
        'deviceIdPrefix=${_safeDeviceIdPrefix()} errorType=${error.runtimeType}',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  String _safeDeviceIdPrefix() {
    final deviceId = DeviceInfoService.getSecureVideoDeviceId();
    if (deviceId.length <= 10) return deviceId;
    return deviceId.substring(0, 10);
  }

  void _log(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      '[VideoSecurity] $message',
      name: 'VideoAccessService',
      error: error,
      stackTrace: stackTrace,
    );
  }

  Options _options() {
    final headers = <String, dynamic>{
      HttpHeaders.acceptHeader: 'application/json',
      HttpHeaders.contentTypeHeader: 'application/json',
      'User-Agent':
          'device OS:${Platform.isAndroid ? 'Android' : 'IOS'} , application version: 1.0.0',
    };
    final token = _prefs.token;
    if (token != null) {
      headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
    return Options(headers: headers, responseType: ResponseType.json);
  }

  Options _guestOptions() {
    return Options(
      headers: {
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
        // The shared Dio may still carry a stale default Authorization header
        // (BaseApi mutates the singleton's base headers); guest calls must not.
        HttpHeaders.authorizationHeader: null,
        'User-Agent':
            'device OS:${Platform.isAndroid ? 'Android' : 'IOS'} , application version: 1.0.0',
      },
      responseType: ResponseType.json,
    );
  }

  void _ensureAuthenticatedStudent() {
    if (_prefs.isGuest || _prefs.token == null) {
      throw StateError('Guest users must use the guest playback session');
    }
  }

  void _ensureAuthenticatedForDownload() {
    if (_prefs.isGuest || _prefs.token == null) {
      _log('guest download rejected');
      throw StateError('Guest users cannot download videos');
    }
    if (_prefs.isTeacher) {
      _log('teacher download rejected');
      throw StateError('Offline downloads are only available to students');
    }
  }

  void _recordTrustedTime(Response response) {
    final dateHeader = response.headers.value(HttpHeaders.dateHeader);
    DateTime serverTime;
    try {
      serverTime = dateHeader == null
          ? DateTime.now().toUtc()
          : HttpDate.parse(dateHeader).toUtc();
    } catch (_) {
      serverTime = DateTime.now().toUtc();
    }
    if (dateHeader != null) {
      _serverClockOffset = serverTime.difference(DateTime.now().toUtc());
    }
    _sharedPreferences.setString(
      'trustedServerTime',
      serverTime.toIso8601String(),
    );
    final localNow = DateTime.now().toUtc().toIso8601String();
    _sharedPreferences.setString('trustedLocalRecordedTime', localNow);
    // A fresh server timestamp re-anchors offline time, so a legitimately
    // corrected (earlier) device clock does not keep failing offline checks.
    _sharedPreferences.setString('offlineClockHighWater', localNow);
  }

  Future<String> _readHlsText(Uri uri, Map<String, String> headers) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
    try {
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, '*/*');
      headers.forEach(request.headers.set);
      final response = await request.close().timeout(
        const Duration(seconds: 20),
      );
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'HLS playlist request failed with ${response.statusCode}',
          uri: uri,
        );
      }
      return body;
    } finally {
      client.close(force: true);
    }
  }
}

/// base64url (no padding) SHA-256 of the canonical proof, used as the Play
/// Integrity request hash. Matches the backend `buildPlaybackRequestHash`.
@visibleForTesting
String videoPlaybackRequestHash(String canonicalPayload) {
  return base64Url
      .encode(sha256.convert(utf8.encode(canonicalPayload)).bytes)
      .replaceAll('=', '');
}

/// Returns the variant whose height matches [quality], else the first one.
@visibleForTesting
Uri? selectHlsVariant(String masterText, Uri masterUri, String quality) {
  final lines = const LineSplitter().convert(masterText);
  final targetHeight = int.tryParse(quality.replaceAll(RegExp('[^0-9]'), ''));
  Uri? firstVariant;
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trim();
    if (!line.startsWith('#EXT-X-STREAM-INF')) continue;
    final nextUri = i + 1 < lines.length ? lines[i + 1].trim() : '';
    if (nextUri.isEmpty || nextUri.startsWith('#')) continue;
    firstVariant ??= _resolveHlsUri(masterUri, nextUri);
    if (targetHeight != null &&
        RegExp('RESOLUTION=\\d+x$targetHeight(?:[,\\s]|\$)').hasMatch(line)) {
      return _resolveHlsUri(masterUri, nextUri);
    }
  }
  return firstVariant;
}

Uri _resolveHlsUri(Uri base, String reference) {
  final referenceUri = Uri.parse(reference);
  final baseTokenIndex = base.pathSegments.indexWhere(
    (segment) => segment.startsWith('bcdn_token='),
  );

  if (!referenceUri.hasScheme &&
      reference.startsWith('/') &&
      baseTokenIndex != -1 &&
      !referenceUri.pathSegments.any(
        (segment) => segment.startsWith('bcdn_token='),
      )) {
    return base.replace(
      pathSegments: [
        base.pathSegments[baseTokenIndex],
        ...referenceUri.pathSegments.where((segment) => segment.isNotEmpty),
      ],
      query: referenceUri.query.isEmpty ? null : referenceUri.query,
    );
  }

  final resolved = base.resolve(reference);
  if (resolved.queryParameters.keys.any(
    (key) => key.toLowerCase().contains('token'),
  )) {
    return resolved;
  }
  final tokenQuery = Map<String, String>.fromEntries(
    base.queryParameters.entries.where(
      (entry) => entry.key.toLowerCase().contains('token'),
    ),
  );
  if (tokenQuery.isEmpty) return resolved;
  return resolved.replace(
    queryParameters: {...resolved.queryParameters, ...tokenQuery},
  );
}
