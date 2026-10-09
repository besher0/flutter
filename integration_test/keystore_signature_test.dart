// On-device check of the Android Keystore bridge in MainActivity.kt.
//
// Run on an Android device or emulator:
//   flutter test integration_test/keystore_signature_test.dart -d <device>
//
// It signs the canonical payload from test/fixtures/device_proof_contract.json
// with the real Keystore key and prints the public key and signature as one
// JSON line prefixed with KEYSTORE_PROOF=. The backend test
// src/modules/videos/device-proof-contract.spec.ts verifies such a capture
// with the production verification code (see __fixtures__/android-keystore-proof.json).
import 'dart:convert';

import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/video_access_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const _channel = MethodChannel('coursaty/video_security');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Keystore key is EC P-256 SPKI, stable, and signs proofs', (
    tester,
  ) async {
    // Non-destructive: reuse the installation's key if it already exists, so
    // running this on a real phone never breaks its registered device key.
    await _channel.invokeMethod<void>('ensureVideoDeviceKey');
    expect(await _channel.invokeMethod<bool>('hasVideoDeviceKey'), isTrue);

    final publicKey = await _channel.invokeMethod<String>(
      'getVideoDevicePublicKey',
    );
    final der = base64Url.decode(base64Url.normalize(publicKey!));
    expect(der.length, 91, reason: 'P-256 SubjectPublicKeyInfo is 91 bytes');
    expect(
      base64.encode(der.sublist(0, 27)),
      'MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE',
    );

    // Re-ensuring must not rotate the key (registration stays idempotent).
    await _channel.invokeMethod<void>('ensureVideoDeviceKey');
    expect(
      await _channel.invokeMethod<String>('getVideoDevicePublicKey'),
      publicKey,
    );

    final proofs = <Map<String, String>>[];
    for (final action in VideoProofAction.values) {
      final payload = videoDeviceProofPayload(
        action: action,
        videoId: '4a6f6b8e-2f1c-4d3b-9a7e-1c2d3e4f5a6b',
        deviceId: 'install_Zm9vYmFyLWRldmljZS1pZC0xMjM0NTY3ODkwYWJjZGVm',
        timestamp: 1791100800123,
        challenge: 'q8Jx3mZ0cW9tLXZpZGVvLWNoYWxsZW5nZS1zYW1wbGU',
      );
      final signature = await _channel.invokeMethod<String>(
        'signVideoPayload',
        {'payload': payload},
      );
      expect(signature, isNotEmpty);
      // DER ECDSA signature: SEQUENCE tag, then two INTEGERs.
      final sigDer = base64Url.decode(base64Url.normalize(signature!));
      expect(sigDer.first, 0x30);
      proofs.add({
        'action': action.wireName,
        'canonical': payload,
        'signature': signature,
      });
    }

    // ignore: avoid_print
    print(
      'KEYSTORE_PROOF=${jsonEncode({'publicKey': publicKey, 'proofs': proofs})}',
    );
  });
}
