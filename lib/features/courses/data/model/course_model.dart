// To parse this JSON data, do
//
//     final coursesResponseModel = coursesResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:coursaty_student_and_teacher/features/teachers/data/model/teacher_model.dart';

import '../../../auth/data/model/profile_model.dart' show CollegeYear;

CoursesResponseModel coursesResponseModelFromJson(String str) =>
    CoursesResponseModel.fromJson(json.decode(str));

String coursesResponseModelToJson(CoursesResponseModel data) =>
    json.encode(data.toJson());

List<CourseModel> coursesListFromJson(List<dynamic> data) =>
    List<CourseModel>.from(data.map((json) => CourseModel.fromJson(json)));

class CoursesResponseModel {
  final College? college;
  final List<YearElement>? years;
  final List<CourseModel>? courses;

  CoursesResponseModel({this.college, this.years, this.courses});

  CoursesResponseModel copyWith({
    College? college,
    List<YearElement>? years,
    List<CourseModel>? courses,
  }) => CoursesResponseModel(
    college: college ?? this.college,
    years: years ?? this.years,
    courses: courses ?? this.courses,
  );

  factory CoursesResponseModel.fromJson(Map<String, dynamic> json) =>
      CoursesResponseModel(
        college: json["college"] == null
            ? null
            : College.fromJson(json["college"]),
        years: json["years"] == null
            ? []
            : List<YearElement>.from(
                json["years"]!.map((x) => YearElement.fromJson(x)),
              ),

        courses: json["courses"] == null
            ? []
            : List<CourseModel>.from(
                json["courses"]!.map((x) => CourseModel.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "college": college?.toJson(),
    "years": years == null
        ? []
        : List<dynamic>.from(years!.map((x) => x.toJson())),
    "courses": courses == null
        ? []
        : List<dynamic>.from(courses!.map((x) => x.toJson())),
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

class YearElement {
  final SeasonClass? year;
  final Pagination? pagination;
  final List<CourseModel>? courses;

  YearElement({this.year, this.pagination, this.courses});

  YearElement copyWith({
    SeasonClass? year,
    Pagination? pagination,
    List<CourseModel>? courses,
  }) => YearElement(
    year: year ?? this.year,
    pagination: pagination ?? this.pagination,
    courses: courses ?? this.courses,
  );

  factory YearElement.fromJson(Map<String, dynamic> json) => YearElement(
    year: json["year"] == null ? null : SeasonClass.fromJson(json["year"]),
    pagination: json["pagination"] == null
        ? null
        : Pagination.fromJson(json["pagination"]),
    courses: json["courses"] == null
        ? []
        : List<CourseModel>.from(
            json["courses"]!.map((x) => CourseModel.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "year": year?.toJson(),
    "pagination": pagination?.toJson(),
    "courses": courses == null
        ? []
        : List<dynamic>.from(courses!.map((x) => x.toJson())),
  };
}

class CourseModel {
  final String? id;
  final String? name;
  final String? description;
  final String? imageUrl;
  final String? price;
  final DateTime? subscriptionExpiresAt;
  final DateTime? subscribedAt;
  final DateTime? freeCourseExpirationAt;
  final SeasonClass? season;
  final SeasonClass? year;
  final int? studentsCount;
  final Teacher? teacher;
  final double? rating;
  final CollegeYear? collegeYear;
  final bool? isFree;

  CourseModel({
    this.id,
    this.name,
    this.description,
    this.imageUrl,
    this.price,
    this.season,
    this.year,
    this.subscribedAt,
    this.freeCourseExpirationAt,
    this.subscriptionExpiresAt,
    this.studentsCount,
    this.teacher,
    this.rating,
    this.collegeYear,
    this.isFree,
  });

  CourseModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? price,
    DateTime? subscriptionExpiresAt,
    DateTime? subscribedAt,
    DateTime? freeCourseExpirationAt,
    SeasonClass? season,
    SeasonClass? year,
    CollegeYear? collegeYear,
    int? studentsCount,
    Teacher? teacher,
    double? rating,
    bool? isFree,
  }) => CourseModel(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    imageUrl: imageUrl ?? this.imageUrl,
    price: price ?? this.price,
    season: season ?? this.season,
    year: year ?? this.year,
    subscribedAt: subscribedAt ?? this.subscribedAt,
    teacher: teacher ?? this.teacher,
    subscriptionExpiresAt: subscriptionExpiresAt ?? this.subscriptionExpiresAt,
    studentsCount: studentsCount ?? this.studentsCount,
    rating: rating ?? this.rating,
    isFree: isFree ?? this.isFree,
    freeCourseExpirationAt:
        freeCourseExpirationAt ?? this.freeCourseExpirationAt,
  );

  factory CourseModel.fromJson(Map<String, dynamic> json) => CourseModel(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    imageUrl: json["imageUrl"],
    price: json["price"],
    isFree: json["isFree"] ?? false,
    subscriptionExpiresAt: DateTime.tryParse(
      json["subscriptionExpiresAt"].toString(),
    ),
    subscribedAt: DateTime.tryParse(json["subscribedAt"].toString()),
    season: json["season"] == null
        ? null
        : SeasonClass.fromJson(json["season"]),
    teacher: json["teacher"] == null ? null : Teacher.fromJson(json["teacher"]),
    collegeYear: json["collegeYear"] == null
        ? null
        : CollegeYear.fromJson(json["collegeYear"]),
    year: json["year"] == null ? null : SeasonClass.fromJson(json["year"]),
    studentsCount: json["studentsCount"],
    rating: json["_count"] == null
        ? null
        : json["_count"]['courseRatings']?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "imageUrl": imageUrl,
    "price": price,
    "isFree": isFree,
    "subscriptionExpiresAt": subscriptionExpiresAt?.toIso8601String(),
    "subscribedAt": subscribedAt?.toIso8601String(),
    "season": season?.toJson(),
    "year": year?.toJson(),
    "collegeYear": collegeYear?.toJson(),
    "studentsCount": studentsCount,
    "_count": {"courseRatings": rating},
  };
}

class YearClass {
  final String? id;
  final String? name;
  final int? number;

  YearClass({this.id, this.name, this.number});

  YearClass copyWith({String? id, String? name, int? number}) => YearClass(
    id: id ?? this.id,
    name: name ?? this.name,
    number: number ?? this.number,
  );

  factory YearClass.fromJson(Map<String, dynamic> json) => YearClass(
    id: json["id"],
    name: json["name"] ?? json["yearName"],
    number: json["number"],
  );

  Map<String, dynamic> toJson() => {"id": id, "name": name, "number": number};
}

class SeasonClass {
  final String? id;
  final String? name;
  final int? number;

  SeasonClass({this.id, this.name, this.number});

  SeasonClass copyWith({String? id, String? name, int? number}) => SeasonClass(
    id: id ?? this.id,
    name: name ?? this.name,
    number: number ?? this.number,
  );

  factory SeasonClass.fromJson(Map<String, dynamic> json) => SeasonClass(
    id: json["id"],
    name: json["name"] ?? json["seasonName"],
    number: json["number"],
  );

  Map<String, dynamic> toJson() => {"id": id, "name": name, "number": number};
}

class Pagination {
  final int? page;
  final int? limit;
  final int? total;
  final int? totalPages;

  Pagination({this.page, this.limit, this.total, this.totalPages});

  Pagination copyWith({int? page, int? limit, int? total, int? totalPages}) =>
      Pagination(
        page: page ?? this.page,
        limit: limit ?? this.limit,
        total: total ?? this.total,
        totalPages: totalPages ?? this.totalPages,
      );

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    page: json["page"],
    limit: json["limit"],
    total: json["total"],
    totalPages: json["totalPages"],
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "limit": limit,
    "total": total,
    "totalPages": totalPages,
  };
}
