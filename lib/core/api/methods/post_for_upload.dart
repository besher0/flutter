import 'dart:async';
import 'package:dio/dio.dart';
import '../../../services/device_info_service.dart';
import '../../common/constant/configuration/url_routes.dart';
import '../../enums/status_code_type.dart';
import '../api.dart';
import '../client_config.dart';
import '../detect_server.dart';

typedef whenComplete = FutureOr<void> Function();

class PostForUploadClient<T> extends BaseApi<T> {
  final void Function(bool isUploadingSuccess)? onUploadingFinished;

  PostForUploadClient({
    required this.requestPrams,
    this.serverName = ServerName.master,
    this.onUploadingFinished,
    this.onSendProgress,
    this.onReceiveProgress,
  }) : _fromJson = requestPrams.response.fromJson,
       _valueOnSuccess = requestPrams.response.returnValueOnSuccess,
       _queryParameters = requestPrams.queryParameters,
       _data = requestPrams.data,
       _endpoint = requestPrams.endpoint,
       _receiveTimeout = requestPrams.receiveTimeout,
       _sendTimeout = requestPrams.sendTimeout,
       super();
  final Stopwatch stopWatch = Stopwatch();
  final RequestConfig<T> requestPrams;

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
      final Response response = await client.postUri(
        Uri(
          host: baseUri.host,
          scheme: baseUri.scheme,
          path: _endpoint,
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

      if (response.statusCode == StatusCode.operationSucceeded.code ||
          response.statusCode == StatusCode.createSucceeded.code) {
        if (_fromJson == null) {
          return Future.value(_valueOnSuccess);
        }

        return _fromJson(response.data);
      } else {
        print(response.statusCode);
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
