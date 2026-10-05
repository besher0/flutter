// To parse this JSON data, do
//
//     final teacherDetailsResponseModel = teacherDetailsResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:coursaty_student_and_teacher/features/teachers/data/model/teacher_model.dart';

TeacherDetailsResponseModel teacherDetailsResponseModelFromJson(String str) =>
    TeacherDetailsResponseModel.fromJson(json.decode(str));

String teacherDetailsResponseModelToJson(TeacherDetailsResponseModel data) =>
    json.encode(data.toJson());

class TeacherDetailsResponseModel {
  final Teacher? teacher;
  final Courses? courses;

  TeacherDetailsResponseModel({this.teacher, this.courses});

  TeacherDetailsResponseModel copyWith({Teacher? teacher, Courses? courses}) =>
      TeacherDetailsResponseModel(
        teacher: teacher ?? this.teacher,
        courses: courses ?? this.courses,
      );

  factory TeacherDetailsResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => TeacherDetailsResponseModel(
    teacher: json["teacher"] == null ? null : Teacher.fromJson(json["teacher"]),
    courses: json["courses"] == null ? null : Courses.fromJson(json["courses"]),
  );

  Map<String, dynamic> toJson() => {
    "teacher": teacher?.toJson(),
    "courses": courses?.toJson(),
  };
}

class Courses {
  final List<CourseModel>? data;
  final Pagination? pagination;

  Courses({this.data, this.pagination});

  Courses copyWith({List<CourseModel>? data, Pagination? pagination}) =>
      Courses(
        data: data ?? this.data,
        pagination: pagination ?? this.pagination,
      );

  factory Courses.fromJson(Map<String, dynamic> json) => Courses(
    data: json["data"] == null
        ? []
        : List<CourseModel>.from(
            json["data"]!.map((x) => CourseModel.fromJson(x)),
          ),
    pagination: json["pagination"] == null
        ? null
        : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
  };
}

class CourseModel {
  final String? id;
  final String? name;
  final String? imageUrl;
  final int? studentsCount;
  final int? duration;
  final Year? year;
  final Season? season;
  final bool? isFree;

  CourseModel({
    this.id,
    this.name,
    this.studentsCount,
    this.imageUrl,
    this.duration,
    this.year,
    this.season,
    this.isFree,
  });

  CourseModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    int? studentsCount,
    int? duration,
    Year? year,
    Season? season,
    bool? isFree,
  }) => CourseModel(
    id: id ?? this.id,
    name: name ?? this.name,
    imageUrl: imageUrl ?? this.imageUrl,
    studentsCount: studentsCount ?? this.studentsCount,
    duration: duration ?? this.duration,
    year: year ?? this.year,
    season: season ?? this.season,
    isFree: isFree ?? this.isFree,
  );

  factory CourseModel.fromJson(Map<String, dynamic> json) => CourseModel(
    id: json["id"],
    name: json["name"],
    studentsCount: json["studentsCount"],
    imageUrl: json["imageUrl"],
    duration: json["duration"],
    isFree: json["isFree"],
    year: json["year"] == null ? null : Year.fromJson(json["year"]),
    season: json["season"] == null ? null : Season.fromJson(json["season"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "studentsCount": studentsCount,
    "imageUrl": imageUrl,
    "duration": duration,
    "isFree": isFree,
    "year": year?.toJson(),
    "season": season?.toJson(),
  };
}

class Season {
  final String? id;
  final int? seasonNumber;
  final String? seasonName;

  Season({this.id, this.seasonNumber, this.seasonName});

  Season copyWith({String? id, int? seasonNumber, String? seasonName}) =>
      Season(
        id: id ?? this.id,
        seasonNumber: seasonNumber ?? this.seasonNumber,
        seasonName: seasonName ?? this.seasonName,
      );

  factory Season.fromJson(Map<String, dynamic> json) => Season(
    id: json["id"],
    seasonNumber: json["seasonNumber"],
    seasonName: json["seasonName"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "seasonNumber": seasonNumber,
    "seasonName": seasonName,
  };
}

class Year {
  final String? id;
  final int? yearNumber;
  final String? yearName;

  Year({this.id, this.yearNumber, this.yearName});

  Year copyWith({String? id, int? yearNumber, String? yearName}) => Year(
    id: id ?? this.id,
    yearNumber: yearNumber ?? this.yearNumber,
    yearName: yearName ?? this.yearName,
  );

  factory Year.fromJson(Map<String, dynamic> json) => Year(
    id: json["id"],
    yearNumber: json["yearNumber"],
    yearName: json["yearName"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "yearNumber": yearNumber,
    "yearName": yearName,
  };
}

class Pagination {
  final int? page;
  final int? limit;
  final int? total;
  final int? totalPages;
  final bool? hasNextPage;
  final bool? hasPreviousPage;

  Pagination({
    this.page,
    this.limit,
    this.total,
    this.totalPages,
    this.hasNextPage,
    this.hasPreviousPage,
  });

  Pagination copyWith({
    int? page,
    int? limit,
    int? total,
    int? totalPages,
    bool? hasNextPage,
    bool? hasPreviousPage,
  }) => Pagination(
    page: page ?? this.page,
    limit: limit ?? this.limit,
    total: total ?? this.total,
    totalPages: totalPages ?? this.totalPages,
    hasNextPage: hasNextPage ?? this.hasNextPage,
    hasPreviousPage: hasPreviousPage ?? this.hasPreviousPage,
  );

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    page: json["page"],
    limit: json["limit"],
    total: json["total"],
    totalPages: json["totalPages"],
    hasNextPage: json["hasNextPage"],
    hasPreviousPage: json["hasPreviousPage"],
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "limit": limit,
    "total": total,
    "totalPages": totalPages,
    "hasNextPage": hasNextPage,
    "hasPreviousPage": hasPreviousPage,
  };
}
