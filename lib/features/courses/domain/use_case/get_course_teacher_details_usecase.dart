import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/model/teacher_course_details_model.dart';
import '../repository/courses_repository.dart';
import 'get_course_details_use_case.dart';

@injectable
class GetCourseTeacherDetailsUsecase
    extends UseCase<TeacherCourseDetailsResponseModel, ParamGetCourseDetails> {
  final CoursesRepository repository;

  GetCourseTeacherDetailsUsecase(this.repository);

  @override
  Future<Either<Failure, TeacherCourseDetailsResponseModel>> call(
    ParamGetCourseDetails param,
  ) {
    return repository.getTeacherCourseDetails(param);
  }
}
