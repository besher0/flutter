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
    return ResolutionModel(
      resolution: map["resolution"],
      path: map["path"],
      sizeBytes: (map["sizeBytes"] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    "resolution": resolution,
    "path": path,
    "sizeBytes": sizeBytes,
  };
}
