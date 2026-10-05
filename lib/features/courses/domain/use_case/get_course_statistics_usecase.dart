import 'package:coursaty_student_and_teacher/features/courses/data/model/course_statistcis_model.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repository/courses_repository.dart';
import 'get_course_details_use_case.dart';

@injectable
class GetCourseStatisticsUsecase
    extends UseCase<CourseStatisticsModel, ParamGetCourseDetails> {
  final CoursesRepository repository;

  GetCourseStatisticsUsecase(this.repository);

  @override
  Future<Either<Failure, CourseStatisticsModel>> call(
    ParamGetCourseDetails param,
  ) {
    return repository.getCourseStatistics(param);
  }
}
