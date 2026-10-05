// To parse this JSON data, do
//
//     final departmentsResponseModel = departmentsResponseModelFromJson(jsonString);

import 'dart:convert';

List<DepartmentsResponseModel> departmentsResponseModelFromJson(
  List<dynamic> data,
) => List<DepartmentsResponseModel>.from(
  data.map((x) => DepartmentsResponseModel.fromJson(x)),
);

String departmentsResponseModelToJson(List<DepartmentsResponseModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DepartmentsResponseModel {
  final String? id;
  final String? collegeId;
  final String? name;

  DepartmentsResponseModel({this.id, this.collegeId, this.name});

  DepartmentsResponseModel copyWith({
    String? id,
    String? collegeId,
    String? name,
  }) => DepartmentsResponseModel(
    id: id ?? this.id,
    collegeId: collegeId ?? this.collegeId,
    name: name ?? this.name,
  );

  factory DepartmentsResponseModel.fromJson(Map<String, dynamic> json) =>
      DepartmentsResponseModel(
        id: json["id"],
        collegeId: json["collegeId"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "collegeId": collegeId,
    "name": name,
  };
}
