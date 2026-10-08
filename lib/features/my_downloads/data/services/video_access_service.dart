import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:coursaty_student_and_teacher/core/common/constant/configuration/url_routes.dart';
import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/models/secure_video_models.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/play_integrity_service.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/video_device_key_service.dart';
import 'package:coursaty_student_and_teacher/services/device_info_service.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/api/detect_server.dart';

@lazySingleton
class VideoAccessService {
  VideoAccessService(this._client, this._prefs, this._sharedPreferences);

  final Dio _client;
  final PrefsRepository _prefs;
  final SharedPreferences _sharedPreferences;
  final PlayIntegrityService _playIntegrityService = PlayIntegrityService();
  late final VideoDeviceKeyService _videoDeviceKeyService =
      VideoDeviceKeyService(_client, _prefs);

  Future<PlaybackSessionResponse> createPlaybackSession({
    required String videoId,
    required String preferredResolution,
  }) async {
    final isTeacher = _prefs.isTeacher;
    if (!isTeacher) {
      await _ensureRegistered(stage: 'playback-session');
    }
    final body = <String, dynamic>{
      'deviceId': DeviceInfoService.getSecureVideoDeviceId(),
      'preferredResolution': preferredResolution,
    };
    if (!isTeacher) {
      final integrity = await _buildIntegrityBody(videoId: videoId);
      body.addAll(integrity);
    }

    try {
      final response = await _client.postUri(
        _uri(EndPoints.createPlaybackSession(videoId: videoId)),
        data: body,
        options: _options(),
      );
      _recordTrustedTime(response);
      _log('playback session success videoId=$videoId');
      return PlaybackSessionResponse.fromJson(response.data);
    } catch (error, stackTrace) {
      _log(
        'playback session failure videoId=$videoId errorType=${error.runtimeType}',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

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
      return PlaybackSessionResponse.fromJson(response.data);
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

  Future<PlaybackSessionResponse> refreshPlaybackSession({
    required String videoId,
    required String playbackSessionId,
    required String preferredResolution,
  }) async {
    if (!_prefs.isTeacher) {
      await _ensureRegistered(stage: 'playback-session-refresh');
    }
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
      return PlaybackSessionResponse.fromJson(response.data);
    } catch (error, stackTrace) {
      _log(
        'playback session refresh failure videoId=$videoId '
        'errorType=${error.runtimeType}',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<String> resolvePlayableHlsUrl({
    required String playbackUrl,
    required String preferredResolution,
  }) async {
    final masterUri = Uri.parse(playbackUrl);
    final masterText = await _readHlsText(masterUri);
    final variant = _selectVariant(masterText, masterUri, preferredResolution);
    return (variant ?? masterUri).toString();
  }

  Future<Map<String, dynamic>> _buildIntegrityBody({
    required String videoId,
  }) async {
    if (!Platform.isAndroid) return const {};

    try {
      await _playIntegrityService.prepare();
      final challengeResponse = await _client.postUri(
        _uri(EndPoints.createPlaybackChallenge(videoId: videoId)),
        data: {'deviceId': DeviceInfoService.getSecureVideoDeviceId()},
        options: _options(),
      );
      final data = Map<String, dynamic>.from(challengeResponse.data as Map);
      final challengeId = data['challengeId'] as String;
      final challenge = data['challenge'] as String;
      final challengeTimestamp = (data['challengeTimestamp'] as num).toInt();
      _log('playback challenge success videoId=$videoId');
      final requestHash = _buildPlaybackRequestHash(
        videoId: videoId,
        deviceId: DeviceInfoService.getSecureVideoDeviceId(),
        timestamp: challengeTimestamp,
        challenge: challenge,
      );
      final integrityToken = await _playIntegrityService.requestToken(
        requestHash: requestHash,
      );
      _log('integrity available videoId=$videoId');
      return {
        'challengeId': challengeId,
        'challengeTimestamp': challengeTimestamp,
        'integrityToken': integrityToken,
      };
    } catch (error, stackTrace) {
      _log(
        'integrity unavailable videoId=$videoId errorType=${error.runtimeType}',
        error: error,
        stackTrace: stackTrace,
      );
      if (kDebugMode) debugPrint('Play Integrity audit flow skipped: $error');
      return const {};
    }
  }

  String _buildPlaybackRequestHash({
    required String videoId,
    required String deviceId,
    required int timestamp,
    required String challenge,
  }) {
    final canonical = [
      'action=video_playback',
      'videoId=$videoId',
      'deviceId=$deviceId',
      'timestamp=$timestamp',
      'challenge=$challenge',
    ].join('\n');
    return base64Url
        .encode(sha256.convert(utf8.encode(canonical)).bytes)
        .replaceAll('=', '');
  }

  Future<DownloadSessionResponse> createDownloadSession({
    required String videoId,
    required String preferredResolution,
  }) async {
    _ensureAuthenticatedForDownload();
    await _ensureRegistered(stage: 'download-session');
    try {
      final response = await _client.postUri(
        _uri(EndPoints.createDownloadSession(videoId: videoId)),
        data: {
          'deviceId': DeviceInfoService.getSecureVideoDeviceId(),
          'preferredResolution': preferredResolution,
        },
        options: _options(),
      );
      _recordTrustedTime(response);
      _log('download session success videoId=$videoId');
      return DownloadSessionResponse.fromJson(response.data);
    } catch (error, stackTrace) {
      _log(
        'download session failure videoId=$videoId errorType=${error.runtimeType}',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
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
      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      _log('offline license success videoId=$videoId');
      return OfflineLicense.fromJson(
        (data['offlineLicense'] ?? data) as Map<String, dynamic>,
      );
    } catch (error, stackTrace) {
      _log(
        'offline license failure videoId=$videoId errorType=${error.runtimeType}',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
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
    if (!Platform.isAndroid) return;
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
        'User-Agent':
            'device OS:${Platform.isAndroid ? 'Android' : 'IOS'} , application version: 1.0.0',
      },
      responseType: ResponseType.json,
    );
  }

  void _ensureAuthenticatedForDownload() {
    if (_prefs.isGuest || _prefs.token == null) {
      _log('guest download rejected');
      throw StateError('Guest users cannot download videos');
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
    _sharedPreferences.setString(
      'trustedServerTime',
      serverTime.toIso8601String(),
    );
    _sharedPreferences.setString(
      'trustedLocalRecordedTime',
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  Future<String> _readHlsText(Uri uri) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, '*/*');
      final response = await request.close();
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

  Uri? _selectVariant(String masterText, Uri masterUri, String quality) {
    final lines = const LineSplitter().convert(masterText);
    final targetHeight = int.tryParse(quality.replaceAll(RegExp('[^0-9]'), ''));
    Uri? firstVariant;
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (!line.startsWith('#EXT-X-STREAM-INF')) continue;
      final nextUri = i + 1 < lines.length ? lines[i + 1].trim() : '';
      if (nextUri.isEmpty || nextUri.startsWith('#')) continue;
      firstVariant ??= _resolveHlsUri(masterUri, nextUri);
      if (targetHeight != null && line.contains('x$targetHeight')) {
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
}
