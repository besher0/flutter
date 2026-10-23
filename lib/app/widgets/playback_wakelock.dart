import 'dart:async';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Keeps the screen awake only while [controller] is playing.
///
/// Paused, finished or closed videos give the screen back to the device's own
/// sleep timeout, so the rest of the app behaves normally.
class PlaybackWakelock {
  PlaybackWakelock(this.controller) {
    controller.addEventsListener(_onEvent);
  }

  final BetterPlayerController controller;
  bool? _awake;
  Timer? _resync;

  void _onEvent(BetterPlayerEvent event) {
    switch (event.betterPlayerEventType) {
      case BetterPlayerEventType.hideFullscreen:
        // better_player releases the wakelock itself when leaving full screen,
        // right after this event: apply ours again once it has done so.
        _resync?.cancel();
        _resync = Timer(const Duration(seconds: 1), () {
          _awake = null;
          _sync();
        });
      case BetterPlayerEventType.finished:
      case BetterPlayerEventType.exception:
        _set(false);
      default:
        _sync();
    }
  }

  void _sync() => _set(controller.isPlaying() ?? false);

  void _set(bool awake) {
    if (_awake == awake) return;
    _awake = awake;
    if (awake) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
  }

  void dispose() {
    _resync?.cancel();
    controller.removeEventsListener(_onEvent);
    if (_awake ?? false) WakelockPlus.disable();
    _awake = false;
  }
}
