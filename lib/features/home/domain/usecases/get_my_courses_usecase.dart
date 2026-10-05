import 'package:coursaty_student_and_teacher/features/courses/data/model/course_model.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repositories/home_repository.dart';

@injectable
class GetMyCoursesUsecase extends UseCase<List<CourseModel>, bool> {
  final HomeRepository repository;

  GetMyCoursesUsecase(this.repository);

  @override
  Future<Either<Failure, List<CourseModel>>> call(bool getActive) {
    return repository.getMyCourses(getActive);
  }
}
