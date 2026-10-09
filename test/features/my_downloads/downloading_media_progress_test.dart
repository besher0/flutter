import 'dart:async';

import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_details_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/lecture_details_model.dart'
    as lecture;
import 'package:coursaty_student_and_teacher/features/my_downloads/data/models/secure_video_models.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/encrypted_hls_download_service.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/presentation/bloc/downloading_media/downloading_media_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (_) async => '/tmp',
        );
  });

  test('video download exposes status and progress while it runs', () async {
    final downloads = _ControlledDownload();
    final bloc = DownloadingMediaBloc(_Prefs(), downloads, Dio());
    final states = <DownloadingMediaState>[];
    final sub = bloc.stream.listen(states.add);

    bloc.add(
      DownloadFileEvent(
        fileUrl: 'video-1',
        downloadUrl: 'video-1',
        fileType: 'video',
        quality: '720p',
        courseId: 'course-1',
        lectureId: 'lecture-1',
        courseDetailsModel: CourseDetailsModel(course: Course(id: 'course-1')),
        lectureDetailsModel: lecture.LectureDetailsModel(
          lecture: lecture.Lecture(id: 'lecture-1'),
        ),
      ),
    );
    await downloads.started.future;
    await pumpEventQueue();

    expect(bloc.state.downloadingStatus['video-1'], isTrue);

    downloads.report(40);
    await pumpEventQueue();
    expect(bloc.state.downloadingProcesses['video-1'], 40);
    expect(bloc.state.downloadingStatus['video-1'], isTrue);

    await sub.cancel();
  });
}

class _ControlledDownload implements EncryptedHlsDownloadService {
  final started = Completer<void>();
  final finished = Completer<DownloadedVideoManifest>();
  SecureVideoProgress? _onProgress;

  void report(double value) => _onProgress?.call(value);

  @override
  Future<void> cleanupLegacyPlaintextDownloads() async {}

  @override
  Future<DownloadedVideoManifest> download({
    required String videoId,
    required String courseId,
    required String lectureId,
    required String preferredResolution,
    required SecureVideoProgress onProgress,
    CancelToken? cancelToken,
  }) {
    _onProgress = onProgress;
    started.complete();
    return finished.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Prefs implements PrefsRepository {
  @override
  bool get isGuest => false;

  @override
  bool get isTeacher => false;

  @override
  String? get token => 'jwt';

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
