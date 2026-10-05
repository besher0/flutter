import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/model/courses_of_subject_response_model.dart';
import '../repository/courses_repository.dart';

@injectable
class GetCoursesBySubjectUseCase
    extends UseCase<CoursesOfSubjectResponseModel, ParamGetCoursesBySubject> {
  final CoursesRepository repository;

  GetCoursesBySubjectUseCase(this.repository);

  @override
  Future<Either<Failure, CoursesOfSubjectResponseModel>> call(
    ParamGetCoursesBySubject param,
  ) {
    return repository.getCoursesBySubject(param);
  }
}

class ParamGetCoursesBySubject {
  final String subjectId;
  final int limit;
  final int page;
  ParamGetCoursesBySubject(
    this.subjectId, {
    required this.limit,
    required this.page,
  });
}
