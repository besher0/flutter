// To parse this JSON data, do
//
//     final resolutionModel = resolutionModelFromJson(jsonString);

import 'dart:convert';

List<ResolutionModel> resolutionModelFromJson(List<dynamic> data) =>
    List<ResolutionModel>.from(data.map(ResolutionModel.fromJson));

String resolutionModelToJson(List<ResolutionModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ResolutionModel {
  final String? resolution;
  final String? path;
  final int? sizeBytes;

  ResolutionModel({this.resolution, this.path, this.sizeBytes});

  ResolutionModel copyWith({
    String? resolution,
    String? path,
    int? sizeBytes,
  }) => ResolutionModel(
    resolution: resolution ?? this.resolution,
    path: path ?? this.path,
    sizeBytes: sizeBytes ?? this.sizeBytes,
  );

  factory ResolutionModel.fromJson(dynamic json) {
    if (json is String) {
      return ResolutionModel(resolution: json);
    }
    final map = json as Map<String, dynamic>;
    final rawSize = map['sizeBytes'] ??
        map['fileSizeBytes'] ??
        map['fileSize'] ??
        map['size'] ??
        map['sizeMb'] ??
        map['sizeMB'];
    final sizeBytes = _parseSizeBytes(rawSize);
    return ResolutionModel(
      resolution: map["resolution"]?.toString(),
      path: map["path"]?.toString(),
      sizeBytes: sizeBytes,
    );
  }

  static int? _parseSizeBytes(dynamic value) {
    if (value is num) return value.toInt();
    if (value is! String) return null;
    final normalized = value.trim().toLowerCase();
    final number = double.tryParse(
      normalized.replaceAll(RegExp(r'[^0-9.]'), ''),
    );
    if (number == null) return null;
    if (normalized.contains('gb')) {
      return (number * 1024 * 1024 * 1024).round();
    }
    if (normalized.contains('mb')) {
      return (number * 1024 * 1024).round();
    }
    if (normalized.contains('kb')) {
      return (number * 1024).round();
    }
    return number.toInt();
  }

  Map<String, dynamic> toJson() => {
    "resolution": resolution,
    "path": path,
    "sizeBytes": sizeBytes,
  };
}
