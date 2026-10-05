import 'dart:io';

import 'package:coursaty_student_and_teacher/core/error/failures.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/data/models/course_interest_model.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/domain/repositories/subscriptions_repository.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/domain/usecases/create_course_interest_usecase.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/domain/usecases/get_course_interests_usecase.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/domain/usecases/get_course_payment_info_usecase.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/domain/usecases/remove_course_interest_usecase.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/domain/usecases/submit_subscription_receipt_usecase.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/presentation/bloc/subscription_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

class _SubscriptionsRepositoryFake implements SubscriptionsRepository {
  int createdInterests = 0;

  CourseInterest get interest => const CourseInterest(
    id: 'interest-1',
    courseId: 'course-1',
    source: InterestSource.manual,
    course: CoursePaymentInfo(id: 'course-1', name: 'البرمجة'),
  );

  @override
  Future<Either<Failure, CourseInterest>> createInterest(
    String courseId,
    InterestSource source,
  ) async {
    createdInterests++;
    return Right(interest);
  }

  @override
  Future<Either<Failure, CoursePaymentInfo>> getCoursePaymentInfo(
    String courseId,
  ) async => const Right(CoursePaymentInfo(id: 'course-1', name: 'البرمجة'));

  @override
  Future<Either<Failure, List<CourseInterest>>> getInterests() async =>
      const Right([]);

  @override
  Future<Either<Failure, bool>> removeInterest(String courseId) async =>
      const Right(true);

  @override
  Future<Either<Failure, SubscriptionRequestSummary>> submitReceipt({
    required String courseId,
    required File file,
    String? note,
    void Function(int sent, int total)? onSendProgress,
  }) async => const Right(
    SubscriptionRequestSummary(id: 'request-1', status: 'PENDING'),
  );
}

void main() {
  test('saving an interest updates the in-memory interests list', () async {
    final repository = _SubscriptionsRepositoryFake();
    final bloc = SubscriptionBloc(
      GetCourseInterestsUsecase(repository),
      GetCoursePaymentInfoUsecase(repository),
      CreateCourseInterestUsecase(repository),
      RemoveCourseInterestUsecase(repository),
      SubmitSubscriptionReceiptUsecase(repository),
    );
    addTearDown(bloc.close);

    final saved = bloc.stream.firstWhere(
      (state) => state.lastCreatedInterest?.courseId == 'course-1',
    );
    bloc.add(
      SaveCourseInterest(courseId: 'course-1', source: InterestSource.manual),
    );

    final state = await saved;
    expect(state.interests.single.courseId, 'course-1');
    expect(repository.createdInterests, 1);
  });
}
