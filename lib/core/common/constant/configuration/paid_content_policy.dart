import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../api/client_config.dart';
import '../../../api/detect_server.dart';
import '../../../api/methods/get.dart';
import 'url_routes.dart';

/// Whether the iPhone app shows anything about paid content: prices, buy and
/// subscribe buttons, code activation, QR payment, purchase requests, points
/// of sale, and lessons (videos, files, questions) shown as locked.
///
/// An admin decides (`GET system-settings/app-config` →
/// `iosPaidContentVisible`). Other platforms always show paid content, and
/// teacher-only screens are not affected. Until the server has answered once,
/// the iPhone hides it: the safe state for App Store review. The last answer is
/// kept so the app starts in the right state offline.
abstract final class PaidContentPolicy {
  static const _prefsKey = 'coursaty_ios_paid_content_visible_v1';

  static bool _iosVisible = false;

  /// True on an iPhone whose admin setting hides paid content.
  static bool get hidePaid => isHidden(
    isIOS: defaultTargetPlatform == TargetPlatform.iOS,
    iosVisible: _iosVisible,
  );

  @visibleForTesting
  static bool isHidden({required bool isIOS, required bool iosVisible}) =>
      isIOS && !iosVisible;

  @visibleForTesting
  static set iosVisibleForTesting(bool value) => _iosVisible = value;

  /// Reads the last known setting; fast, no network.
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _iosVisible = prefs.getBool(_prefsKey) ?? false;
    } catch (_) {}
  }

  /// Asks the server; screens built afterwards follow the new setting.
  static Future<void> refresh() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;
    try {
      final visible = await GetClient<bool>(
        serverName: ServerName.master,
        requestPrams: RequestConfig(
          endpoint: EndPoints.appConfig,
          response: ResponseValue(
            fromJson: (json) => json is Map && json['iosPaidContentVisible'] == true,
          ),
        ),
      )();
      _iosVisible = visible;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, visible);
    } catch (error) {
      debugPrint('app config unavailable: ${error.runtimeType}');
    }
  }
}
