import 'dart:async';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/foundation.dart';

/// Merges a burst of seeks into a few native ones.
///
/// better_player's progress bars call `seekTo` on every drag update (about
/// 60 a second). Each native seek drops the player's buffer and opens new
/// segment requests, and for downloaded videos decrypts a new segment, so a
/// drag along the bar queued dozens of downloads and decryptions at once:
/// the player felt heavy and memory could spike enough to close the app.
///
/// Here at most one native seek runs at a time and a new one starts at least
/// [minInterval] after the previous one; only the latest requested position
/// is kept while waiting, so the player always ends exactly where the finger
/// stopped. A single seek after a quiet moment (a tap, a skip button) runs at
/// once. Every caller's future completes when the seeks queued up to then are
/// done.
class SeekCoalescer {
  SeekCoalescer(
    this._seek, {
    this.minInterval = const Duration(milliseconds: 300),
    @visibleForTesting Duration Function()? elapsed,
  }) : _elapsed = elapsed ?? _monotonic;

  final Future<void> Function(Duration position) _seek;
  final Duration minInterval;
  final Duration Function() _elapsed;

  static final Stopwatch _clock = Stopwatch()..start();
  static Duration _monotonic() => _clock.elapsed;

  Duration? _pending;
  Duration? _lastSeekAt;
  bool _running = false;
  Completer<void>? _waiters;

  Future<void> seekTo(Duration position) {
    _pending = position;
    final waiters = _waiters ??= Completer<void>();
    if (!_running) unawaited(_run());
    return waiters.future;
  }

  Future<void> _run() async {
    _running = true;
    try {
      while (_pending != null) {
        final last = _lastSeekAt;
        if (last != null) {
          final wait = minInterval - (_elapsed() - last);
          if (wait > Duration.zero) await Future<void>.delayed(wait);
        }
        final target = _pending!;
        _pending = null;
        _lastSeekAt = _elapsed();
        await _seek(target);
      }
      final waiters = _waiters;
      _waiters = null;
      waiters?.complete();
    } catch (error, stackTrace) {
      _pending = null;
      final waiters = _waiters;
      _waiters = null;
      waiters?.completeError(error, stackTrace);
    } finally {
      _running = false;
    }
  }
}

/// [BetterPlayerController] whose seeks go through a [SeekCoalescer], so
/// dragging the progress bar (material or cupertino controls) stays light.
class SmoothSeekBetterPlayerController extends BetterPlayerController {
  SmoothSeekBetterPlayerController(
    super.betterPlayerConfiguration, {
    super.betterPlayerDataSource,
  });

  late final SeekCoalescer _seeks = SeekCoalescer(_nativeSeek);

  Future<void> _nativeSeek(Duration position) => super.seekTo(position);

  @override
  Future<void> seekTo(Duration moment) => _seeks.seekTo(moment);
}
