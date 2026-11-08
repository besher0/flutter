import 'dart:async';
import 'dart:io';

import 'package:coursaty_student_and_teacher/app/widgets/coursaty_button.dart';
import 'package:coursaty_student_and_teacher/app/widgets/skeleton/skeleton.dart';
import 'package:coursaty_student_and_teacher/core/error/failures.dart';
import 'package:coursaty_student_and_teacher/features/home/presentation/pages/subscription_interests_tab.dart';
import 'package:coursaty_student_and_teacher/features/home/presentation/widgets/home_skeletons.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/data/models/course_interest_model.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/domain/repositories/subscriptions_repository.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/domain/usecases/create_course_interest_usecase.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/domain/usecases/get_course_interests_usecase.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/domain/usecases/get_course_payment_info_usecase.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/domain/usecases/remove_course_interest_usecase.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/domain/usecases/submit_subscription_receipt_usecase.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/presentation/bloc/subscription_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Interests come from [next], completed by the test.
class _InterestsRepositoryFake implements SubscriptionsRepository {
  Completer<Either<Failure, List<CourseInterest>>> next = Completer();

  @override
  Future<Either<Failure, List<CourseInterest>>> getInterests() => next.future;

  @override
  Future<Either<Failure, CourseInterest>> createInterest(
    String courseId,
    InterestSource source,
  ) => throw UnimplementedError();

  @override
  Future<Either<Failure, CoursePaymentInfo>> getCoursePaymentInfo(
    String courseId,
  ) => throw UnimplementedError();

  @override
  Future<Either<Failure, bool>> removeInterest(String courseId) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, SubscriptionRequestSummary>> submitReceipt({
    required String courseId,
    required File file,
    String? note,
    void Function(int sent, int total)? onSendProgress,
  }) => throw UnimplementedError();
}

Widget _host(Widget child, {bool reduceMotion = false}) => ScreenUtilInit(
  designSize: const Size(375, 812),
  builder: (_, _) => MaterialApp(
    builder: (context, app) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
      child: app!,
    ),
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(body: child),
    ),
  ),
);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('skeleton primitives', () {
    testWidgets('bones shimmer, and are static when motion is reduced', (
      tester,
    ) async {
      Widget skeleton() => const AppShimmer(
        child: Column(
          children: [
            SkeletonBox(width: 100, height: 20),
            SkeletonBox(width: 60, height: 20),
          ],
        ),
      );

      await tester.pumpWidget(_host(skeleton()));
      final bones = tester.allRenderObjects
          .whereType<RenderSkeletonBone>()
          .toList();
      expect(bones, hasLength(2));
      expect(bones.every((b) => b.isAnimated), isTrue);
      // One loading label for the whole skeleton, not one per bone.
      expect(find.bySemanticsLabel('جاري التحميل'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(_host(skeleton(), reduceMotion: true));
      final staticBones = tester.allRenderObjects
          .whereType<RenderSkeletonBone>()
          .toList();
      expect(staticBones, hasLength(2));
      expect(staticBones.every((b) => !b.isAnimated), isTrue);
    });

    testWidgets('text and chip bones take the real widgets\' sizes', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SkeletonText(fontSize: 20, width: 120),
                SkeletonText(fontSize: 14, lineHeight: 1.8, lines: 3),
                SkeletonChip(),
              ],
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byType(SkeletonText).first).height, 28);
      expect(
        tester.getSize(find.byType(SkeletonText).last).height,
        14 * 1.8 * 3,
      );
      expect(tester.getSize(find.byType(SkeletonChip)), const Size(72, 30));
    });
  });

  group('async buttons', () {
    testWidgets('loading keeps the label and size, shows a spinner, ignores '
        'taps', (tester) async {
      var taps = 0;
      Widget button(bool loading) => Padding(
        padding: const EdgeInsets.all(16),
        child: CoursatyPrimaryButton(
          label: 'حفظ',
          isLoading: loading,
          onPressed: () => taps++,
        ),
      );

      await tester.pumpWidget(_host(button(false)));
      final idleSize = tester.getSize(find.byType(CoursatyPrimaryButton));
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.pumpWidget(_host(button(true)));
      expect(find.text('حفظ'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.getSize(find.byType(CoursatyPrimaryButton)), idleSize);
      await tester.tap(find.byType(CoursatyPrimaryButton));
      expect(taps, 0);

      // Back to idle (success or failure): taps work again.
      await tester.pumpWidget(_host(button(false)));
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await tester.tap(find.byType(CoursatyPrimaryButton));
      expect(taps, 1);
      await tester.pump(kButtonTapCooldown);
    });

    testWidgets('a quick double tap sends the action once', (tester) async {
      var primaryTaps = 0;
      var secondaryTaps = 0;
      await tester.pumpWidget(
        _host(
          Column(
            children: [
              CoursatyPrimaryButton(
                label: 'اشترك',
                onPressed: () => primaryTaps++,
              ),
              CoursatySecondaryButton(
                label: 'حفظ في اهتماماتي',
                onPressed: () => secondaryTaps++,
              ),
            ],
          ),
        ),
      );

      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byType(CoursatyPrimaryButton));
        await tester.tap(find.byType(CoursatySecondaryButton));
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(primaryTaps, 1);
      expect(secondaryTaps, 1);

      await tester.pump(kButtonTapCooldown);
      await tester.tap(find.byType(CoursatyPrimaryButton));
      expect(primaryTaps, 2);
      await tester.pump(kButtonTapCooldown);
    });
  });

  group('interests tab (bloc driven)', () {
    late _InterestsRepositoryFake repository;
    late SubscriptionBloc bloc;

    const interest = CourseInterest(
      id: 'interest-1',
      courseId: 'course-1',
      source: InterestSource.manual,
      course: CoursePaymentInfo(id: 'course-1', name: 'البرمجة'),
    );

    // Built inside each test body so the bloc runs in the test's fake-async
    // zone (pump then flushes its events).
    Widget tab() {
      repository = _InterestsRepositoryFake();
      bloc = SubscriptionBloc(
        GetCourseInterestsUsecase(repository),
        GetCoursePaymentInfoUsecase(repository),
        CreateCourseInterestUsecase(repository),
        RemoveCourseInterestUsecase(repository),
        SubmitSubscriptionReceiptUsecase(repository),
      );
      addTearDown(bloc.close);
      return _host(
        BlocProvider.value(value: bloc, child: const InterestsTab()),
      );
    }

    testWidgets('skeleton on every load (also a refresh), then content', (
      tester,
    ) async {
      // Wide enough for the test font (Ahem) in the real card.
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(tab());
      bloc.add(LoadCourseInterests());
      await tester.pump();
      await tester.pump();
      expect(find.byType(InterestListSkeleton), findsOneWidget);
      expect(find.text('البرمجة'), findsNothing);

      repository.next.complete(const Right([interest]));
      await tester.pump();
      await tester.pump();
      expect(find.byType(InterestListSkeleton), findsNothing);
      expect(find.text('البرمجة'), findsOneWidget);

      // Refresh: the skeleton shows again until the new list arrives.
      repository.next = Completer();
      bloc.add(LoadCourseInterests());
      await tester.pump();
      await tester.pump();
      expect(bloc.state.interestsStatus.isLoading, isTrue);
      expect(find.byType(InterestListSkeleton), findsOneWidget);
      repository.next.complete(const Right([interest]));
      await tester.pump();
      await tester.pump();
      expect(find.byType(InterestListSkeleton), findsNothing);
      expect(find.text('البرمجة'), findsOneWidget);
    });

    testWidgets('a failed first load ends the skeleton with a message', (
      tester,
    ) async {
      await tester.pumpWidget(tab());
      bloc.add(LoadCourseInterests());
      await tester.pump();
      await tester.pump();
      expect(find.byType(InterestListSkeleton), findsOneWidget);

      repository.next.complete(const Left(ServerFailure('offline')));
      await tester.pump();
      await tester.pump();
      expect(find.byType(InterestListSkeleton), findsNothing);
      expect(find.textContaining('تعذر تحميل اهتماماتك'), findsOneWidget);
    });

    testWidgets('no interests shows the empty state, not a skeleton', (
      tester,
    ) async {
      await tester.pumpWidget(tab());
      bloc.add(LoadCourseInterests());
      await tester.pump();
      repository.next.complete(const Right([]));
      await tester.pump();
      await tester.pump();
      expect(find.byType(InterestListSkeleton), findsNothing);
      expect(find.textContaining('لا توجد كورسات محفوظة'), findsOneWidget);
    });
  });
}
