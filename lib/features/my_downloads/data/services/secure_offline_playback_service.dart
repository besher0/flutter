import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:coursaty_student_and_teacher/features/my_downloads/data/models/secure_video_models.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/encrypted_hls_download_service.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/offline_license_service.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/video_device_key_service.dart';
import 'package:injectable/injectable.dart';

/// Offline playback failure with a user-facing (Arabic) [message].
class OfflinePlaybackException implements Exception {
  const OfflinePlaybackException(this.message, {this.reason});

  factory OfflinePlaybackException.fromReason(
    OfflineLicenseInvalidReason? reason,
  ) {
    switch (reason) {
      case OfflineLicenseInvalidReason.expired:
        return OfflinePlaybackException(
          'انتهت صلاحية الفيديو المحمّل. اتصل بالإنترنت لتجديدها',
          reason: reason,
        );
      case OfflineLicenseInvalidReason.trustedTimeUnavailable:
        return OfflinePlaybackException(
          'اتصل بالإنترنت مرة واحدة للتحقق من صلاحية الفيديو المحمّل',
          reason: reason,
        );
      case OfflineLicenseInvalidReason.userMismatch:
        return OfflinePlaybackException(
          'هذا الفيديو محمّل بحساب آخر',
          reason: reason,
        );
      case OfflineLicenseInvalidReason.deviceMismatch:
        return OfflinePlaybackException(
          'هذا الفيديو محمّل على جهاز آخر',
          reason: reason,
        );
      case OfflineLicenseInvalidReason.contentVersionMismatch:
        return OfflinePlaybackException(
          'تم تحديث هذا الفيديو. احذفه وأعد تحميله',
          reason: reason,
        );
      case OfflineLicenseInvalidReason.unsupportedAlgorithm:
      case OfflineLicenseInvalidReason.invalidSignature:
      case OfflineLicenseInvalidReason.videoMismatch:
      case null:
        return OfflinePlaybackException(
          'رخصة الفيديو المحمّل غير صالحة. احذفه وأعد تحميله',
          reason: reason,
        );
    }
  }

  final String message;
  final OfflineLicenseInvalidReason? reason;

  @override
  String toString() => message;
}

class SecureOfflinePlaybackSession {
  final Uri playlistUri;
  final Future<void> Function() close;

  SecureOfflinePlaybackSession({
    required this.playlistUri,
    required this.close,
  });
}

@lazySingleton
class SecureOfflinePlaybackService {
  SecureOfflinePlaybackService(this._downloadService, this._licenseService);

  final EncryptedHlsDownloadService _downloadService;
  final OfflineLicenseService _licenseService;
  final Random _random = Random.secure();

  Future<SecureOfflinePlaybackSession> start({
    required String videoId,
    required bool allowRenewal,
  }) async {
    var manifest = await _downloadService.loadManifest(videoId);
    if (manifest == null ||
        manifest.status != SecureVideoDownloadStatus.completed) {
      throw const OfflinePlaybackException('الفيديو غير محمّل بالكامل');
    }

    final validation = await _licenseService.validate(
      license: manifest.offlineLicense,
      videoId: manifest.videoId,
      contentVersion: manifest.contentVersion,
    );
    if (!validation.isValid) {
      final canRenew =
          allowRenewal &&
          (validation.reason == OfflineLicenseInvalidReason.expired ||
              validation.reason ==
                  OfflineLicenseInvalidReason.trustedTimeUnavailable);
      if (!canRenew) {
        throw OfflinePlaybackException.fromReason(validation.reason);
      }
      final OfflineLicense? renewed;
      try {
        renewed = await _licenseService.renewIfNeeded(
          license: manifest.offlineLicense,
          videoId: manifest.videoId,
          contentVersion: manifest.contentVersion,
          preferredResolution: manifest.preferredResolution,
        );
      } on DeviceReplacementRequiredException {
        throw const OfflinePlaybackException(
          'تم ربط حسابك بجهاز آخر، لذا لا يمكن تجديد الفيديوهات المحمّلة هنا',
        );
      } catch (_) {
        throw OfflinePlaybackException.fromReason(validation.reason);
      }
      if (renewed == null) {
        throw OfflinePlaybackException.fromReason(validation.reason);
      }
      manifest = manifest.copyWith(offlineLicense: renewed);
      await _downloadService.replaceOfflineLicense(
        videoId: manifest.videoId,
        license: renewed,
      );
    } else if (allowRenewal) {
      OfflineLicense? renewed;
      try {
        renewed = await _licenseService.renewIfNeeded(
          license: manifest.offlineLicense,
          videoId: manifest.videoId,
          contentVersion: manifest.contentVersion,
          preferredResolution: manifest.preferredResolution,
        );
      } catch (error) {
        // The current license is still valid; renewal is opportunistic and
        // must not block offline playback.
        developer.log(
          'Opportunistic offline license renewal skipped: ${error.runtimeType}',
          name: 'SecureOfflinePlaybackService',
        );
      }
      if (renewed != null && renewed != manifest.offlineLicense) {
        manifest = manifest.copyWith(offlineLicense: renewed);
        await _downloadService.replaceOfflineLicense(
          videoId: manifest.videoId,
          license: renewed,
        );
      }
    }

    final token = _randomToken();
    _logLocalPlaylist(manifest);
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    late StreamSubscription<HttpRequest> subscription;
    subscription = server.listen((request) async {
      var responseStarted = false;
      var responseCompleted = false;
      final response = request.response;
      final requestedRange =
          request.headers.value(HttpHeaders.rangeHeader) ?? 'none';
      final requestPath = _safeRequestPath(request.uri.pathSegments);
      try {
        if (request.uri.pathSegments.isEmpty ||
            request.uri.pathSegments.first != token) {
          responseStarted = true;
          response.statusCode = HttpStatus.forbidden;
          await response.close();
          responseCompleted = true;
          return;
        }
        if (request.uri.pathSegments.length == 2 &&
            request.uri.pathSegments[1] == 'playlist.m3u8') {
          final localPlaylist = manifest!.playlistText
              .replaceAll('URI="segment/', 'URI="/$token/segment/')
              .replaceAll('\nsegment/', '\n/$token/segment/');
          responseStarted = true;
          response.headers.contentType = ContentType(
            'application',
            'vnd.apple.mpegurl',
          );
          response.statusCode = HttpStatus.ok;
          response.headers.contentLength = utf8.encode(localPlaylist).length;
          developer.log(
            'OFFLINE ${request.method} $requestPath range=$requestedRange -> '
            '200 contentLength=${response.headers.contentLength} bytes='
            '${utf8.encode(localPlaylist).length}',
            name: 'SecureOfflinePlaybackService',
          );
          response.write(localPlaylist);
          await response.close();
          responseCompleted = true;
          return;
        }
        if (request.uri.pathSegments.length == 3 &&
            request.uri.pathSegments[1] == 'segment') {
          final index = int.tryParse(request.uri.pathSegments[2]);
          EncryptedSegmentMetadata? segment;
          for (final item in manifest!.segments) {
            if (item.index == index) {
              segment = item;
              break;
            }
          }
          if (segment == null || !segment.completed) {
            responseStarted = true;
            response.statusCode = HttpStatus.notFound;
            await response.close();
            responseCompleted = true;
            return;
          }
          final bytes = await _downloadService.decryptSegment(
            manifest,
            segment,
          );
          final decryptedSha256 = await _downloadService.sha256Hex(bytes);
          final sha256Match =
              segment.originalSha256.isEmpty ||
              segment.originalSha256 == decryptedSha256;
          final lengthMatch =
              segment.originalLength == 0 ||
              segment.originalLength == bytes.length;
          developer.log(
            'segment=${segment.localName} originalLength=${segment.originalLength} '
            'decryptedLength=${bytes.length} sha256Match=$sha256Match '
            'lengthMatch=$lengthMatch',
            name: 'SecureOfflinePlaybackService',
          );
          if (!sha256Match || !lengthMatch) {
            response.statusCode = HttpStatus.internalServerError;
            await response.close();
            responseCompleted = true;
            return;
          }
          final range = request.headers.value(HttpHeaders.rangeHeader);
          responseStarted = true;
          response.headers.contentType =
              segment.contentType.toLowerCase() == 'video/mp2t'
              ? ContentType('video', 'mp2t')
              : ContentType.parse(segment.contentType);
          response.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');
          if (range != null && range.startsWith('bytes=')) {
            final parsed = _parseRange(range, bytes.length);
            response.statusCode = HttpStatus.partialContent;
            response.headers.contentLength = parsed.length;
            response.headers.set(
              HttpHeaders.contentRangeHeader,
              'bytes ${parsed.start}-${parsed.end}/${bytes.length}',
            );
            developer.log(
              'OFFLINE ${request.method} $requestPath range=$requestedRange -> '
              '206 contentLength=${parsed.length} '
              'contentRange=bytes ${parsed.start}-${parsed.end}/${bytes.length} '
              'bytes=${parsed.length}',
              name: 'SecureOfflinePlaybackService',
            );
            response.add(
              Uint8List.fromList(bytes.sublist(parsed.start, parsed.end + 1)),
            );
          } else {
            response.statusCode = HttpStatus.ok;
            response.headers.contentLength = bytes.length;
            developer.log(
              'OFFLINE ${request.method} $requestPath range=none -> '
              '200 contentLength=${bytes.length} contentRange=none '
              'bytes=${bytes.length}',
              name: 'SecureOfflinePlaybackService',
            );
            response.add(Uint8List.fromList(bytes));
          }
          await response.close();
          responseCompleted = true;
          return;
        }
        responseStarted = true;
        response.statusCode = HttpStatus.notFound;
        await response.close();
        responseCompleted = true;
      } catch (error, stackTrace) {
        developer.log(
          'Offline request failed: ${error.runtimeType}',
          name: 'SecureOfflinePlaybackService',
          error: error,
          stackTrace: stackTrace,
        );
        if (!responseStarted && !responseCompleted) {
          responseStarted = true;
          response.statusCode = HttpStatus.internalServerError;
          await response.close();
          responseCompleted = true;
        } else if (!responseCompleted) {
          try {
            await response.close();
          } catch (_) {}
        }
      }
    });

    return SecureOfflinePlaybackSession(
      playlistUri: Uri.parse(
        'http://127.0.0.1:${server.port}/$token/playlist.m3u8',
      ),
      close: () async {
        await subscription.cancel();
        await server.close(force: true);
      },
    );
  }

  _ByteRange _parseRange(String header, int length) {
    final value = header.substring('bytes='.length);
    final parts = value.split('-');
    if (parts.first.isEmpty) {
      final suffixLength =
          int.tryParse(parts.length > 1 ? parts[1] : '') ?? length;
      final size = suffixLength.clamp(1, length);
      return _ByteRange(length - size, length - 1);
    }
    final start = int.tryParse(parts.first) ?? 0;
    final end = parts.length > 1 && parts[1].isNotEmpty
        ? int.tryParse(parts[1]) ?? length - 1
        : length - 1;
    return _ByteRange(
      start.clamp(0, length - 1),
      end.clamp(start.clamp(0, length - 1), length - 1),
    );
  }

  String _randomToken() {
    final bytes = List<int>.generate(24, (_) => _random.nextInt(256));
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  String _safeRequestPath(List<String> segments) {
    if (segments.length <= 1) return 'unknown';
    if (segments[1] == 'playlist.m3u8') return 'playlist.m3u8';
    final index = segments.length > 2 ? segments[2] : 'unknown';
    return 'video$index.ts';
  }

  void _logLocalPlaylist(DownloadedVideoManifest manifest) {
    final lines = const LineSplitter().convert(manifest.playlistText);
    final uris = lines
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && !line.startsWith('#'))
        .toList();
    final hasEndList = lines.any((line) => line.trim() == '#EXT-X-ENDLIST');
    final expectedUris = manifest.segments.length;
    developer.log(
      'Offline playlist: segments=${uris.length} expected=$expectedUris '
      'endList=$hasEndList order=${uris.join('|')}',
      name: 'SecureOfflinePlaybackService',
    );
  }
}

class _ByteRange {
  final int start;
  final int end;

  _ByteRange(this.start, this.end);

  int get length => end - start + 1;
}
