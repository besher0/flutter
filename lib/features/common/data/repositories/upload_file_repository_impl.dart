import 'package:coursaty_student_and_teacher/core/api/api.dart';
import 'package:coursaty_student_and_teacher/core/error/failures.dart';
import 'package:coursaty_student_and_teacher/features/common/data/models/upload_file_response_model.dart';
import 'package:coursaty_student_and_teacher/features/common/data/sources/upload_file_remote_datasource.dart';
import 'package:coursaty_student_and_teacher/features/common/domain/repositories/upload_file_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: UploadFileRepository)
class UploadFileRepositoryImpl extends UploadFileRepository
    with HandlingExceptionRequest {
  final UploadFileRemoteDatasource datasource;

  UploadFileRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, UploadFileResponseModel>> uploadFile(
    Map<String, dynamic> data,
  ) {
    return handlingExceptionRequest(tryCall: () => datasource.uploadFile(data));
  }
}
