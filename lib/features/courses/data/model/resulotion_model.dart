// To parse this JSON data, do
//
//     final resolutionModel = resolutionModelFromJson(jsonString);

import 'dart:convert';

List<ResolutionModel> resolutionModelFromJson(List<dynamic> data) =>
    List<ResolutionModel>.from(data.map((x) => ResolutionModel.fromJson(x)));

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

  factory ResolutionModel.fromJson(Map<String, dynamic> json) =>
      ResolutionModel(
        resolution: json["resolution"],
        path: json["path"],
        sizeBytes: json["sizeBytes"],
      );

  Map<String, dynamic> toJson() => {
    "resolution": resolution,
    "path": path,
    "sizeBytes": sizeBytes,
  };
}
