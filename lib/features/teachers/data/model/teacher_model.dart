// To parse this JSON data, do
//
//     final teachersResponseModel = teachersResponseModelFromJson(jsonString);

import 'dart:convert';

TeachersResponseModel teachersResponseModelFromJson(String str) =>
    TeachersResponseModel.fromJson(json.decode(str));

String teachersResponseModelToJson(TeachersResponseModel data) =>
    json.encode(data.toJson());

List<Teacher> teachersListFromJson(List<dynamic> data) =>
    List<Teacher>.from(data.map((x) => Teacher.fromJson(x)));

class TeachersResponseModel {
  final College? college;
  final List<Teacher>? teachers;

  TeachersResponseModel({this.college, this.teachers});

  TeachersResponseModel copyWith({College? college, List<Teacher>? teachers}) =>
      TeachersResponseModel(
        college: college ?? this.college,
        teachers: teachers ?? this.teachers,
      );

  factory TeachersResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => TeachersResponseModel(
    college: json["college"] == null ? null : College.fromJson(json["college"]),
    teachers: json["teachers"] == null
        ? []
        : List<Teacher>.from(json["teachers"]!.map((x) => Teacher.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "college": college?.toJson(),
    "teachers": teachers == null
        ? []
        : List<dynamic>.from(teachers!.map((x) => x.toJson())),
  };
}

class College {
  final String? id;
  final String? name;
  final String? universityId;

  College({this.id, this.name, this.universityId});

  College copyWith({String? id, String? name, String? universityId}) => College(
    id: id ?? this.id,
    name: name ?? this.name,
    universityId: universityId ?? this.universityId,
  );

  factory College.fromJson(Map<String, dynamic> json) => College(
    id: json["id"],
    name: json["name"],
    universityId: json["universityId"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "universityId": universityId,
  };
}

class Teacher {
  final String? id;
  final String? name;
  final String? description;
  final String? image;
  final int? coursesCount;
  final int? likesCount;
  final String? instagramUrl;

  Teacher({
    this.id,
    this.name,
    this.description,
    this.image,
    this.coursesCount,
    this.likesCount,
    this.instagramUrl,
  });

  Teacher copyWith({
    String? id,
    String? name,
    String? description,
    String? image,
    int? coursesCount,
    int? likesCount,
    String? instagramUrl,
  }) => Teacher(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    image: image ?? this.image,
    coursesCount: coursesCount ?? this.coursesCount,
    likesCount: likesCount ?? this.likesCount,
    instagramUrl: instagramUrl ?? this.instagramUrl,
  );

  factory Teacher.fromJson(Map<String, dynamic> json) => Teacher(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    image: json["image"],
    coursesCount: json["coursesCount"],
    likesCount: json["likesCount"],
    instagramUrl: json["instagramUrl"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "image": image,
    "coursesCount": coursesCount,
    "likesCount": likesCount,
    "instagramUrl": instagramUrl,
  };
}
