import 'package:coursaty_student_and_teacher/features/course_content_management/domain/repositories/course_content_management_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class DeleteFromCourseUsecase extends UseCase<bool, DeleteFromCourseParams> {
  final CourseContentManagementRepository repository;

  DeleteFromCourseUsecase(this.repository);

  @override
  Future<Either<Failure, bool>> call(DeleteFromCourseParams param) {
    return repository.deleteFromCourse(param);
  }
}

class DeleteFromCourseParams {
  final String id;
  final String endpoint;

  DeleteFromCourseParams({required this.id, required this.endpoint});
}
