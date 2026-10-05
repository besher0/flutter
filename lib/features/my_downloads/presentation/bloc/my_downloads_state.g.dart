// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_downloads_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyDownloadsState _$MyDownloadsStateFromJson(
  Map<String, dynamic> json,
) => MyDownloadsState(
  courses:
      (json['courses'] as List<dynamic>?)
          ?.map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  urlToFileReferences:
      (json['urlToFileReferences'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  courseIdToCourseDetailsReferences:
      (json['courseIdToCourseDetailsReferences'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, CourseDetailsModel.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
  lectureIdToLectureDetailsReferences:
      (json['lectureIdToLectureDetailsReferences'] as Map<String, dynamic>?)
          ?.map(
            (k, e) => MapEntry(
              k,
              LectureDetailsModel.fromJson(e as Map<String, dynamic>),
            ),
          ) ??
      const {},
);

Map<String, dynamic> _$MyDownloadsStateToJson(MyDownloadsState instance) =>
    <String, dynamic>{
      'courses': instance.courses.map((e) => e.toJson()).toList(),
      'urlToFileReferences': instance.urlToFileReferences,
      'courseIdToCourseDetailsReferences': instance
          .courseIdToCourseDetailsReferences
          .map((k, e) => MapEntry(k, e.toJson())),
      'lectureIdToLectureDetailsReferences': instance
          .lectureIdToLectureDetailsReferences
          .map((k, e) => MapEntry(k, e.toJson())),
    };
