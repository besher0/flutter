import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repository/courses_repository.dart';

@injectable
class RateCourseUseCase extends UseCase<bool, ParamRateCourse> {
  final CoursesRepository repository;

  RateCourseUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(ParamRateCourse param) {
    return repository.rateCourse(param.data);
  }
}

class ParamRateCourse {
  final int stars;
  final String courseId;

  ParamRateCourse({required this.courseId, required this.stars});

  Map<String, dynamic> get data => {"courseId": courseId, "rating": stars};
}
