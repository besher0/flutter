import 'package:flutter/foundation.dart';

/// Which platform the app runs on, and what that platform offers.
///
/// One codebase serves Android, iOS and Windows. Services that only exist on
/// the phones (Firebase push and crash reporting, the native video player,
/// screenshot blocking, root checks) ask here before starting, so Windows
/// skips them instead of failing. Based on [defaultTargetPlatform], so tests
/// can switch platform with `debugDefaultTargetPlatformOverride`.
abstract final class AppPlatform {
  static TargetPlatform get _platform => defaultTargetPlatform;

  static bool get isAndroid => !kIsWeb && _platform == TargetPlatform.android;
  static bool get isIOS => !kIsWeb && _platform == TargetPlatform.iOS;
  static bool get isWindows => !kIsWeb && _platform == TargetPlatform.windows;

  static bool get isMobile => isAndroid || isIOS;

  static bool get isDesktop =>
      !kIsWeb &&
      (_platform == TargetPlatform.windows ||
          _platform == TargetPlatform.macOS ||
          _platform == TargetPlatform.linux);

  /// Firebase (push notifications, Crashlytics) is set up for the phones
  /// only; its Windows SDK has neither messaging nor Crashlytics.
  static bool get hasFirebase => isMobile;
}
