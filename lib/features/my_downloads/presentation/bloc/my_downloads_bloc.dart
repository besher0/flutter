import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_details_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/lecture_details_model.dart'
    hide Lecture;
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
    emit(
      state.copyWith(
        courses: event.courses.map((item) {
          if (item.isFree ?? false) {
            if (item.freeCourseExpirationAt == null) {
              return item.copyWith(freeCourseExpirationAt: DateTime.now());
            }
            return item;
          }
          return item;
        }).toList(),
      ),
    );
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
    // List<CourseModel> courses = List.of(state.courses);
    // CourseModel? course = courses.firstWhereOrNull(
    //   (item) => item.id == event.courseId,
    // );
    // if (course == null) {
    //   return;
    // }
    Map<String, CourseDetailsModel> coursesDetails = Map.of(
      state.courseIdToCourseDetailsReferences,
    );
    Map<String, LectureDetailsModel> lecturesDetails = Map.of(
      state.lectureIdToLectureDetailsReferences,
    );
    final Map<String, String> filePaths = Map.of(state.urlToFileReferences);
    List<String> lecturesIds = [];
    for (final item in coursesDetails[event.courseId]?.lectures ?? const []) {
      lecturesIds.add(item.id!);
      for (final item in lecturesDetails[item.id!]?.videos ?? const []) {
        final videoKey = item.id!;
        final url = filePaths[videoKey];
        if (url != null) {
          await _deleteFileFromLocal(path: url, videoId: videoKey);
        }
        filePaths.remove(videoKey);
      }
      for (final item in lecturesDetails[item.id!]?.files ?? const []) {
        final url = filePaths[item.fileUrl!];
        if (url != null) {
          await _deleteFileFromLocal(path: url);
        }
        filePaths.remove(item.fileUrl!);
      }
      for (final item in lecturesDetails[item.id!]?.questions ?? const []) {
        final url = filePaths[item.imageUrl ?? ''];
        if (url != null) {
          await _deleteFileFromLocal(path: url);
          filePaths.remove(item.imageUrl ?? '');
        }
      }
    }
    lecturesDetails.removeWhere((k, v) => lecturesIds.contains(k));
    coursesDetails.removeWhere((k, v) => k == event.courseId);
    // courses.removeWhere((item) => item.id == event.courseId);
    final nextState = state.copyWith(
      courseIdToCourseDetailsReferences: coursesDetails,
      urlToFileReferences: filePaths,
      lectureIdToLectureDetailsReferences: lecturesDetails,
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
      final hasFile = lecture.files?.any(
            (file) => file.fileUrl != null && references[file.fileUrl] != null,
          ) ??
          false;
      final hasVideo = lecture.videos?.any(
            (video) => video.id != null && references[video.id] != null,
          ) ??
          false;
      final hasQuestion = lecture.questions?.any(
            (question) =>
                question.imageUrl != null &&
                references[question.imageUrl] != null,
          ) ??
          false;
      return hasFile || hasVideo || hasQuestion;
    }

    lectures.removeWhere((_, lecture) => !lectureHasDownloads(lecture));
    courses.removeWhere(
      (_, course) =>
          !(course.lectures ?? []).any((lecture) => lectures.containsKey(lecture.id)),
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

  FutureOr<void> _onDeleteCoursesWhichAreExpired(
    DeleteCoursesWhichAreExpired event,
    Emitter<MyDownloadsState> emit,
  ) {
    Map<String, CourseDetailsModel> references = Map.of(
      state.courseIdToCourseDetailsReferences,
    );

    List<CourseModel> courses = List.of(state.courses);
    references.forEach((k, v) {
      final course = courses.firstWhereOrNull((item) => item.id == k);
      final remove =
          ((v.subscriptionExpiresAt != null &&
                  !DateTime.now()
                      .difference(v.subscriptionExpiresAt!)
                      .isNegative) ||
              (v.details?.expiresAt != null &&
                  !DateTime.now()
                      .difference(v.details!.expiresAt!)
                      .isNegative)) ||
          (course != null &&
              course.freeCourseExpirationAt != null &&
              course.isFree == true &&
              DateTime.now()
                      .difference(course.freeCourseExpirationAt!)
                      .inDays >=
                  30);
      if (remove) {
        add(DeleteEveryThingRelatedToCourse(k));
      }
    });
  }
}
