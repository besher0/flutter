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
    await _channel.invokeMethod<void>('ensureVideoDeviceKey');
    final publicKey = await _channel.invokeMethod<String>(
      'getVideoDevicePublicKey',
    );
    if (publicKey == null || publicKey.isEmpty) return;

    await _client.postUri(
      _uri('devices/video-key'),
      data: {
        'deviceId': DeviceInfoService.getSecureVideoDeviceId(),
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
}
