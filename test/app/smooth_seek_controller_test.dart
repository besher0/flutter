import 'package:coursaty_student_and_teacher/app/widgets/smooth_seek_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SeekCoalescer', () {
    late List<Duration> nativeSeeks;
    late SeekCoalescer seeks;

    setUp(() {
      nativeSeeks = [];
      seeks = SeekCoalescer(
        (position) async => nativeSeeks.add(position),
        minInterval: const Duration(milliseconds: 200),
      );
    });

    test('a single seek (a tap or a skip button) runs at once', () async {
      await seeks.seekTo(const Duration(seconds: 42));
      expect(nativeSeeks, [const Duration(seconds: 42)]);
    });

    test('a drag burst becomes two seeks ending where the finger stopped', () async {
      // 60 drag updates arrive faster than the player could seek.
      final done = [
        for (var i = 1; i <= 60; i++) seeks.seekTo(Duration(seconds: i)),
      ];
      await Future.wait(done);

      expect(nativeSeeks, [
        const Duration(seconds: 1),
        const Duration(seconds: 60),
      ]);
    });

    test('the next seek waits for the minimum interval', () async {
      final watch = Stopwatch()..start();
      final first = seeks.seekTo(const Duration(seconds: 1));
      await first;
      final second = seeks.seekTo(const Duration(seconds: 2));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(nativeSeeks, [const Duration(seconds: 1)]);

      await second;
      expect(nativeSeeks.last, const Duration(seconds: 2));
      expect(watch.elapsed, greaterThanOrEqualTo(const Duration(milliseconds: 190)));
    });

    test('a failed seek reaches the caller and does not block later seeks', () async {
      var fail = true;
      final failing = SeekCoalescer(
        (position) async {
          if (fail) throw StateError('not initialized');
          nativeSeeks.add(position);
        },
        minInterval: Duration.zero,
      );

      await expectLater(
        failing.seekTo(const Duration(seconds: 5)),
        throwsStateError,
      );
      fail = false;
      await failing.seekTo(const Duration(seconds: 6));
      expect(nativeSeeks, [const Duration(seconds: 6)]);
    });
  });
}
