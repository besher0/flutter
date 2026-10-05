import 'dart:io';

import 'package:coursaty_student_and_teacher/core/api/api.dart';
import 'package:coursaty_student_and_teacher/core/error/failures.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/data/models/course_interest_model.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/data/sources/subscriptions_remote_datasource.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/domain/repositories/subscriptions_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: SubscriptionsRepository)
class SubscriptionsRepositoryImpl extends SubscriptionsRepository
    with HandlingExceptionRequest {
  SubscriptionsRepositoryImpl(this._datasource);

  final SubscriptionsRemoteDatasource _datasource;

  @override
  Future<Either<Failure, List<CourseInterest>>> getInterests() =>
      handlingExceptionRequest(tryCall: _datasource.getInterests);

  @override
  Future<Either<Failure, CoursePaymentInfo>> getCoursePaymentInfo(
    String courseId,
  ) => handlingExceptionRequest(
    tryCall: () => _datasource.getCoursePaymentInfo(courseId),
  );

  @override
  Future<Either<Failure, CourseInterest>> createInterest(
    String courseId,
    InterestSource source,
  ) => handlingExceptionRequest(
    tryCall: () => _datasource.createInterest(courseId, source),
  );

  @override
  Future<Either<Failure, bool>> removeInterest(String courseId) =>
      handlingExceptionRequest(
        tryCall: () => _datasource.removeInterest(courseId),
      );

  @override
  Future<Either<Failure, SubscriptionRequestSummary>> submitReceipt({
    required String courseId,
    required File file,
    String? note,
    void Function(int sent, int total)? onSendProgress,
  }) => handlingExceptionRequest(
    tryCall: () => _datasource.submitReceipt(
      courseId: courseId,
      file: file,
      note: note,
      onSendProgress: onSendProgress,
    ),
  );
}
