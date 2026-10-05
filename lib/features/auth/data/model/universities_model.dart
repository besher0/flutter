// To parse this JSON data, do
//
//     final universitiesResponseModel = universitiesResponseModelFromJson(jsonString);

import 'dart:convert';

List<UniversitiesResponseModel> universitiesResponseModelFromJson(
  List<dynamic> data,
) => List<UniversitiesResponseModel>.from(
  data.map((x) => UniversitiesResponseModel.fromJson(x)),
);

String universitiesResponseModelToJson(List<UniversitiesResponseModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UniversitiesResponseModel {
  final String? id;
  final String? provinceId;
  final String? name;
  final DateTime? createdAt;
  final Province? province;

  UniversitiesResponseModel({
    this.id,
    this.provinceId,
    this.name,
    this.createdAt,
    this.province,
  });

  UniversitiesResponseModel copyWith({
    String? id,
    String? provinceId,
    String? name,
    DateTime? createdAt,
    Province? province,
  }) => UniversitiesResponseModel(
    id: id ?? this.id,
    provinceId: provinceId ?? this.provinceId,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    province: province ?? this.province,
  );

  factory UniversitiesResponseModel.fromJson(Map<String, dynamic> json) =>
      UniversitiesResponseModel(
        id: json["id"],
        provinceId: json["provinceId"],
        name: json["name"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        province: json["province"] == null
            ? null
            : Province.fromJson(json["province"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "provinceId": provinceId,
    "name": name,
    "createdAt": createdAt?.toIso8601String(),
    "province": province?.toJson(),
  };
}

class Province {
  final String? id;
  final String? name;
  final DateTime? createdAt;

  Province({this.id, this.name, this.createdAt});

  Province copyWith({String? id, String? name, DateTime? createdAt}) =>
      Province(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
      );

  factory Province.fromJson(Map<String, dynamic> json) => Province(
    id: json["id"],
    name: json["name"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "createdAt": createdAt?.toIso8601String(),
  };
}
