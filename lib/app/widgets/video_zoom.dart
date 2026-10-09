import 'dart:io';
import 'dart:math' as math;

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';

/// Pinch-to-zoom state for the video picture.
///
/// [offset] is a translation expressed as a fraction of the viewport, so the
/// same zoom maps correctly onto the inline player and the (larger)
/// full-screen player. With `scale = s`, each offset component is clamped to
/// `[1 - s, 0]`, which keeps the zoomed picture covering the viewport.
@immutable
class VideoZoom {
  const VideoZoom({this.scale = 1, this.offset = Offset.zero});

  static const identity = VideoZoom();

  final double scale;
  final Offset offset;

  bool get isZoomed => scale > 1;

  @override
  bool operator ==(Object other) =>
      other is VideoZoom && other.scale == scale && other.offset == offset;

  @override
  int get hashCode => Object.hash(scale, offset);
}

class VideoZoomController extends ValueNotifier<VideoZoom> {
  VideoZoomController({this.maxScale = 4}) : super(VideoZoom.identity);

  /// The zoom copy is drawn from the player's video texture, which is how
  /// better_player renders on Android. On iOS it renders through a platform
  /// view (UiKitView) that cannot be redrawn this way, so zoom is Android only.
  static bool get isSupported => Platform.isAndroid;

  final double maxScale;

  /// Below this scale a gesture snaps back to the unzoomed picture.
  static const double snapBackScale = 1.05;

  double _startScale = 1;
  Offset _startOffset = Offset.zero;
  Offset _startFocal = Offset.zero;

  void reset() => value = VideoZoom.identity;

  /// [normalizedFocal] is the focal point divided by the viewport size.
  void startGesture(Offset normalizedFocal) {
    _startScale = value.scale;
    _startOffset = value.offset;
    _startFocal = normalizedFocal;
  }

  void updateGesture({
    required double gestureScale,
    required Offset normalizedFocal,
  }) {
    final scale = (_startScale * gestureScale).clamp(1.0, maxScale);
    // Keep the picture point that was under the fingers at the start under
    // the (possibly moved) fingers now.
    final picturePoint = (_startFocal - _startOffset) / _startScale;
    final offset = normalizedFocal - picturePoint * scale;
    value = VideoZoom(scale: scale, offset: _clampOffset(offset, scale));
  }

  void endGesture() {
    if (value.scale < snapBackScale) reset();
  }

  static Offset _clampOffset(Offset offset, double scale) {
    final min = 1 - scale;
    return Offset(
      offset.dx.clamp(min, 0.0).toDouble(),
      offset.dy.clamp(min, 0.0).toDouble(),
    );
  }
}

/// Wraps the player (inline or full screen) and turns pinch / pan gestures
/// into [VideoZoomController] updates. Single-finger drags only pan while the
/// picture is zoomed, so taps, the seek bar and page scrolling keep working.
class VideoZoomGestureLayer extends StatelessWidget {
  const VideoZoomGestureLayer({
    super.key,
    required this.controller,
    required this.child,
  });

  final VideoZoomController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        Offset normalize(Offset point) => size.isEmpty
            ? Offset.zero
            : Offset(point.dx / size.width, point.dy / size.height);

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onScaleStart: (details) =>
              controller.startGesture(normalize(details.localFocalPoint)),
          onScaleUpdate: (details) {
            if (details.pointerCount < 2 && !controller.value.isZoomed) return;
            controller.updateGesture(
              gestureScale: details.pointerCount < 2 ? 1 : details.scale,
              normalizedFocal: normalize(details.localFocalPoint),
            );
          },
          onScaleEnd: (_) => controller.endGesture(),
          child: child,
        );
      },
    );
  }
}

/// Drawn through `BetterPlayerConfiguration.overlay`, i.e. above the video
/// layer and below the controls. While zoomed it paints a transformed copy of
/// the video texture over the original picture; the controls stay unscaled.
class VideoZoomOverlay extends StatelessWidget {
  const VideoZoomOverlay({super.key, required this.zoomController});

  final VideoZoomController zoomController;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ValueListenableBuilder<VideoZoom>(
        valueListenable: zoomController,
        builder: (context, zoom, _) {
          // Same provider in the inline and the full-screen player.
          final video = BetterPlayerController.of(
            context,
          ).videoPlayerController;
          // better_player_plus marks textureId @visibleForTesting, but it is
          // exactly what its Android view renders (`Texture(textureId)`) and
          // there is no public alternative. Pinned by pubspec.lock (1.2.1).
          // ignore: invalid_use_of_visible_for_testing_member
          final textureId = video?.textureId;
          final videoSize = video?.value.size;
          if (!zoom.isZoomed ||
              textureId == null ||
              videoSize == null ||
              videoSize.isEmpty) {
            return const SizedBox.shrink();
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final viewport = constraints.biggest;
              final transform = Matrix4.identity()
                ..translateByDouble(
                  zoom.offset.dx * viewport.width,
                  zoom.offset.dy * viewport.height,
                  0,
                  1,
                )
                ..scaleByDouble(zoom.scale, zoom.scale, 1, 1);
              return ColoredBox(
                color: Colors.black,
                child: ClipRect(
                  child: Transform(
                    transform: transform,
                    // Same fit as the player's own video layer (BoxFit.contain).
                    child: SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: math.max(1, videoSize.width),
                          height: math.max(1, videoSize.height),
                          child: Texture(textureId: textureId),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
