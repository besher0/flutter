import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_details_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/lecture_details_model.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/downloaded_course_expiry.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/encrypted_hls_download_service.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/presentation/bloc/my_downloads_bloc.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/presentation/bloc/my_downloads_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

CourseDetailsModel _course({
  required String id,
  bool isFree = false,
  DateTime? subscriptionExpiresAt,
  DateTime? courseEndsAt,
}) => CourseDetailsModel.fromJson({
  'course': {'id': id, 'name': 'Course $id', 'isFree': isFree},
  'details': {'expiresAt': courseEndsAt?.toIso8601String()},
  'subscriptionExpiresAt': subscriptionExpiresAt?.toIso8601String(),
  'lectures': [
    {'id': 'lecture-$id'},
  ],
});

/// Downloads state holding one downloaded video for each course.
MyDownloadsState _downloads(
  Map<String, CourseDetailsModel> courses, {
  Map<String, DateTime> firstDownloads = const {},
}) => MyDownloadsState(
  courseIdToCourseDetailsReferences: courses,
  lectureIdToLectureDetailsReferences: {
    for (final id in courses.keys)
      'lecture-$id': LectureDetailsModel.fromJson({
        'course': {'imageurl': null},
        'lecture': {'id': 'lecture-$id'},
        'videos': [
          {'id': 'video-$id'},
        ],
      }),
  },
  urlToFileReferences: {
    for (final id in courses.keys) 'video-$id': 'secure-hls://video-$id',
  },
  courseIdToFirstDownloadAt: firstDownloads,
);

void main() {
  final now = DateTime(2026, 10, 16, 12);

  group('expiry rule', () {
    test('a free course stays two months after its first download', () {
      final free = _course(id: 'free', isFree: true);
      bool deleted(Duration age) => DownloadedCourseExpiry.shouldDelete(
        course: free,
        firstDownloadedAt: now.subtract(age),
        now: now,
      );

      expect(deleted(const Duration(days: 59)), isFalse);
      expect(deleted(const Duration(days: 60)), isTrue);
    });

    test('a paid course leaves when its subscription ends', () {
      bool deleted(DateTime expiresAt) => DownloadedCourseExpiry.shouldDelete(
        course: _course(id: 'paid', subscriptionExpiresAt: expiresAt),
        firstDownloadedAt: now.subtract(const Duration(days: 365)),
        now: now,
      );

      expect(deleted(now.add(const Duration(minutes: 1))), isFalse);
      expect(deleted(now), isTrue);
    });

    test('a renewal known from the server keeps the paid course', () {
      expect(
        DownloadedCourseExpiry.shouldDelete(
          course: _course(
            id: 'paid',
            subscriptionExpiresAt: now.subtract(const Duration(days: 1)),
          ),
          firstDownloadedAt: null,
          renewedSubscriptionExpiresAt: now.add(const Duration(days: 30)),
          now: now,
        ),
        isFalse,
      );
    });

    test('any course leaves once the course itself has ended', () {
      expect(
        DownloadedCourseExpiry.shouldDelete(
          course: _course(
            id: 'free',
            isFree: true,
            courseEndsAt: now.subtract(const Duration(hours: 1)),
          ),
          firstDownloadedAt: now,
          now: now,
        ),
        isTrue,
      );
    });
  });

  group('downloads bloc', () {
    var offline = false;
    setUp(() {
      HydratedBloc.storage = _MemoryStorage();
      offline = false;
      MyDownloadsBloc.isOffline = () async => offline;
    });
    Future<void> settle() =>
        Future<void>.delayed(const Duration(milliseconds: 20));

    MyDownloadsState endedSubscription() => _downloads({
      'paid': _course(
        id: 'paid',
        subscriptionExpiresAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    });

    test('online, an ended subscription waits for the server list', () async {
      final bloc = MyDownloadsBloc(_Prefs(), _FakeDownloadService());
      bloc.emit(endedSubscription());
      bloc.add(DeleteCoursesWhichAreExpired());
      await settle();
      await settle();
      expect(bloc.state.courseIdToCourseDetailsReferences, contains('paid'));

      // The list confirms no renewal.
      bloc.add(SaveCoursesInLocalEvent(const []));
      await settle();
      await settle();
      await settle();
      expect(bloc.state.courseIdToCourseDetailsReferences, isEmpty);
      await bloc.close();
    });

    test(
      'offline, an ended subscription is removed by its saved date',
      () async {
        offline = true;
        final bloc = MyDownloadsBloc(_Prefs(), _FakeDownloadService());
        bloc.emit(endedSubscription());
        bloc.add(DeleteCoursesWhichAreExpired());
        await settle();
        await settle();
        await settle();
        expect(bloc.state.courseIdToCourseDetailsReferences, isEmpty);
        await bloc.close();
      },
    );

    test('the first download date survives a restart', () {
      final state = MyDownloadsState().withDownloadedFile(
        fileUrl: 'video-1',
        localFilePath: 'secure-hls://video-1',
        courseId: 'free',
      );
      final firstDownload = state.courseIdToFirstDownloadAt['free'];
      expect(firstDownload, isNotNull);

      final restored = MyDownloadsState.fromJson(state.toJson());
      expect(restored.courseIdToFirstDownloadAt['free'], firstDownload);
      // A second download from the same course keeps the first date.
      expect(
        restored
            .withDownloadedFile(
              fileUrl: 'video-2',
              localFilePath: 'secure-hls://video-2',
              courseId: 'free',
            )
            .courseIdToFirstDownloadAt['free'],
        firstDownload,
      );
    });

    test('expired courses are removed, renewed ones are kept', () async {
      final bloc = MyDownloadsBloc(_Prefs(), _FakeDownloadService());
      final past = DateTime.now().subtract(const Duration(days: 1));
      bloc.emit(
        _downloads(
          {
            'old-free': _course(id: 'old-free', isFree: true),
            'paid-ended': _course(
              id: 'paid-ended',
              subscriptionExpiresAt: past,
            ),
            'paid-renewed': _course(
              id: 'paid-renewed',
              subscriptionExpiresAt: past,
            ),
          },
          firstDownloads: {
            'old-free': DateTime.now().subtract(const Duration(days: 61)),
          },
        ),
      );

      // The server's list of active courses shows the renewal.
      bloc.add(
        SaveCoursesInLocalEvent([
          CourseModel.fromJson({
            'id': 'paid-renewed',
            'subscriptionExpiresAt': DateTime.now()
                .add(const Duration(days: 30))
                .toIso8601String(),
          }),
        ]),
      );
      await settle();
      await settle();
      await settle();

      expect(bloc.state.courseIdToCourseDetailsReferences.keys, [
        'paid-renewed',
      ]);
      expect(
        bloc.state.courseIdToFirstDownloadAt.containsKey('old-free'),
        isFalse,
      );
      await bloc.close();
    });
  });
}

class _FakeDownloadService implements EncryptedHlsDownloadService {
  @override
  Future<void> deleteVideo(String videoId) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Prefs implements PrefsRepository {
  @override
  String? get userId => null;

  @override
  bool get isGuest => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MemoryStorage implements Storage {
  final _values = <String, dynamic>{};

  @override
  dynamic read(String key) => _values[key];

  @override
  Future<void> write(String key, dynamic value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<void> clear() async => _values.clear();

  @override
  Future<void> close() async {}
}
