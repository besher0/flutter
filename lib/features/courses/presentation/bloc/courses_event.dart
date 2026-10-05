part of 'courses_bloc.dart';

@immutable
sealed class CoursesEvent {}

class GetCoursesBySubjectEvent extends CoursesEvent {
  final String subjectId;
  final bool reset;

  GetCoursesBySubjectEvent(this.subjectId, {this.reset = false});
}

class RemoveQuestionFromLecture extends CoursesEvent {
  final String questionId;

  RemoveQuestionFromLecture({required this.questionId});
}

class GetCourseDetailsEvent extends CoursesEvent {
  final String courseId;

  GetCourseDetailsEvent({required this.courseId});
}

class GetVideoResolutionsEvent extends CoursesEvent {
  final String videoId;

  GetVideoResolutionsEvent({required this.videoId});
}

class GetLectureDetailsEvent extends CoursesEvent {
  final String lectureId;
  final String courseId;

  GetLectureDetailsEvent({required this.lectureId, required this.courseId});
}

class GetCoursesWithFilteringEvent extends CoursesEvent {
  final String? categoryId;
  final String? filter;
  final bool reset;

  GetCoursesWithFilteringEvent({
    this.categoryId,
    this.reset = false,
    this.filter,
  });
}

class GetCoursesByYearEvent extends CoursesEvent {
  final String yearId;
  final bool reset;

  GetCoursesByYearEvent({required this.yearId, this.reset = false});
}

class GetCoursesCategoriesEvent extends CoursesEvent {}

class RateCourseEvent extends CoursesEvent {
  final int stars;
  final String courseId;

  RateCourseEvent({required this.stars, required this.courseId});
}

class GetCourseRating extends CoursesEvent {
  final String courseId;

  GetCourseRating({required this.courseId});
}

class ClearCoursesState extends CoursesEvent {}

class GetTeacherCourseDetailsEvent extends CoursesEvent {
  final String courseId;

  GetTeacherCourseDetailsEvent({required this.courseId});
}

class GetCourseStatisticsEvent extends CoursesEvent {
  final String courseId;

  GetCourseStatisticsEvent({required this.courseId});
}

class GetTeacherCourses extends CoursesEvent {
  final bool getActive;
  final bool reset;

  GetTeacherCourses({this.getActive = true, this.reset = false});
}

class GetVideoInteractionsEvent extends CoursesEvent {
  final String videoId;

  GetVideoInteractionsEvent(this.videoId);
}

class ToggleVideoInteractionEvent extends CoursesEvent {
  final String videoId;

  ToggleVideoInteractionEvent(this.videoId);
}
