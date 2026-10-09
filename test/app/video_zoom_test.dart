import 'package:coursaty_student_and_teacher/app/widgets/video_zoom.dart';
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
  });
}
