// To parse this JSON data, do
//
//     final coursesOfSubjectResponseModel = coursesOfSubjectResponseModelFromJson(jsonString);

import 'dart:convert';

CoursesOfSubjectResponseModel coursesOfSubjectResponseModelFromJson(
  String str,
) => CoursesOfSubjectResponseModel.fromJson(json.decode(str));

String coursesOfSubjectResponseModelToJson(
  CoursesOfSubjectResponseModel data,
) => json.encode(data.toJson());

class CoursesOfSubjectResponseModel {
  final Subject? subject;
  final Courses? courses;

  CoursesOfSubjectResponseModel({this.subject, this.courses});

  CoursesOfSubjectResponseModel copyWith({
    Subject? subject,
    Courses? courses,
  }) => CoursesOfSubjectResponseModel(
    subject: subject ?? this.subject,
    courses: courses ?? this.courses,
  );

  factory CoursesOfSubjectResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => CoursesOfSubjectResponseModel(
    subject: json["subject"] == null ? null : Subject.fromJson(json["subject"]),
    courses: json["courses"] == null ? null : Courses.fromJson(json["courses"]),
  );

  Map<String, dynamic> toJson() => {
    "subject": subject?.toJson(),
    "courses": courses?.toJson(),
  };
}

class Courses {
  final List<CourseInSubjectModel>? data;
  final Pagination? pagination;

  Courses({this.data, this.pagination});

  Courses copyWith({
    List<CourseInSubjectModel>? data,
    Pagination? pagination,
  }) => Courses(
    data: data ?? this.data,
    pagination: pagination ?? this.pagination,
  );

  factory Courses.fromJson(Map<String, dynamic> json) => Courses(
    data: json["data"] == null
        ? []
        : List<CourseInSubjectModel>.from(
            json["data"]!.map((x) => CourseInSubjectModel.fromJson(x)),
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

class CourseInSubjectModel {
  final String? id;
  final String? name;
  final String? imageUrl;
  final String? price;
  final Season? season;
  final Season? year;
  final Teacher? teacher;
  final int? studentsCount;
  final int? duration;
  final bool? isFree;

  CourseInSubjectModel({
    this.id,
    this.name,
    this.imageUrl,
    this.price,
    this.season,
    this.year,
    this.teacher,
    this.studentsCount,
    this.duration,
    this.isFree,
  });

  CourseInSubjectModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? price,
    Season? season,
    Season? year,
    Teacher? teacher,
    int? studentsCount,
    int? duration,
    bool? isFree,
  }) => CourseInSubjectModel(
    id: id ?? this.id,
    name: name ?? this.name,
    imageUrl: imageUrl ?? this.imageUrl,
    price: price ?? this.price,
    season: season ?? this.season,
    year: year ?? this.year,
    teacher: teacher ?? this.teacher,
    studentsCount: studentsCount ?? this.studentsCount,
    duration: duration ?? this.duration,
    isFree: isFree ?? this.isFree,
  );

  factory CourseInSubjectModel.fromJson(Map<String, dynamic> json) =>
      CourseInSubjectModel(
        id: json["id"],
        name: json["name"],
        imageUrl: json["imageUrl"],
        price: json["price"],
        duration: json["duration"],
        season: json["season"] == null ? null : Season.fromJson(json["season"]),
        year: json["year"] == null ? null : Season.fromJson(json["year"]),
        teacher: json["teacher"] == null
            ? null
            : Teacher.fromJson(json["teacher"]),
        studentsCount: json["studentsCount"],
        isFree: json["isFree"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "imageUrl": imageUrl,
    "price": price,
    "duration": duration,
    "season": season?.toJson(),
    "year": year?.toJson(),
    "teacher": teacher?.toJson(),
    "studentsCount": studentsCount,
    "isFree": isFree,
  };
}

class Season {
  final String? id;
  final String? name;
  final int? number;

  Season({this.id, this.name, this.number});

  Season copyWith({String? id, String? name, int? number}) => Season(
    id: id ?? this.id,
    name: name ?? this.name,
    number: number ?? this.number,
  );

  factory Season.fromJson(Map<String, dynamic> json) =>
      Season(id: json["id"], name: json["name"], number: json["number"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name, "number": number};
}

class Teacher {
  final String? id;
  final String? name;
  final String? image;

  Teacher({this.id, this.name, this.image});

  Teacher copyWith({String? id, String? name, String? image}) => Teacher(
    id: id ?? this.id,
    name: name ?? this.name,
    image: image ?? this.image,
  );

  factory Teacher.fromJson(Map<String, dynamic> json) =>
      Teacher(id: json["id"], name: json["name"], image: json["image"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name, "image": image};
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

class Subject {
  final String? id;
  final String? name;
  final String? image;

  Subject({this.id, this.name, this.image});

  Subject copyWith({String? id, String? name, String? image}) => Subject(
    id: id ?? this.id,
    name: name ?? this.name,
    image: image ?? this.image,
  );

  factory Subject.fromJson(Map<String, dynamic> json) =>
      Subject(id: json["id"], name: json["name"], image: json["imageUrl"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name, "imageUrl": image};
}
