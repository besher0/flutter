// To parse this JSON data, do
//
//     final teacherCoursesResponseModel = teacherCoursesResponseModelFromJson(jsonString);

import 'dart:convert';

TeacherCoursesResponseModel teacherCoursesResponseModelFromJson(String str) =>
    TeacherCoursesResponseModel.fromJson(json.decode(str));

String teacherCoursesResponseModelToJson(TeacherCoursesResponseModel data) =>
    json.encode(data.toJson());

class TeacherCoursesResponseModel {
  final List<UniversityElement>? universities;
  final Pagination? pagination;

  TeacherCoursesResponseModel({this.universities, this.pagination});

  TeacherCoursesResponseModel copyWith({
    List<UniversityElement>? universities,
    Pagination? pagination,
  }) => TeacherCoursesResponseModel(
    universities: universities ?? this.universities,
    pagination: pagination ?? this.pagination,
  );

  factory TeacherCoursesResponseModel.fromJson(Map<String, dynamic> json) =>
      TeacherCoursesResponseModel(
        universities: json["universities"] == null
            ? []
            : List<UniversityElement>.from(
                json["universities"]!.map((x) => UniversityElement.fromJson(x)),
              ),
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
    "universities": universities == null
        ? []
        : List<dynamic>.from(universities!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
  };
}

class Pagination {
  final int? page;
  final int? limit;
  final int? total;

  Pagination({this.page, this.limit, this.total});

  Pagination copyWith({int? page, int? limit, int? total}) => Pagination(
    page: page ?? this.page,
    limit: limit ?? this.limit,
    total: total ?? this.total,
  );

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    page: json["page"],
    limit: json["limit"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "limit": limit,
    "total": total,
  };
}

class UniversityElement {
  final UniversityUniversity? university;
  final List<YearElement>? years;

  UniversityElement({this.university, this.years});

  UniversityElement copyWith({
    UniversityUniversity? university,
    List<YearElement>? years,
  }) => UniversityElement(
    university: university ?? this.university,
    years: years ?? this.years,
  );

  factory UniversityElement.fromJson(Map<String, dynamic> json) =>
      UniversityElement(
        university: json["university"] == null
            ? null
            : UniversityUniversity.fromJson(json["university"]),
        years: json["years"] == null
            ? []
            : List<YearElement>.from(
                json["years"]!.map((x) => YearElement.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "university": university?.toJson(),
    "years": years == null
        ? []
        : List<dynamic>.from(years!.map((x) => x.toJson())),
  };
}

class UniversityUniversity {
  final String? id;
  final String? name;

  UniversityUniversity({this.id, this.name});

  UniversityUniversity copyWith({String? id, String? name}) =>
      UniversityUniversity(id: id ?? this.id, name: name ?? this.name);

  factory UniversityUniversity.fromJson(Map<String, dynamic> json) =>
      UniversityUniversity(id: json["id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}

class YearElement {
  final SeasonClass? year;
  final List<Course>? courses;

  YearElement({this.year, this.courses});

  YearElement copyWith({SeasonClass? year, List<Course>? courses}) =>
      YearElement(year: year ?? this.year, courses: courses ?? this.courses);

  factory YearElement.fromJson(Map<String, dynamic> json) => YearElement(
    year: json["year"] == null ? null : SeasonClass.fromJson(json["year"]),
    courses: json["courses"] == null
        ? []
        : List<Course>.from(json["courses"]!.map((x) => Course.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "year": year?.toJson(),
    "courses": courses == null
        ? []
        : List<dynamic>.from(courses!.map((x) => x.toJson())),
  };
}

class Course {
  final String? id;
  final String? name;
  final String? imageUrl;
  final int? duration;
  final DateTime? expiresAt;
  final int? studentsCount;
  final SeasonClass? season;
  final bool? isFree;
  final String? telegramUrl;

  Course({
    this.id,
    this.name,
    this.imageUrl,
    this.duration,
    this.expiresAt,
    this.studentsCount,
    this.season,
    this.isFree,
    this.telegramUrl,
  });

  Course copyWith({
    String? id,
    String? name,
    String? imageUrl,
    int? duration,
    DateTime? expiresAt,
    int? studentsCount,
    bool? isFree,
    SeasonClass? season,
    String? telegramUrl,
  }) => Course(
    id: id ?? this.id,
    name: name ?? this.name,
    imageUrl: imageUrl ?? this.imageUrl,
    duration: duration ?? this.duration,
    expiresAt: expiresAt ?? this.expiresAt,
    studentsCount: studentsCount ?? this.studentsCount,
    season: season ?? this.season,
    isFree: isFree ?? this.isFree,
    telegramUrl: telegramUrl ?? this.telegramUrl,
  );

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    id: json["id"],
    name: json["name"],
    imageUrl: json["imageUrl"],
    duration: json["duration"],
    isFree: json["isFree"],
    telegramUrl: json["telegramUrl"] as String?,
    expiresAt: json["expiresAt"] == null
        ? null
        : DateTime.parse(json["expiresAt"]),
    studentsCount: json["studentsCount"],
    season: json["season"] == null
        ? null
        : SeasonClass.fromJson(json["season"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "imageUrl": imageUrl,
    "duration": duration,
    "isFree": isFree,
    "telegramUrl": telegramUrl,
    "expiresAt": expiresAt?.toIso8601String(),
    "studentsCount": studentsCount,
    "season": season?.toJson(),
  };
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

  factory SeasonClass.fromJson(Map<String, dynamic> json) =>
      SeasonClass(id: json["id"], name: json["name"], number: json["number"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name, "number": number};
}
