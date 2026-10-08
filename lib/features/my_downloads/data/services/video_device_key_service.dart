import 'dart:developer' as developer;

import 'package:coursaty_student_and_teacher/core/common/constant/configuration/url_routes.dart';
import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:coursaty_student_and_teacher/services/device_info_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import '../../../../core/api/detect_server.dart';

class VideoDeviceKeyService {
  VideoDeviceKeyService(this._client, this._prefs);

  static const MethodChannel _channel = MethodChannel(
    'coursaty/video_security',
  );

  final Dio _client;
  final PrefsRepository _prefs;

  Future<void> ensureAndRegister() async {
    final deviceId = DeviceInfoService.getSecureVideoDeviceId();
    final deviceIdPrefix = _safeDeviceIdPrefix(deviceId);

    try {
      final keyExistsBefore =
          await _channel.invokeMethod<bool>('hasVideoDeviceKey') ?? false;
      _log(
        'registration started '
        'deviceIdPrefix=$deviceIdPrefix keyExists=$keyExistsBefore',
      );
      await _channel.invokeMethod<void>('ensureVideoDeviceKey');
      final publicKey = await _channel.invokeMethod<String>(
        'getVideoDevicePublicKey',
      );
      if (publicKey == null || publicKey.isEmpty) {
        throw const VideoDeviceRegistrationException(
          'Android Keystore returned an empty video public key',
        );
      }

      await _client.postUri(
        _uri('devices/video-key'),
        data: {
          'deviceId': deviceId,
          'publicKey': publicKey,
          'algorithm': 'ECDSA_P256_SHA256',
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            if (_prefs.token != null) 'Authorization': 'Bearer ${_prefs.token}',
          },
        ),
      );
      _log(
        'registration succeeded '
        'deviceIdPrefix=$deviceIdPrefix keyExists=true',
      );
    } catch (error, stackTrace) {
      _log(
        'device registration failed '
        'deviceIdPrefix=$deviceIdPrefix stage=register-device-key '
        'errorType=${error.runtimeType}',
        error: error,
        stackTrace: stackTrace,
      );
      if (DeviceReplacementRequiredException.matches(error)) {
        throw const DeviceReplacementRequiredException();
      }
      if (error is VideoDeviceRegistrationException) rethrow;
      throw VideoDeviceRegistrationException.from(error);
    }
  }

  Future<void> replaceDevice() async {
    final deviceId = DeviceInfoService.getSecureVideoDeviceId();
    await _channel.invokeMethod<void>('ensureVideoDeviceKey');
    final publicKey = await _channel.invokeMethod<String>(
      'getVideoDevicePublicKey',
    );
    if (publicKey == null || publicKey.isEmpty) {
      throw const VideoDeviceRegistrationException(
        'Android Keystore returned an empty video public key',
      );
    }
    await _client.postUri(
      _uri(EndPoints.replaceVideoDeviceKey),
      data: {
        'deviceId': deviceId,
        'publicKey': publicKey,
        'algorithm': 'ECDSA_P256_SHA256',
      },
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  Future<String> sign(String payload) async {
    final signature = await _channel.invokeMethod<String>('signVideoPayload', {
      'payload': payload,
    });
    if (signature == null || signature.isEmpty) {
      throw PlatformException(
        code: 'empty_video_signature',
        message: 'Android Keystore returned an empty signature',
      );
    }
    return signature;
  }

  Future<void> deleteKey() async {
    await _channel.invokeMethod<void>('deleteVideoDeviceKey');
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
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      return VideoDeviceRegistrationException(
        statusCode == null
            ? 'Video device registration failed'
            : 'Video device registration failed with HTTP $statusCode',
      );
    }

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

class DeviceReplacementRequiredException implements Exception {
  const DeviceReplacementRequiredException();

  static bool matches(Object error) {
    return error is DioException &&
        error.response?.data is Map<String, dynamic> &&
        (error.response!.data as Map<String, dynamic>)['errorCode'] ==
            'VIDEO_DEVICE_LIMIT_EXCEEDED_REPLACEMENT_REQUIRED';
  }

  @override
  String toString() => 'Video device replacement is required';
}
