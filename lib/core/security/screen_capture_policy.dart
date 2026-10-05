import 'dart:async';

import 'package:no_screenshot/no_screenshot.dart';

/// Abstraction kept small so nested screen protection can be unit-tested
/// without invoking a platform channel.
abstract interface class ScreenCaptureController {
  Future<void> allowCapture();

  Future<void> blockCapture();
}

class NoScreenshotController implements ScreenCaptureController {
  NoScreenshotController([NoScreenshot? noScreenshot])
    : _noScreenshot = noScreenshot ?? NoScreenshot.instance;

  final NoScreenshot _noScreenshot;

  @override
  Future<void> allowCapture() => _noScreenshot.screenshotOn();

  @override
  Future<void> blockCapture() => _noScreenshot.screenshotOff();
}

/// Coordinates screenshot/recording protection for nested routes.
///
/// A temporary allowance (the QR page) takes priority over content protection
/// so a QR opened from a protected lesson remains capturable. Releasing it
/// restores the lesson's protection automatically.
class ScreenCapturePolicy {
  ScreenCapturePolicy({ScreenCaptureController? controller})
    : _controller = controller ?? NoScreenshotController();

  static final ScreenCapturePolicy instance = ScreenCapturePolicy();

  final ScreenCaptureController _controller;
  int _protectedScopes = 0;
  int _allowedScopes = 0;
  Future<void> _operations = Future.value();

  ScreenCaptureLease protectEducationalContent() {
    _protectedScopes++;
    unawaited(_scheduleSync());
    return ScreenCaptureLease._(this, _ScopeType.protected);
  }

  ScreenCaptureLease temporarilyAllowCapture() {
    _allowedScopes++;
    unawaited(_scheduleSync());
    return ScreenCaptureLease._(this, _ScopeType.allowed);
  }

  Future<void> resetToAllowed() {
    _protectedScopes = 0;
    _allowedScopes = 0;
    return _scheduleSync();
  }

  /// Re-applies the correct policy after returning from background.
  Future<void> refresh() => _scheduleSync();

  Future<void> waitForIdle() => _operations;

  void _release(_ScopeType type) {
    if (type == _ScopeType.protected && _protectedScopes > 0) {
      _protectedScopes--;
    }
    if (type == _ScopeType.allowed && _allowedScopes > 0) {
      _allowedScopes--;
    }
    unawaited(_scheduleSync());
  }

  Future<void> _scheduleSync() {
    _operations = _operations.then((_) async {
      try {
        if (_allowedScopes > 0 || _protectedScopes == 0) {
          await _controller.allowCapture();
        } else {
          await _controller.blockCapture();
        }
      } catch (_) {
        // A platform-channel failure must not prevent a later route/lifecycle
        // change from restoring the desired protection state.
      }
    });
    return _operations;
  }
}

enum _ScopeType { protected, allowed }

class ScreenCaptureLease {
  ScreenCaptureLease._(this._policy, this._type);

  final ScreenCapturePolicy _policy;
  final _ScopeType _type;
  bool _released = false;

  void release() {
    if (_released) return;
    _released = true;
    _policy._release(_type);
  }
}
