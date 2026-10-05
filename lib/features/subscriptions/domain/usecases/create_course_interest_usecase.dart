import 'package:coursaty_student_and_teacher/core/error/failures.dart';
import 'package:coursaty_student_and_teacher/core/use_case/use_case.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/data/models/course_interest_model.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/domain/repositories/subscriptions_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

class CreateCourseInterestParams {
  const CreateCourseInterestParams({
    required this.courseId,
    required this.source,
  });
  final String courseId;
  final InterestSource source;
}

@injectable
class CreateCourseInterestUsecase
    extends UseCase<CourseInterest, CreateCourseInterestParams> {
  CreateCourseInterestUsecase(this._repository);
  final SubscriptionsRepository _repository;

  @override
  Future<Either<Failure, CourseInterest>> call(
    CreateCourseInterestParams params,
  ) => _repository.createInterest(params.courseId, params.source);
}
