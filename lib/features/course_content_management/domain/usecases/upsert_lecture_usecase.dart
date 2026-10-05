import 'package:coursaty_student_and_teacher/features/course_content_management/domain/repositories/course_content_management_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class UpsertLectureUsecase extends UseCase<bool, UpsertLectureParams> {
  final CourseContentManagementRepository repository;

  UpsertLectureUsecase(this.repository);

  @override
  Future<Either<Failure, bool>> call(UpsertLectureParams param) {
    return repository.upsertLecture(param);
  }
}

class UpsertLectureParams {
  final String? lectureId, description;
  final String courseId, title;

  final int? sortOrder;

  UpsertLectureParams({
    this.lectureId,
    required this.courseId,
    required this.title,
    this.description,
    this.sortOrder,
  });

  Map<String, dynamic> get data => {
    "courseId": courseId,
    "title": title,
    "description": description,
    if (sortOrder != null) "sortOrder": sortOrder,
  };
}
