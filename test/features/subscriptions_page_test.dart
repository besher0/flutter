import 'dart:io';

import 'package:coursaty_student_and_teacher/core/enums/request_status.dart';
import 'package:coursaty_student_and_teacher/core/error/failures.dart';
import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:coursaty_student_and_teacher/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_model.dart';
import 'package:coursaty_student_and_teacher/features/home/domain/usecases/get_my_courses_usecase.dart';
import 'package:coursaty_student_and_teacher/features/home/presentation/bloc/home_bloc.dart';
import 'package:coursaty_student_and_teacher/features/home/presentation/pages/subscriptions_screen.dart';
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
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:coursaty_student_and_teacher/features/home/domain/usecases/get_advertisements_usecase.dart';
import 'package:coursaty_student_and_teacher/features/home/domain/usecases/get_home_content_usecase.dart';
import 'package:coursaty_student_and_teacher/features/home/domain/usecases/get_all_programs_usecase.dart';
import 'package:coursaty_student_and_teacher/features/home/domain/usecases/get_subjects_with_filtering_usecase.dart';
import 'package:coursaty_student_and_teacher/features/home/domain/usecases/get_teacher_summary_usecase.dart';
import 'package:coursaty_student_and_teacher/features/home/domain/usecases/search_usecase.dart';

class _FakePrefs implements PrefsRepository {
  @override
  bool get isGuest => false;
  @override
  bool get isStudent => true;
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeAuthBloc extends Bloc<AuthEvent, AuthState> implements AuthBloc {
  _FakeAuthBloc() : super(AuthState());
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Records the events the page sends; the test sets its states.
class _FakeHomeBloc extends Bloc<HomeEvent, HomeState> implements HomeBloc {
  _FakeHomeBloc(super.initial) {
    on<HomeEvent>((event, _) => events.add(event));
  }
  final events = <HomeEvent>[];
  void set(HomeState s) => emit(s);
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _UnusedGetAdvertisementsUsecase implements GetAdvertisementsUsecase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedGetHomeContentUsecase implements GetHomeContentUsecase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedGetAllProgramsUsecase implements GetAllProgramsUsecase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedGetSubjectsWithFilteringUsecase
    implements GetSubjectsWithFilteringUsecase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedGetTeacherSummaryUsecase implements GetTeacherSummaryUsecase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedSearchUsecase implements SearchUsecase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeMyCourses implements GetMyCoursesUsecase {
  @override
  Future<Either<Failure, List<CourseModel>>> call(bool active) async =>
      const Right([]);
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _InterestsRepo implements SubscriptionsRepository {
  int loads = 0;
  @override
  Future<Either<Failure, List<CourseInterest>>> getInterests() async {
    loads++;
    return const Right([]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();

  @override
  Future<Either<Failure, SubscriptionRequestSummary>> submitReceipt({
    required String courseId,
    required File file,
    String? note,
    void Function(int sent, int total)? onSendProgress,
  }) => throw UnimplementedError();
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    GetIt.I.registerSingleton<PrefsRepository>(_FakePrefs());
  });
  tearDown(() => GetIt.I.reset());

  test(
    'loading the expired list never marks the active list as loading',
    () async {
      TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('dev.fluttercommunity.plus/connectivity'),
            (_) async => ['wifi'],
          );
      final bloc = HomeBloc(
        _UnusedGetAdvertisementsUsecase(),
        _UnusedGetHomeContentUsecase(),
        getAllProgramsUsecase: _UnusedGetAllProgramsUsecase(),
        getSubjectsWithFilteringUsecase:
            _UnusedGetSubjectsWithFilteringUsecase(),
        getMyCoursesUsecase: _FakeMyCourses(),
        getTeacherSummaryUsecase: _UnusedGetTeacherSummaryUsecase(),
        searchUsecase: _UnusedSearchUsecase(),
      );
      addTearDown(bloc.close);

      final states = <HomeState>[];
      final sub = bloc.stream.listen(states.add);
      bloc.add(GetMyInActiveCourses());
      await bloc.stream.firstWhere((s) => s.getInActiveCourses.isSuccess);
      await sub.cancel();

      expect(states.any((s) => s.getActiveCourses.isLoading), isFalse);
      expect(states.first.getInActiveCourses, Status.loading);
      expect(bloc.state.getActiveCourses, Status.init);
    },
  );

  testWidgets('refresh in any tab reloads every tab, each shows its '
      'skeleton while loading and is usable after', (tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final course = CourseModel(id: 'c1', name: 'البرمجة');
    final home = _FakeHomeBloc(
      HomeState(
        activeCourses: [course],
        getActiveCourses: Status.loaded,
        getInActiveCourses: Status.loaded,
      ),
    );
    final repo = _InterestsRepo();
    final subscriptions = SubscriptionBloc(
      GetCourseInterestsUsecase(repo),
      GetCoursePaymentInfoUsecase(repo),
      CreateCourseInterestUsecase(repo),
      RemoveCourseInterestUsecase(repo),
      SubmitSubscriptionReceiptUsecase(repo),
    );
    final auth = _FakeAuthBloc();
    addTearDown(home.close);
    addTearDown(subscriptions.close);
    addTearDown(auth.close);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<HomeBloc>.value(value: home),
          BlocProvider<SubscriptionBloc>.value(value: subscriptions),
          BlocProvider<AuthBloc>.value(value: auth),
        ],
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, _) => const MaterialApp(home: SubscriptionsScreen()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(repo.loads, 1);

    // Expired tab (empty) → pull to refresh.
    await tester.tap(find.text('المنتهية'));
    await tester.pumpAndSettle();
    await tester.fling(
      find.text('لا توجد اشتراكات'),
      const Offset(0, 400),
      1000,
    );
    await tester.pumpAndSettle();
    expect(home.events.whereType<GetMyActiveCourses>(), hasLength(1));
    expect(home.events.whereType<GetMyInActiveCourses>(), hasLength(1));
    expect(repo.loads, 2, reason: 'interests reload too');

    // While both lists load, both tabs shimmer.
    home.set(
      home.state.copyWith(
        getActiveCourses: Status.loading,
        getInActiveCourses: Status.loading,
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.byType(SubscriptionListSkeleton), findsOneWidget);
    await tester.tap(find.text('الفعالة'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(SubscriptionListSkeleton), findsOneWidget);

    // Loaded: the active list is back, not covered by a busy bar, and
    // its own refresh works.
    home.set(
      home.state.copyWith(
        getActiveCourses: Status.loaded,
        getInActiveCourses: Status.loaded,
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(SubscriptionListSkeleton), findsNothing);
    expect(find.text('البرمجة'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    await tester.fling(find.text('البرمجة'), const Offset(0, 400), 1000);
    // Step through the indicator's arm and snap (images shimmer, so no
    // pumpAndSettle here).
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(home.events.whereType<GetMyActiveCourses>(), hasLength(2));
    expect(home.events.whereType<GetMyInActiveCourses>(), hasLength(2));
    expect(repo.loads, 3);
  });
}
