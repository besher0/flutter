import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/upload_file_response_model.dart';

abstract class UploadFileRepository {
  Future<Either<Failure, UploadFileResponseModel>> uploadFile(
    Map<String, dynamic> data,
  );
}
