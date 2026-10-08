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

bool canOpenLectureFileAsGuest({
  required FileElement file,
  required bool isCourseFree,
  required bool isGuest,
}) {
  final isFree = isCourseFree || file.isFree == true;
  return isGuest && isFree && file.locked != true && file.fileUrl != null;
}
