import 'package:coursaty_student_and_teacher/features/courses/data/model/get_teacher_courses_model.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repository/courses_repository.dart';

@injectable
class GetTeacherCoursesUsecase
    extends UseCase<TeacherCoursesResponseModel, GetTeacherCoursesParams> {
  final CoursesRepository repository;

  GetTeacherCoursesUsecase(this.repository);

  @override
  Future<Either<Failure, TeacherCoursesResponseModel>> call(
    GetTeacherCoursesParams param,
  ) {
    return repository.getTeacherCourses(param);
  }
}

class GetTeacherCoursesParams {
  final bool getActive;
  final int page;
  final int limit;

  GetTeacherCoursesParams({
    required this.page,
    required this.limit,
    this.getActive = true,
  });
}
