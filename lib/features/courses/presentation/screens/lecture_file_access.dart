import '../../data/model/lecture_details_model.dart';

bool isLectureFileLocked({
  required FileElement file,
  required String courseId,
  required bool isCourseFree,
  required bool isGuest,
  required Iterable<String> activeCourseIds,
}) {
  final isFree = isCourseFree || file.isFree == true;
  return file.fileUrl == null ||
      file.locked == true ||
      (!isFree && !activeCourseIds.contains(courseId));
}

/// Same rule as the lecture screen's lock icon on a video.
bool isLectureVideoLocked({
  required Video video,
  required String courseId,
  required bool isCourseFree,
  required bool isGuest,
  required Iterable<String> activeCourseIds,
}) {
  final isFree = isCourseFree || (video.isFree ?? false);
  return video.id == null ||
      video.locked == true ||
      (isGuest
          ? !(video.isFree ?? false)
          : (!isFree && !activeCourseIds.contains(courseId)));
}

bool canOpenLectureFileAsGuest({
  required FileElement file,
  required bool isCourseFree,
  required bool isGuest,
}) {
  final isFree = isCourseFree || file.isFree == true;
  return isGuest && isFree && file.locked != true && file.fileUrl != null;
}
