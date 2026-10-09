import 'dart:typed_data';

import 'package:coursaty_student_and_teacher/core/api/client_config.dart';
import 'package:coursaty_student_and_teacher/core/api/detect_server.dart';
import 'package:coursaty_student_and_teacher/core/api/device_header_interceptor.dart';
import 'package:coursaty_student_and_teacher/core/api/methods/post.dart';
import 'package:coursaty_student_and_teacher/core/common/constant/configuration/url_routes.dart';
import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:coursaty_student_and_teacher/services/device_info_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

/// The backend API lives under /v2 (older app builds stop working), and every
/// backend request identifies this phone for the student single-device login.
void main() {
  group('/v2 routes', () {
    test('backend endpoints resolve under /v2', () {
      expect(MasterUrlRoutes.apiPath('auth/login'), '/v2/auth/login');
      expect(MasterUrlRoutes.apiPath('/auth/login'), '/v2/auth/login');
      expect(MasterUrlRoutes.baseUrl, endsWith('/v2/'));
      expect(apiPathFor(ServerName.master, 'videos/x'), '/v2/videos/x');
    });

    test('Bunny endpoints are not versioned', () {
      expect(apiPathFor(ServerName.bunny, 'library/1/videos'), 'library/1/videos');
    });

    test('a real request goes to /v2 with the device header', () async {
      final adapter = _RecordingAdapter();
      final dio = Dio()
        ..httpClientAdapter = adapter
        ..interceptors.add(DeviceHeaderInterceptor());
      GetIt.I
        ..registerSingleton<Dio>(dio)
        ..registerSingleton<PrefsRepository>(_Prefs());
      addTearDown(GetIt.I.reset);

      await PostClient<bool>(
        requestPrams: RequestConfig(
          endpoint: EndPoints.signUpEP,
          data: {'phone': '0999999999'},
          response: ResponseValue(returnValueOnSuccess: true),
        ),
      )();

      final sent = adapter.requests.single;
      expect(sent.uri.path, '/v2/auth/register-complete');
      expect(sent.uri.host, MasterUrlRoutes.baseUri.host);
      expect(
        sent.headers[DeviceHeaderInterceptor.header],
        DeviceInfoService.getLoginDeviceId(),
      );
    });
  });

  test('the device header is never sent to other hosts', () async {
    final adapter = _RecordingAdapter();
    final dio = Dio()
      ..httpClientAdapter = adapter
      ..interceptors.add(DeviceHeaderInterceptor());

    await dio.get('https://video.bunnycdn.com/library/1/videos');

    expect(
      adapter.requests.single.headers.containsKey(DeviceHeaderInterceptor.header),
      isFalse,
    );
  });

  group('video device follows the login device', () {
    test('video sessions use the login device id', () {
      expect(
        DeviceInfoService.getSecureVideoDeviceId(),
        DeviceInfoService.getLoginDeviceId(),
      );
    });

    test('licenses issued to the old installation id still belong to this phone', () {
      expect(
        DeviceInfoService.isThisDevice(DeviceInfoService.getLoginDeviceId()),
        isTrue,
      );
      expect(
        DeviceInfoService.isThisDevice(
          DeviceInfoService.getInstallationDeviceId(),
        ),
        isTrue,
      );
      expect(DeviceInfoService.isThisDevice('android_someone-else'), isFalse);
    });
  });
}

class _RecordingAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      '{"ok":true}',
      201,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _Prefs implements PrefsRepository {
  @override
  String? get token => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
