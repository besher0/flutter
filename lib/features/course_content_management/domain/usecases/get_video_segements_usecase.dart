import 'package:coursaty_student_and_teacher/features/course_content_management/domain/repositories/course_content_management_repository.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/lecture_details_model.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class GetVideoSegementsUsecase extends UseCase<List<Segment>, String> {
  final CourseContentManagementRepository repository;

  GetVideoSegementsUsecase(this.repository);

  @override
  Future<Either<Failure, List<Segment>>> call(String videoId) {
    return repository.getAllVideoSegments(videoId);
  }
}
