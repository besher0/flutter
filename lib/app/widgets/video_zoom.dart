import 'dart:io';

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

  /// better_player renders through a Flutter texture on Android, which scales
  /// cleanly. On iOS it renders through a platform view (UiKitView), so zoom
  /// is Android only.
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
/// A double tap resets a zoomed picture (only then, so it never delays the
/// player's own taps).
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

        return ValueListenableBuilder<VideoZoom>(
          valueListenable: controller,
          child: child,
          builder: (context, zoom, child) => GestureDetector(
            behavior: HitTestBehavior.translucent,
            onDoubleTap: zoom.isZoomed ? controller.reset : null,
            onScaleStart: (details) =>
                controller.startGesture(normalize(details.localFocalPoint)),
            onScaleUpdate: (details) {
              if (details.pointerCount < 2 && !controller.value.isZoomed) {
                return;
              }
              controller.updateGesture(
                gestureScale: details.pointerCount < 2 ? 1 : details.scale,
                normalizedFocal: normalize(details.localFocalPoint),
              );
            },
            onScaleEnd: (_) => controller.endGesture(),
            child: child,
          ),
        );
      },
    );
  }
}

/// Scales and pans the player itself while zoomed: a single video texture is
/// on screen.
///
/// ⚠️ The zoom used to paint a second, transformed `Texture` of the player's
/// texture id over the picture. Sampling one video texture twice per frame
/// made Android's renderer tear the picture into black, stair-stepped blocks
/// while pinching. The player's controls would be scaled too, so the player
/// hides them while zoomed.
///
/// The child keeps the same place in the tree whether zoomed or not (identity
/// transform at 1x), so the player is never rebuilt by a zoom change.
class VideoZoomTransform extends StatelessWidget {
  const VideoZoomTransform({
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
        final viewport = constraints.biggest;
        return ValueListenableBuilder<VideoZoom>(
          valueListenable: controller,
          child: child,
          builder: (context, zoom, player) => ClipRect(
            child: Transform(
              transform: zoomTransform(zoom, viewport),
              child: player,
            ),
          ),
        );
      },
    );
  }

  /// Translation then scale, with the offset given as a fraction of [viewport].
  @visibleForTesting
  static Matrix4 zoomTransform(VideoZoom zoom, Size viewport) {
    if (!zoom.isZoomed || !viewport.isFinite) return Matrix4.identity();
    return Matrix4.identity()
      ..translateByDouble(
        zoom.offset.dx * viewport.width,
        zoom.offset.dy * viewport.height,
        0,
        1,
      )
      ..scaleByDouble(zoom.scale, zoom.scale, 1, 1);
  }
}

/// Shown while zoomed, above the zoomed picture and unscaled: the player's own
/// controls are hidden then, and pinching out is not obvious to everyone.
class VideoZoomResetButton extends StatelessWidget {
  const VideoZoomResetButton({super.key, required this.controller});

  final VideoZoomController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoZoom>(
      valueListenable: controller,
      builder: (context, zoom, _) => zoom.isZoomed
          ? Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: IconButton(
                tooltip: 'إلغاء التكبير',
                icon: const Icon(Icons.zoom_out, color: Colors.white),
                onPressed: controller.reset,
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
