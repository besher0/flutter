import 'package:coursaty_student_and_teacher/core/common/helper/show_message.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:device_safety_info/device_safety_info.dart';
import 'package:flutter/foundation.dart';

bool kIsIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
bool kIsAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

class DeviceInfoService {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  static late final AndroidDeviceInfo androidDeviceInfo;
  static late final IosDeviceInfo iosDeviceInfo;
  static bool isRealDevice = false;
  static bool screenLockEnabled = false;
  static bool isRealDeviceEmulatorDetector = false;
  DeviceInfoService();

  static Future<void> init() async {
    screenLockEnabled = await DeviceSafetyInfo.isScreenLock;
    isRealDeviceEmulatorDetector = await DeviceSafetyInfo.isRealDevice;
    if (kIsAndroid) {
      androidDeviceInfo = await deviceInfoPlugin.androidInfo;
    } else if (kIsIOS) {
      iosDeviceInfo = await deviceInfoPlugin.iosInfo;
    }
    isRealDevice = isPhysicalDevice();
  }

  static bool isPhysicalDevice() {
    if (kIsIOS) {
      return true;
    } else if (kIsAndroid) {
      return screenLockEnabled &&
          !isKnownEmulator() &&
          isRealDeviceEmulatorDetector &&
          androidDeviceInfo.isPhysicalDevice;
    }
    return false;
  }

  static bool isKnownEmulator() {
    final info = androidDeviceInfo;

    final values = [
      info.brand.toLowerCase(),
      info.device.toLowerCase(),
      info.model.toLowerCase(),
      info.hardware.toLowerCase(),
      info.product.toLowerCase(),
      info.fingerprint.toLowerCase(),
      info.manufacturer.toLowerCase(),
    ];

    const emulatorKeywords = [
      'unknown',
      'google_sdk',
      'android sdk built for x86',
      'generic',
      'goldfish',
      'vbox86',
      'sdk_google',
      'ranchu',
      'sdk',
      'emulator',
      'vbox',
      'virtualbox',
      'genymotion',
      'nox',
      'bluestacks',
      'memu',
      'andy',
      'ldplayer',
      'waydroid',
      'x86',
      'virtual',
      'gracelte',
    ];
    String data = values.join('');
    for (var item in emulatorKeywords) {
      if (data.contains(item)) {
        return true;
      }
    }
    return false;
  }

  static String getDeviceId() {
    if (kIsIOS) {
      return iosDeviceInfo.identifierForVendor!;
    } else if (kIsAndroid) {
      return '${androidDeviceInfo.id}_${androidDeviceInfo.model}';
    }
    return 'AAAA-BBBB-99CC-36EE';
  }
}
