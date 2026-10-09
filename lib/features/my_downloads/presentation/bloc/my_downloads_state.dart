import 'package:coursaty_student_and_teacher/features/courses/data/model/course_details_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/lecture_details_model.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../courses/data/model/course_model.dart';

part 'my_downloads_state.g.dart';

@JsonSerializable(explicitToJson: true)
class MyDownloadsState {
  final List<CourseModel> courses;
  final Map<String, String> urlToFileReferences;
  final Map<String, CourseDetailsModel> courseIdToCourseDetailsReferences;
  final Map<String, LectureDetailsModel> lectureIdToLectureDetailsReferences;

  /// Account that owns these downloads. Offline licenses and segment keys are
  /// bound to that account, so another account on this installation cannot
  /// use (or see) them.
  final String? ownerUserId;

  MyDownloadsState({
    this.ownerUserId,
    this.courses = const [],
    this.urlToFileReferences = const {},
    this.courseIdToCourseDetailsReferences = const {},
    this.lectureIdToLectureDetailsReferences = const {},
  });

  MyDownloadsState copyWith({
    final List<CourseModel>? courses,
    final Map<String, String>? urlToFileReferences,
    final Map<String, CourseDetailsModel>? courseIdToCourseDetailsReferences,
    final Map<String, LectureDetailsModel>? lectureIdToLectureDetailsReferences,
    final String? ownerUserId,
  }) {
    return MyDownloadsState(
      ownerUserId: ownerUserId ?? this.ownerUserId,
      courses: courses ?? this.courses,
      urlToFileReferences: urlToFileReferences ?? this.urlToFileReferences,
      courseIdToCourseDetailsReferences:
          courseIdToCourseDetailsReferences ??
          this.courseIdToCourseDetailsReferences,
      lectureIdToLectureDetailsReferences:
          lectureIdToLectureDetailsReferences ??
          this.lectureIdToLectureDetailsReferences,
    );
  }

  MyDownloadsState withDownloadedFile({
    required String fileUrl,
    required String localFilePath,
    required String courseId,
    String? lectureId,
    CourseDetailsModel? courseDetailsModel,
    LectureDetailsModel? lectureDetailsModel,
  }) {
    final courses = Map<String, CourseDetailsModel>.of(
      courseIdToCourseDetailsReferences,
    );
    if (courseDetailsModel?.course?.id == courseId) {
      courses[courseId] = courseDetailsModel!;
    }

    final lectures = Map<String, LectureDetailsModel>.of(
      lectureIdToLectureDetailsReferences,
    );
    if (lectureDetailsModel?.lecture?.id != null &&
        lectureDetailsModel!.lecture!.id == lectureId) {
      lectures[lectureDetailsModel.lecture!.id!] = lectureDetailsModel;
    }

    return copyWith(
      urlToFileReferences: {
        ...urlToFileReferences,
        fileUrl: localFilePath,
      },
      courseIdToCourseDetailsReferences: courses,
      lectureIdToLectureDetailsReferences: lectures,
    );
  }

  factory MyDownloadsState.fromJson(Map<String, dynamic> data) =>
      _$MyDownloadsStateFromJson(data);

  Map<String, dynamic> toJson() => _$MyDownloadsStateToJson(this);
}
