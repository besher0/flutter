import 'package:dio/dio.dart';

import '../../services/device_info_service.dart';
import '../common/constant/configuration/url_routes.dart';

/// Identifies this phone on every backend request. A student account works
/// on one device only; for sessions from before device binding, the first
/// device that uses the session becomes the account's device.
class DeviceHeaderInterceptor extends Interceptor {
  static const header = 'X-Coursaty-Device';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Backend only: never sent to Bunny or other hosts.
    if (options.uri.host == MasterUrlRoutes.baseUri.host) {
      options.headers[header] = DeviceInfoService.getLoginDeviceId();
    }
    handler.next(options);
  }
}
