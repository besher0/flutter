import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../enums/status_code_type.dart';
import 'api.dart';
import 'handling_exception.dart';

enum _StatusType { succeed, failed }

class LoggerInterceptor extends Interceptor with HandlingExceptionRequest {
  static const _sensitiveKeys = {
    'authorization',
    'token',
    'accessToken',
    'refreshToken',
    'playback',
    'playbackUrl',
    'downloadUrl',
    'signature',
  };

  Object? _redact(Object? value) {
    if (value is Map) {
      return value.map((key, dynamic item) {
        final lowerKey = key.toString().toLowerCase();
        if (_sensitiveKeys.any(
          (sensitive) => lowerKey.contains(sensitive.toLowerCase()),
        )) {
          return MapEntry(key, '<redacted>');
        }
        return MapEntry(key, _redact(item));
      });
    }
    if (value is Iterable) {
      return value.map(_redact).toList();
    }
    if (value is String) {
      return value
          .replaceAll(RegExp(r'bcdn_token=[^&\s]+'), 'bcdn_token=<redacted>')
          .replaceAllMapped(
            RegExp(r'([?&]deviceId=)[^&\s]+'),
            (match) => '${match.group(1)}<redacted>',
          )
          .replaceAllMapped(
            RegExp(r'(deviceId:\s*)[^,}\s]+'),
            (match) => '${match.group(1)}<redacted>',
          )
          .replaceAll(
            RegExp(r'Bearer\s+[A-Za-z0-9._\-]+'),
            'Bearer <redacted>',
          );
    }
    return value;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final redactedPath = _redact(options.path);
      prettyPrinterI(
        "***|| INFO Request $redactedPath ||***"
        "\n HTTP Method: ${options.method}"
        "\n token : <redacted>"
        "\n param : ${_redact(options.data)}"
        "\n url: $redactedPath"
        "\n Header: ${_redact(options.headers)}"
        "\n timeout: ${options.connectTimeout! ~/ 1000}s",
      );
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final statusType =
          response.statusCode == StatusCode.operationSucceeded.code ||
              response.statusCode == StatusCode.createSucceeded.code
          ? _StatusType.succeed
          : _StatusType.failed;
      final requestRoute = _redact(response.requestOptions.path);

      if (statusType == _StatusType.failed) {
        prettyPrinterError(
          '***|| ${statusType.name.toUpperCase()} Response into -> $requestRoute ||***',
        );
      } else {
        prettyPrinterV(
          '***|| ${statusType.name.toUpperCase()} Response into -> $requestRoute ||***',
        );
      }
      prettyPrinterWtf(
        "***|| INFO Response Request $requestRoute ||***"
        "\n Status code: ${response.statusCode}"
        "\n Status message: ${response.statusMessage}"
        "\n Data: ${_redact(response.data)}",
      );
      log(_redact(response.data).toString());
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      log(_redact(err.response?.data).toString());
      prettyPrinterError(
        "***|| SOMETHING ERROR ||***"
        "\n error: ${err.error}"
        "\n response: ${_redact(err.response?.data)}"
        "\n message: ${err.message}"
        "\n type: ${err.type}"
        "\n stackTrace: ${err.stackTrace}",
      );
    }
    handler.next(err);
  }
}
