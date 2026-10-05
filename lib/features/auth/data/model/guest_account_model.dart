// To parse this JSON data, do
//
//     final guestAccountModel = guestAccountModelFromJson(jsonString);

import 'dart:convert';

GuestAccountModel guestAccountModelFromJson(String str) =>
    GuestAccountModel.fromJson(json.decode(str));

String guestAccountModelToJson(GuestAccountModel data) =>
    json.encode(data.toJson());

class GuestAccountModel {
  final String? id;
  final String? deviceId;
  final String? universityId;
  final String? collegeId;
  final String? departmentId;
  final String? collegeYearId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  GuestAccountModel({
    this.id,
    this.deviceId,
    this.universityId,
    this.collegeId,
    this.departmentId,
    this.collegeYearId,
    this.createdAt,
    this.updatedAt,
  });

  GuestAccountModel copyWith({
    String? id,
    String? deviceId,
    String? universityId,
    String? collegeId,
    String? departmentId,
    String? collegeYearId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => GuestAccountModel(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    universityId: universityId ?? this.universityId,
    collegeId: collegeId ?? this.collegeId,
    departmentId: departmentId ?? this.departmentId,
    collegeYearId: collegeYearId ?? this.collegeYearId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory GuestAccountModel.fromJson(Map<String, dynamic> json) =>
      GuestAccountModel(
        id: json["id"],
        deviceId: json["deviceId"],
        universityId: json["universityId"],
        collegeId: json["collegeId"],
        departmentId: json["departmentId"],
        collegeYearId: json["collegeYearId"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "deviceId": deviceId,
    "universityId": universityId,
    "collegeId": collegeId,
    "departmentId": departmentId,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}
