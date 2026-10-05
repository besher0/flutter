// To parse this JSON data, do
//
//     final salePoint = salePointFromJson(jsonString);

import 'dart:convert';

List<SalePoint> salePointFromJson(List<dynamic> data) =>
    List<SalePoint>.from(data.map((x) => SalePoint.fromJson(x)));

String salePointToJson(List<SalePoint> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SalePoint {
  final String? id;
  final String? universityId;
  final String? provinceId;
  final String? name;
  final String? address;
  final String? phone;
  final String? description;
  final String? image;
  final String? imageLocation;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SalePoint({
    this.id,
    this.universityId,
    this.provinceId,
    this.name,
    this.address,
    this.phone,
    this.description,
    this.image,
    this.imageLocation,
    this.createdAt,
    this.updatedAt,
  });

  SalePoint copyWith({
    String? id,
    String? universityId,
    String? provinceId,
    String? name,
    String? address,
    String? phone,
    String? description,
    String? image,
    String? imageLocation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SalePoint(
    id: id ?? this.id,
    universityId: universityId ?? this.universityId,
    provinceId: provinceId ?? this.provinceId,
    name: name ?? this.name,
    address: address ?? this.address,
    phone: phone ?? this.phone,
    description: description ?? this.description,
    image: image ?? this.image,
    imageLocation: imageLocation ?? this.imageLocation,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory SalePoint.fromJson(Map<String, dynamic> json) => SalePoint(
    id: json["id"],
    universityId: json["universityId"],
    provinceId: json["provinceId"],
    name: json["name"],
    address: json["address"],
    phone: json["phone"],
    description: json["description"],
    image: json["image"],
    imageLocation: json["imageLocation"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "universityId": universityId,
    "provinceId": provinceId,
    "name": name,
    "address": address,
    "phone": phone,
    "description": description,
    "image": image,
    "imageLocation": imageLocation,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}
