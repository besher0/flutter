import 'package:coursaty_student_and_teacher/features/course_content_management/domain/repositories/course_content_management_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class DeleteVideoSegmentUsecase
    extends UseCase<bool, DeleteVideoSegmentParams> {
  final CourseContentManagementRepository repository;

  DeleteVideoSegmentUsecase(this.repository);

  @override
  Future<Either<Failure, bool>> call(DeleteVideoSegmentParams params) {
    return repository.deleteVideoSegment(params);
  }
}

class DeleteVideoSegmentParams {
  final String videoId, segmentId;
  DeleteVideoSegmentParams({required this.videoId, required this.segmentId});
}
