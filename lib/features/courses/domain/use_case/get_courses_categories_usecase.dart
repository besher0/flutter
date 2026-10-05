import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/model/course_category.dart';
import '../repository/courses_repository.dart';

@injectable
class GetCoursesCategoriesUsecase
    extends UseCase<List<CourseCategory>, NoParams> {
  final CoursesRepository repository;

  GetCoursesCategoriesUsecase(this.repository);

  @override
  Future<Either<Failure, List<CourseCategory>>> call(NoParams param) {
    return repository.getCoursesCategories();
  }
}
