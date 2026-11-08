import 'package:coursaty_student_and_teacher/app/widgets/coursaty_button.dart';
import 'package:coursaty_student_and_teacher/app/widgets/interaction/app_pressable.dart';
import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:coursaty_student_and_teacher/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/lecture_details_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/bloc/courses_bloc.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/screens/mcq_questions_screen.dart';
import 'package:coursaty_student_and_teacher/features/study_progress/data/study_progress_store.dart';
import 'package:coursaty_student_and_teacher/features/study_progress/presentation/widgets/studied_toggle.dart';
import 'package:coursaty_student_and_teacher/services/haptics/app_haptics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

/// What reached the platform: `light`, `medium`, `heavy`, `selection`
/// (Flutter's HapticFeedback) or `native:success|error|warning`.
final List<String> _played = [];

/// Whether the `coursaty/haptics` channel "exists" (Android 11+ / iOS).
bool _nativeOutcomes = true;

void _installRecorders(TestWidgetsFlutterBinding binding) {
  final messenger = binding.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
    if (call.method == 'HapticFeedback.vibrate') {
      _played.add(switch (call.arguments as String?) {
        'HapticFeedbackType.lightImpact' => 'light',
        'HapticFeedbackType.mediumImpact' => 'medium',
        'HapticFeedbackType.heavyImpact' => 'heavy',
        'HapticFeedbackType.selectionClick' => 'selection',
        final other => '$other',
      });
    }
    return null;
  });
  messenger.setMockMethodCallHandler(const MethodChannel('coursaty/haptics'), (
    call,
  ) async {
    if (!_nativeOutcomes) throw MissingPluginException();
    // Android plays taps and selections natively too (the vibration motor,
    // see AppVibration.kt); recorded like Flutter's so expectations read the
    // same on both paths.
    _played.add(switch (call.method) {
      'lightTap' => 'light',
      'selection' => 'selection',
      final outcome => 'native:$outcome',
    });
    return true;
  });
}

class _FakePrefs implements PrefsRepository {
  @override
  bool get isStudent => false;
  @override
  bool get isGuest => false;
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeAuthBloc extends Bloc<AuthEvent, AuthState> implements AuthBloc {
  _FakeAuthBloc() : super(AuthState());
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeCoursesBloc extends Bloc<CoursesEvent, CoursesState>
    implements CoursesBloc {
  _FakeCoursesBloc() : super(CoursesState());
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Widget _host(Widget child) => ScreenUtilInit(
  designSize: const Size(375, 812),
  builder: (_, _) => MaterialApp(
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(body: Center(child: child)),
    ),
  ),
);

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    AppHaptics.debugReset();
    _played.clear();
    _nativeOutcomes = true;
    _installRecorders(binding);
  });

  group('AppHaptics', () {
    testWidgets('a tap plays one light impact', (tester) async {
      AppHaptics.lightTap();
      expect(_played, isEmpty, reason: 'queued to the end of the event');
      await tester.pump();
      expect(_played, ['light']);
    });

    testWidgets('Android: taps go to the native vibration channel', (
      tester,
    ) async {
      final methods = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('coursaty/haptics'),
        (call) async {
          methods.add(call.method);
          return true;
        },
      );
      AppHaptics.lightTap();
      await tester.pump();
      AppHaptics.debugReset();
      AppHaptics.selection();
      await tester.pump();
      expect(methods, ['lightTap', 'selection']);
    });

    testWidgets('without the native channel, taps fall back to Flutter', (
      tester,
    ) async {
      _nativeOutcomes = false;
      AppHaptics.lightTap();
      await tester.pump();
      expect(_played, ['light']);
    });

    testWidgets('submit = tap + result in one event plays only the result', (
      tester,
    ) async {
      // A check button (light tap), the answer changing (selection) and the
      // validation (success) in one action: one haptic, the outcome.
      AppHaptics.lightTap();
      AppHaptics.selection();
      AppHaptics.success();
      await tester.pump(const Duration(milliseconds: 300));
      expect(_played, ['native:success']);
    });

    testWidgets('of a tap and a selection in one event, the selection wins', (
      tester,
    ) async {
      AppHaptics.lightTap();
      AppHaptics.selection();
      AppHaptics.lightTap();
      await tester.pump();
      expect(_played, ['selection']);
    });

    testWidgets('no duplicates: repeated outcome, taps right after it', (
      tester,
    ) async {
      var now = DateTime(2026);
      AppHaptics.clock = () => now;

      AppHaptics.error();
      AppHaptics.error(); // a second listener / rebuild
      await tester.pump();
      expect(_played, ['native:error']);

      now = now.add(const Duration(milliseconds: 100));
      AppHaptics.selection(); // inside the quiet window: dropped
      await tester.pump();
      expect(_played, ['native:error']);

      now = now.add(const Duration(milliseconds: 400));
      AppHaptics.selection();
      AppHaptics.success();
      await tester.pump();
      expect(_played, ['native:error', 'native:success']);
    });

    testWidgets('without native notification haptics, patterns are played', (
      tester,
    ) async {
      _nativeOutcomes = false;
      AppHaptics.success();
      await tester.pump(const Duration(milliseconds: 300));
      expect(_played, ['light', 'medium']);

      _played.clear();
      AppHaptics.clock = () => DateTime.now().add(const Duration(seconds: 5));
      AppHaptics.error();
      await tester.pump(const Duration(milliseconds: 300));
      expect(_played, ['medium', 'medium', 'heavy']);
    });

    testWidgets('a newer outcome stops an older pattern', (tester) async {
      _nativeOutcomes = false;
      AppHaptics.error();
      await tester.pump(); // first pulse
      AppHaptics.success();
      await tester.pump(const Duration(milliseconds: 400));
      expect(_played, ['medium', 'light', 'medium']);
    });

    testWidgets('disabled: nothing at all', (tester) async {
      AppHaptics.enabled = false;
      AppHaptics.lightTap();
      AppHaptics.success();
      await tester.pump(const Duration(milliseconds: 300));
      expect(_played, isEmpty);
    });
  });

  group('press scale and buttons', () {
    double scaleOf(WidgetTester tester) => tester
        .widget<AnimatedScale>(
          find.descendant(
            of: find.byType(AppPressScale),
            matching: find.byType(AnimatedScale),
          ),
        )
        .scale;

    testWidgets('scales down while pressed, restores and acts once on '
        'release, with one light haptic', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(CoursatyPrimaryButton(label: 'حفظ', onPressed: () => taps++)),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(CoursatyPrimaryButton)),
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(scaleOf(tester), PressScale.button);
      expect(taps, 0, reason: 'nothing runs on touch down');

      await gesture.up();
      await tester.pump();
      expect(scaleOf(tester), 1);
      expect(taps, 1);
      expect(_played, ['light']);
      await tester.pump(kButtonTapCooldown);
    });

    testWidgets('a cancelled touch restores without acting or vibrating', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(CoursatyPrimaryButton(label: 'حفظ', onPressed: () => taps++)),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(CoursatyPrimaryButton)),
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(scaleOf(tester), PressScale.button);

      // Finger slides away like a scroll, then lifts elsewhere.
      await gesture.moveBy(const Offset(0, 200));
      await tester.pump();
      expect(scaleOf(tester), 1);
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 200));
      expect(taps, 0);
      expect(_played, isEmpty);
    });

    testWidgets('disabled and loading buttons neither scale nor vibrate', (
      tester,
    ) async {
      var taps = 0;
      for (final button in [
        const CoursatyPrimaryButton(label: 'حفظ', onPressed: null),
        CoursatyPrimaryButton(
          label: 'حفظ',
          isLoading: true,
          onPressed: () => taps++,
        ),
      ]) {
        await tester.pumpWidget(_host(button));
        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(CoursatyPrimaryButton)),
        );
        await tester.pump(const Duration(milliseconds: 50));
        expect(scaleOf(tester), 1);
        await gesture.up();
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(taps, 0);
      expect(_played, isEmpty);
    });

    testWidgets('reduced motion: no scale, the action still works', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: _host(
            CoursatyPrimaryButton(label: 'حفظ', onPressed: () => taps++),
          ),
        ),
      );
      expect(find.byType(AnimatedScale), findsNothing);
      await tester.tap(find.byType(CoursatyPrimaryButton));
      await tester.pump(kButtonTapCooldown);
      expect(taps, 1);
    });
  });

  group('video studied toggle', () {
    testWidgets('marking plays success, clearing plays error, opening a '
        'studied video plays nothing', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = StudyProgressStore(prefs: prefs, accountId: () => 'a1')
        ..setVideoStudied('v2', true);
      StudyProgressStore.instanceForTesting = store;
      addTearDown(() => StudyProgressStore.instanceForTesting = null);

      // Restoring an already studied mark is silent.
      await tester.pumpWidget(_host(const VideoStudiedToggle(videoId: 'v2')));
      await tester.pump(const Duration(milliseconds: 800));
      expect(_played, isEmpty);

      await tester.pumpWidget(_host(const VideoStudiedToggle(videoId: 'v1')));
      await tester.tap(find.byType(StudiedToggle));
      await tester.pump(const Duration(milliseconds: 800));
      expect(store.isVideoStudied('v1'), isTrue);
      expect(_played, ['native:success']);

      await tester.tap(find.byType(StudiedToggle));
      await tester.pump(const Duration(milliseconds: 800));
      expect(store.isVideoStudied('v1'), isFalse);
      expect(_played, ['native:success', 'native:error']);
    });
  });

  group('MCQ feedback', () {
    late _FakeCoursesBloc courses;
    late _FakeAuthBloc auth;

    QuestionModel question(String id) => QuestionModel(
      id: id,
      questionText: 'سؤال $id',
      options: [
        Option(id: '$id-a', optionText: 'صح', isCorrect: true),
        Option(id: '$id-b', optionText: 'خطأ', isCorrect: false),
      ],
    );

    Future<void> pumpMcq(WidgetTester tester, List<QuestionModel> qs) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      GetIt.I.registerSingleton<PrefsRepository>(_FakePrefs());
      addTearDown(() => GetIt.I.unregister<PrefsRepository>());
      courses = _FakeCoursesBloc();
      auth = _FakeAuthBloc();
      addTearDown(courses.close);
      addTearDown(auth.close);
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<CoursesBloc>.value(value: courses),
            BlocProvider<AuthBloc>.value(value: auth),
          ],
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (_, _) => MaterialApp(
              home: McqQuestionsScreen(
                questions: qs,
                courseId: 'c1',
                fromNetwork: false,
                lectureDetailsModelFromDownload: LectureDetailsModel(
                  questions: qs,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('selecting plays a selection; re-selecting the same answer '
        'plays nothing', (tester) async {
      await pumpMcq(tester, [question('q1')]);
      await tester.tap(find.text('خطأ'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(_played, ['selection']);

      await tester.tap(find.text('خطأ'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(_played, ['selection']);
    });

    testWidgets('check: one success for a right answer, one error for a '
        'wrong one, nothing when checked again', (tester) async {
      await pumpMcq(tester, [question('q1')]);

      await tester.tap(find.text('صح'));
      await tester.pump(const Duration(milliseconds: 300));
      _played.clear();
      await tester.tap(find.text('فحص'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(_played, ['native:success']);

      // Checking the already checked question again: no repeat.
      await tester.tap(find.text('فحص'));
      await tester.pump(const Duration(milliseconds: 500));
      expect(_played, ['native:success']);

      // Reset, choose the wrong answer, check: error only.
      await tester.tap(find.text('إعادة'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('خطأ'));
      await tester.pump(const Duration(milliseconds: 500));
      _played.clear();
      await tester.tap(find.text('فحص'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(_played, ['native:error']);
    });

    testWidgets('check all: mixed results give one warning', (tester) async {
      await pumpMcq(tester, [question('q1'), question('q2')]);
      await tester.tap(find.text('صح').first);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('خطأ').last);
      await tester.pump(const Duration(milliseconds: 500));
      _played.clear();
      await tester.tap(find.text('فحص جميع الإجابات'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(_played, ['native:warning']);
    });
  });
}
