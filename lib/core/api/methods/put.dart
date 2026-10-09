import 'dart:async';
import 'package:coursaty_student_and_teacher/core/common/constant/configuration/url_routes.dart';
import 'package:dio/dio.dart';
import '../../../services/device_info_service.dart';
import '../../enums/status_code_type.dart';
import '../api.dart';
import '../client_config.dart';
import 'dart:developer';

import '../detect_server.dart';

class PutClient<T> extends BaseApi<T> {
  PutClient({
    required this.requestPrams,
    this.serverName = ServerName.master,
    this.onSendProgress,
    this.onReceiveProgress,
  }) : _fromJson = requestPrams.response.fromJson,
       _valueOnSuccess = requestPrams.response.returnValueOnSuccess,
       _data = requestPrams.data,
       _queryParameters = requestPrams.queryParameters,
       _endpoint = requestPrams.endpoint,
       _receiveTimeout = requestPrams.receiveTimeout,
       _sendTimeout = requestPrams.sendTimeout,
       super();

  final RequestConfig<T> requestPrams;
  final Stopwatch stopWatch = Stopwatch();
  final ProgressCallback? onSendProgress;
  final ProgressCallback? onReceiveProgress;
  final Duration? _receiveTimeout;
  final Duration? _sendTimeout;

  final FromJson<T>? _fromJson;
  final T? _valueOnSuccess;
  final dynamic _queryParameters;
  final dynamic _data;
  final String _endpoint;
  final ServerName serverName;

  @override
  Future<T> call() async {
    try {
      final baseUri = getBaseUriForSpecificServer(serverName);
      stopWatch.start();
      final Response response = await client.putUri(
        Uri(
          host: baseUri.host,
          scheme: baseUri.scheme,
          path: apiPathFor(serverName, _endpoint),
          port: MasterUrlRoutes.port,
          queryParameters: _queryParameters,
        ),
        options: options.copyWith(
          receiveTimeout: _receiveTimeout ?? options.receiveTimeout,
          sendTimeout: _sendTimeout ?? options.sendTimeout,
        ),
        data: {...?_data, "deviceId": DeviceInfoService.getDeviceId()},
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      stopWatch.stop();
      log('request time: ${stopWatch.elapsed.toString()}');
      prettyPrinterI(stopWatch.elapsed.toString());
      if (response.statusCode == StatusCode.operationSucceeded.code) {
        if (_fromJson == null) {
          return Future.value(_valueOnSuccess);
        }

        return _fromJson(response.data);
      } else {
        throw getException(
          statusCode: response.statusCode!,
          message:
              response.data['message'] ??
              response.data['result'] ??
              response.data['error'],
        );
      }
    } catch (exception) {
      rethrow;
    }
  }
}
