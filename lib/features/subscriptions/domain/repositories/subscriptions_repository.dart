import 'dart:io';

import 'package:coursaty_student_and_teacher/core/error/failures.dart';
import 'package:dartz/dartz.dart';

import '../../data/models/course_interest_model.dart';

abstract class SubscriptionsRepository {
  Future<Either<Failure, List<CourseInterest>>> getInterests();
  Future<Either<Failure, CoursePaymentInfo>> getCoursePaymentInfo(
    String courseId,
  );
  Future<Either<Failure, CourseInterest>> createInterest(
    String courseId,
    InterestSource source,
  );
  Future<Either<Failure, bool>> removeInterest(String courseId);
  Future<Either<Failure, SubscriptionRequestSummary>> submitReceipt({
    required String courseId,
    required File file,
    String? note,
    void Function(int sent, int total)? onSendProgress,
  });
}
