import 'package:coursaty_student_and_teacher/features/courses/data/model/course_details_model.dart';

/// When a downloaded course must leave the device.
///
/// * A free course is kept for [freeCourseRetention] after its first download.
/// * A paid course is kept until its subscription ends. The date saved with
///   the download is only a snapshot, so [renewedSubscriptionExpiresAt] (the
///   server's current date, when known) wins when it is later: a renewal must
///   not delete the course.
/// * Any course is removed once the course itself has ended.
abstract final class DownloadedCourseExpiry {
  static const freeCourseRetention = Duration(days: 60);

  static bool shouldDelete({
    required CourseDetailsModel course,
    required DateTime? firstDownloadedAt,
    required DateTime now,
    DateTime? renewedSubscriptionExpiresAt,
  }) {
    final courseEndsAt = course.details?.expiresAt;
    if (courseEndsAt != null && !now.isBefore(courseEndsAt)) return true;

    if (course.course?.isFree == true) {
      return firstDownloadedAt != null &&
          !now.isBefore(firstDownloadedAt.add(freeCourseRetention));
    }

    final expiresAt = latest(
      course.subscriptionExpiresAt,
      renewedSubscriptionExpiresAt,
    );
    return expiresAt != null && !now.isBefore(expiresAt);
  }

  /// Whether an expired [course] leaves only because of its subscription
  /// date (a paid course that has not ended), which a renewal may change.
  static bool endsWithSubscription(CourseDetailsModel course, DateTime now) {
    final courseEndsAt = course.details?.expiresAt;
    final courseEnded = courseEndsAt != null && !now.isBefore(courseEndsAt);
    return course.course?.isFree != true && !courseEnded;
  }

  static DateTime? latest(DateTime? a, DateTime? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a.isAfter(b) ? a : b;
  }
}
