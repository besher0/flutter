import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../storage/prefs_repository.dart';
import 'handling_exception.dart';

abstract class BaseApi<T> with HandlingExceptionRequest {
  BaseApi() {
    Map<String, dynamic> headers = client.options.headers;
    final String? token = GetIt.I<PrefsRepository>().token;

    if (token != null) {
      headers = client.options.headers
        ..[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
    headers.addAll({
      'User-Agent':
          'device OS:${Platform.isAndroid ? 'Android' : 'IOS'} , application version: 1.0.0',
    });
    options = Options(headers: headers);
  }

  final client = GetIt.I<Dio>();

  late Options options;

  Future<T> call();
}
