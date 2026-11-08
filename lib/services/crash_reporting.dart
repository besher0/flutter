import 'dart:async';
import 'dart:isolate';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Where crash reports go. [FirebaseCrashSink] in the app; tests use a fake.
abstract interface class CrashSink {
  Future<void> setCollectionEnabled(bool enabled);
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal,
  });
  Future<void> log(String message);
  Future<void> setCustomKey(String key, Object value);
}

class FirebaseCrashSink implements CrashSink {
  FirebaseCrashlytics get _crashlytics => FirebaseCrashlytics.instance;

  @override
  Future<void> setCollectionEnabled(bool enabled) =>
      _crashlytics.setCrashlyticsCollectionEnabled(enabled);

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) => _crashlytics.recordError(error, stack, reason: reason, fatal: fatal);

  @override
  Future<void> log(String message) => _crashlytics.log(message);

  @override
  Future<void> setCustomKey(String key, Object value) =>
      _crashlytics.setCustomKey(key, value);
}

/// Crash reporting (Firebase Crashlytics).
///
/// Native crashes (Java/Kotlin, and C/C++ through the NDK on Android, e.g. an
/// OutOfMemoryError in the player or a crash in the Flutter engine) are
/// caught by the Crashlytics SDK itself. [init] adds the Dart side: uncaught
/// framework, zone and isolate errors. [log] leaves breadcrumbs (the last
/// ones are attached to the next report), so a crash on the video screen
/// shows what the player was doing.
///
/// Nothing is collected in debug builds. No personal data is sent: no
/// phone number, name or token, only the role and app-defined breadcrumbs.
abstract final class CrashReporting {
  static CrashSink? _sink;

  static bool get isEnabled => _sink != null;

  /// Call once, after `Firebase.initializeApp` succeeded.
  static Future<void> init({
    CrashSink? sink,
    bool collect = !kDebugMode,
  }) async {
    final target = sink ?? FirebaseCrashSink();
    try {
      await target.setCollectionEnabled(collect);
    } catch (error) {
      debugPrint('crash reporting unavailable: ${error.runtimeType}');
      return;
    }
    if (!collect) return;
    _sink = target;

    final previousFlutterHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      // Layout or build errors leave the app running: reported, not fatal.
      _record(
        details.exception,
        details.stack,
        reason: details.context?.toDescription(),
        fatal: false,
      );
      previousFlutterHandler?.call(details);
    };
    // Errors no zone handled (async gaps, platform callbacks).
    PlatformDispatcher.instance.onError = (error, stack) {
      _record(error, stack, fatal: true);
      return true;
    };
    Isolate.current.addErrorListener(
      RawReceivePort((dynamic pair) {
        final list = pair as List<dynamic>;
        _record(
          list.first as Object,
          StackTrace.fromString(list.last.toString()),
          fatal: true,
        );
      }).sendPort,
    );
  }

  /// A breadcrumb attached to the next report.
  static void log(String message) {
    final sink = _sink;
    if (sink == null) return;
    unawaited(sink.log(message).catchError((Object _) {}));
  }

  /// A handled error worth knowing about (the app keeps running).
  static void recordError(Object error, StackTrace? stack, {String? reason}) =>
      _record(error, stack, reason: reason, fatal: false);

  static void setCustomKey(String key, Object value) {
    final sink = _sink;
    if (sink == null) return;
    unawaited(sink.setCustomKey(key, value).catchError((Object _) {}));
  }

  static void _record(
    Object error,
    StackTrace? stack, {
    String? reason,
    required bool fatal,
  }) {
    final sink = _sink;
    if (sink == null) return;
    unawaited(
      sink
          .recordError(error, stack, reason: reason, fatal: fatal)
          .catchError((Object _) {}),
    );
  }

  @visibleForTesting
  static void resetForTesting() => _sink = null;
}
