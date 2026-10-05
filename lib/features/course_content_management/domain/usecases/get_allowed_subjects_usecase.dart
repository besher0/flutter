import 'package:coursaty_student_and_teacher/features/course_content_management/data/models/allowed_subjects_model.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/repositories/course_content_management_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class GetAllowedSubjectsUsecase
    extends UseCase<GetAllowedSubjectsResponseModel, NoParams> {
  final CourseContentManagementRepository repository;

  GetAllowedSubjectsUsecase(this.repository);

  @override
  Future<Either<Failure, GetAllowedSubjectsResponseModel>> call(
    NoParams params,
  ) {
    return repository.getAllowedSubjects();
  }
}
