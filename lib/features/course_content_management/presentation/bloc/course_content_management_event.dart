part of 'course_content_management_bloc.dart';

@immutable
sealed class CourseContentManagementEvent {}

class GetAllowedSubjects extends CourseContentManagementEvent {}

class UpsertCourseEvent extends CourseContentManagementEvent {
  final UpsertCourseParams params;
  final File? image;

  UpsertCourseEvent({required this.params, this.image});
}

class ClearContentManagementState extends CourseContentManagementEvent {}

class UpsertLectureEvent extends CourseContentManagementEvent {
  final UpsertLectureParams params;

  UpsertLectureEvent(this.params);
}

class DeleteLectureEvent extends CourseContentManagementEvent {
  final DeleteFromCourseParams params;
  final String courseId;

  DeleteLectureEvent(this.params, {required this.courseId});
}

class GetAllSeasonsEvent extends CourseContentManagementEvent {}

class UpsertVideoEvent extends CourseContentManagementEvent {
  final UpsertVideoParams params;
  final String courseId;

  UpsertVideoEvent(this.params, {required this.courseId});
}

class VideoSelectedEvent extends CourseContentManagementEvent {
  final XFile? file;

  VideoSelectedEvent({this.file});
}

class UpsertFileEvent extends CourseContentManagementEvent {
  final UpsertFileParams params;
  final XFile? file;
  final String courseId, lectureId;

  UpsertFileEvent(
    this.params, {
    this.file,
    required this.courseId,
    required this.lectureId,
  });
}

class UpsertQuestionEvent extends CourseContentManagementEvent {
  final UpsertQuestionParams params;
  final XFile? file;
  final String courseId, lectureId;

  UpsertQuestionEvent(
    this.params, {
    this.file,
    required this.courseId,
    required this.lectureId,
  });
}

class UpsertVideoSegmentEvent extends CourseContentManagementEvent {
  final UpsertVideoSegmentParams params;

  UpsertVideoSegmentEvent(this.params);
}

class GetVideoSegmentsEvent extends CourseContentManagementEvent {
  final String videoId;

  GetVideoSegmentsEvent(this.videoId);
}

class DeleteVideoSegmentsEvent extends CourseContentManagementEvent {
  final DeleteVideoSegmentParams params;

  DeleteVideoSegmentsEvent({required this.params});
}

class DeleteFromLectureEvent extends CourseContentManagementEvent {
  final DeleteFromCourseParams params;
  final String lectureId;
  final String courseId;

  DeleteFromLectureEvent({
    required this.params,
    required this.lectureId,
    required this.courseId,
  });
}

class DeleteQuestionEvent extends CourseContentManagementEvent {
  final DeleteFromCourseParams params;
  final String lectureId;
  final String courseId;

  DeleteQuestionEvent({
    required this.params,
    required this.lectureId,
    required this.courseId,
  });
}
