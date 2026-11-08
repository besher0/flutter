import 'dart:async';

import 'package:flutter/foundation.dart';

/// Waits until calls stop for [delay], then runs only the last one.
///
/// For typing: each keystroke calls [call]; the action runs once the user
/// pauses. [flush] runs the pending action now (e.g. the keyboard's search
/// key), [cancel] drops it. Call [dispose] with the owning widget.
class Debouncer {
  Debouncer(this.delay);

  final Duration delay;
  Timer? _timer;
  VoidCallback? _pending;

  bool get isPending => _timer?.isActive ?? false;

  void call(VoidCallback action) {
    _timer?.cancel();
    _pending = action;
    _timer = Timer(delay, flush);
  }

  void flush() {
    _timer?.cancel();
    _timer = null;
    final action = _pending;
    _pending = null;
    action?.call();
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
    _pending = null;
  }

  void dispose() => cancel();
}
