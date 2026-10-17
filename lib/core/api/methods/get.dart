import 'dart:async';
import 'dart:developer';
import 'package:coursaty_student_and_teacher/services/device_info_service.dart';
import 'package:dio/dio.dart';

import '../../common/constant/configuration/url_routes.dart';
import '../../enums/status_code_type.dart';
import '../api.dart';
import '../client_config.dart';

import '../detect_server.dart';

class GetClient<T> extends BaseApi<T> {
  GetClient({
    required this.requestPrams,
    this.serverName = ServerName.master,
    this.onReceiveProgress,
  }) : _fromJson = requestPrams.response.fromJson,
       _valueOnSuccess = requestPrams.response.returnValueOnSuccess,
       _endpoint = requestPrams.endpoint,
       _queryParameters = requestPrams.queryParameters,
       _data = requestPrams.data,
       _receiveTimeout = requestPrams.receiveTimeout,
       _sendTimeout = requestPrams.sendTimeout,
       super();
  final Duration? _receiveTimeout;
  final Duration? _sendTimeout;
  final Stopwatch stopWatch = Stopwatch();
  RequestConfig<T> requestPrams;
  final ProgressCallback? onReceiveProgress;

  final FromJson<T>? _fromJson;
  final T? _valueOnSuccess;
  final String _endpoint;
  final Map<String, dynamic>? _queryParameters;
  final dynamic _data;
  final ServerName serverName;

  /// `Uri` throws on non-string query values (an `int` page or year), so
  /// numbers and booleans are sent as text; lists keep one entry per value and
  /// null stays null (a bare key, as before).
  static Map<String, dynamic> _stringQuery(Map<String, dynamic>? query) => {
    for (final entry in (query ?? const <String, dynamic>{}).entries)
      entry.key: switch (entry.value) {
        null => null,
        final Iterable values => values.map((v) => '$v').toList(),
        final value => '$value',
      },
  };

  @override
  Future<T> call() async {
    try {
      stopWatch.start();
      final baseUri = getBaseUriForSpecificServer(serverName);
      final Response response = await client.getUri(
        Uri(
          host: baseUri.host,
          scheme: baseUri.scheme,
          path: apiPathFor(serverName, _endpoint),
          port: MasterUrlRoutes.port,
          queryParameters: {
            ..._stringQuery(_queryParameters),
            "deviceId": DeviceInfoService.getDeviceId(),
          },
        ),
        options: options.copyWith(
          receiveTimeout: _receiveTimeout ?? options.receiveTimeout,
          sendTimeout: _sendTimeout ?? options.sendTimeout,
        ),
        onReceiveProgress: onReceiveProgress,
        data: _data,
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
        final exception = getException(
          statusCode: response.statusCode!,
          message:
              response.data['message'] ??
              response.data['result'] ??
              response.data['error'],
        );
        throw exception;
      }
    } catch (exception) {
      rethrow;
    }
  }
}
