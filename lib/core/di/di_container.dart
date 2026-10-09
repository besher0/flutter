import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/log_interceptor.dart';
import '../storage/prefs_repository.dart';
import '../storage/prefs_repository_impl.dart';
import 'di_container.config.dart';

final GetIt _getIt = GetIt.I;

@InjectableInit(
  initializerName: r'$initGetIt',
  preferRelativeImports: true,
  asExtension: false,
)
Future<GetIt> configureDependencies() async => $initGetIt(_getIt);

/// Bumped by [resetDependencies] so the root providers (ServiceProvider) hand
/// out the newly created singletons.
final ValueNotifier<int> dependenciesGeneration = ValueNotifier(0);

/// Recreates every GetIt singleton (sign-out, guest to login) and lets the
/// widget tree switch to the new instances. Without the switch, code reading
/// a bloc from `context` keeps the old instance while code using `GetIt` gets
/// the new one: a download then runs on one bloc while the screen watches
/// another, so its progress and cancel button never appear.
Future<void> resetDependencies() async {
  await _getIt.reset();
  await configureDependencies();
  dependenciesGeneration.value++;
}

@module
abstract class AppModule {
  BaseOptions get dioOption => BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
    contentType: 'application/json',
    responseType: ResponseType.json,
    headers: <String, String>{HttpHeaders.acceptHeader: 'application/json'},
  );

  @singleton
  Logger get logger => Logger();

  @preResolve
  @singleton
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  @preResolve
  @singleton
  Future<PrefsRepository> get prefsRepository async {
    SharedPreferences prefs = await sharedPreferences;
    return PrefsRepositoryImpl(prefs);
  }

  @singleton
  Dio dio(BaseOptions option, Logger logger) {
    final dio = Dio(option);
    if (kDebugMode) dio.interceptors.add(LoggerInterceptor());
    return dio;
  }
}
