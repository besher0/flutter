import 'package:coursaty_student_and_teacher/features/courses/presentation/widgets/lecture_item.dart';
import 'package:coursaty_student_and_teacher/features/study_progress/data/study_progress_store.dart';
import 'package:coursaty_student_and_teacher/features/study_progress/presentation/widgets/studied_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  String? account = 'student-1';

  StudyProgressStore newStore() =>
      StudyProgressStore(prefs: prefs, accountId: () => account);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    account = 'student-1';
  });

  group('study progress store', () {
    test('a lecture is studied only once all of its videos are', () {
      final store = newStore()..rememberLectureVideos('L1', ['v1', 'v2', 'v3']);
      store
        ..setVideoStudied('v1', true)
        ..setVideoStudied('v2', true);
      // v3 (e.g. never downloaded) is not studied yet.
      expect(store.isLectureStudied('L1'), isFalse);
      expect(store.studiedVideoCountOf('L1'), 2);
      expect(store.totalVideoCountOf('L1'), 3);

      store.setVideoStudied('v3', true);
      expect(store.isLectureStudied('L1'), isTrue);

      store.setVideoStudied('v2', false);
      expect(store.isLectureStudied('L1'), isFalse);
    });

    test('a lecture whose videos are unknown or empty is never studied', () {
      final store = newStore()..rememberLectureVideos('empty', const []);
      expect(store.isLectureStudied('unknown'), isFalse);
      expect(store.isLectureStudied('empty'), isFalse);
    });

    test('marks are kept on the device across restarts', () {
      newStore()
        ..rememberLectureVideos('L1', ['v1'])
        ..setVideoStudied('v1', true);
      final reopened = newStore();
      expect(reopened.isVideoStudied('v1'), isTrue);
      expect(reopened.isLectureStudied('L1'), isTrue);
    });

    test('each account has its own marks', () {
      final store = newStore()..setVideoStudied('v1', true);
      account = 'student-2';
      expect(store.isVideoStudied('v1'), isFalse);
      store.setVideoStudied('v9', true);
      account = 'student-1';
      expect(store.isVideoStudied('v1'), isTrue);
      expect(store.isVideoStudied('v9'), isFalse);
    });

    test('the server list overwrites; a download copy only fills a gap', () {
      final store = newStore()
        ..rememberLectureVideos('L1', ['v1', 'v2'], overwrite: false);
      expect(store.totalVideoCountOf('L1'), 2);

      // Opened online: the server's full list wins.
      store.rememberLectureVideos('L1', ['v1', 'v2', 'v3']);
      expect(store.totalVideoCountOf('L1'), 3);

      // An older download listing fewer videos does not shrink it.
      store.rememberLectureVideos('L1', ['v1'], overwrite: false);
      expect(store.totalVideoCountOf('L1'), 3);
    });

    test('a video the teacher deleted leaves the record; the lecture stays '
        'studied', () {
      final ids = ['v1', 'v2', 'v3', 'v4', 'v5', 'v6'];
      final store = newStore()..rememberLectureVideos('L1', ids);
      for (final id in ids) {
        store.setVideoStudied(id, true);
      }
      expect(store.isLectureStudied('L1'), isTrue);

      // The teacher deletes v6; the student opens the lecture online.
      store.rememberLectureVideos('L1', ids.sublist(0, 5));
      expect(store.isVideoStudied('v6'), isFalse);
      expect(store.studiedVideoCountOf('L1'), 5);
      expect(store.totalVideoCountOf('L1'), 5);
      expect(store.isLectureStudied('L1'), isTrue);
      // And it stays so after the app restarts.
      expect(newStore().isVideoStudied('v6'), isFalse);
      expect(newStore().isLectureStudied('L1'), isTrue);

      // An older download listing v6 again does not bring it back.
      store.rememberLectureVideos('L1', ids, overwrite: false);
      expect(store.totalVideoCountOf('L1'), 5);
    });

    test('a video moved to another lecture keeps its mark', () {
      final store = newStore()
        ..rememberLectureVideos('L1', ['v1', 'v2'])
        ..rememberLectureVideos('L2', ['v3'])
        ..setVideoStudied('v2', true);

      store.rememberLectureVideos('L2', ['v3', 'v2']);
      store.rememberLectureVideos('L1', ['v1']);
      expect(store.isVideoStudied('v2'), isTrue);
    });

    test('a new video makes the lecture unstudied again', () {
      final store = newStore()
        ..rememberLectureVideos('L1', ['v1'])
        ..setVideoStudied('v1', true);
      store.rememberLectureVideos('L1', ['v1', 'v2']);
      expect(store.isLectureStudied('L1'), isFalse);
      expect(store.studiedVideoCountOf('L1'), 1);
    });

    test('listeners hear only real changes', () {
      final store = newStore();
      var calls = 0;
      store.addListener(() => calls++);
      store
        ..setVideoStudied('v1', true)
        ..setVideoStudied('v1', true)
        ..rememberLectureVideos('L1', ['v1'])
        ..rememberLectureVideos('L1', ['v1']);
      expect(calls, 2);
    });
  });

  group('studied widgets', () {
    Widget host(Widget child) => ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, _) => MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: Center(child: child)),
        ),
      ),
    );

    testWidgets('the video toggle saves to the local store and animates', (
      tester,
    ) async {
      final store = newStore()..rememberLectureVideos('L1', ['v1']);
      StudyProgressStore.instanceForTesting = store;
      addTearDown(() => StudyProgressStore.instanceForTesting = null);

      await tester.pumpWidget(
        host(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              VideoStudiedToggle(videoId: 'v1'),
              LectureStudyProgress(lectureId: 'L1'),
            ],
          ),
        ),
      );
      expect(find.text('درست 0 من 1 فيديو'), findsOneWidget);

      await tester.tap(find.byType(StudiedToggle));
      await tester.pumpAndSettle();
      expect(store.isVideoStudied('v1'), isTrue);
      expect(find.text('مدروسة'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byType(StudiedToggle));
      await tester.pumpAndSettle();
      expect(store.isVideoStudied('v1'), isFalse);
      expect(find.text('درست 0 من 1 فيديو'), findsOneWidget);
    });

    testWidgets('a studied lecture shows its badge in the lecture card', (
      tester,
    ) async {
      final store = newStore()
        ..rememberLectureVideos('L1', ['v1'])
        ..setVideoStudied('v1', true);
      StudyProgressStore.instanceForTesting = store;
      addTearDown(() => StudyProgressStore.instanceForTesting = null);

      await tester.pumpWidget(
        host(
          const LectureItem(
            index: 0,
            lectureName: 'المحاضرة الأولى',
            trailing: LectureStudiedBadge(lectureId: 'L1'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('مدروسة'), findsOneWidget);

      store.setVideoStudied('v1', false);
      await tester.pumpAndSettle();
      expect(find.text('مدروسة'), findsNothing);
    });
  });
}
