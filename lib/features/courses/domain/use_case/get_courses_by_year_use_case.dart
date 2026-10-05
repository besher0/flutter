import 'package:coursaty_student_and_teacher/features/courses/data/model/course_model.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repository/courses_repository.dart';

@injectable
class GetCoursesByYearUseCase
    extends UseCase<List<CourseModel>, ParamGetCoursesByYear> {
  final CoursesRepository repository;

  GetCoursesByYearUseCase(this.repository);

  @override
  Future<Either<Failure, List<CourseModel>>> call(ParamGetCoursesByYear param) {
    return repository.getCoursesByYear(param);
  }
}

class ParamGetCoursesByYear {
  final String yearId;
  final int page;
  final int limit;

  ParamGetCoursesByYear(this.yearId, {required this.page, required this.limit});
}
