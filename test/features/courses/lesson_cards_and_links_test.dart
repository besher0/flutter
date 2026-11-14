import 'package:coursaty_student_and_teacher/app/widgets/tint_chip.dart';
import 'package:coursaty_student_and_teacher/core/common/helper/content_links.dart';
import 'package:coursaty_student_and_teacher/core/theme/app_theme.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/widgets/lecture_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('lesson and video length', () {
    test('under a minute shows one minute', () {
      expect(formatStudyDuration(20), '1 د');
      expect(formatStudyDuration(59), '1 د');
    });

    test('minutes, whole hours, hours and minutes', () {
      expect(formatStudyDuration(30 * 60), '30 د');
      expect(formatStudyDuration(3600), '1 ساعة');
      expect(formatStudyDuration(14 * 3600 + 4 * 60), '14 ساعة و4 د');
    });

    test('no length shows no chip', () {
      expect(formatStudyDuration(null), isNull);
      expect(formatStudyDuration(0), isNull);
    });
  });

  group('page links', () {
    test('course link', () {
      expect(
        ContentLinks.course('c1'),
        'https://coursay.duckdns.org/course?cid=c1',
      );
    });

    test('lesson link encodes the name and marks free courses', () {
      final link = ContentLinks.lecture(
        lectureId: 'l1',
        lectureName: 'الدرس 1/2',
        courseId: 'c1',
        isCourseFree: true,
      );
      final uri = Uri.parse(link);
      expect(uri.pathSegments, ['lecture']);
      expect(uri.queryParameters['lid'], 'l1');
      expect(uri.queryParameters['name'], 'الدرس 1/2');
      expect(uri.queryParameters['cid'], 'c1');
      expect(uri.queryParameters['fc'], isNotNull);
      expect(
        Uri.parse(
          ContentLinks.lecture(
            lectureId: 'l1',
            lectureName: 'x',
            courseId: 'c1',
          ),
        ).queryParameters.containsKey('fc'),
        isFalse,
      );
    });
  });

  // The lesson grid gives each card a fixed height (width / 3 on a phone).
  for (final size in const [Size(320, 640), Size(430, 932)]) {
    testWidgets('a lesson card with two-line name and chips fits its cell '
        'at ${size.width.toInt()}w', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, _) => MaterialApp(
            theme: AppTheme.light,
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: GridView.count(
                  crossAxisCount: 1,
                  childAspectRatio: 3.h,
                  padding: const EdgeInsets.all(16),
                  children: const [
                    LectureItem(
                      index: 0,
                      lectureName:
                          'درس طويل الاسم جداً ليأخذ سطرين كاملين في البطاقة',
                      videosCount: 12,
                      videosDurationSeconds: 14 * 3600 + 4 * 60,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('12 فيديو'), findsOneWidget);
      expect(find.text('14 ساعة و4 د'), findsOneWidget);
    });
  }
}
