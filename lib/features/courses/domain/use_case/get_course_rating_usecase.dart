import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/model/course_rating.dart';
import '../repository/courses_repository.dart';

@injectable
class GetCourseRatingUsecase extends UseCase<CourseRatingModel, String> {
  final CoursesRepository repository;

  GetCourseRatingUsecase(this.repository);

  @override
  Future<Either<Failure, CourseRatingModel>> call(String id) {
    return repository.getCourseRating(id);
  }
}
