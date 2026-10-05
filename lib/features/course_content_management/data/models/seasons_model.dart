// To parse this JSON data, do
//
//     final seasonsModel = seasonsModelFromJson(jsonString);

import 'dart:convert';

List<SeasonsModel> seasonsModelFromJson(List<dynamic> data) =>
    List<SeasonsModel>.from(data.map((x) => SeasonsModel.fromJson(x)));

String seasonsModelToJson(List<SeasonsModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SeasonsModel {
  final String? id;
  final String? seasonName;
  final int? seasonNumber;
  final bool? isHomeActive;

  SeasonsModel({
    this.id,
    this.seasonName,
    this.seasonNumber,
    this.isHomeActive,
  });

  SeasonsModel copyWith({
    String? id,
    String? seasonName,
    int? seasonNumber,
    bool? isHomeActive,
  }) => SeasonsModel(
    id: id ?? this.id,
    seasonName: seasonName ?? this.seasonName,
    seasonNumber: seasonNumber ?? this.seasonNumber,
    isHomeActive: isHomeActive ?? this.isHomeActive,
  );

  factory SeasonsModel.fromJson(Map<String, dynamic> json) => SeasonsModel(
    id: json["id"],
    seasonName: json["seasonName"],
    seasonNumber: json["seasonNumber"],
    isHomeActive: json["isHomeActive"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "seasonName": seasonName,
    "seasonNumber": seasonNumber,
    "isHomeActive": isHomeActive,
  };
}
