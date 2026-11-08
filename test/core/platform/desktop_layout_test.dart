import 'package:coursaty_student_and_teacher/app/widgets/adaptive_card_row.dart';
import 'package:coursaty_student_and_teacher/core/platform/app_layout.dart';
import 'package:coursaty_student_and_teacher/core/platform/app_platform.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  group('AppPlatform', () {
    test('Windows is desktop and skips the phone-only services', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      expect(AppPlatform.isWindows, isTrue);
      expect(AppPlatform.isDesktop, isTrue);
      expect(AppPlatform.isMobile, isFalse);
      expect(AppPlatform.hasFirebase, isFalse);
    });

    test('Android and iOS keep Firebase and the phone layout', () {
      for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
        debugDefaultTargetPlatformOverride = platform;
        expect(AppPlatform.isMobile, isTrue, reason: '$platform');
        expect(AppPlatform.isDesktop, isFalse, reason: '$platform');
        expect(AppPlatform.hasFirebase, isTrue, reason: '$platform');
      }
    });
  });

  group('AppLayout', () {
    test('content width is capped, height kept', () {
      expect(
        AppLayout.contentSize(const Size(1920, 1000)),
        const Size(AppLayout.maxContentWidth, 1000),
      );
      expect(
        AppLayout.contentSize(const Size(1100, 700)),
        const Size(1100, 700),
      );
    });

    test('mouse drag: horizontal rows on desktop only, never app-wide', () {
      // App-wide mouse drag swallowed clicks on the desktop video controls
      // inside scrolling pages.
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      expect(
        const AppScrollBehavior().dragDevices,
        isNot(contains(PointerDeviceKind.mouse)),
      );
      expect(
        const HorizontalDragScrollBehavior().dragDevices,
        contains(PointerDeviceKind.mouse),
      );
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(
        const HorizontalDragScrollBehavior().dragDevices,
        isNot(contains(PointerDeviceKind.mouse)),
      );
    });
  });

  group('AdaptiveCardRow', () {
    Widget row() => MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: AdaptiveCardRow(
            height: 130,
            itemCount: 5,
            itemBuilder: (_, i) => SizedBox(width: 200, child: Text('card $i')),
          ),
        ),
      ),
    );

    testWidgets('phone: one horizontal list, as before', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(row());
      expect(find.byType(Wrap), findsNothing);
      final list = tester.widget<ListView>(find.byType(ListView));
      expect(list.scrollDirection, Axis.horizontal);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('wide desktop window: every card shown in a wrapping grid', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(row());
      expect(find.byType(Wrap), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
      for (var i = 0; i < 5; i++) {
        expect(find.text('card $i'), findsOneWidget);
      }
      // Cards keep the phone list's height minus its vertical padding.
      expect(tester.getSize(find.text('card 0').first).height, lessThan(130));
      debugDefaultTargetPlatformOverride = null;
    });
  });
}
