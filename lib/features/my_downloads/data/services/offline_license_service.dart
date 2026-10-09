import 'dart:convert';
import 'dart:developer';

import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/models/secure_video_models.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/video_access_service.dart';
import 'package:coursaty_student_and_teacher/services/device_info_service.dart';
import 'package:cryptography/cryptography.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineLicenseValidationResult {
  final bool isValid;
  final String? message;
  final OfflineLicenseInvalidReason? reason;

  const OfflineLicenseValidationResult.valid()
    : isValid = true,
      message = null,
      reason = null;

  const OfflineLicenseValidationResult.invalid(this.message, {this.reason})
    : isValid = false;
}

enum OfflineLicenseInvalidReason {
  unsupportedAlgorithm,
  invalidSignature,
  videoMismatch,
  deviceMismatch,
  userMismatch,
  contentVersionMismatch,
  trustedTimeUnavailable,
  expired,
}

@lazySingleton
class OfflineLicenseService {
  OfflineLicenseService(
    this._videoAccessService,
    this._prefs,
    this._sharedPreferences,
  );

  final VideoAccessService _videoAccessService;
  final PrefsRepository _prefs;
  final SharedPreferences _sharedPreferences;
  final Ed25519 _ed25519 = Ed25519();

  Future<OfflineLicenseValidationResult> validate({
    required OfflineLicense license,
    required String videoId,
    required int contentVersion,
  }) async {
    if (license.algorithm.toLowerCase() != 'ed25519') {
      return const OfflineLicenseValidationResult.invalid(
        'Unsupported offline license algorithm',
        reason: OfflineLicenseInvalidReason.unsupportedAlgorithm,
      );
    }
    final hasValidSignature = await verifySignature(license);
    if (!hasValidSignature) {
      return const OfflineLicenseValidationResult.invalid(
        'Invalid offline license signature',
        reason: OfflineLicenseInvalidReason.invalidSignature,
      );
    }
    if (!_signedPayloadMatchesVisiblePayload(license)) {
      return const OfflineLicenseValidationResult.invalid(
        'Offline license signed payload mismatch',
        reason: OfflineLicenseInvalidReason.invalidSignature,
      );
    }
    final payload = license.payload;
    if (payload.videoId != videoId) {
      return const OfflineLicenseValidationResult.invalid(
        'Offline license video mismatch',
        reason: OfflineLicenseInvalidReason.videoMismatch,
      );
    }
    if (!DeviceInfoService.isThisDevice(payload.deviceId)) {
      return const OfflineLicenseValidationResult.invalid(
        'Offline license device mismatch',
        reason: OfflineLicenseInvalidReason.deviceMismatch,
      );
    }
    if ((_prefs.userId ?? '') != payload.userId) {
      return const OfflineLicenseValidationResult.invalid(
        'Offline license user mismatch',
        reason: OfflineLicenseInvalidReason.userMismatch,
      );
    }
    if (payload.contentVersion != contentVersion) {
      return const OfflineLicenseValidationResult.invalid(
        'Offline license content version mismatch',
        reason: OfflineLicenseInvalidReason.contentVersionMismatch,
      );
    }
    final trustedNow = _trustedNow();
    if (trustedNow == null) {
      return const OfflineLicenseValidationResult.invalid(
        'Online validation is required for trusted offline time',
        reason: OfflineLicenseInvalidReason.trustedTimeUnavailable,
      );
    }
    if (!trustedNow.isBefore(payload.expiresAt)) {
      return const OfflineLicenseValidationResult.invalid(
        'Offline license expired',
        reason: OfflineLicenseInvalidReason.expired,
      );
    }
    return const OfflineLicenseValidationResult.valid();
  }

  Future<bool> verifySignature(OfflineLicense license) async {
    if (license.signedPayload.isEmpty) return false;
    final publicKey = await _publicKeyFor(license.keyId);
    if (publicKey == null || publicKey.publicKey.isEmpty) return false;
    final signatureBytes = _decodeKeyMaterial(license.signature);
    final signedPayloadBytes = _decodeKeyMaterial(license.signedPayload);
    final keyBytes = _decodePublicKeyMaterial(publicKey.publicKey);
    if (keyBytes.length != 32) {
      throw FormatException(
        'Ed25519 public key must contain 32 raw bytes, got ${keyBytes.length}',
      );
    }
    final publicKeyObject = SimplePublicKey(
      keyBytes,
      type: KeyPairType.ed25519,
    );
    return _ed25519.verify(
      signedPayloadBytes,
      signature: Signature(signatureBytes, publicKey: publicKeyObject),
    );
  }

  Future<OfflineLicense?> renewIfNeeded({
    required OfflineLicense license,
    required String videoId,
    required int contentVersion,
    required String preferredResolution,
  }) async {
    final now = _trustedNow();
    if (now != null && license.payload.expiresAt.difference(now).inHours > 24) {
      return license;
    }
    final renewed = await _videoAccessService.renewOfflineLicense(
      videoId: videoId,
      preferredResolution: preferredResolution,
    );
    final result = await validate(
      license: renewed,
      videoId: videoId,
      contentVersion: contentVersion,
    );
    return result.isValid ? renewed : null;
  }

  /// Latest device time observed while validating offline licenses. Reset to
  /// "now" whenever a server response records trusted time.
  static const clockHighWaterKey = 'offlineClockHighWater';
  static const _clockTolerance = Duration(minutes: 2);

  /// Server time advanced by the device clock since it was recorded.
  ///
  /// If the device clock is earlier than any time already observed (it was
  /// set back), offline time cannot be trusted and null is returned, which
  /// forces one online check instead of freezing the license clock forever.
  DateTime? _trustedNow() {
    final trusted = _sharedPreferences.getString('trustedServerTime');
    final local = _sharedPreferences.getString('trustedLocalRecordedTime');
    if (trusted == null || local == null) return null;
    final trustedTime = DateTime.tryParse(trusted);
    final localTime = DateTime.tryParse(local);
    if (trustedTime == null || localTime == null) return null;

    final now = DateTime.now().toUtc();
    final highWater = DateTime.tryParse(
      _sharedPreferences.getString(clockHighWaterKey) ?? '',
    );
    var floor = localTime;
    if (highWater != null && highWater.isAfter(floor)) floor = highWater;
    if (now.isBefore(floor.subtract(_clockTolerance))) {
      log('Device clock moved backwards; offline time is not trusted');
      return null;
    }
    if (highWater == null || now.isAfter(highWater)) {
      _sharedPreferences.setString(clockHighWaterKey, now.toIso8601String());
    }

    final elapsed = now.difference(localTime);
    return trustedTime.add(elapsed.isNegative ? Duration.zero : elapsed);
  }

  Future<OfflinePublicKey?> _publicKeyFor(String keyId) async {
    final cached = _sharedPreferences.getString('offline_public_key_$keyId');
    if (cached != null) {
      return OfflinePublicKey.fromJson(jsonDecode(cached));
    }
    log('Offline license public-key cache miss; requesting public key');
    final keys = await _videoAccessService.getOfflineLicensePublicKeys();
    for (final key in keys) {
      await _sharedPreferences.setString(
        'offline_public_key_${key.keyId}',
        jsonEncode(key.toJson()),
      );
    }
    for (final key in keys) {
      if (key.keyId == keyId) return key;
    }
    return null;
  }

  List<int> _decodeKeyMaterial(String value) {
    final normalized = value.trim();
    try {
      return base64Url.decode(base64Url.normalize(normalized));
    } catch (_) {
      return base64.decode(normalized);
    }
  }

  List<int> _decodePublicKeyMaterial(String value) {
    final normalized = value.trim();
    if (!normalized.contains('BEGIN PUBLIC KEY')) {
      return _decodeKeyMaterial(normalized);
    }
    final pemBody = normalized
        .replaceAll(RegExp(r'-----BEGIN PUBLIC KEY-----'), '')
        .replaceAll(RegExp(r'-----END PUBLIC KEY-----'), '')
        .replaceAll(RegExp(r'\s'), '');
    final der = base64.decode(pemBody);
    const oidEd25519 = <int>[0x06, 0x03, 0x2b, 0x65, 0x70];
    for (var i = 0; i <= der.length - oidEd25519.length; i++) {
      var matches = true;
      for (var j = 0; j < oidEd25519.length; j++) {
        if (der[i + j] != oidEd25519[j]) {
          matches = false;
          break;
        }
      }
      if (!matches) continue;
      final bitString = der.indexOf(0x03, i + oidEd25519.length);
      if (bitString < 0 || bitString + 2 >= der.length) break;
      final bitStringLength = der[bitString + 1];
      final bitStringStart = bitString + 2;
      if (bitStringLength != 33 ||
          bitStringStart + bitStringLength > der.length ||
          der[bitStringStart] != 0) {
        break;
      }
      return der.sublist(bitStringStart + 1, bitStringStart + bitStringLength);
    }
    throw const FormatException('Invalid Ed25519 PEM/SPKI public key');
  }

  bool _signedPayloadMatchesVisiblePayload(OfflineLicense license) {
    try {
      final signedPayload = jsonDecode(
        utf8.decode(_decodeKeyMaterial(license.signedPayload)),
      );
      return _jsonEquals(signedPayload, license.rawPayload);
    } catch (_) {
      return false;
    }
  }

  bool _jsonEquals(Object? left, Object? right) {
    if (left is Map && right is Map) {
      if (left.length != right.length) return false;
      for (final key in left.keys) {
        if (!right.containsKey(key)) return false;
        if (!_jsonEquals(left[key], right[key])) return false;
      }
      return true;
    }
    if (left is List && right is List) {
      if (left.length != right.length) return false;
      for (var i = 0; i < left.length; i++) {
        if (!_jsonEquals(left[i], right[i])) return false;
      }
      return true;
    }
    return left == right;
  }
}
