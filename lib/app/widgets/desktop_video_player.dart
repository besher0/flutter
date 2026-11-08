import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// Video playback on desktop (Windows), used by `MyVideoWidgetBetterPlayer`.
///
/// better_player has no desktop version; media_kit plays through libmpv
/// (bundled for Windows by `media_kit_libs_windows_video`). The phones keep
/// better_player: nothing here runs on Android or iOS.
///
/// The video widget keeps its session logic (playback session, loopback
/// proxy, renewal); this class only replaces the player itself.
class DesktopVideoPlayer {
  DesktopVideoPlayer._(this._player) : controller = VideoController(_player);

  static bool _initialized = false;

  /// Loads libmpv. Called once from `main` on desktop, before the first
  /// player is created.
  static void ensureInitialized() {
    if (_initialized) return;
    MediaKit.ensureInitialized();
    _initialized = true;
  }

  /// Opens [url] paused, like the phone player (`autoPlay: false`).
  static Future<DesktopVideoPlayer> open(
    String url, {
    Map<String, String> headers = const {},
  }) async {
    ensureInitialized();
    final instance = DesktopVideoPlayer._(
      Player(
        configuration: const PlayerConfiguration(
          title: 'Coursaty',
          // About 50 s of 1080p ahead, the same limit as the phone player.
          bufferSize: 48 * 1024 * 1024,
        ),
      ),
    );
    await instance._player.open(Media(url, httpHeaders: headers), play: false);
    return instance;
  }

  final Player _player;
  final VideoController controller;

  /// A media request failed (for example an expired session).
  Stream<String> get errors => _player.stream.error;

  /// Starts again on every play, like better_player's play event.
  Stream<bool> get playingChanges => _player.stream.playing;

  bool get isPlaying => _player.state.playing;

  /// The video's length once known (0 before the file is read).
  Stream<Duration> get durationChanges => _player.stream.duration;

  Future<void> seekTo(Duration position) => _player.seek(position);

  /// Opens [url] at the current position, speed and play state. Used after a
  /// failed request stopped playback, or if the stream URL itself changed.
  Future<void> reload(String url, Map<String, String> headers) async {
    final state = _player.state;
    final position = state.position;
    final wasPlaying = state.playing;
    final rate = state.rate;
    await _player.open(
      Media(url, httpHeaders: headers, start: position),
      play: wasPlaying,
    );
    if (rate != 1.0) await _player.setRate(rate);
  }

  Future<void> dispose() => _player.dispose();

  /// The picture with desktop controls (mouse hover, keyboard shortcuts:
  /// space, arrows, F for full screen). The controls stay left to right like
  /// any media player, also inside the Arabic layout.
  Widget view(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final theme = MaterialDesktopVideoControlsThemeData(
      // Clicks on the picture are handled by [_ClickGestures] (one click:
      // play/pause; double click: 10 s back or forward), so media_kit's own
      // tap and double-click (full screen) are off.
      playAndPauseOnTap: false,
      toggleFullscreenOnDoublePress: false,
      seekBarPositionColor: accent,
      seekBarThumbColor: accent,
      bottomButtonBar: [
        const MaterialDesktopPlayOrPauseButton(),
        // Same as the phone player's 10-second skip buttons.
        _SkipButton(player: _player, seconds: -10),
        _SkipButton(player: _player, seconds: 10),
        const MaterialDesktopVolumeButton(),
        const MaterialDesktopPositionIndicator(),
        const Spacer(),
        _SpeedButton(player: _player),
        const MaterialDesktopFullscreenButton(),
      ],
    );
    return Directionality(
      textDirection: TextDirection.ltr,
      child: MaterialDesktopVideoControlsTheme(
        normal: theme,
        fullscreen: theme,
        child: Video(
          controller: controller,
          // The same builder draws the full-screen controls, so the clicks
          // work there too.
          controls: (state) => _ClickGestures(
            player: _player,
            child: MaterialDesktopVideoControls(state),
          ),
        ),
      ),
    );
  }
}

/// Plays one local file or plain URL (no session or proxy): the upload
/// preview and the ad preview on desktop. [onDuration] reports the length
/// once the file is read.
class SimpleDesktopVideo extends StatefulWidget {
  const SimpleDesktopVideo({super.key, required this.source, this.onDuration});

  final String source;
  final ValueChanged<Duration>? onDuration;

  @override
  State<SimpleDesktopVideo> createState() => _SimpleDesktopVideoState();
}

class _SimpleDesktopVideoState extends State<SimpleDesktopVideo> {
  DesktopVideoPlayer? _player;
  StreamSubscription<Duration>? _duration;
  String? _error;

  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    try {
      final player = await DesktopVideoPlayer.open(widget.source);
      if (!mounted) {
        await player.dispose();
        return;
      }
      _duration = player.durationChanges.listen((duration) {
        if (duration > Duration.zero) widget.onDuration?.call(duration);
      });
      setState(() => _player = player);
    } catch (error) {
      if (mounted) setState(() => _error = 'تعذر تشغيل الفيديو');
    }
  }

  @override
  void dispose() {
    _duration?.cancel();
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = _player;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: player != null
            ? player.view(context)
            : ColoredBox(
                color: Colors.black,
                child: Center(
                  child: _error != null
                      ? Text(
                          _error!,
                          style: const TextStyle(color: Colors.white),
                        )
                      : const CircularProgressIndicator(),
                ),
              ),
      ),
    );
  }
}

/// Seeks [seconds] back (negative) or forward, kept within the video.
void _skip(Player player, int seconds) {
  final state = player.state;
  var target = state.position + Duration(seconds: seconds);
  if (target < Duration.zero) target = Duration.zero;
  if (state.duration > Duration.zero && target > state.duration) {
    target = state.duration;
  }
  player.seek(target);
}

/// Clicks on the picture, like the phone player's taps:
/// - one click plays or pauses;
/// - a double click on the right half jumps 10 s forward, on the left half
///   10 s back.
///
/// A [Listener] (raw pointer events) so it never competes with the controls'
/// own gestures; clicks on the bottom bar (buttons, seek bar) are ignored. A
/// single click waits [_doubleClickTime] to make sure it is not the first half
/// of a double click.
class _ClickGestures extends StatefulWidget {
  const _ClickGestures({required this.player, required this.child});

  final Player player;
  final Widget child;

  @override
  State<_ClickGestures> createState() => _ClickGesturesState();
}

class _ClickGesturesState extends State<_ClickGestures> {
  static const _doubleClickTime = Duration(milliseconds: 280);

  /// Seek bar + button bar of the desktop controls, plus a margin.
  static const _bottomBarHeight = 100.0;

  Timer? _singleClick;
  Offset? _downAt;
  Timer? _hideFeedback;
  IconData? _feedbackIcon;
  bool _feedbackOnRight = true;
  bool _feedbackCentered = true;

  bool _onPicture(Offset local, Size size) =>
      local.dy < size.height - _bottomBarHeight;

  void _onUp(PointerUpEvent event, Size size) {
    final down = _downAt;
    _downAt = null;
    if (down == null || (event.localPosition - down).distance > 8) return;
    final pending = _singleClick;
    if (pending != null && pending.isActive) {
      // Second click: a double click.
      pending.cancel();
      _singleClick = null;
      final forward = event.localPosition.dx >= size.width / 2;
      _skip(widget.player, forward ? 10 : -10);
      _showFeedback(
        forward ? Icons.forward_10 : Icons.replay_10,
        centered: false,
        right: forward,
      );
      return;
    }
    _singleClick = Timer(_doubleClickTime, () {
      _singleClick = null;
      final willPlay = !widget.player.state.playing;
      widget.player.playOrPause();
      _showFeedback(willPlay ? Icons.play_arrow : Icons.pause, centered: true);
    });
  }

  void _showFeedback(
    IconData icon, {
    required bool centered,
    bool right = true,
  }) {
    if (!mounted) return;
    _hideFeedback?.cancel();
    setState(() {
      _feedbackIcon = icon;
      _feedbackCentered = centered;
      _feedbackOnRight = right;
    });
    _hideFeedback = Timer(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _feedbackIcon = null);
    });
  }

  @override
  void dispose() {
    _singleClick?.cancel();
    _hideFeedback?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final icon = _feedbackIcon;
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (event) {
            final primary = event.buttons == kPrimaryButton;
            _downAt = primary && _onPicture(event.localPosition, size)
                ? event.localPosition
                : null;
          },
          onPointerUp: (event) => _onUp(event, size),
          child: Stack(
            fit: StackFit.expand,
            children: [
              widget.child,
              IgnorePointer(
                child: AnimatedOpacity(
                  opacity: icon == null ? 0 : 1,
                  duration: const Duration(milliseconds: 150),
                  child: Align(
                    alignment: _feedbackCentered
                        ? Alignment.center
                        : (_feedbackOnRight
                              ? const Alignment(0.6, 0)
                              : const Alignment(-0.6, 0)),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: Color(0x88000000),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon ?? Icons.play_arrow,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Jumps [seconds] back (negative) or forward, within the video.
class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.player, required this.seconds});

  final Player player;
  final int seconds;

  @override
  Widget build(BuildContext context) {
    return MaterialDesktopCustomButton(
      icon: Icon(seconds < 0 ? Icons.replay_10 : Icons.forward_10),
      onPressed: () => _skip(player, seconds),
    );
  }
}

/// Playback speed menu (the phone player's controls have one too).
///
/// ⚠️ Not a `PopupMenuButton`: it applies the choice only if the button is
/// still on screen, and the player's controls hide as soon as the mouse moves
/// onto the menu, so the chosen speed was dropped (it stayed at 1x). The menu
/// is opened here and the speed is set whatever happened to the button.
class _SpeedButton extends StatelessWidget {
  const _SpeedButton({required this.player});

  final Player player;

  static const _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  Future<void> _openMenu(BuildContext context, double current) async {
    final button = context.findRenderObject() as RenderBox?;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (button == null || overlay == null) return;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );
    final player = this.player;
    final speed = await showMenu<double>(
      context: context,
      position: position,
      initialValue: current,
      items: [
        for (final speed in _speeds)
          PopupMenuItem(value: speed, child: Text('${_label(speed)}x')),
      ],
    );
    if (speed != null) await player.setRate(speed);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: player.stream.rate,
      initialData: player.state.rate,
      builder: (context, snapshot) {
        final current = snapshot.data ?? 1.0;
        return Tooltip(
          message: 'سرعة التشغيل',
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () => _openMenu(context, current),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(
                '${_label(current)}x',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static String _label(double speed) =>
      speed == speed.roundToDouble() ? speed.toStringAsFixed(0) : '$speed';
}
