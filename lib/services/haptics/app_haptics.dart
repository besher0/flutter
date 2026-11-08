import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum _Impact { light, medium, heavy }

/// Kinds of haptic feedback, from the lightest to the strongest.
///
/// [priority] decides which one wins when several are asked for by the same
/// user action (see [AppHaptics]).
enum AppHapticType {
  /// A standard button press.
  lightTap(0),

  /// Changing a selection: a toggle, a tab, a chip, an answer.
  selection(1),

  /// An important or destructive action being confirmed.
  warning(2),

  /// The confirmed result of an action: it worked.
  success(3),

  /// The confirmed result of an action: it failed / was wrong.
  error(3);

  const AppHapticType(this.priority);

  final int priority;

  bool get isOutcome => this == success || this == error || this == warning;
}

/// The one place the app asks for haptic feedback.
///
/// Context-aware, so one user action never produces a stack of vibrations:
///
/// * [lightTap] and [selection] are not played at once but at the end of the
///   current event (a microtask). If the same action then reports an outcome
///   ([success], [error], [warning]) — e.g. tapping «فحص» validates the answer
///   synchronously — only the outcome is felt, not «tap + outcome».
/// * Of several taps/selections asked for in the same event, only the
///   strongest is played.
/// * For a short moment after an outcome, taps and selections are dropped,
///   and the same outcome is not repeated (rebuilds, double listeners).
///
/// Android: every kind is played by the app itself through the vibration
/// motor (`coursaty/haptics` channel, `MainActivity`). ⚠️ Flutter's
/// [HapticFeedback] asks the view for "touch feedback", which Xiaomi
/// (MIUI/HyperOS) and Honor (MagicOS) ship turned off and whose light effects
/// they ignore: nothing was felt on those phones. The phone's silent mode is
/// respected (no vibration).
///
/// iOS: success / error / warning use `UINotificationFeedbackGenerator`
/// through the same channel, taps and selections Flutter's [HapticFeedback];
/// where the channel answers false, a short pattern of impacts plays instead.
/// Haptics are never the only feedback: every caller keeps its visual
/// state.
abstract final class AppHaptics {
  AppHaptics._();

  /// App-wide switch (e.g. for a future settings toggle or tests).
  static bool enabled = true;

  static const MethodChannel _channel = MethodChannel('coursaty/haptics');

  /// After an outcome, taps and selections in this window are dropped.
  static const Duration outcomeQuietWindow = Duration(milliseconds: 250);

  /// The same outcome is not repeated within this window.
  static const Duration repeatOutcomeWindow = Duration(milliseconds: 400);

  /// The same tap/selection is not repeated within this window.
  static const Duration repeatLightWindow = Duration(milliseconds: 60);

  @visibleForTesting
  static DateTime Function() clock = DateTime.now;

  static AppHapticType? _pending;
  static bool _flushScheduled = false;
  static AppHapticType? _last;
  static DateTime? _lastAt;
  static int _generation = 0;

  /// Standard button press.
  static void lightTap() => _request(AppHapticType.lightTap);

  /// Toggle / tab / chip / answer selection.
  static void selection() => _request(AppHapticType.selection);

  /// Confirmed success of a user action.
  static void success() => _outcome(AppHapticType.success);

  /// Confirmed failure of a user action (or a wrong answer).
  static void error() => _outcome(AppHapticType.error);

  /// Confirming an important or destructive action.
  static void warning() => _outcome(AppHapticType.warning);

  /// Plays [type] through the same rules as the named methods.
  static void play(AppHapticType type) =>
      type.isOutcome ? _outcome(type) : _request(type);

  static bool _within(Duration window) {
    final at = _lastAt;
    return at != null && clock().difference(at) < window;
  }

  static void _request(AppHapticType type) {
    if (!enabled) return;
    if (_last != null && _last!.isOutcome && _within(outcomeQuietWindow)) {
      return;
    }
    if (_last == type && _within(repeatLightWindow)) return;
    final pending = _pending;
    if (pending == null || type.priority > pending.priority) _pending = type;
    if (_flushScheduled) return;
    _flushScheduled = true;
    scheduleMicrotask(_flush);
  }

  static void _flush() {
    _flushScheduled = false;
    final type = _pending;
    _pending = null;
    if (type == null || !enabled) return;
    _record(type);
    _impact(type);
  }

  static void _outcome(AppHapticType type) {
    if (!enabled) return;
    // The outcome replaces the tap/selection of the same action.
    _pending = null;
    if (_last == type && _within(repeatOutcomeWindow)) return;
    _record(type);
    final generation = ++_generation;
    unawaited(_playOutcome(type, generation));
  }

  static void _record(AppHapticType type) {
    _last = type;
    _lastAt = clock();
  }

  static Future<void> _playOutcome(AppHapticType type, int generation) async {
    final native = await _native(type.name);
    if (native || generation != _generation) return;
    await _pattern(type, generation);
  }

  /// Fallback patterns made of impacts, for platforms without notification
  /// haptics. Stops early when a newer outcome starts.
  static Future<void> _pattern(AppHapticType type, int generation) async {
    final steps = switch (type) {
      // Two rising taps.
      AppHapticType.success => const [(_Impact.light, 0), (_Impact.medium, 90)],
      // Three firm taps, the last the strongest.
      AppHapticType.error => const [
        (_Impact.medium, 0),
        (_Impact.medium, 80),
        (_Impact.heavy, 80),
      ],
      // A strong tap then a light one.
      AppHapticType.warning => const [(_Impact.heavy, 0), (_Impact.light, 110)],
      _ => const <(_Impact, int)>[],
    };
    for (final (kind, delayMs) in steps) {
      if (delayMs > 0) {
        await Future<void>.delayed(Duration(milliseconds: delayMs));
      }
      if (generation != _generation || !enabled) return;
      await _impactOf(kind);
    }
  }

  static Future<void> _impact(AppHapticType type) async {
    if (defaultTargetPlatform == TargetPlatform.android &&
        await _native(type.name)) {
      return;
    }
    await switch (type) {
      AppHapticType.selection => HapticFeedback.selectionClick(),
      _ => HapticFeedback.lightImpact(),
    };
  }

  /// Plays [method] natively; false when the platform has no such effect.
  static Future<bool> _native(String method) async {
    try {
      return await _channel.invokeMethod<bool>(method) ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  static Future<void> _impactOf(_Impact kind) => switch (kind) {
    _Impact.light => HapticFeedback.lightImpact(),
    _Impact.medium => HapticFeedback.mediumImpact(),
    _Impact.heavy => HapticFeedback.heavyImpact(),
  };

  /// Clears all state (tests).
  @visibleForTesting
  static void debugReset() {
    enabled = true;
    clock = DateTime.now;
    _pending = null;
    _flushScheduled = false;
    _last = null;
    _lastAt = null;
    _generation++;
  }
}
