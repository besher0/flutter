import 'package:coursaty_student_and_teacher/core/api/client_config.dart';
import 'package:coursaty_student_and_teacher/core/api/detect_server.dart';
import 'package:coursaty_student_and_teacher/core/api/methods/post.dart';
import 'package:coursaty_student_and_teacher/core/common/constant/configuration/bunny_url_routes.dart';
import 'package:coursaty_student_and_teacher/features/common/data/models/upload_file_response_model.dart';
import 'package:injectable/injectable.dart';

@injectable
class UploadFileRemoteDatasource {
  Future<UploadFileResponseModel> uploadFile(Map<String, dynamic> data) {
    final PostClient<UploadFileResponseModel> uploadFile = PostClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        data: data['data'],
        endpoint: BunnyEndPoints.uploadFile,
        receiveTimeout: const Duration(minutes: 2),
        sendTimeout: const Duration(minutes: 2),
        response: ResponseValue(
          fromJson: (data) => UploadFileResponseModel.fromJson(data),
        ),
      ),
    );

    return uploadFile();
  }
}
