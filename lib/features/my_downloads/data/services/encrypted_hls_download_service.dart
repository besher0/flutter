import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:developer' as developer;

import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/models/secure_video_models.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/models/video_security_errors.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/offline_license_service.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/video_access_service.dart';
import 'package:coursaty_student_and_teacher/services/check_device_root_service.dart';
import 'package:coursaty_student_and_teacher/services/device_info_service.dart';
import 'package:cryptography/cryptography.dart';
import 'package:device_safety_info/device_safety_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

typedef SecureVideoProgress = void Function(double progress);

@lazySingleton
class EncryptedHlsDownloadService {
  EncryptedHlsDownloadService(
    this._client,
    this._videoAccessService,
    this._offlineLicenseService,
    this._prefs, {
    @ignoreParam FlutterSecureStorage? secureStorage,
    @ignoreParam Future<Directory> Function()? storageRoot,
    @ignoreParam Future<bool> Function()? isSecureDevice,
  }) : _secureStorage = secureStorage ?? _defaultSecureStorage,
       _storageRoot = storageRoot ?? getApplicationSupportDirectory,
       _isSecureDevice = isSecureDevice ?? _defaultIsSecureDevice;

  final Dio _client;

  /// Media comes only from the video edge gateway, authorized by the download
  /// session header. Gateway requests must never carry the app's
  /// `Authorization` (BaseApi mutates the shared [_client]'s base headers), so
  /// they use a separate client with no default headers.
  late final Dio _gatewayClient = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 2),
    ),
  )..httpClientAdapter = _client.httpClientAdapter;
  final VideoAccessService _videoAccessService;
  final OfflineLicenseService _offlineLicenseService;
  final FlutterSecureStorage _secureStorage;
  final PrefsRepository _prefs;
  final Future<Directory> Function() _storageRoot;
  final Future<bool> Function() _isSecureDevice;
  final AesGcm _aesGcm = AesGcm.with256bits();
  final Random _random = Random.secure();

  static const FlutterSecureStorage _defaultSecureStorage =
      FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );

  static Future<bool> _defaultIsSecureDevice() async {
    await CheckDeviceRootService.isDeviceRooted();
    if (CheckDeviceRootService.isDeviceHasRoot) return false;
    return DeviceSafetyInfo.isRealDevice;
  }

  Future<DownloadedVideoManifest> download({
    required String videoId,
    required String courseId,
    required String lectureId,
    required String preferredResolution,
    required SecureVideoProgress onProgress,
    CancelToken? cancelToken,
  }) async {
    if (!await _isSecureDevice()) {
      throw const SecureDownloadException(SecureDownloadFailure.insecureDevice);
    }
    var session = await _videoAccessService.createDownloadSession(
      videoId: videoId,
      preferredResolution: preferredResolution,
    );
    final access = _GatewayAccess(session);
    var directory = await _videoDirectory(videoId);
    await directory.create(recursive: true);
    var existing = await loadManifest(videoId);
    if (existing != null && existing.contentVersion != session.contentVersion) {
      await deleteVideo(videoId);
      directory = await _videoDirectory(videoId);
      await directory.create(recursive: true);
      existing = null;
    }
    final validation = await _offlineLicenseService.validate(
      license: session.offlineLicense,
      videoId: videoId,
      contentVersion: session.contentVersion,
    );
    if (!validation.isValid) {
      throw SecureDownloadException(
        SecureDownloadFailure.offlineLicenseInvalid,
        validation.message,
      );
    }
    await _ensureVideoKey(videoId);

    final selectedPlaylist = await _loadSelectedPlaylist(
      access,
      preferredResolution,
      cancelToken,
    );
    var activeEntries = _parsePlaylistEntries(selectedPlaylist.text);
    if (existing != null && existing.totalSegments != activeEntries.length) {
      await deleteVideo(videoId);
      directory = await _videoDirectory(videoId);
      await directory.create(recursive: true);
      existing = null;
      await _ensureVideoKey(videoId);
    }
    var manifest =
        existing ??
        DownloadedVideoManifest(
          videoId: videoId,
          courseId: courseId,
          lectureId: lectureId,
          userId: _prefs.userId ?? '',
          deviceId: DeviceInfoService.getSecureVideoDeviceId(),
          contentVersion: session.contentVersion,
          preferredResolution: preferredResolution,
          selectedResolution: selectedPlaylist.selectedResolution,
          status: SecureVideoDownloadStatus.downloading,
          playlistText: '',
          totalSegments: activeEntries.length,
          segments: activeEntries
              .asMap()
              .entries
              .map(
                (entry) => EncryptedSegmentMetadata(
                  index: entry.key,
                  originalUri: entry.value.manifestUri,
                  localName: 'segment_${entry.key}.bin',
                  nonce: '',
                  mac: '',
                  originalLength: 0,
                  originalSha256: '',
                  completed: false,
                  contentType: entry.value.contentType,
                ),
              )
              .toList(),
          offlineLicense: session.offlineLicense,
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        );
    manifest = manifest.copyWith(
      status: SecureVideoDownloadStatus.downloading,
      totalSegments: activeEntries.length,
      offlineLicense: session.offlineLicense,
      selectedResolution: selectedPlaylist.selectedResolution,
      playlistText: _localPlaylist(selectedPlaylist.text, manifest.segments),
      updatedAt: DateTime.now().toUtc(),
    );
    await _saveManifest(manifest);

    var refreshedOnceForIndex = <int>{};
    for (final segment in manifest.segments) {
      if (cancelToken?.isCancelled ?? false) {
        throw DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.cancel,
          message: 'The request was manually cancelled by the user.',
        );
      }
      if (segment.completed) {
        onProgress(manifest.progress);
        continue;
      }
      var absoluteUri = _resolveUri(
        selectedPlaylist.uri,
        activeEntries[segment.index].downloadUri,
      );
      try {
        final encrypted = await _downloadAndEncryptSegment(
          access,
          absoluteUri,
          directory,
          segment,
          cancelToken,
        );
        manifest = manifest.copyWith(
          segments: manifest.segments
              .map((item) => item.index == encrypted.index ? encrypted : item)
              .toList(),
          updatedAt: DateTime.now().toUtc(),
        );
        await _saveManifest(manifest);
        onProgress(manifest.progress);
      } on SecureDownloadException catch (error) {
        // Sessions are short-lived; a long download outlives its token. Get a
        // fresh session (new device proof) once per segment and continue.
        if (error.failure == SecureDownloadFailure.gatewayAccessDenied &&
            !refreshedOnceForIndex.contains(segment.index)) {
          refreshedOnceForIndex.add(segment.index);
          session = await _videoAccessService.createDownloadSession(
            videoId: videoId,
            preferredResolution: preferredResolution,
          );
          access.renew(session);
          if (session.contentVersion != manifest.contentVersion) {
            await deleteVideo(videoId);
            return download(
              videoId: videoId,
              courseId: courseId,
              lectureId: lectureId,
              preferredResolution: preferredResolution,
              onProgress: onProgress,
              cancelToken: cancelToken,
            );
          }
          final newPlaylist = await _loadSelectedPlaylist(
            access,
            preferredResolution,
            cancelToken,
          );
          selectedPlaylist.uri = newPlaylist.uri;
          selectedPlaylist.text = newPlaylist.text;
          manifest = manifest.copyWith(
            selectedResolution: newPlaylist.selectedResolution,
          );
          activeEntries = _parsePlaylistEntries(newPlaylist.text);
          manifest = manifest.copyWith(
            offlineLicense: session.offlineLicense,
            playlistText: _localPlaylist(newPlaylist.text, manifest.segments),
            updatedAt: DateTime.now().toUtc(),
          );
          await _saveManifest(manifest);
          absoluteUri = _resolveUri(
            selectedPlaylist.uri,
            activeEntries[segment.index].downloadUri,
          );
          final encrypted = await _downloadAndEncryptSegment(
            access,
            absoluteUri,
            directory,
            segment,
            cancelToken,
          );
          manifest = manifest.copyWith(
            segments: manifest.segments
                .map((item) => item.index == encrypted.index ? encrypted : item)
                .toList(),
            updatedAt: DateTime.now().toUtc(),
          );
          await _saveManifest(manifest);
          onProgress(manifest.progress);
          continue;
        }
        rethrow;
      }
    }
    manifest = manifest.copyWith(
      status: SecureVideoDownloadStatus.completed,
      updatedAt: DateTime.now().toUtc(),
    );
    await _saveManifest(manifest);
    onProgress(100);
    return manifest;
  }

  Future<DownloadedVideoManifest?> loadManifest(String videoId) async {
    final file = await _manifestFile(videoId);
    if (!await file.exists()) return null;
    return DownloadedVideoManifest.fromJson(
      jsonDecode(await file.readAsString()),
    );
  }

  Future<void> deleteVideo(String videoId) async {
    final dir = await _videoDirectory(videoId);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
    await _secureStorage.delete(key: _keyName(videoId));
  }

  Future<void> cleanupLegacyPlaintextDownloads() async {
    try {
      final root = await getApplicationDocumentsDirectory();
      final legacyVideosDir = Directory('${root.path}/videos');
      if (!await legacyVideosDir.exists()) return;
      await for (final entity in legacyVideosDir.list(recursive: true)) {
        if (entity is! File) continue;
        final path = entity.path.toLowerCase();
        if (path.endsWith('.mp4') ||
            path.endsWith('.m4s') ||
            path.endsWith('.ts') ||
            path.endsWith('.mp4.temp') ||
            path.endsWith('.temp')) {
          try {
            await entity.delete();
          } catch (_) {}
        }
      }
    } catch (_) {}
  }

  Future<void> replaceOfflineLicense({
    required String videoId,
    required OfflineLicense license,
  }) async {
    final manifest = await loadManifest(videoId);
    if (manifest == null) return;
    await _saveManifest(
      manifest.copyWith(
        offlineLicense: license,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }

  Future<List<int>> decryptSegment(
    DownloadedVideoManifest manifest,
    EncryptedSegmentMetadata segment,
  ) async {
    final key = await _readVideoKey(manifest.videoId);
    if (key == null) throw StateError('Missing encryption key');
    final file = File(
      '${(await _videoDirectory(manifest.videoId)).path}/${segment.localName}',
    );
    final cipherText = await file.readAsBytes();
    final box = SecretBox(
      cipherText,
      nonce: base64Url.decode(segment.nonce),
      mac: Mac(base64Url.decode(segment.mac)),
    );
    return _aesGcm.decrypt(box, secretKey: SecretKey(key));
  }

  Future<EncryptedSegmentMetadata> _downloadAndEncryptSegment(
    _GatewayAccess access,
    Uri uri,
    Directory directory,
    EncryptedSegmentMetadata segment,
    CancelToken? cancelToken,
  ) async {
    final response = await _gatewayGet<List<int>>(
      access,
      uri,
      ResponseType.bytes,
      cancelToken,
    );
    final plainBytes = response.data ?? <int>[];
    final originalSha256 = await _sha256Hex(plainBytes);
    developer.log(
      'Downloaded ${segment.localName}: length=${plainBytes.length} sha256=$originalSha256',
      name: 'EncryptedHlsDownloadService',
    );
    final key = await _ensureVideoKey(_videoIdFromDirectory(directory));
    final nonce = List<int>.generate(12, (_) => _random.nextInt(256));
    final secretBox = await _aesGcm.encrypt(
      plainBytes,
      secretKey: SecretKey(key),
      nonce: nonce,
    );
    final file = File('${directory.path}/${segment.localName}');
    await file.writeAsBytes(secretBox.cipherText, flush: true);
    return segment.copyWith(
      nonce: base64Url.encode(secretBox.nonce),
      mac: base64Url.encode(secretBox.mac.bytes),
      originalLength: plainBytes.length,
      originalSha256: originalSha256,
      completed: true,
    );
  }

  Future<_SelectedPlaylist> _loadSelectedPlaylist(
    _GatewayAccess access,
    String preferredResolution,
    CancelToken? cancelToken,
  ) async {
    final masterUri = access.playlistUri;
    final masterText = await _readPlaylist(access, masterUri, cancelToken);
    final variant = _selectVariant(masterText, masterUri, preferredResolution);
    if (variant == null) {
      final selected = _normalizeResolution(preferredResolution) ?? 'master';
      developer.log(
        'requestedResolution=$preferredResolution selectedResolution=$selected',
        name: 'EncryptedHlsDownloadService',
      );
      return _SelectedPlaylist(masterUri, masterText, selected);
    }
    final mediaText = await _readPlaylist(access, variant.uri, cancelToken);
    developer.log(
      'requestedResolution=$preferredResolution selectedResolution=${variant.resolution}',
      name: 'EncryptedHlsDownloadService',
    );
    return _SelectedPlaylist(variant.uri, mediaText, variant.resolution);
  }

  Future<String> _readPlaylist(
    _GatewayAccess access,
    Uri uri,
    CancelToken? cancelToken,
  ) async {
    final response = await _gatewayGet<String>(
      access,
      uri,
      ResponseType.plain,
      cancelToken,
    );
    final text = response.data ?? '';
    final hasMedia = const LineSplitter()
        .convert(text)
        .any((line) => line.trim().isNotEmpty && !line.trim().startsWith('#'));
    // trimLeft also drops a leading BOM.
    if (!text.trimLeft().startsWith('#EXTM3U') || !hasMedia) {
      throw SecureDownloadException(
        SecureDownloadFailure.invalidPlaylist,
        uri.path,
      );
    }
    return text;
  }

  /// The only way media is fetched: gateway origin only, session header on
  /// every request (master and variant playlists, segments, init and keys).
  Future<Response<T>> _gatewayGet<T>(
    _GatewayAccess access,
    Uri uri,
    ResponseType responseType,
    CancelToken? cancelToken,
  ) async {
    access.ensureAllowed(uri);
    try {
      return await _gatewayClient.getUri<T>(
        uri,
        cancelToken: cancelToken,
        options: Options(
          responseType: responseType,
          headers: access.headers,
          // A redirect could carry the session header to another host.
          followRedirects: false,
        ),
      );
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == 401 || status == 403) {
        throw SecureDownloadException(
          SecureDownloadFailure.gatewayAccessDenied,
          'HTTP $status ${uri.path}',
        );
      }
      rethrow;
    }
  }

  _PlaylistVariant? _selectVariant(
    String masterText,
    Uri masterUri,
    String quality,
  ) {
    final lines = const LineSplitter().convert(masterText);
    final targetHeight = _normalizeResolution(quality);
    final variants = <_PlaylistVariant>[];
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (!line.startsWith('#EXT-X-STREAM-INF')) continue;
      final nextUri = i + 1 < lines.length ? lines[i + 1].trim() : '';
      if (nextUri.isEmpty || nextUri.startsWith('#')) continue;
      final uri = _resolveUri(masterUri, nextUri);
      final resolution = _variantResolution(nextUri, line);
      variants.add(_PlaylistVariant(uri, resolution));
    }
    if (variants.isEmpty) return null;
    if (targetHeight != null) {
      final exact = variants.where((item) => item.resolution == targetHeight);
      if (exact.isNotEmpty) return exact.first;
      final requested = int.parse(targetHeight);
      variants.sort(
        (a, b) => (int.parse(a.resolution) - requested).abs().compareTo(
          (int.parse(b.resolution) - requested).abs(),
        ),
      );
      return variants.first;
    }
    return variants.first;
  }

  String? _normalizeResolution(String value) {
    final match = RegExp(r'(\d+)\s*p?', caseSensitive: false).firstMatch(value);
    return match?.group(1);
  }

  String _variantResolution(String uri, String attributes) {
    final pathMatch = RegExp(
      r'(?:^|/)(\d+)\s*p?(?:/|$)',
      caseSensitive: false,
    ).firstMatch(uri);
    if (pathMatch != null) return pathMatch.group(1)!;
    final sizeMatch = RegExp(r'RESOLUTION=\d+x(\d+)').firstMatch(attributes);
    return sizeMatch?.group(1) ?? '0';
  }

  List<_PlaylistEntry> _parsePlaylistEntries(String playlistText) {
    final entries = <_PlaylistEntry>[];
    final lines = const LineSplitter().convert(playlistText);
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed.startsWith('#EXT-X-MAP')) {
        final uri = _extractQuotedUri(trimmed);
        if (uri != null) {
          entries.add(_PlaylistEntry(uri, _stripSignedParts(uri), 'video/mp4'));
        }
      } else if (trimmed.startsWith('#EXT-X-KEY')) {
        final uri = _extractQuotedUri(trimmed);
        if (uri != null) {
          entries.add(
            _PlaylistEntry(
              uri,
              _stripSignedParts(uri),
              'application/octet-stream',
            ),
          );
        }
      } else if (!trimmed.startsWith('#')) {
        entries.add(
          _PlaylistEntry(trimmed, _stripSignedParts(trimmed), 'video/MP2T'),
        );
      }
    }
    return entries;
  }

  String _localPlaylist(
    String playlistText,
    List<EncryptedSegmentMetadata> segments,
  ) {
    var cursor = 0;
    final output = <String>[];
    final lines = const LineSplitter().convert(playlistText);
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('#EXT-X-MAP') ||
          trimmed.startsWith('#EXT-X-KEY')) {
        final segment = segments[cursor++];
        output.add(
          line.replaceFirst(
            RegExp(r'URI="[^"]+"'),
            'URI="segment/${segment.index}"',
          ),
        );
      } else if (trimmed.isNotEmpty && !trimmed.startsWith('#')) {
        final segment = segments[cursor++];
        output.add('segment/${segment.index}');
      } else {
        output.add(line);
      }
    }
    return output.join('\n');
  }

  String? _extractQuotedUri(String value) {
    final match = RegExp(r'URI="([^"]+)"').firstMatch(value);
    return match?.group(1);
  }

  String _stripSignedParts(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return value;
    final filteredQuery = Map<String, dynamic>.from(uri.queryParameters)
      ..removeWhere((key, _) => key.toLowerCase().contains('token'));
    final sanitized = uri.replace(
      queryParameters: filteredQuery.isEmpty ? null : filteredQuery,
    );
    return sanitized.toString().replaceAll(RegExp(r'/bcdn_token=[^/]+/'), '/');
  }

  Uri _resolveUri(Uri base, String reference) => base.resolve(reference);

  Future<List<int>> _ensureVideoKey(String videoId) async {
    final current = await _readVideoKey(videoId);
    if (current != null) return current;
    final key = List<int>.generate(32, (_) => _random.nextInt(256));
    await _secureStorage.write(
      key: _keyName(videoId),
      value: base64Url.encode(key),
    );
    return key;
  }

  Future<List<int>?> _readVideoKey(String videoId) async {
    final encoded = await _secureStorage.read(key: _keyName(videoId));
    return encoded == null ? null : base64Url.decode(encoded);
  }

  Future<String> sha256Hex(List<int> bytes) => _sha256Hex(bytes);

  Future<String> _sha256Hex(List<int> bytes) async {
    final digest = await Sha256().hash(bytes);
    return digest.bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  String _keyName(String videoId) =>
      'secure_video_key_${_prefs.userId ?? 'guest'}_$videoId';

  String _videoIdFromDirectory(Directory directory) =>
      directory.uri.pathSegments.where((segment) => segment.isNotEmpty).last;

  Future<Directory> _videoDirectory(String videoId) async {
    final root = await _storageRoot();
    return Directory('${root.path}/secure_videos/$videoId');
  }

  Future<File> _manifestFile(String videoId) async =>
      File('${(await _videoDirectory(videoId)).path}/manifest.json');

  Future<void> _saveManifest(DownloadedVideoManifest manifest) async {
    final file = await _manifestFile(manifest.videoId);
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(manifest.toJson()), flush: true);
  }
}

/// Where the current download may fetch from and with which header. Renewed
/// in place when a fresh session replaces an expired one.
class _GatewayAccess {
  _GatewayAccess(DownloadSessionResponse session) {
    renew(session);
  }

  late Uri playlistUri;
  late Map<String, String> headers;

  void renew(DownloadSessionResponse session) {
    final uri = Uri.tryParse(session.downloadUrl);
    if (session.downloadHeaders.isEmpty ||
        uri == null ||
        !uri.isScheme('https') ||
        uri.host.isEmpty) {
      // No gateway session (e.g. a direct CDN link): never download without
      // the device-bound session.
      throw const SecureDownloadException(
        SecureDownloadFailure.gatewaySessionMissing,
      );
    }
    playlistUri = uri;
    headers = session.downloadHeaders;
  }

  /// Relative playlist references resolve under the gateway; anything that
  /// points to another origin is refused so the header never leaves it.
  void ensureAllowed(Uri uri) {
    if (uri.scheme != playlistUri.scheme ||
        uri.host != playlistUri.host ||
        uri.port != playlistUri.port) {
      throw SecureDownloadException(
        SecureDownloadFailure.untrustedMediaHost,
        uri.host,
      );
    }
  }
}

class _PlaylistEntry {
  final String downloadUri;
  final String manifestUri;
  final String contentType;

  _PlaylistEntry(this.downloadUri, this.manifestUri, this.contentType);
}

class _SelectedPlaylist {
  Uri uri;
  String text;
  final String selectedResolution;

  _SelectedPlaylist(this.uri, this.text, this.selectedResolution);
}

class _PlaylistVariant {
  final Uri uri;
  final String resolution;

  _PlaylistVariant(this.uri, this.resolution);
}
