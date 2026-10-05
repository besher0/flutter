import 'package:coursaty_student_and_teacher/features/courses/data/model/lecture_details_model.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repository/courses_repository.dart';

@injectable
class GetLectureDetailsUsecase
    extends UseCase<LectureDetailsModel, GetLectureDetailsParams> {
  final CoursesRepository repository;

  GetLectureDetailsUsecase(this.repository);

  @override
  Future<Either<Failure, LectureDetailsModel>> call(
    GetLectureDetailsParams param,
  ) {
    return repository.getLectureDetails(param);
  }
}

class GetLectureDetailsParams {
  final String lectureId;

  GetLectureDetailsParams({required this.lectureId});
}
