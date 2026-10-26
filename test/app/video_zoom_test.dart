import 'package:coursaty_student_and_teacher/app/widgets/video_zoom.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VideoZoomController', () {
    test('keeps the picture point under the fingers fixed while zooming', () {
      final zoom = VideoZoomController();
      const focal = Offset(0.25, 0.75);

      zoom.startGesture(focal);
      zoom.updateGesture(gestureScale: 2, normalizedFocal: focal);

      expect(zoom.value.scale, 2);
      // Picture point (0.25, 0.75) maps to 2 * p + offset; it must stay put.
      final mapped = focal * 2 + zoom.value.offset;
      expect(mapped.dx, closeTo(focal.dx, 1e-9));
      expect(mapped.dy, closeTo(focal.dy, 1e-9));
    });

    test('never lets the zoomed picture leave the viewport', () {
      final zoom = VideoZoomController();
      zoom.startGesture(const Offset(0.5, 0.5));
      zoom.updateGesture(gestureScale: 3, normalizedFocal: const Offset(0.5, 0.5));
      zoom.startGesture(const Offset(0.5, 0.5));

      // Pan far beyond the edges in both directions.
      zoom.updateGesture(gestureScale: 1, normalizedFocal: const Offset(9, 9));
      expect(zoom.value.offset, Offset.zero);
      zoom.updateGesture(gestureScale: 1, normalizedFocal: const Offset(-9, -9));
      expect(zoom.value.offset, const Offset(-2, -2)); // 1 - scale
    });

    test('clamps to the maximum scale and never below 1x', () {
      final zoom = VideoZoomController(maxScale: 4);
      zoom.startGesture(Offset.zero);
      zoom.updateGesture(gestureScale: 10, normalizedFocal: Offset.zero);
      expect(zoom.value.scale, 4);

      zoom.startGesture(Offset.zero);
      zoom.updateGesture(gestureScale: 0.01, normalizedFocal: Offset.zero);
      expect(zoom.value.scale, 1);
      expect(zoom.value.isZoomed, isFalse);
    });

    test('snaps back to 1x when released just above it', () {
      final zoom = VideoZoomController();
      zoom.startGesture(const Offset(0.5, 0.5));
      zoom.updateGesture(gestureScale: 1.03, normalizedFocal: const Offset(0.5, 0.5));
      zoom.endGesture();

      expect(zoom.value, VideoZoom.identity);
    });
  });

  group('VideoZoomGestureLayer', () {
    Future<VideoZoomController> pump(WidgetTester tester) async {
      final zoom = VideoZoomController();
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(
              width: 400,
              height: 225,
              child: VideoZoomGestureLayer(
                controller: zoom,
                child: const ColoredBox(color: Colors.black),
              ),
            ),
          ),
        ),
      );
      return zoom;
    }

    testWidgets('pinching out zooms in', (tester) async {
      final zoom = await pump(tester);
      final center = tester.getCenter(find.byType(VideoZoomGestureLayer));

      final a = await tester.startGesture(center - const Offset(20, 0));
      final b = await tester.startGesture(center + const Offset(20, 0), pointer: 2);
      await tester.pump();
      for (var i = 0; i < 10; i++) {
        await a.moveBy(const Offset(-8, 0));
        await b.moveBy(const Offset(8, 0));
        await tester.pump();
      }
      await a.up();
      await b.up();
      await tester.pump();

      expect(zoom.value.scale, greaterThan(2));
      expect(zoom.value.offset.dx, lessThan(0));
    });

    testWidgets('one finger does not zoom or pan an unzoomed picture', (tester) async {
      final zoom = await pump(tester);

      await tester.drag(find.byType(VideoZoomGestureLayer), const Offset(120, 40));
      await tester.pump();

      expect(zoom.value, VideoZoom.identity);
    });

    testWidgets('one finger pans a zoomed picture', (tester) async {
      final zoom = await pump(tester);
      zoom.value = const VideoZoom(scale: 2, offset: Offset(-0.5, -0.5));

      await tester.drag(find.byType(VideoZoomGestureLayer), const Offset(80, 0));
      await tester.pump();

      expect(zoom.value.scale, 2);
      expect(zoom.value.offset.dx, greaterThan(-0.5));
      expect(zoom.value.offset.dy, closeTo(-0.5, 1e-9));
    });

    testWidgets('a double tap resets a zoomed picture', (tester) async {
      final zoom = await pump(tester);
      zoom.value = const VideoZoom(scale: 2, offset: Offset(-0.5, -0.5));
      await tester.pump();

      final center = tester.getCenter(find.byType(VideoZoomGestureLayer));
      await tester.tapAt(center);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tapAt(center);
      await tester.pumpAndSettle();

      expect(zoom.value, VideoZoom.identity);
    });
  });

  // The zoom used to paint a second Texture of the same video over the
  // player, which tore the picture into black blocks on Android. Now the
  // player itself is transformed, and must not be rebuilt by a zoom change.
  group('VideoZoomTransform', () {
    test('translates by the viewport fraction, then scales', () {
      final m = VideoZoomTransform.zoomTransform(
        const VideoZoom(scale: 2, offset: Offset(-0.5, -0.25)),
        const Size(400, 200),
      );
      expect(MatrixUtils.transformPoint(m, Offset.zero), const Offset(-200, -50));
      expect(MatrixUtils.transformPoint(m, const Offset(100, 100)), const Offset(0, 150));
      expect(
        VideoZoomTransform.zoomTransform(VideoZoom.identity, const Size(400, 200)),
        Matrix4.identity(),
      );
    });

    testWidgets('keeps the same player while zooming and back', (tester) async {
      final zoom = VideoZoomController();
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(
              width: 400,
              height: 225,
              child: VideoZoomTransform(controller: zoom, child: const _Player()),
            ),
          ),
        ),
      );
      final state = tester.state(find.byType(_Player));

      zoom.value = const VideoZoom(scale: 3, offset: Offset(-1, -1));
      await tester.pump();
      expect(tester.state(find.byType(_Player)), same(state));
      final transform = tester.widget<Transform>(
        find.descendant(of: find.byType(VideoZoomTransform), matching: find.byType(Transform)),
      );
      expect(transform.transform.getMaxScaleOnAxis(), 3);

      zoom.reset();
      await tester.pump();
      expect(tester.state(find.byType(_Player)), same(state));
      expect(find.byType(Texture), findsNothing);
    });
  });

  // The player's controls are drawn above the zoomed picture (as in
  // MyVideoWidgetBetterPlayer._zoomable), so they keep their size and place at
  // any zoom, still take taps, and a pinch over them still zooms.
  group('controls above the zoomed picture', () {
    Future<(VideoZoomController, List<String>)> pump(WidgetTester tester) async {
      final zoom = VideoZoomController();
      final taps = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(
              width: 400,
              height: 225,
              child: VideoZoomGestureLayer(
                controller: zoom,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    VideoZoomTransform(controller: zoom, child: const _Player()),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: TextButton(
                        key: const Key('play'),
                        onPressed: () => taps.add('play'),
                        child: const Text('play'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      return (zoom, taps);
    }

    testWidgets('stay unscaled and tappable while zoomed', (tester) async {
      final (zoom, taps) = await pump(tester);
      final before = tester.getRect(find.byKey(const Key('play')));

      zoom.value = const VideoZoom(scale: 3, offset: Offset(-1, -1));
      await tester.pump();
      expect(tester.getRect(find.byKey(const Key('play'))), before);

      // While zoomed a double tap resets the zoom, so a single tap lands once
      // the double-tap window has passed (the player's controls wait for
      // their own double tap the same way).
      await tester.tap(find.byKey(const Key('play')));
      await tester.pump(kDoubleTapTimeout + const Duration(milliseconds: 50));
      expect(taps, ['play']);
      expect(zoom.value.scale, 3);
    });

    testWidgets('a pinch over the controls still zooms the picture', (tester) async {
      final (zoom, _) = await pump(tester);
      final center = tester.getCenter(find.byKey(const Key('play')));

      final a = await tester.startGesture(center - const Offset(20, 0));
      final b = await tester.startGesture(center + const Offset(20, 0), pointer: 2);
      await tester.pump();
      for (var i = 0; i < 10; i++) {
        await a.moveBy(const Offset(-8, 0));
        await b.moveBy(const Offset(8, 0));
        await tester.pump();
      }
      await a.up();
      await b.up();
      await tester.pump();

      expect(zoom.value.scale, greaterThan(2));
    });
  });
}

class _Player extends StatefulWidget {
  const _Player();

  @override
  State<_Player> createState() => _PlayerState();
}

class _PlayerState extends State<_Player> {
  @override
  Widget build(BuildContext context) => const ColoredBox(color: Colors.black);
}
