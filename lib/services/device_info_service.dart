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

  /// Emulator / PC Android signals found by the native check (Android only).
  static List<String> emulatorSignals = const [];
  static bool _platformInfoInitialized = false;
  static const String _deviceIdPrefsKey = 'coursaty_installation_device_id_v2';
  static String? _installationDeviceId;
  static const MethodChannel _securityChannel = MethodChannel(
    'coursaty/video_security',
  );
  static const String _iosLoginDeviceKey = 'coursaty_login_device_id_v1';
  static String? _loginDeviceId;
  static String? _loginDeviceAltId;
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
    if (kIsAndroid) emulatorSignals = await _readEmulatorSignals();
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

  /// A second id of this phone that does not depend on the app's signing key
  /// (hashed Widevine id, Android only). ANDROID_ID changes when the app is
  /// reinstalled with another signature — an APK from outside the store, then
  /// the store version — and the student was refused as "another device"; the
  /// server recognises the phone by this id and moves the binding. Null when
  /// the phone has no Widevine.
  static String? getLoginDeviceAltId() => _loginDeviceAltId;

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
    if (!kIsAndroid) return;
    try {
      final alt = await _securityChannel.invokeMethod<String>(
        'getLoginDeviceAltId',
      );
      if (alt != null && alt.trim().isNotEmpty) {
        _loginDeviceAltId = await loginDeviceIdFrom(
          alt.trim(),
          platform: 'android-drm',
        );
      }
    } catch (error) {
      debugPrint('second login device id unavailable: ${error.runtimeType}');
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

  /// Only real phones and tablets may run the app.
  ///
  /// Android: emulators on Windows/macOS (BlueStacks, LDPlayer, Nox, WSA, ...)
  /// report isPhysicalDevice = true, so the native check looks for what they
  /// cannot hide: an x86 CPU or hypervisor, QEMU/VirtualBox traces, and a
  /// missing or emulated accelerometer. A screen lock is no longer required:
  /// it said nothing about the device (emulators can set one) and locked out
  /// real phones without one.
  ///
  /// ⚠️ The plugins' own checks (device_info_plus `isPhysicalDevice`,
  /// device_safety_info `isRealDevice`) and an AOSP "generic" fingerprint used
  /// to refuse the device too. They look for words such as "generic",
  /// "unknown" or "sdk" anywhere in the build strings, which unbranded tablets
  /// carry, so they no longer decide; every emulator they catch also leaves
  /// one of the signals above.
  /// iOS: refuses the Simulator and iPhone apps running on a Mac.
  static bool isPhysicalDevice() {
    if (kIsIOS) {
      return iosDeviceInfo.isPhysicalDevice && !iosDeviceInfo.isiOSAppOnMac;
    } else if (kIsAndroid) {
      return isPhysicalAndroid(
        emulatorSignals: emulatorSignals,
        knownEmulatorModel: isKnownEmulator(),
      );
    }
    return false;
  }

  /// Native signals that real devices can show as well; reported, never
  /// blocking on their own.
  static const Set<String> weakEmulatorSignals = {'fingerprint'};

  @visibleForTesting
  static bool isPhysicalAndroid({
    required List<String> emulatorSignals,
    required bool knownEmulatorModel,
  }) =>
      emulatorSignals.every(weakEmulatorSignals.contains) &&
      !knownEmulatorModel;

  /// Why this device was refused, shown on the refusal page so a wrongly
  /// refused device can be reported (e.g. "cpu:hypervisor, model").
  static String get emulatorDiagnostics => [
    ...emulatorSignals.where((s) => !weakEmulatorSignals.contains(s)),
    if (kIsAndroid && _platformInfoInitialized && isKnownEmulator())
      'known-build',
  ].join(', ');

  static Future<List<String>> _readEmulatorSignals() async {
    try {
      return await _securityChannel.invokeListMethod<String>(
            'getEmulatorSignals',
          ) ??
          const [];
    } catch (error) {
      // Fail closed: a check that cannot run must not let an emulator in.
      debugPrint('emulator check failed: ${error.runtimeType}');
      return const ['check-failed'];
    }
  }

  static bool isKnownEmulator() {
    final info = androidDeviceInfo;
    return isKnownEmulatorBuild([
      info.brand,
      info.device,
      info.model,
      info.hardware,
      info.product,
      info.fingerprint,
      info.manufacturer,
    ]);
  }

  /// Emulator names, matched as whole words of each build field.
  ///
  /// ⚠️ The fields used to be joined into one string and searched for
  /// fragments such as "unknown", "generic", "sdk", "x86", "virtual" or
  /// "andy", which real (often unbranded) tablets and phones contain, and the
  /// list even named a real Samsung phone ("gracelte").
  @visibleForTesting
  static bool isKnownEmulatorBuild(List<String> fields) {
    const emulatorWords = {
      'goldfish',
      'ranchu',
      'vbox',
      'vbox86',
      'vbox86p',
      'virtualbox',
      'genymotion',
      'bluestacks',
      'memu',
      'nox',
      'ldplayer',
      'waydroid',
      'google_sdk',
      'sdk_google',
      'sdk_x86',
      'emulator',
    };
    for (final field in fields) {
      for (final word in field.toLowerCase().split(RegExp(r'[^a-z0-9_]+'))) {
        if (emulatorWords.contains(word) ||
            word.startsWith('sdk_gphone') ||
            word.startsWith('generic_x86')) {
          return true;
        }
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
