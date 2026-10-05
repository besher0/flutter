import 'dart:async';
import 'package:dio/dio.dart';
import '../../common/constant/configuration/url_routes.dart';
import '../../enums/status_code_type.dart';
import '../base_api.dart';
import '../client_config.dart';
import '../detect_server.dart';

class DeleteClient<T> extends BaseApi<T> {
  DeleteClient({
    required this.requestPrams,
    this.serverName = ServerName.master,
  }) : _fromJson = requestPrams.response.fromJson,
       _valueOnSuccess = requestPrams.response.returnValueOnSuccess,
       _queryParameters = requestPrams.queryParameters,
       _endpoint = requestPrams.endpoint,
       _data = requestPrams.data,

       _receiveTimeout = requestPrams.receiveTimeout,
       _sendTimeout = requestPrams.sendTimeout,
       super();

  final RequestConfig<T> requestPrams;
  final FromJson<T>? _fromJson;
  final T? _valueOnSuccess;
  final Map<String, dynamic>? _queryParameters;
  final String _endpoint;
  final Stopwatch stopWatch = Stopwatch();
  final Duration? _receiveTimeout;
  final Duration? _sendTimeout;
  final ServerName serverName;
  final dynamic _data;

  @override
  Future<T> call() async {
    try {
      final baseUri = getBaseUriForSpecificServer(serverName);
      final Uri uri = Uri(
        host: baseUri.host,
        scheme: baseUri.scheme,
        path: _endpoint,
        port: MasterUrlRoutes.port,
        queryParameters: _queryParameters,
      );
      stopWatch.start();
      final Response response = await client.deleteUri(
        uri,
        options: options.copyWith(
          receiveTimeout: _receiveTimeout ?? options.receiveTimeout,
          sendTimeout: _sendTimeout ?? options.sendTimeout,
        ),
        data: _data,
      );
      stopWatch.stop();
      prettyPrinterI(stopWatch.elapsed.toString());
      if (response.statusCode == StatusCode.operationSucceeded.code ||
          response.statusCode == 204) {
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
