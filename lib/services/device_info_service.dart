import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:device_safety_info/device_safety_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  static const MethodChannel _securityChannel = MethodChannel(
    'coursaty/video_security',
  );
  static const String _iosLoginDeviceKey = 'coursaty_login_device_id_v1';
  static String? _loginDeviceId;
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
    await _initLoginDeviceId();
    isRealDevice = isPhysicalDevice();
  }

  /// Identifies this phone for the student single-device login. Unlike the
  /// installation id it survives reinstalling the app, so a reinstall does not
  /// lock the student out: Android's ANDROID_ID (per device and signing key,
  /// reset only by a factory reset) or an iOS Keychain entry (kept across
  /// reinstalls). Sent hashed; falls back to the installation id.
  static String getLoginDeviceId() =>
      _loginDeviceId ?? getInstallationDeviceId();

  /// Random id of this app installation (lost when the app is reinstalled).
  static String getInstallationDeviceId() =>
      _installationDeviceId ?? getDeviceId();

  /// Whether [deviceId] names this phone: its login device id, or the
  /// installation id that video licenses used before the two were unified.
  static bool isThisDevice(String deviceId) =>
      deviceId == getLoginDeviceId() || deviceId == getInstallationDeviceId();

  static Future<void> _initLoginDeviceId() async {
    try {
      String? raw;
      if (kIsAndroid) {
        raw = await _securityChannel.invokeMethod<String>('getLoginDeviceId');
      } else if (kIsIOS) {
        const storage = FlutterSecureStorage();
        raw = await storage.read(key: _iosLoginDeviceKey);
        if (raw == null || raw.isEmpty) {
          final random = Random.secure();
          raw = base64Url.encode(
            List<int>.generate(32, (_) => random.nextInt(256)),
          );
          await storage.write(key: _iosLoginDeviceKey, value: raw);
        }
      }
      if (raw != null && raw.trim().isNotEmpty) {
        _loginDeviceId = await loginDeviceIdFrom(
          raw.trim(),
          platform: kIsAndroid ? 'android' : 'ios',
        );
      }
    } catch (error) {
      debugPrint('login device id unavailable: ${error.runtimeType}');
    }
  }

  /// Opaque form of a platform device id; the raw id never leaves the phone.
  @visibleForTesting
  static Future<String> loginDeviceIdFrom(
    String raw, {
    required String platform,
  }) async {
    final digest = await Sha256().hash(
      utf8.encode('coursaty-login-device:$platform:$raw'),
    );
    return '${platform}_${base64Url.encode(digest.bytes).replaceAll('=', '')}';
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

  /// The video device is the login device: the account is bound to one
  /// phone, so a reinstall (new installation id, new Keystore key) is
  /// recognised as the same phone instead of needing a device replacement.
  static String getSecureVideoDeviceId() => getLoginDeviceId();
}
