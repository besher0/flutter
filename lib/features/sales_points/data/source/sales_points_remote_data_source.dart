import 'package:injectable/injectable.dart';

import '../../../../core/api/client_config.dart';
import '../../../../core/api/detect_server.dart';
import '../../../../core/api/methods/get.dart';
import '../../../../core/common/constant/configuration/url_routes.dart';
import '../model/sale_point_model.dart';

@injectable
class SalesPointsRemoteDataSource {
  Future<List<SalePoint>> getSalesPoints() async {
    final GetClient<List<SalePoint>> getSalesPoints = GetClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        endpoint: EndPoints.getSalesPoints,
        response: ResponseValue(fromJson: (data) => salePointFromJson(data)),
      ),
    );
    return getSalesPoints();
  }
}
