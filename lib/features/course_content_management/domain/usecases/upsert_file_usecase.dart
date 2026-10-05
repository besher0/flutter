import 'package:coursaty_student_and_teacher/features/course_content_management/domain/repositories/course_content_management_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class UpsertFileUsecase extends UseCase<bool, UpsertFileParams> {
  final CourseContentManagementRepository repository;

  UpsertFileUsecase(this.repository);

  @override
  Future<Either<Failure, bool>> call(UpsertFileParams param) {
    return repository.upsertFile(param);
  }
}

class UpsertFileParams {
  final String? lectureId;
  final String? fileId;
  String? fileUrl;
  final bool isFree;
  final String fileName;
  final String? sortOrder;
  final String? size;

  UpsertFileParams({
    this.lectureId,
    this.fileId,
    this.fileUrl,
    required this.isFree,
    this.sortOrder,
    this.size,
    required this.fileName,
  });

  Map<String, dynamic> get data => {
    "fileName": fileName,
    "fileUrl": fileUrl,
    "isFree": isFree,
    if (sortOrder != null) "sortOrder": int.parse(sortOrder!),
    "fileType": "pdf",
    if (lectureId != null) "lectureId": lectureId,
    if (size != null) "size": size,
  };
}
