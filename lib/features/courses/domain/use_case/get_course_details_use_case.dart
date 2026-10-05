import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/model/course_details_model.dart';
import '../repository/courses_repository.dart';

@injectable
class GetCourseDetailsUseCase
    extends UseCase<CourseDetailsModel, ParamGetCourseDetails> {
  final CoursesRepository repository;

  GetCourseDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, CourseDetailsModel>> call(
    ParamGetCourseDetails param,
  ) {
    return repository.getCourseDetails(param);
  }
}

class ParamGetCourseDetails {
  final String courseId;

  ParamGetCourseDetails({required this.courseId});
}
