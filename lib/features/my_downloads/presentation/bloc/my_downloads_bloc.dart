import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:coursaty_student_and_teacher/core/common/helper/helper_functions.dart';
import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_details_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/lecture_details_model.dart'
    hide Lecture;
import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/downloaded_course_expiry.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/encrypted_hls_download_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable_generator/utils.dart';

import 'my_downloads_state.dart';

part 'my_downloads_event.dart';

@singleton
class MyDownloadsBloc extends HydratedBloc<MyDownloadsEvent, MyDownloadsState> {
  MyDownloadsBloc(this._prefsRepository, this._encryptedHlsDownloadService)
    : super(MyDownloadsState()) {
    on<MyDownloadsEvent>((event, emit) {});
    on<SaveCoursesInLocalEvent>(_onSaveCoursesInLocalEvent);
    on<SaveReferenceOfDownloadedFile>(_onSaveReferenceOfDownloadedFile);
    on<DeleteReferenceOfDownloadedFile>(_onDeleteReferenceOfDownloadedFile);
    on<DeleteEveryThingRelatedToCourse>(_onDeleteEveryThingRelatedToCourse);
    on<SaveCourseDetailsInLocalEvent>(_onSaveCourseDetailsInLocalEvent);
    on<SaveLectureDetailsInLocalEvent>(_onSaveLectureDetailsInLocalEvent);
    on<DeleteCoursesWhichAreExpired>(_onDeleteCoursesWhichAreExpired);
    on<SyncDownloadsOwner>(_onSyncDownloadsOwner);

    final userId = _prefsRepository.userId;
    if (!_prefsRepository.isGuest && userId != null && userId.isNotEmpty) {
      add(SyncDownloadsOwner(userId));
    }
    // Expired courses leave the device on every start, not only when the
    // downloads screen is opened.
    add(DeleteCoursesWhichAreExpired());
  }

  final PrefsRepository _prefsRepository;
  final EncryptedHlsDownloadService _encryptedHlsDownloadService;

  @override
  MyDownloadsState? fromJson(Map<String, dynamic> json) {
    return MyDownloadsState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(MyDownloadsState state) {
    return state.toJson();
  }

  FutureOr<void> _onSaveCoursesInLocalEvent(
    SaveCoursesInLocalEvent event,
    Emitter<MyDownloadsState> emit,
  ) {
    // The server's current subscription dates replace the snapshots saved
    // with the downloads, so a renewal keeps the course on the device.
    _serverCoursesFresh = true;
    final details = Map.of(state.courseIdToCourseDetailsReferences);
    for (final course in event.courses) {
      final saved = details[course.id];
      if (saved == null) continue;
      final expiresAt = DownloadedCourseExpiry.latest(
        saved.subscriptionExpiresAt,
        course.subscriptionExpiresAt,
      );
      if (expiresAt != saved.subscriptionExpiresAt) {
        details[course.id!] = saved.copyWith(subscriptionExpiresAt: expiresAt);
      }
    }
    final previous = {for (final item in state.courses) item.id: item};
    emit(
      state.copyWith(
        courseIdToCourseDetailsReferences: details,
        courses: event.courses.map((item) {
          if (!(item.isFree ?? false)) return item;
          // Keep the first date: a refreshed list must not restart it.
          return item.copyWith(
            freeCourseExpirationAt:
                previous[item.id]?.freeCourseExpirationAt ??
                item.freeCourseExpirationAt ??
                DateTime.now(),
          );
        }).toList(),
      ),
    );
    add(DeleteCoursesWhichAreExpired());
  }

  void _onSaveReferenceOfDownloadedFile(
    SaveReferenceOfDownloadedFile event,
    Emitter<MyDownloadsState> emit,
  ) {
    final nextState = state.withDownloadedFile(
      fileUrl: event.fileUrl,
      localFilePath: event.localFilePath,
      courseId: event.courseId,
      lectureId: event.lectureId,
      courseDetailsModel: event.courseDetailsModel,
      lectureDetailsModel: event.lectureDetailsModel,
    );
    debugPrint(
      '[Downloads] saved reference '
      'courseId=${event.courseId} '
      'lectureId=${event.lectureDetailsModel?.lecture?.id} '
      'courses count=${nextState.courseIdToCourseDetailsReferences.length} '
      'lectures count=${nextState.lectureIdToLectureDetailsReferences.length} '
      'references count=${nextState.urlToFileReferences.length}',
    );
    assert(
      event.courseDetailsModel?.course?.id == event.courseId,
      '[Downloads] course metadata does not match courseId',
    );
    assert(
      event.lectureDetailsModel?.lecture?.id == event.lectureId,
      '[Downloads] lecture metadata does not match lectureId',
    );
    emit(nextState);
  }

  Future<void> _onDeleteEveryThingRelatedToCourse(
    DeleteEveryThingRelatedToCourse event,
    Emitter<MyDownloadsState> emit,
  ) async {
    final lecturesDetails = state.lectureIdToLectureDetailsReferences;
    final filePaths = state.urlToFileReferences;
    final lecturesIds = <String>[];
    final removedFiles = <String>{};
    for (final item
        in state.courseIdToCourseDetailsReferences[event.courseId]?.lectures ??
            const []) {
      lecturesIds.add(item.id!);
      for (final item in lecturesDetails[item.id!]?.videos ?? const []) {
        final videoKey = item.id!;
        final url = filePaths[videoKey];
        if (url != null) {
          await _deleteFileFromLocal(path: url, videoId: videoKey);
        }
        removedFiles.add(videoKey);
      }
      for (final item in lecturesDetails[item.id!]?.files ?? const []) {
        final url = filePaths[item.fileUrl!];
        if (url != null) {
          await _deleteFileFromLocal(path: url);
        }
        removedFiles.add(item.fileUrl!);
      }
      for (final item in lecturesDetails[item.id!]?.questions ?? const []) {
        final url = filePaths[item.imageUrl ?? ''];
        if (url != null) {
          await _deleteFileFromLocal(path: url);
          removedFiles.add(item.imageUrl ?? '');
        }
      }
    }
    // Several courses can be removed at once: apply this removal to the state
    // as it is now, not to the copy taken before the files were deleted, or
    // one removal would bring back the course another one just removed.
    final current = state;
    final nextState = current.copyWith(
      courseIdToCourseDetailsReferences: Map.of(
        current.courseIdToCourseDetailsReferences,
      )..remove(event.courseId),
      urlToFileReferences: Map.of(current.urlToFileReferences)
        ..removeWhere((key, _) => removedFiles.contains(key)),
      lectureIdToLectureDetailsReferences: Map.of(
        current.lectureIdToLectureDetailsReferences,
      )..removeWhere((key, _) => lecturesIds.contains(key)),
      courseIdToFirstDownloadAt: Map.of(current.courseIdToFirstDownloadAt)
        ..remove(event.courseId),
    );
    emit(_pruneEmptyMetadata(nextState));
  }

  void _onSaveCourseDetailsInLocalEvent(
    SaveCourseDetailsInLocalEvent event,
    Emitter<MyDownloadsState> emit,
  ) {
    final String courseId = event.courseDetailsModel.course!.id!;
    // if (!state.courses.any((item) => item.id == courseId)) {
    //   return;
    // }
    Map<String, CourseDetailsModel> coursesDetails = Map.of(
      state.courseIdToCourseDetailsReferences,
    );
    coursesDetails[courseId] = event.courseDetailsModel;
    emit(state.copyWith(courseIdToCourseDetailsReferences: coursesDetails));
  }

  void _onSaveLectureDetailsInLocalEvent(
    SaveLectureDetailsInLocalEvent event,
    Emitter<MyDownloadsState> emit,
  ) {
    final String lectureId = event.lectureDetailsModel.lecture!.id!;
    // if (!state.courses.any((item) => item.id == event.courseId)) {
    //   return;
    // }
    Map<String, LectureDetailsModel> lecturesDetails = Map.of(
      state.lectureIdToLectureDetailsReferences,
    );
    lecturesDetails[lectureId] = event.lectureDetailsModel;
    emit(state.copyWith(lectureIdToLectureDetailsReferences: lecturesDetails));
  }

  Future<void> _deleteFileFromLocal({
    required String path,
    String? videoId,
  }) async {
    try {
      if (path.startsWith('secure-hls://') && videoId != null) {
        await _encryptedHlsDownloadService.deleteVideo(videoId);
      } else {
        await File(path).delete();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _onDeleteReferenceOfDownloadedFile(
    DeleteReferenceOfDownloadedFile event,
    Emitter<MyDownloadsState> emit,
  ) async {
    Map<String, String> urlToFileReferences = Map.of(state.urlToFileReferences);
    final filePath = urlToFileReferences[event.fileUrl];
    if (filePath != null) {
      try {
        if (filePath.startsWith('secure-hls://')) {
          await _encryptedHlsDownloadService.deleteVideo(event.fileUrl);
        } else {
          await File(filePath).delete();
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    urlToFileReferences.remove(event.fileUrl);
    _prefsRepository.removeQuality(event.fileUrl);
    final nextState = _pruneEmptyMetadata(
      state.copyWith(urlToFileReferences: urlToFileReferences),
    );
    debugPrint(
      '[Downloads] deleted reference=${event.fileUrl} '
      'courses count=${nextState.courseIdToCourseDetailsReferences.length} '
      'lectures count=${nextState.lectureIdToLectureDetailsReferences.length} '
      'references count=${nextState.urlToFileReferences.length}',
    );
    emit(nextState);
  }

  MyDownloadsState _pruneEmptyMetadata(MyDownloadsState source) {
    final lectures = Map<String, LectureDetailsModel>.of(
      source.lectureIdToLectureDetailsReferences,
    );
    final courses = Map<String, CourseDetailsModel>.of(
      source.courseIdToCourseDetailsReferences,
    );
    final references = source.urlToFileReferences;

    bool lectureHasDownloads(LectureDetailsModel lecture) {
      final hasFile =
          lecture.files?.any(
            (file) => file.fileUrl != null && references[file.fileUrl] != null,
          ) ??
          false;
      final hasVideo =
          lecture.videos?.any(
            (video) => video.id != null && references[video.id] != null,
          ) ??
          false;
      final hasQuestion =
          lecture.questions?.any(
            (question) =>
                question.imageUrl != null &&
                references[question.imageUrl] != null,
          ) ??
          false;
      return hasFile || hasVideo || hasQuestion;
    }

    lectures.removeWhere((_, lecture) => !lectureHasDownloads(lecture));
    courses.removeWhere(
      (_, course) => !(course.lectures ?? []).any(
        (lecture) => lectures.containsKey(lecture.id),
      ),
    );
    return source.copyWith(
      courseIdToCourseDetailsReferences: courses,
      lectureIdToLectureDetailsReferences: lectures,
    );
  }

  /// Downloads belong to one account: the offline license is checked against
  /// the account id and segment keys are stored per account. When another
  /// account signs in on this installation, the previous account's downloads
  /// are unusable and would leak its course list, so they are removed.
  /// Signing back in with the same account keeps them.
  Future<void> _onSyncDownloadsOwner(
    SyncDownloadsOwner event,
    Emitter<MyDownloadsState> emit,
  ) async {
    final owner = state.ownerUserId;
    if (owner == event.userId) return;
    if (owner == null) {
      // State saved before ownership existed: adopt it for the current user.
      emit(state.copyWith(ownerUserId: event.userId));
      return;
    }
    for (final entry in state.urlToFileReferences.entries) {
      await _deleteFileFromLocal(path: entry.value, videoId: entry.key);
    }
    debugPrint('[Downloads] cleared downloads of a previous account');
    emit(MyDownloadsState(ownerUserId: event.userId));
  }

  /// Whether this session already received the server's list of active
  /// courses (and so the current subscription dates).
  bool _serverCoursesFresh = false;

  /// Overridden in tests.
  @visibleForTesting
  static Future<bool> Function() isOffline =
      HelperFunctions.lostInternetConnection;

  Future<void> _onDeleteCoursesWhichAreExpired(
    DeleteCoursesWhichAreExpired event,
    Emitter<MyDownloadsState> emit,
  ) async {
    final now = DateTime.now();
    final firstDownloads = Map.of(state.courseIdToFirstDownloadAt);
    final expired = <String>[];
    final awaitingRenewalCheck = <String>[];
    state.courseIdToCourseDetailsReferences.forEach((courseId, course) {
      // Courses downloaded before this date was recorded start their two
      // months now.
      firstDownloads.putIfAbsent(courseId, () => now);
      final active = state.courses.firstWhereOrNull(
        (item) => item.id == courseId,
      );
      if (!DownloadedCourseExpiry.shouldDelete(
        course: course,
        firstDownloadedAt: firstDownloads[courseId],
        renewedSubscriptionExpiresAt: active?.subscriptionExpiresAt,
        now: now,
      )) {
        return;
      }
      if (DownloadedCourseExpiry.endsWithSubscription(course, now)) {
        awaitingRenewalCheck.add(courseId);
      } else {
        expired.add(courseId);
      }
    });
    if (firstDownloads.length != state.courseIdToFirstDownloadAt.length) {
      emit(state.copyWith(courseIdToFirstDownloadAt: firstDownloads));
    }
    // A saved subscription date may be older than a renewal: wait for the
    // server's list, unless there is no connection to get it.
    if (awaitingRenewalCheck.isNotEmpty &&
        (_serverCoursesFresh || await isOffline())) {
      expired.addAll(awaitingRenewalCheck);
    }
    for (final courseId in expired) {
      debugPrint('[Downloads] removing expired course $courseId');
      add(DeleteEveryThingRelatedToCourse(courseId));
    }
  }
}
