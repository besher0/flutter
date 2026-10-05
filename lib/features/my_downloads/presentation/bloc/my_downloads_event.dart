part of 'my_downloads_bloc.dart';

sealed class MyDownloadsEvent {}

class SaveReferenceOfDownloadedFile extends MyDownloadsEvent {
  final String fileUrl, localFilePath, courseId;

  SaveReferenceOfDownloadedFile({
    required this.courseId,
    required this.fileUrl,
    required this.localFilePath,
  });
}

class DeleteReferenceOfDownloadedFile extends MyDownloadsEvent {
  final String fileUrl;

  DeleteReferenceOfDownloadedFile({required this.fileUrl});
}

class SaveCoursesInLocalEvent extends MyDownloadsEvent {
  final List<CourseModel> courses;

  SaveCoursesInLocalEvent(this.courses);
}

class SaveCourseDetailsInLocalEvent extends MyDownloadsEvent {
  final CourseDetailsModel courseDetailsModel;

  SaveCourseDetailsInLocalEvent({required this.courseDetailsModel});
}

class SaveLectureDetailsInLocalEvent extends MyDownloadsEvent {
  final LectureDetailsModel lectureDetailsModel;
  final String courseId;

  SaveLectureDetailsInLocalEvent({
    required this.lectureDetailsModel,
    required this.courseId,
  });
}

class DeleteEveryThingRelatedToCourse extends MyDownloadsEvent {
  final String courseId;

  DeleteEveryThingRelatedToCourse(this.courseId);
}

class DeleteCoursesWhichAreInActive extends MyDownloadsEvent {
  final List<CourseModel> courses;

  DeleteCoursesWhichAreInActive(this.courses);
}

class DeleteCoursesWhichAreExpired extends MyDownloadsEvent {}
