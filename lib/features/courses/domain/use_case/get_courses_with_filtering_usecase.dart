import 'package:coursaty_student_and_teacher/features/courses/data/model/course_model.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repository/courses_repository.dart';

@injectable
class GetCoursesWithFilteringUsecase
    extends UseCase<CoursesResponseModel, ParamGetCoursesWithFilters> {
  final CoursesRepository repository;

  GetCoursesWithFilteringUsecase(this.repository);

  @override
  Future<Either<Failure, CoursesResponseModel>> call(
    ParamGetCoursesWithFilters param,
  ) {
    return repository.getCoursesWithFiltering(param);
  }
}

class ParamGetCoursesWithFilters {
  final int page;
  final int limit;
  final String? filter;
  final String? categoryId;

  ParamGetCoursesWithFilters({
    required this.page,
    required this.limit,
    this.filter,
    this.categoryId,
  });
}
