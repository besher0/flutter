// To parse this JSON data, do
//
//     final TeacherAffiliationsResponseModel = teacherAffilationsResponseModelFromJson(jsonString);

import 'dart:convert';

List<TeacherAffiliationsResponseModel> teacherAffilationsResponseModelFromJson(
  List<dynamic> data,
) => List<TeacherAffiliationsResponseModel>.from(
  data.map((x) => TeacherAffiliationsResponseModel.fromJson(x)),
);

String teacherAffilationsResponseModelToJson(
  List<TeacherAffiliationsResponseModel> data,
) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TeacherAffiliationsResponseModel {
  final String? id;
  final String? teacherId;
  final String? universityId;
  final String? collegeId;
  final String? departmentId;
  final DateTime? createdAt;
  final University? university;
  final College? college;
  final Department? department;

  TeacherAffiliationsResponseModel({
    this.id,
    this.teacherId,
    this.universityId,
    this.collegeId,
    this.departmentId,
    this.createdAt,
    this.university,
    this.college,
    this.department,
  });

  TeacherAffiliationsResponseModel copyWith({
    String? id,
    String? teacherId,
    String? universityId,
    String? collegeId,
    String? departmentId,
    DateTime? createdAt,
    University? university,
    College? college,
    Department? department,
  }) => TeacherAffiliationsResponseModel(
    id: id ?? this.id,
    teacherId: teacherId ?? this.teacherId,
    universityId: universityId ?? this.universityId,
    collegeId: collegeId ?? this.collegeId,
    departmentId: departmentId ?? this.departmentId,
    createdAt: createdAt ?? this.createdAt,
    university: university ?? this.university,
    college: college ?? this.college,
    department: department ?? this.department,
  );

  factory TeacherAffiliationsResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => TeacherAffiliationsResponseModel(
    id: json["id"],
    teacherId: json["teacherId"],
    universityId: json["universityId"],
    collegeId: json["collegeId"],
    departmentId: json["departmentId"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    university: json["university"] == null
        ? null
        : University.fromJson(json["university"]),
    college: json["college"] == null ? null : College.fromJson(json["college"]),
    department: json["department"] == null
        ? null
        : Department.fromJson(json["department"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "teacherId": teacherId,
    "universityId": universityId,
    "collegeId": collegeId,
    "departmentId": departmentId,
    "createdAt": createdAt?.toIso8601String(),
    "university": university?.toJson(),
    "college": college?.toJson(),
    "department": department?.toJson(),
  };
}

class College {
  final String? id;
  final String? universityId;
  final String? name;

  College({this.id, this.universityId, this.name});

  College copyWith({String? id, String? universityId, String? name}) => College(
    id: id ?? this.id,
    universityId: universityId ?? this.universityId,
    name: name ?? this.name,
  );

  factory College.fromJson(Map<String, dynamic> json) => College(
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

class Department {
  final String? id;
  final String? collegeId;
  final String? name;

  Department({this.id, this.collegeId, this.name});

  Department copyWith({String? id, String? collegeId, String? name}) =>
      Department(
        id: id ?? this.id,
        collegeId: collegeId ?? this.collegeId,
        name: name ?? this.name,
      );

  factory Department.fromJson(Map<String, dynamic> json) => Department(
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

class University {
  final String? id;
  final String? provinceId;
  final String? name;
  final DateTime? createdAt;

  University({this.id, this.provinceId, this.name, this.createdAt});

  University copyWith({
    String? id,
    String? provinceId,
    String? name,
    DateTime? createdAt,
  }) => University(
    id: id ?? this.id,
    provinceId: provinceId ?? this.provinceId,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
  );

  factory University.fromJson(Map<String, dynamic> json) => University(
    id: json["id"],
    provinceId: json["provinceId"],
    name: json["name"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "provinceId": provinceId,
    "name": name,
    "createdAt": createdAt?.toIso8601String(),
  };
}
