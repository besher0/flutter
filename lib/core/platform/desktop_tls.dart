import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';

import 'app_platform.dart';

/// Trusted root certificates for HTTPS on Windows.
///
/// ⚠️ Dart on Windows trusts only the roots already in the Windows store.
/// Windows itself downloads a missing root the first time a browser needs it,
/// Dart never does: on a PC that never visited a site of that CA, every
/// request fails with CERTIFICATE_VERIFY_FAILED. The Bunny CDN (course images,
/// video segments) uses "SSL.com TLS RSA Root CA 2022", which a fresh Windows
/// often lacks, so images failed on the first test PC.
///
/// The app ships Mozilla's root list (`assets/certs/mozilla_roots.pem`, from
/// https://curl.se/ca/cacert.pem, the list Android and Firefox build on) and
/// adds it to the roots Windows already has. Phones use their own stores and
/// skip this. Update the file now and then (see CLAUDE.md).
abstract final class DesktopTls {
  static const asset = 'assets/certs/mozilla_roots.pem';

  static Uint8List? _roots;

  /// The loaded roots, for isolates that make their own HTTPS requests (the
  /// playback proxy): pass them to [trustInThisIsolate] there. Null when not
  /// needed (phones) or not loaded.
  static Uint8List? get roots => _roots;

  /// Called once from `main`, on the main isolate.
  static Future<void> init() async {
    if (!AppPlatform.isWindows) return;
    try {
      final data = await rootBundle.load(asset);
      final roots = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      trustInThisIsolate(roots);
      _roots = roots;
    } catch (error) {
      log('bundled root certificates not loaded: $error');
    }
  }

  /// Each isolate has its own default security context.
  static void trustInThisIsolate(Uint8List roots) {
    SecurityContext.defaultContext.setTrustedCertificatesBytes(roots);
  }
}
