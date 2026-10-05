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

  MyDownloadsState({
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
  }) {
    return MyDownloadsState(
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

  factory MyDownloadsState.fromJson(Map<String, dynamic> data) =>
      _$MyDownloadsStateFromJson(data);

  Map<String, dynamic> toJson() => _$MyDownloadsStateToJson(this);
}
