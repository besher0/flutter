import 'dart:async';
import 'dart:typed_data';

import 'package:coursaty_student_and_teacher/core/utils/ascii_digits_formatter.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/decrypted_segment_cache.dart';
import 'package:coursaty_student_and_teacher/services/background_download_keep_alive.dart';
import 'package:coursaty_student_and_teacher/services/device_info_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('phone digits on iOS Arabic keyboards', () {
    test('Arabic-Indic and Persian digits become 0-9', () {
      expect(AsciiDigitsFormatter.normalize('٠٩٦٨٠٤٥٠٢٢'), '0968045022');
      expect(AsciiDigitsFormatter.normalize('۰۹۶۸'), '0968');
      expect(AsciiDigitsFormatter.normalize('09 68-04'), '096804');
    });

    test('typed Arabic digits are kept instead of being dropped', () {
      final value = AsciiDigitsFormatter().formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '٠٩٦',
          selection: TextSelection.collapsed(offset: 3),
        ),
      );
      expect(value.text, '096');
      expect(value.selection.baseOffset, 3);
    });
  });

  group('real devices only', () {
    bool decide({List<String> signals = const [], bool knownModel = false}) =>
        DeviceInfoService.isPhysicalAndroid(
          emulatorSignals: signals,
          knownEmulatorModel: knownModel,
        );

    test('a phone with no emulator signal passes', () {
      expect(decide(), isTrue);
    });

    test('a PC emulator reporting isPhysicalDevice=true is still refused', () {
      // e.g. BlueStacks / LDPlayer / WSA: x86 CPU under a hypervisor.
      expect(decide(signals: ['abi:x86', 'cpu:hypervisor']), isFalse);
      expect(decide(signals: ['sensor:no-accelerometer']), isFalse);
    });

    test('a check that could not run fails closed', () {
      expect(decide(signals: ['check-failed']), isFalse);
    });

    test('an unbranded tablet with a "generic" build fingerprint passes', () {
      expect(decide(signals: ['fingerprint']), isTrue);
      expect(decide(signals: ['fingerprint', 'cpu:hypervisor']), isFalse);
    });

    test('emulator names are matched as whole words of the build fields', () {
      bool known(List<String> fields) =>
          DeviceInfoService.isKnownEmulatorBuild(fields);
      expect(known(['google', 'sdk_gphone64_x86_64', 'Pixel']), isTrue);
      expect(known(['generic/generic_x86/generic_x86:9/...']), isTrue);
      expect(known(['Genymotion', 'vbox86p']), isTrue);
      expect(known(['unknown']), isFalse);
      expect(known(['generic/full_rk3326/rk3326:10/user/release-keys']), isFalse);
      expect(known(['samsung', 'gracelte', 'SM-N935F']), isFalse);
      expect(known(['Lenovo', 'TB-X606F', 'mt6771', 'TB-X606F_EEA']), isFalse);
      expect(known(['Candy', 'virtual_tab', 'x86_64']), isFalse);
    });
  });

  group('offline segment cache', () {
    test('decrypts a segment once even for concurrent and range requests', () async {
      var decrypts = 0;
      final cache = DecryptedSegmentCache((index) async {
        decrypts++;
        return Uint8List.fromList([index]);
      });

      await Future.wait([cache.get(1), cache.get(1), cache.get(1)]);

      expect(decrypts, 1);
    });

    test('prefetches the next segment so it is ready when requested', () async {
      final started = <int>[];
      final cache = DecryptedSegmentCache((index) async {
        started.add(index);
        return Uint8List(0);
      });

      await cache.get(1);
      cache.prefetch(2);
      await cache.get(2);

      expect(started, [1, 2]);
    });

    test('keeps only the most recent segments in memory', () async {
      final started = <int>[];
      final cache = DecryptedSegmentCache((index) async {
        started.add(index);
        return Uint8List(0);
      }, capacity: 2);

      for (final index in [1, 2, 3, 1]) {
        await cache.get(index);
      }

      expect(started, [1, 2, 3, 1]); // 1 was evicted by 3
    });

    test('does not cache a failed decryption', () async {
      var attempts = 0;
      final cache = DecryptedSegmentCache((index) async {
        attempts++;
        if (attempts == 1) throw StateError('auth tag mismatch');
        return Uint8List(1);
      });

      await expectLater(cache.get(1), throwsStateError);
      await expectLater(cache.get(1), completion(hasLength(1)));
    });
  });

  test('background keep-alive starts with the first download and stops with the last', () async {
    final calls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('coursaty/background_downloads'),
          (call) async {
            calls.add(call.method);
            return true;
          },
        );

    await BackgroundDownloadKeepAlive.acquire();
    await BackgroundDownloadKeepAlive.acquire();
    await BackgroundDownloadKeepAlive.release();
    expect(calls, ['start']);
    await BackgroundDownloadKeepAlive.release();

    expect(calls, ['start', 'stop']);
    expect(BackgroundDownloadKeepAlive.activeDownloads, 0);
  });
}
