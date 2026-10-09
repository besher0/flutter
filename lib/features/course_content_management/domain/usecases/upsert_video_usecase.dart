import 'package:coursaty_student_and_teacher/features/course_content_management/domain/repositories/course_content_management_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class UpsertVideoUsecase extends UseCase<bool, UpsertVideoParams> {
  final CourseContentManagementRepository repository;

  UpsertVideoUsecase(this.repository);

  @override
  Future<Either<Failure, bool>> call(UpsertVideoParams param) {
    return repository.upsertVideo(param);
  }
}

class UpsertVideoParams {
  final String lectureId;
  final String? videoId;

  final String videoName;
  final String? description;
  final bool isFree;

  /// Stable Bunny play URL (contains the Bunny GUID). Only set when a new file
  /// was uploaded; metadata-only edits leave it null so the backend keeps the
  /// current video, its GUID and contentVersion (offline downloads stay valid).
  String? videoUrl;
  final String? sortOrder;
  final String? videoSize;
  final int? duration;

  UpsertVideoParams({
    required this.lectureId,
    this.description,
    this.videoId,
    required this.videoName,
    this.videoUrl,
    required this.isFree,
    this.sortOrder,
    this.videoSize,
    this.duration,
  });

  Map<String, dynamic> data() {
    final url = videoUrl?.trim();
    return {
      'videoName': videoName,
      if (description != null) 'description': description,
      'isFree': isFree,
      if (url != null && url.isNotEmpty) 'videoUrl': url,
      'lectureId': lectureId,
      if (duration != null) 'duration': duration,
      if (sortOrder != null) "sortOrder": int.parse(sortOrder!),
      if (videoSize != null) "size": videoSize,
    };
  }
}
