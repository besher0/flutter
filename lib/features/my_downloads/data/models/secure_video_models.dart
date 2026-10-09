PlaybackSessionResponse playbackSessionResponseFromJson(dynamic json) =>
    PlaybackSessionResponse.fromJson(json as Map<String, dynamic>);

DownloadSessionResponse downloadSessionResponseFromJson(dynamic json) =>
    DownloadSessionResponse.fromJson(json as Map<String, dynamic>);

class PlaybackSessionResponse {
  final String playbackUrl;
  final DateTime expiresAt;
  final String videoId;
  final String bunnyVideoId;
  final String playbackSessionId;
  final String? accessToken;
  final String accessHeader;

  PlaybackSessionResponse({
    required this.playbackUrl,
    required this.expiresAt,
    required this.videoId,
    required this.bunnyVideoId,
    required this.playbackSessionId,
    this.accessToken,
    this.accessHeader = 'X-Coursaty-Playback-Session',
  });

  factory PlaybackSessionResponse.fromJson(Map<String, dynamic> json) =>
      PlaybackSessionResponse(
        playbackUrl: json['playbackUrl'] as String,
        expiresAt: DateTime.parse(json['expiresAt'] as String),
        videoId: json['videoId'] as String,
        bunnyVideoId: json['bunnyVideoId'] as String? ?? '',
        playbackSessionId: json['playbackSessionId'] as String,
        accessToken: json['accessToken'] as String?,
        accessHeader:
            json['accessHeader'] as String? ?? 'X-Coursaty-Playback-Session',
      );

  Map<String, String> get playbackHeaders {
    final token = accessToken;
    if (token == null || token.isEmpty) return const {};
    return {accessHeader: token};
  }
}

/// A download session. [downloadUrl] points at the video edge gateway, which
/// only serves media to requests carrying [accessToken] in [accessHeader].
/// The token lives in memory for the duration of one download and is never
/// written to the manifest or into any URL.
class DownloadSessionResponse {
  final String downloadUrl;
  final String downloadSessionId;
  final String? accessToken;
  final String accessHeader;
  final DateTime? expiresAt;
  final String videoId;
  final String bunnyVideoId;
  final int contentVersion;
  final int? fileSize;
  final String? checksum;
  final OfflineLicense offlineLicense;

  DownloadSessionResponse({
    required this.downloadUrl,
    required this.downloadSessionId,
    this.accessToken,
    this.accessHeader = 'X-Coursaty-Playback-Session',
    this.expiresAt,
    required this.videoId,
    required this.bunnyVideoId,
    required this.contentVersion,
    required this.fileSize,
    required this.checksum,
    required this.offlineLicense,
  });

  factory DownloadSessionResponse.fromJson(Map<String, dynamic> json) =>
      DownloadSessionResponse(
        downloadUrl: json['downloadUrl'] as String,
        downloadSessionId: json['downloadSessionId'] as String,
        accessToken: json['accessToken'] as String?,
        accessHeader:
            json['accessHeader'] as String? ?? 'X-Coursaty-Playback-Session',
        expiresAt: DateTime.tryParse(json['expiresAt'] as String? ?? ''),
        videoId: json['videoId'] as String,
        bunnyVideoId: json['bunnyVideoId'] as String? ?? '',
        contentVersion: (json['contentVersion'] as num?)?.toInt() ?? 1,
        fileSize: (json['fileSize'] as num?)?.toInt(),
        checksum: json['checksum'] as String?,
        offlineLicense: OfflineLicense.fromJson(
          json['offlineLicense'] as Map<String, dynamic>,
        ),
      );

  /// Headers for every gateway request of this session (playlists, segments,
  /// keys). Empty when the backend did not issue a gateway session.
  Map<String, String> get downloadHeaders {
    final token = accessToken;
    if (token == null || token.isEmpty) return const {};
    return {accessHeader: token};
  }
}

class OfflinePublicKey {
  final String keyId;
  final String algorithm;
  final String publicKey;

  OfflinePublicKey({
    required this.keyId,
    required this.algorithm,
    required this.publicKey,
  });

  factory OfflinePublicKey.fromJson(Map<String, dynamic> json) =>
      OfflinePublicKey(
        keyId: json['keyId'] as String? ?? 'default',
        algorithm: json['algorithm'] as String? ?? 'Ed25519',
        publicKey:
            json['publicKey'] as String? ??
            json['key'] as String? ??
            json['value'] as String? ??
            '',
      );

  Map<String, dynamic> toJson() => {
    'keyId': keyId,
    'algorithm': algorithm,
    'publicKey': publicKey,
  };
}

class OfflineLicense {
  final String algorithm;
  final String keyId;
  final OfflineLicensePayload payload;
  final Map<String, dynamic> rawPayload;
  final String signature;
  final String signedPayload;

  OfflineLicense({
    required this.algorithm,
    required this.keyId,
    required this.payload,
    required this.rawPayload,
    required this.signature,
    required this.signedPayload,
  });

  factory OfflineLicense.fromJson(Map<String, dynamic> json) {
    final rawPayload = Map<String, dynamic>.from(
      json['payload'] as Map<String, dynamic>,
    );
    final signedPayload = json['signedPayload'];
    if (signedPayload is! String) {
      throw const FormatException(
        'Offline license signedPayload must be a String',
      );
    }
    return OfflineLicense(
      algorithm: json['algorithm'] as String? ?? 'Ed25519',
      keyId: json['keyId'] as String? ?? 'default',
      payload: OfflineLicensePayload.fromJson(rawPayload),
      rawPayload: rawPayload,
      signature: json['signature'] as String,
      signedPayload: signedPayload,
    );
  }

  Map<String, dynamic> toJson() => {
    'algorithm': algorithm,
    'keyId': keyId,
    'payload': rawPayload,
    'signature': signature,
    'signedPayload': signedPayload,
  };
}

class OfflineLicensePayload {
  final String licenseId;
  final String userId;
  final String deviceId;
  final String courseId;
  final String lectureId;
  final String videoId;
  final int contentVersion;
  final DateTime issuedAt;
  final DateTime expiresAt;

  OfflineLicensePayload({
    required this.licenseId,
    required this.userId,
    required this.deviceId,
    required this.courseId,
    required this.lectureId,
    required this.videoId,
    required this.contentVersion,
    required this.issuedAt,
    required this.expiresAt,
  });

  factory OfflineLicensePayload.fromJson(Map<String, dynamic> json) =>
      OfflineLicensePayload(
        licenseId: json['licenseId'] as String,
        userId: json['userId'] as String,
        deviceId: json['deviceId'] as String,
        courseId: json['courseId'] as String,
        lectureId: json['lectureId'] as String,
        videoId: json['videoId'] as String,
        contentVersion: (json['contentVersion'] as num?)?.toInt() ?? 1,
        issuedAt: DateTime.parse(json['issuedAt'] as String),
        expiresAt: DateTime.parse(json['expiresAt'] as String),
      );

  Map<String, dynamic> toJson() => {
    'licenseId': licenseId,
    'userId': userId,
    'deviceId': deviceId,
    'courseId': courseId,
    'lectureId': lectureId,
    'videoId': videoId,
    'contentVersion': contentVersion,
    'issuedAt': issuedAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
  };
}

enum SecureVideoDownloadStatus { pending, downloading, completed, failed }

class DownloadedVideoManifest {
  final String videoId;
  final String courseId;
  final String lectureId;
  final String userId;
  final String deviceId;
  final int contentVersion;
  final String preferredResolution;
  final String selectedResolution;
  final SecureVideoDownloadStatus status;
  final String playlistText;
  final int totalSegments;
  final List<EncryptedSegmentMetadata> segments;
  final OfflineLicense offlineLicense;
  final DateTime createdAt;
  final DateTime updatedAt;

  DownloadedVideoManifest({
    required this.videoId,
    required this.courseId,
    required this.lectureId,
    required this.userId,
    required this.deviceId,
    required this.contentVersion,
    required this.preferredResolution,
    required this.selectedResolution,
    required this.status,
    required this.playlistText,
    required this.totalSegments,
    required this.segments,
    required this.offlineLicense,
    required this.createdAt,
    required this.updatedAt,
  });

  int get completedSegments =>
      segments.where((segment) => segment.completed).length;

  double get progress =>
      totalSegments == 0 ? 0 : (completedSegments / totalSegments) * 100;

  DownloadedVideoManifest copyWith({
    SecureVideoDownloadStatus? status,
    String? playlistText,
    int? totalSegments,
    List<EncryptedSegmentMetadata>? segments,
    OfflineLicense? offlineLicense,
    DateTime? updatedAt,
    int? contentVersion,
    String? selectedResolution,
  }) {
    return DownloadedVideoManifest(
      videoId: videoId,
      courseId: courseId,
      lectureId: lectureId,
      userId: userId,
      deviceId: deviceId,
      contentVersion: contentVersion ?? this.contentVersion,
      preferredResolution: preferredResolution,
      selectedResolution: selectedResolution ?? this.selectedResolution,
      status: status ?? this.status,
      playlistText: playlistText ?? this.playlistText,
      totalSegments: totalSegments ?? this.totalSegments,
      segments: segments ?? this.segments,
      offlineLicense: offlineLicense ?? this.offlineLicense,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory DownloadedVideoManifest.fromJson(Map<String, dynamic> json) =>
      DownloadedVideoManifest(
        videoId: json['videoId'] as String,
        courseId: json['courseId'] as String,
        lectureId: json['lectureId'] as String,
        userId: json['userId'] as String? ?? '',
        deviceId: json['deviceId'] as String? ?? '',
        contentVersion: (json['contentVersion'] as num?)?.toInt() ?? 1,
        preferredResolution: json['preferredResolution'] as String? ?? '720p',
        selectedResolution:
            json['selectedResolution'] as String? ??
            json['preferredResolution'] as String? ??
            '720p',
        status: SecureVideoDownloadStatus.values.firstWhere(
          (value) => value.name == json['status'],
          orElse: () => SecureVideoDownloadStatus.pending,
        ),
        playlistText: json['playlistText'] as String,
        totalSegments: (json['totalSegments'] as num?)?.toInt() ?? 0,
        segments: (json['segments'] as List<dynamic>? ?? [])
            .map(
              (item) => EncryptedSegmentMetadata.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList(),
        offlineLicense: OfflineLicense.fromJson(
          json['offlineLicense'] as Map<String, dynamic>,
        ),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
    'videoId': videoId,
    'courseId': courseId,
    'lectureId': lectureId,
    'userId': userId,
    'deviceId': deviceId,
    'contentVersion': contentVersion,
    'preferredResolution': preferredResolution,
    'selectedResolution': selectedResolution,
    'status': status.name,
    'playlistText': playlistText,
    'totalSegments': totalSegments,
    'segments': segments.map((item) => item.toJson()).toList(),
    'offlineLicense': offlineLicense.toJson(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

class EncryptedSegmentMetadata {
  final int index;
  final String originalUri;
  final String localName;
  final String nonce;
  final String mac;
  final int originalLength;
  final String originalSha256;
  final bool completed;
  final String contentType;

  EncryptedSegmentMetadata({
    required this.index,
    required this.originalUri,
    required this.localName,
    required this.nonce,
    required this.mac,
    required this.originalLength,
    required this.originalSha256,
    required this.completed,
    required this.contentType,
  });

  EncryptedSegmentMetadata copyWith({
    String? nonce,
    String? mac,
    int? originalLength,
    String? originalSha256,
    bool? completed,
  }) {
    return EncryptedSegmentMetadata(
      index: index,
      originalUri: originalUri,
      localName: localName,
      nonce: nonce ?? this.nonce,
      mac: mac ?? this.mac,
      originalLength: originalLength ?? this.originalLength,
      originalSha256: originalSha256 ?? this.originalSha256,
      completed: completed ?? this.completed,
      contentType: contentType,
    );
  }

  factory EncryptedSegmentMetadata.fromJson(Map<String, dynamic> json) =>
      EncryptedSegmentMetadata(
        index: (json['index'] as num).toInt(),
        originalUri: json['originalUri'] as String,
        localName: json['localName'] as String,
        nonce: json['nonce'] as String? ?? '',
        mac: json['mac'] as String? ?? '',
        originalLength: (json['originalLength'] as num?)?.toInt() ?? 0,
        originalSha256: json['originalSha256'] as String? ?? '',
        completed: json['completed'] as bool? ?? false,
        contentType: json['contentType'] as String? ?? 'video/MP2T',
      );

  Map<String, dynamic> toJson() => {
    'index': index,
    'originalUri': originalUri,
    'localName': localName,
    'nonce': nonce,
    'mac': mac,
    'originalLength': originalLength,
    'originalSha256': originalSha256,
    'completed': completed,
    'contentType': contentType,
  };
}
