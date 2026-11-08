import 'package:coursaty_student_and_teacher/core/platform/app_platform.dart';
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
    // Informational only (they decide nothing); a plugin that fails on some
    // device must not stop the app from starting.
    try {
      screenLockEnabled = await DeviceSafetyInfo.isScreenLock;
      isRealDeviceEmulatorDetector = await DeviceSafetyInfo.isRealDevice;
    } catch (error) {
      debugPrint('device safety info unavailable: ${error.runtimeType}');
    }
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

  /// Every real phone and tablet may run the app; only emulators are refused
  /// (Android emulators on Windows, Linux or macOS such as BlueStacks,
  /// LDPlayer, Nox, MEmu, Genymotion, WSA and the Android Studio emulator, and
  /// the iOS Simulator).
  ///
  /// A device is refused only on proof of an emulator, never on a hint that
  /// real devices can also show. See [isPhysicalAndroid].
  ///
  /// ⚠️ The plugins' own checks (device_info_plus `isPhysicalDevice`,
  /// device_safety_info `isRealDevice`) look for words such as "generic",
  /// "unknown" or "sdk" anywhere in the build strings, which unbranded tablets
  /// carry, so they do not decide.
  /// iOS: refuses the Simulator and iPhone apps running on a Mac.
  /// Windows: a PC is the device itself (the teachers' version; refusing
  /// virtual machines comes with the students' version).
  static bool isPhysicalDevice() {
    if (AppPlatform.isWindows) return true;
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

  /// Native signals that no real phone or tablet shows: emulator names in
  /// the build (model, manufacturer, hardware, product, bootloader) and the
  /// QEMU kernel / emulator hardware properties.
  static const Set<String> definiteEmulatorSignals = {
    'model',
    'manufacturer',
    'hardware',
    'product',
    'bootloader',
    'prop:qemu',
    'prop:hardware',
  };

  /// Files that desktop emulators install (Genymotion, Nox, LDPlayer,
  /// BlueStacks, MEmu, VirtualBox). QEMU leftovers (`qemud`, `qemu_pipe`,
  /// `libc_malloc_debug_qemu.so`...) are not here: some real system images
  /// carry them.
  static const Set<String> emulatorVendorFiles = {
    '/dev/socket/genyd',
    '/dev/socket/baseband_genyd',
    '/system/bin/nox-prop',
    '/system/bin/nox-vbox-sf',
    '/system/lib/libnoxspeedup.so',
    '/system/bin/ldinit',
    '/system/bin/ldmountsf',
    '/system/lib/libldutils.so',
    '/boot/bstsetup.env',
    '/system/xbin/bstk',
    '/data/.bluestacks.prop',
    '/system/bin/microvirtd',
    '/system/lib/vboxsf.ko',
    '/system/lib/vboxguest.ko',
  };

  /// Kept for the diagnostics only: real devices can show them.
  static const Set<String> weakEmulatorSignals = {
    'fingerprint',
    'sensor:no-accelerometer',
    'check-failed',
    'device:chromebook',
  };

  /// Decides from the native signals ([EmulatorSignals] on the Android side).
  ///
  /// Refused only when one of these proves an emulator:
  /// - an emulator build or emulator file ([definiteEmulatorSignals],
  ///   [emulatorVendorFiles], [knownEmulatorModel]);
  /// - an x86 CPU running under a hypervisor: a virtual machine on a PC
  ///   (every real phone and tablet runs on the bare hardware);
  /// - a QEMU trace or emulated sensor together with an x86 CPU or a
  ///   hypervisor.
  ///
  /// Never refused for what real devices show: an x86 CPU alone (Intel
  /// tablets), no accelerometer (cheap tablets), a generic fingerprint
  /// (unbranded tablets), a QEMU leftover in the system image, or a native
  /// check that could not run. A Chromebook runs Android in a virtual machine
  /// (x86 + hypervisor) but is a real device, so the virtual-machine rule does
  /// not apply to it.
  ///
  /// ⚠️ A single circumstantial signal (no accelerometer, x86) and, later,
  /// any two of them refused real tablets ("run the app on a real device").
  @visibleForTesting
  static bool isPhysicalAndroid({
    required List<String> emulatorSignals,
    required bool knownEmulatorModel,
  }) {
    if (knownEmulatorModel) return false;
    final signals = emulatorSignals.toSet();
    if (signals.any(definiteEmulatorSignals.contains)) return false;
    final files = signals
        .where((s) => s.startsWith('file:'))
        .map((s) => s.substring('file:'.length));
    if (files.any(emulatorVendorFiles.contains)) return false;

    final x86 = signals.contains('abi:x86') || signals.contains('cpu:x86');
    final hypervisor = signals.contains('cpu:hypervisor');
    final chromebook = signals.contains('device:chromebook');
    if (x86 && hypervisor && !chromebook) return false;

    final qemuTrace =
        signals.contains('prop:qemu-service') ||
        signals.contains('sensor:emulated') ||
        files.isNotEmpty;
    if (qemuTrace && (x86 || hypervisor) && !chromebook) return false;
    return true;
  }

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
      // Recorded for the diagnostics only: a check that cannot run proves
      // nothing, and refusing here could lock out a real device.
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
