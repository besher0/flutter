import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/api/client_config.dart';
import '../core/api/detect_server.dart';
import '../core/api/methods/get.dart';
import '../core/common/constant/configuration/url_routes.dart';

/// What the server says about the installed build (`GET app-updates/{platform}/check`).
class AppUpdateInfo {
  const AppUpdateInfo({
    required this.updateAvailable,
    required this.required,
    this.latestVersion,
    this.latestBuild,
    this.storeUrl,
    this.downloadUrl,
    this.message,
  });

  final bool updateAvailable;

  /// The admin made this update mandatory: the app must not be used until it
  /// is installed.
  final bool required;
  final String? latestVersion;
  final int? latestBuild;
  final String? storeUrl;
  final String? downloadUrl;
  final String? message;

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    String? text(dynamic v) {
      final s = v?.toString().trim();
      return s == null || s.isEmpty ? null : s;
    }

    return AppUpdateInfo(
      updateAvailable: json['updateAvailable'] == true,
      required: json['required'] == true,
      latestVersion: text(json['latestVersion']),
      latestBuild: (json['latestBuild'] as num?)?.toInt(),
      storeUrl: text(json['storeUrl']),
      downloadUrl: text(json['downloadUrl']),
      message: text(json['message']),
    );
  }
}

/// Checks the admin's release policy instead of asking the store: the store
/// is slow to report a new version and knows nothing about installs from
/// outside it.
class AppUpdateService {
  AppUpdateService._();

  static const _playStore = 'com.android.vending';

  /// Null when the check cannot run (offline, server error): a failed check
  /// must never lock anyone out of the app.
  static Future<AppUpdateInfo?> check() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final build = int.tryParse(info.buildNumber);
      if (build == null) return null;
      final platform = defaultTargetPlatform == TargetPlatform.iOS
          ? 'ios'
          : 'android';
      final request = GetClient<AppUpdateInfo>(
        serverName: ServerName.master,
        requestPrams: RequestConfig(
          endpoint: EndPoints.appUpdateCheck(platform: platform),
          queryParameters: {'build': '$build'},
          response: ResponseValue(
            fromJson: (json) =>
                AppUpdateInfo.fromJson(Map<String, dynamic>.from(json)),
          ),
        ),
      );
      return await request();
    } catch (error) {
      debugPrint('app update check failed: ${error.runtimeType}');
      return null;
    }
  }

  /// Opens where the update comes from. Returns false when there is nowhere
  /// to go or the link could not be opened.
  static Future<bool> openUpdate(AppUpdateInfo info) async {
    String? installer;
    try {
      installer = (await PackageInfo.fromPlatform()).installerStore;
    } catch (_) {}
    final uri = updateUri(
      info,
      installerStore: installer,
      isIOS: defaultTargetPlatform == TargetPlatform.iOS,
    );
    if (uri == null) return false;
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  /// The store page for store installs (and on iOS); otherwise the direct
  /// download, so a phone that got the app from outside the store gets the
  /// same kind of build again. Falls back to whichever link exists.
  @visibleForTesting
  static Uri? updateUri(
    AppUpdateInfo info, {
    String? installerStore,
    bool isIOS = false,
  }) {
    final fromStore = isIOS || installerStore == _playStore;
    final first = fromStore ? info.storeUrl : info.downloadUrl;
    final second = fromStore ? info.downloadUrl : info.storeUrl;
    final link = first ?? second;
    return link == null ? null : Uri.tryParse(link);
  }
}
