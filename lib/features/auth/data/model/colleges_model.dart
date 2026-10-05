// To parse this JSON data, do
//
//     final collegesResponseModel = collegesResponseModelFromJson(jsonString);

import 'dart:convert';

List<CollegesResponseModel> collegesResponseModelFromJson(List<dynamic> data) =>
    List<CollegesResponseModel>.from(
      data.map((x) => CollegesResponseModel.fromJson(x)),
    );

String collegesResponseModelToJson(List<CollegesResponseModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CollegesResponseModel {
  final String? id;
  final String? universityId;
  final String? name;

  CollegesResponseModel({this.id, this.universityId, this.name});

  CollegesResponseModel copyWith({
    String? id,
    String? universityId,
    String? name,
  }) => CollegesResponseModel(
    id: id ?? this.id,
    universityId: universityId ?? this.universityId,
    name: name ?? this.name,
  );

  factory CollegesResponseModel.fromJson(Map<String, dynamic> json) =>
      CollegesResponseModel(
        id: json["id"],
        universityId: json["universityId"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "universityId": universityId,
    "name": name,
  };
}
