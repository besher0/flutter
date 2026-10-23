import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Keeps video downloads running while the app is in the background: a
/// foreground service with a notification on Android, extra background time
/// on iOS (where a longer pause is resumed by the downloader's retries).
///
/// Reference counted: the platform side starts with the first active download
/// and stops with the last one.
class BackgroundDownloadKeepAlive {
  BackgroundDownloadKeepAlive._();

  static const MethodChannel _channel = MethodChannel(
    'coursaty/background_downloads',
  );
  static int _active = 0;

  @visibleForTesting
  static int get activeDownloads => _active;

  static Future<void> acquire() async {
    _active++;
    if (_active == 1) await _invoke('start');
  }

  static Future<void> release() async {
    if (_active == 0) return;
    _active--;
    if (_active == 0) await _invoke('stop');
  }

  static Future<void> _invoke(String method) async {
    try {
      await _channel.invokeMethod<bool>(method);
    } catch (error) {
      // Not fatal: the download continues while the app is in the foreground.
      debugPrint('background download keep-alive $method failed: $error');
    }
  }
}
