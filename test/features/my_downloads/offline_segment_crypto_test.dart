import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AES-256-GCM segment round-trip preserves bytes and SHA-256', () async {
    final original = List<int>.generate(4096, (index) => index % 251);
    final algorithm = AesGcm.with256bits();
    final key = await algorithm.newSecretKey();
    final encrypted = await algorithm.encrypt(original, secretKey: key);
    final decrypted = await algorithm.decrypt(encrypted, secretKey: key);
    final originalHash = await Sha256().hash(original);
    final decryptedHash = await Sha256().hash(decrypted);

    expect(decrypted, orderedEquals(original));
    expect(decrypted.length, original.length);
    expect(decryptedHash.bytes, orderedEquals(originalHash.bytes));
  });
}
