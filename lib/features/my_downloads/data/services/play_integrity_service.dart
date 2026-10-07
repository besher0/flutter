import 'package:flutter/services.dart';

class PlayIntegrityService {
  static const MethodChannel _channel = MethodChannel(
    'coursaty/video_security',
  );

  Future<void> prepare() async {
    await _channel.invokeMethod<void>('prepareIntegrity');
  }

  Future<String> requestToken({required String requestHash}) async {
    final token = await _channel.invokeMethod<String>('requestIntegrityToken', {
      'requestHash': requestHash,
    });
    if (token == null || token.isEmpty) {
      throw PlatformException(
        code: 'empty_integrity_token',
        message: 'Play Integrity returned an empty token',
      );
    }
    return token;
  }
}
