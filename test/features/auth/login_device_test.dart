import 'package:coursaty_student_and_teacher/core/api/handling_exception.dart';
import 'package:coursaty_student_and_teacher/core/error/failures.dart';
import 'package:coursaty_student_and_teacher/features/auth/domain/use_case/log_in_use_case.dart';
import 'package:coursaty_student_and_teacher/features/auth/domain/use_case/sign_up_use_case.dart';
import 'package:coursaty_student_and_teacher/services/device_info_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Students can only sign in from the device their account is bound to; the
/// app identifies the device on login and sign-up.
class _Api with HandlingExceptionRequest {}

void main() {
  test('login sends the device id', () {
    final data = ParamLogIn(phone: '0999999999', password: 'secret').data;

    expect(data['loginDeviceId'], isA<String>());
    expect(data['loginDeviceId'], isNotEmpty);
    expect(data['loginDeviceId'], DeviceInfoService.getLoginDeviceId());
  });

  test('sign-up binds student accounts to this device, not teacher accounts', () {
    ParamSignUp signUp(String type) => ParamSignUp(
      phone: '0999999999',
      userableType: type,
      password: 'password123',
      name: 'Name',
      gender: 'MALE',
    );

    expect(
      signUp('STUDENT').data['loginDeviceId'],
      DeviceInfoService.getLoginDeviceId(),
    );
    expect(signUp('TEACHER').data.containsKey('loginDeviceId'), isFalse);
  });

  test('the platform device id is sent hashed and stable', () async {
    const raw = '9774d56d682e549c';
    final first = await DeviceInfoService.loginDeviceIdFrom(
      raw,
      platform: 'android',
    );
    final again = await DeviceInfoService.loginDeviceIdFrom(
      raw,
      platform: 'android',
    );
    final other = await DeviceInfoService.loginDeviceIdFrom(
      '0123456789abcdef',
      platform: 'android',
    );

    expect(first, again);
    expect(first, startsWith('android_'));
    expect(first, isNot(contains(raw)));
    expect(first, isNot(other));
  });

  test('shows the server message when another device holds the account', () async {
    const message =
        'هذا الحساب مسجّل على جهاز آخر. لا يمكن تسجيل الدخول إلا من الجهاز الذي أُنشئ عليه الحساب';
    final result = await _Api().handlingExceptionRequest<void>(
      tryCall: () => throw DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/login'),
          statusCode: 403,
          data: {
            'errorCode': 'AUTH_STUDENT_DEVICE_LOCKED',
            'message': message,
          },
        ),
      ),
    );

    final failure = result.fold((l) => l, (_) => null);
    expect(failure, isA<DioFailure>());
    expect(failure!.message, message);
  });
}
