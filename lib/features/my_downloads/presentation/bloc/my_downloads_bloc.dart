import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_details_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/lecture_details_model.dart'
    hide Lecture;
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable_generator/utils.dart';

import 'my_downloads_state.dart';

part 'my_downloads_event.dart';

@singleton
class MyDownloadsBloc extends HydratedBloc<MyDownloadsEvent, MyDownloadsState> {
  MyDownloadsBloc() : super(MyDownloadsState()) {
    on<MyDownloadsEvent>((event, emit) {});
    on<SaveCoursesInLocalEvent>(_onSaveCoursesInLocalEvent);
    on<SaveReferenceOfDownloadedFile>(_onSaveReferenceOfDownloadedFile);
    on<DeleteReferenceOfDownloadedFile>(_onDeleteReferenceOfDownloadedFile);
    on<DeleteEveryThingRelatedToCourse>(_onDeleteEveryThingRelatedToCourse);
    on<SaveCourseDetailsInLocalEvent>(_onSaveCourseDetailsInLocalEvent);
    on<SaveLectureDetailsInLocalEvent>(_onSaveLectureDetailsInLocalEvent);
    on<DeleteCoursesWhichAreExpired>(_onDeleteCoursesWhichAreExpired);
  }

  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();

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
    Map<String, String> urlToFileReferences = Map.of(state.urlToFileReferences);
    // if (!state.courses.any((item) => item.id == event.courseId)) {
    //   return;
    // }
    urlToFileReferences[event.fileUrl] = event.localFilePath;
    emit(state.copyWith(urlToFileReferences: urlToFileReferences));
  }

  void _onDeleteEveryThingRelatedToCourse(
    DeleteEveryThingRelatedToCourse event,
    Emitter<MyDownloadsState> emit,
  ) {
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
    List<Lecture> lectures = [];
    coursesDetails[event.courseId]?.lectures?.forEach((item) {
      lecturesIds.add(item.id!);
      lecturesDetails[item.id!]?.videos?.forEach((item) {
        final url = filePaths[item.videoUrl!];
        if (url != null) {
          _deleteFileFromLocal(path: url);
        }
        filePaths.remove(item.videoUrl!);
      });
      lecturesDetails[item.id!]?.files?.forEach((item) {
        final url = filePaths[item.fileUrl!];
        if (url != null) {
          _deleteFileFromLocal(path: url);
        }
        filePaths.remove(item.fileUrl!);
      });
      lecturesDetails[item.id!]?.questions?.forEach((item) {
        final url = filePaths[item.imageUrl ?? ''];
        if (url != null) {
          _deleteFileFromLocal(path: url);
          filePaths.remove(item.imageUrl ?? '');
        }
      });
    });
    lecturesDetails.removeWhere((k, v) => lecturesIds.contains(k));
    coursesDetails.removeWhere((k, v) => k == event.courseId);
    // courses.removeWhere((item) => item.id == event.courseId);
    emit(
      state.copyWith(
        // courses: courses,
        courseIdToCourseDetailsReferences: coursesDetails,
        urlToFileReferences: filePaths,
        lectureIdToLectureDetailsReferences: lecturesDetails,
      ),
    );
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

  void _deleteFileFromLocal({required String path}) {
    try {
      File(path).delete();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  FutureOr<void> _onDeleteReferenceOfDownloadedFile(
    DeleteReferenceOfDownloadedFile event,
    Emitter<MyDownloadsState> emit,
  ) {
    Map<String, String> urlToFileReferences = Map.of(state.urlToFileReferences);
    final filePath = urlToFileReferences[event.fileUrl];
    if (filePath != null) {
      try {
        File(filePath).delete();
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    urlToFileReferences.remove(event.fileUrl);
    _prefsRepository.removeQuality(event.fileUrl);
    emit(state.copyWith(urlToFileReferences: urlToFileReferences));
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
