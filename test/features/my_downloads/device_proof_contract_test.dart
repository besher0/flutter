import 'dart:convert';
import 'dart:io';

import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/video_access_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Cross-language contract shared with the backend test
/// `src/modules/videos/device-proof-contract.spec.ts`. The fixture was signed
/// by Node with SHA256withECDSA (DER), the same format Android Keystore
/// produces; the backend test verifies the signature, this test verifies the
/// app builds byte-identical signed payloads and Play Integrity hashes.
void main() {
  final contract =
      jsonDecode(
            File('test/fixtures/device_proof_contract.json').readAsStringSync(),
          )
          as Map<String, dynamic>;

  for (final raw in contract['cases'] as List<dynamic>) {
    final fixture = raw as Map<String, dynamic>;
    final action = VideoProofAction.values.firstWhere(
      (value) => value.wireName == fixture['action'],
    );

    test('canonical payload matches the backend for ${action.wireName}', () {
      final payload = videoDeviceProofPayload(
        action: action,
        videoId: fixture['videoId'] as String,
        deviceId: fixture['deviceId'] as String,
        timestamp: (fixture['timestamp'] as num).toInt(),
        challenge: fixture['challenge'] as String,
      );

      expect(payload, fixture['canonical']);
      expect(utf8.encode(payload), utf8.encode(fixture['canonical'] as String));
    });

    test('Play Integrity request hash matches for ${action.wireName}', () {
      expect(
        videoPlaybackRequestHash(fixture['canonical'] as String),
        fixture['requestHash'],
      );
    });
  }

  test('public key fixture is X.509 SPKI for P-256 like Android getEncoded', () {
    final der = base64Url.decode(
      base64Url.normalize(contract['publicKey'] as String),
    );
    // SEQUENCE { SEQUENCE { id-ecPublicKey, prime256v1 }, BIT STRING (04|X|Y) }
    expect(der.length, 91);
    expect(
      base64.encode(der.sublist(0, 27)),
      'MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE',
    );
  });
}
