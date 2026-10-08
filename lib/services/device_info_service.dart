import 'dart:convert';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:device_safety_info/device_safety_info.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool kIsIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
bool kIsAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

class DeviceInfoService {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  static late final AndroidDeviceInfo androidDeviceInfo;
  static late final IosDeviceInfo iosDeviceInfo;
  static bool isRealDevice = false;
  static bool screenLockEnabled = false;
  static bool isRealDeviceEmulatorDetector = false;
  static bool _platformInfoInitialized = false;
  static const String _deviceIdPrefsKey = 'coursaty_installation_device_id_v2';
  static String? _installationDeviceId;
  DeviceInfoService();

  static Future<void> init() async {
    screenLockEnabled = await DeviceSafetyInfo.isScreenLock;
    isRealDeviceEmulatorDetector = await DeviceSafetyInfo.isRealDevice;
    if (kIsAndroid) {
      androidDeviceInfo = await deviceInfoPlugin.androidInfo;
    } else if (kIsIOS) {
      iosDeviceInfo = await deviceInfoPlugin.iosInfo;
    }
    _platformInfoInitialized = true;
    await _initInstallationDeviceId();
    isRealDevice = isPhysicalDevice();
  }

  static Future<void> _initInstallationDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getString(_deviceIdPrefsKey);
    if (current != null && current.isNotEmpty) {
      _installationDeviceId = current;
      return;
    }

    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    final deviceId = 'install_${base64Url.encode(bytes)}';
    await prefs.setString(_deviceIdPrefsKey, deviceId);
    _installationDeviceId = deviceId;
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
    if (kIsIOS && _platformInfoInitialized) {
      return iosDeviceInfo.identifierForVendor!;
    } else if (kIsAndroid && _platformInfoInitialized) {
      return '${androidDeviceInfo.id}_${androidDeviceInfo.model}';
    }
    return 'AAAA-BBBB-99CC-36EE';
  }

  static String getSecureVideoDeviceId() {
    return _installationDeviceId ?? getDeviceId();
  }
}
