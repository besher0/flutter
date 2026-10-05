import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:coursaty_student_and_teacher/features/common/domain/repositories/upload_file_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/upload_file_response_model.dart';
import 'package:mime_type/mime_type.dart';

@injectable
class UploadFileUsecase
    extends UseCase<UploadFileResponseModel, UploadFileParams> {
  final UploadFileRepository repository;

  UploadFileUsecase(this.repository);

  @override
  Future<Either<Failure, UploadFileResponseModel>> call(
    UploadFileParams param,
  ) async {
    return repository.uploadFile(await param.data());
  }
}

class UploadFileParams {
  final File file;

  UploadFileParams({required this.file});

  Future<Map<String, dynamic>> data() async {
    String fileName = file.path.split('/').last;
    String mimeType = mime(fileName) ?? '';
    String mimee = mimeType.split('/')[0];
    String type = mimeType.split('/')[1];
    Map<String, dynamic> data = {
      'data': FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: MediaType(mimee, type),
        ),
      }),
    };
    return data;
  }
}
