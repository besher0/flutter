import 'package:coursaty_student_and_teacher/features/course_content_management/domain/repositories/course_content_management_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class UpsertVideoSegmentUsecase
    extends UseCase<bool, UpsertVideoSegmentParams> {
  final CourseContentManagementRepository repository;

  UpsertVideoSegmentUsecase(this.repository);

  @override
  Future<Either<Failure, bool>> call(UpsertVideoSegmentParams param) {
    return repository.upsertVideoSegment(param);
  }
}

class UpsertVideoSegmentParams {
  final String segmentName;
  final int startSeconds;
  final int? endSeconds;
  final int? sortOrder;
  final String videoId;
  final String? segmentId;

  UpsertVideoSegmentParams({
    required this.segmentName,
    required this.startSeconds,
    required this.endSeconds,
    required this.videoId,
    this.sortOrder,
    this.segmentId,
  });

  Map<String, dynamic> get data => {
    "segmentName": segmentName,
    "startSeconds": startSeconds,
    if (endSeconds != null) "endSeconds": endSeconds,
    if (sortOrder != null) "sortOrder": sortOrder,
  };
}
