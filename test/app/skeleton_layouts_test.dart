import 'package:coursaty_student_and_teacher/core/theme/app_theme.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/widgets/course_skeletons.dart';
import 'package:coursaty_student_and_teacher/features/home/presentation/widgets/home_skeletons.dart';
import 'package:coursaty_student_and_teacher/features/norifications/presentation/widgets/notifications_skeletons.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/presentation/widgets/payment_skeleton.dart';
import 'package:coursaty_student_and_teacher/features/teachers/presentation/widgets/teachers_skeletons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Every screen skeleton lays out without overflow on a small and a large
/// phone, in the light and the dark theme, right to left.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  final skeletons = <String, Widget Function()>{
    'home': () => const HomeContentSkeleton(),
    'subjects': () => const SubjectsScreenSkeleton(),
    'subject list': () => const SubjectListSkeleton(),
    'teacher home': () => const TeacherHomeSkeleton(),
    'subscriptions': () => const SubscriptionListSkeleton(),
    'interests': () => const InterestListSkeleton(),
    'course list': () => const CourseListSkeleton(),
    'courses by year': () => const CoursesByYearSectionsSkeleton(),
    'course details header': () => const CourseDetailsHeaderSkeleton(),
    'course details tab': () => const CourseDetailsTabSkeleton(),
    'lecture list': () => const LectureListSkeleton(childAspectRatio: 3),
    'lecture details header': () => const LectureDetailsHeaderSkeleton(),
    'content list': () => const ContentListSkeleton(),
    'mcq tab': () => const McqTabSkeleton(),
    'course form': () => const CourseFormSkeleton(),
    'teacher lectures': () => const TeacherLectureListSkeleton(),
    'teachers grid': () => const TeachersGridSkeleton(),
    'teacher detail': () => const TeacherDetailSkeleton(),
    'revenue': () => const RevenueReportSkeleton(),
    'withdrawals': () => const WithdrawalsSkeleton(),
    'affiliations': () => const AffiliationListSkeleton(),
    'notifications': () => const NotificationListSkeleton(),
    'payment': () => const PaymentPageSkeleton(),
  };

  for (final size in const [Size(320, 640), Size(430, 932)]) {
    for (final dark in const [false, true]) {
      testWidgets('skeletons lay out at ${size.width.toInt()}w '
          '${dark ? 'dark' : 'light'}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        for (final entry in skeletons.entries) {
          await tester.pumpWidget(
            ScreenUtilInit(
              designSize: const Size(375, 812),
              builder: (_, _) => MaterialApp(
                theme: dark ? AppTheme.dark : AppTheme.light,
                home: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Scaffold(body: entry.value()),
                ),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 300));
          expect(
            tester.takeException(),
            isNull,
            reason: '${entry.key} skeleton threw while laying out',
          );
        }
        // Leave no running animation behind.
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}
