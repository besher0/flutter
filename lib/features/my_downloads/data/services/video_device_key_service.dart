import 'dart:developer' as developer;
import 'dart:io';

import 'package:coursaty_student_and_teacher/core/common/constant/configuration/url_routes.dart';
import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/models/video_security_errors.dart';
import 'package:coursaty_student_and_teacher/services/device_info_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import '../../../../core/api/detect_server.dart';

/// Android Keystore backed device key (EC P-256, non-exportable).
///
/// The native side lives in `MainActivity.kt` on channel
/// `coursaty/video_security`. iOS has no equivalent bridge yet, so on iOS the
/// key flow is reported as unsupported instead of silently skipped.
class VideoDeviceKeyService {
  VideoDeviceKeyService(this._client, this._prefs, {bool? isSupported})
    : isSupported = isSupported ?? Platform.isAndroid;

  static const MethodChannel _channel = MethodChannel(
    'coursaty/video_security',
  );

  final Dio _client;
  final PrefsRepository _prefs;

  /// Whether this platform has the native Keystore key bridge.
  final bool isSupported;

  Future<void> ensureAndRegister() async {
    if (!isSupported) return;
    final deviceId = DeviceInfoService.getSecureVideoDeviceId();
    final deviceIdPrefix = _safeDeviceIdPrefix(deviceId);

    try {
      final publicKey = await _readPublicKey();
      _log('registration started deviceIdPrefix=$deviceIdPrefix');
      await _client.postUri(
        _uri(EndPoints.registerVideoDeviceKey),
        data: {
          'deviceId': deviceId,
          'publicKey': publicKey,
          'algorithm': 'ECDSA_P256_SHA256',
        },
        options: _authOptions(),
      );
      _log('registration succeeded deviceIdPrefix=$deviceIdPrefix');
    } catch (error, stackTrace) {
      _log(
        'device registration failed '
        'deviceIdPrefix=$deviceIdPrefix stage=register-device-key '
        'errorType=${error.runtimeType}',
        error: error,
        stackTrace: stackTrace,
      );
      final replacement = DeviceReplacementRequiredException.fromError(error);
      if (replacement != null) throw replacement;
      if (error is VideoDeviceRegistrationException ||
          error is VideoDeviceSecurityUnsupportedException) {
        rethrow;
      }
      if (error is DioException) rethrow;
      throw VideoDeviceRegistrationException.from(error);
    }
  }

  /// Explicit, user-confirmed replacement. The account is taken from the JWT;
  /// no user or student id is ever sent.
  Future<void> replaceDevice() async {
    if (!isSupported) throw const VideoDeviceSecurityUnsupportedException();
    final deviceId = DeviceInfoService.getSecureVideoDeviceId();
    final publicKey = await _readPublicKey();
    await _client.postUri(
      _uri(EndPoints.replaceVideoDeviceKey),
      data: {
        'deviceId': deviceId,
        'publicKey': publicKey,
        'algorithm': 'ECDSA_P256_SHA256',
      },
      options: _authOptions(),
    );
  }

  /// Signs [payload] (UTF-8) with SHA256withECDSA. Returns base64url DER.
  Future<String> sign(String payload) async {
    if (!isSupported) throw const VideoDeviceSecurityUnsupportedException();
    final String? signature;
    try {
      signature = await _channel.invokeMethod<String>('signVideoPayload', {
        'payload': payload,
      });
    } on MissingPluginException {
      throw const VideoDeviceSecurityUnsupportedException();
    }
    if (signature == null || signature.isEmpty) {
      throw PlatformException(
        code: 'empty_video_signature',
        message: 'Android Keystore returned an empty signature',
      );
    }
    return signature;
  }

  Future<void> deleteKey() async {
    if (!isSupported) return;
    await _channel.invokeMethod<void>('deleteVideoDeviceKey');
  }

  Future<String> _readPublicKey() async {
    final String? publicKey;
    try {
      await _channel.invokeMethod<void>('ensureVideoDeviceKey');
      publicKey = await _channel.invokeMethod<String>(
        'getVideoDevicePublicKey',
      );
    } on MissingPluginException {
      throw const VideoDeviceSecurityUnsupportedException();
    }
    if (publicKey == null || publicKey.isEmpty) {
      throw const VideoDeviceRegistrationException(
        'Android Keystore returned an empty video public key',
      );
    }
    return publicKey;
  }

  Options _authOptions() {
    final token = _prefs.token;
    return Options(
      headers: {
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
        if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
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

  String _safeDeviceIdPrefix(String deviceId) {
    if (deviceId.length <= 10) return deviceId;
    return deviceId.substring(0, 10);
  }

  void _log(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      '[VideoSecurity] $message',
      name: 'VideoDeviceKeyService',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

class VideoDeviceRegistrationException implements Exception {
  const VideoDeviceRegistrationException(this.message);

  factory VideoDeviceRegistrationException.from(Object error) {
    if (error is PlatformException) {
      return VideoDeviceRegistrationException(
        'Video device registration failed: ${error.code}',
      );
    }
    return const VideoDeviceRegistrationException(
      'Video device registration failed',
    );
  }

  final String message;

  @override
  String toString() => message;
}

/// Self-service device replacement is suspended. When another device holds
/// the account (or this device's key changed), the app only shows a warning
/// and never calls the replacement endpoint. Set to true to bring back the
/// confirmation dialog in the video player.
const bool videoDeviceReplacementEnabled = false;

enum DeviceReplacementReason {
  /// Another installation already holds the account's device slot.
  deviceLimit,

  /// This installation id is bound to a different key (Keystore was reset).
  keyMismatch,
}

class DeviceReplacementRequiredException implements Exception {
  const DeviceReplacementRequiredException([
    this.reason = DeviceReplacementReason.deviceLimit,
  ]);

  final DeviceReplacementReason reason;

  static DeviceReplacementRequiredException? fromError(Object error) {
    if (error is DeviceReplacementRequiredException) return error;
    switch (videoErrorCodeOf(error)) {
      case VideoErrorCodes.deviceLimitReplacementRequired:
        return const DeviceReplacementRequiredException();
      case VideoErrorCodes.deviceKeyMismatchReplacementRequired:
        return const DeviceReplacementRequiredException(
          DeviceReplacementReason.keyMismatch,
        );
    }
    return null;
  }

  static bool matches(Object error) => fromError(error) != null;

  @override
  String toString() => 'Video device replacement is required';
}
