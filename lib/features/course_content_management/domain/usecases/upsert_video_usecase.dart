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
  String videoUrl;
  final String? sortOrder;
  final String? videoSize;
  final int? duration;

  UpsertVideoParams({
    required this.lectureId,
    this.description,
    this.videoId,
    required this.videoName,
    required this.videoUrl,
    required this.isFree,
    this.sortOrder,
    this.videoSize,
    this.duration,
  });

  Map<String, dynamic> data() {
    final parts = videoUrl.split('play_');
    String videoFixedUrl = parts.isNotEmpty
        ? "${videoUrl.split('play_')[0]}play_"
        : videoUrl;
    return {
      'videoName': videoName,
      if (description != null) 'description': description,
      'isFree': isFree,
      'preferredResolution': "480p",
      'videoUrl': videoFixedUrl,
      'lectureId': lectureId,
      if (duration != null) 'duration': duration,
      if (sortOrder != null) "sortOrder": int.parse(sortOrder!),
      if (videoSize != null) "size": videoSize,
    };
  }
}
