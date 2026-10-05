import 'package:coursaty_student_and_teacher/core/error/failures.dart';
import 'package:coursaty_student_and_teacher/core/use_case/use_case.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/domain/repositories/subscriptions_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class RemoveCourseInterestUsecase extends UseCase<bool, String> {
  RemoveCourseInterestUsecase(this._repository);
  final SubscriptionsRepository _repository;

  @override
  Future<Either<Failure, bool>> call(String courseId) =>
      _repository.removeInterest(courseId);
}
