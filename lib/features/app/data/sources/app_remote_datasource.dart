import 'package:coursaty_student_and_teacher/core/api/client_config.dart';
import 'package:coursaty_student_and_teacher/core/api/methods/get.dart';
import 'package:coursaty_student_and_teacher/core/api/methods/post.dart';
import 'package:coursaty_student_and_teacher/core/common/constant/configuration/url_routes.dart';
import 'package:coursaty_student_and_teacher/features/app/data/models/customer_service_model.dart';
import 'package:injectable/injectable.dart';

@injectable
class AppRemoteDatasource {
  Future<CustomerServiceModel> getCustomerService() async {
    final GetClient<CustomerServiceModel> getCustomerService = GetClient(
      requestPrams: RequestConfig(
        endpoint: EndPoints.getCustomerServiceEP,
        response: ResponseValue(
          fromJson: (data) => data is! List<dynamic>
              ? CustomerServiceModel.fromJson(data)
              : [
                  ...customerServiceListFromJson(data),
                  CustomerServiceModel(),
                ].first,
        ),
      ),
    );
    return getCustomerService();
  }

  Future<String> scanCode(String code) async {
    final PostClient<String> scanCode = PostClient(
      requestPrams: RequestConfig(
        endpoint: EndPoints.scanCodeEP,
        data: {"codeValue": code},
        response: ResponseValue(fromJson: (data) => data['courseId']),
      ),
    );
    return scanCode();
  }
}
