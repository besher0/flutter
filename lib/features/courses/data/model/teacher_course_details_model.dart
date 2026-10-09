// To parse this JSON data, do
//
//     final teacherCourseDetailsResponseModel = teacherCourseDetailsResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:coursaty_student_and_teacher/features/courses/data/model/course_details_model.dart';

TeacherCourseDetailsResponseModel teacherCourseDetailsResponseModelFromJson(
  String str,
) => TeacherCourseDetailsResponseModel.fromJson(json.decode(str));

String teacherCourseDetailsResponseModelToJson(
  TeacherCourseDetailsResponseModel data,
) => json.encode(data.toJson());

class TeacherCourseDetailsResponseModel {
  final Course? course;
  final Details? details;
  final List<Lecture>? lectures;

  TeacherCourseDetailsResponseModel({this.course, this.details, this.lectures});

  TeacherCourseDetailsResponseModel copyWith({
    Course? course,
    Details? details,
    List<Lecture>? lectures,
  }) => TeacherCourseDetailsResponseModel(
    course: course ?? this.course,
    details: details ?? this.details,
    lectures: lectures ?? this.lectures,
  );

  factory TeacherCourseDetailsResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => TeacherCourseDetailsResponseModel(
    course: json["course"] == null ? null : Course.fromJson(json["course"]),
    details: json["details"] == null ? null : Details.fromJson(json["details"]),
    lectures: json["lectures"] == null
        ? []
        : List<Lecture>.from(json["lectures"]!.map((x) => Lecture.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "course": course?.toJson(),
    "details": details?.toJson(),
    "lectures": lectures == null
        ? []
        : List<dynamic>.from(lectures!.map((x) => x)),
  };
}

class Course {
  final String? id;
  final String? imageUrl;
  final String? name;
  final int? basePrice;
  final int? discountedPrice;
  final bool? isFree;
  final bool? locked;
  final String? telegramUrl;

  /// Whether students see the price. Missing (older backends) means visible.
  final bool isPriceVisible;

  Course({
    this.id,
    this.imageUrl,
    this.name,
    this.basePrice,
    this.discountedPrice,
    this.isFree,
    this.locked,
    this.telegramUrl,
    this.isPriceVisible = true,
  });

  Course copyWith({
    String? id,
    String? imageUrl,
    String? name,
    int? basePrice,
    int? discountedPrice,
    bool? isFree,
    bool? locked,
    String? telegramUrl,
    bool? isPriceVisible,
  }) => Course(
    id: id ?? this.id,
    imageUrl: imageUrl ?? this.imageUrl,
    name: name ?? this.name,
    basePrice: basePrice ?? this.basePrice,
    discountedPrice: discountedPrice ?? this.discountedPrice,
    isFree: isFree ?? this.isFree,
    locked: locked ?? this.locked,
    telegramUrl: telegramUrl ?? this.telegramUrl,
    isPriceVisible: isPriceVisible ?? this.isPriceVisible,
  );

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    id: json["id"],
    imageUrl: json["imageUrl"],
    name: json["name"],
    basePrice: json["basePrice"],
    discountedPrice: json["discountedPrice"]?.toInt(),
    isFree: json["isFree"],
    locked: json["locked"],
    telegramUrl: json["telegramUrl"] as String?,
    isPriceVisible: json["isPriceVisible"] is bool
        ? json["isPriceVisible"] as bool
        : true,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "imageUrl": imageUrl,
    "name": name,
    "basePrice": basePrice,
    "discountedPrice": discountedPrice,
    "isFree": isFree,
    "locked": locked,
    "telegramUrl": telegramUrl,
    "isPriceVisible": isPriceVisible,
  };
}

class Details {
  final Teacher? teacher;
  final int? durationSeconds;
  final String? description;
  final String? introVideoUrl;
  final String? discussionGroupUrl;

  /// Course Telegram link. The backend sends it under `details`.
  final String? telegramUrl;
  final int? studentsCount;
  final Season? year;
  final Season? season;
  final int? lecturesCount;
  final int? videosCount;
  final int? filesCount;
  final int? questionsCount;
  final DateTime? expiresAt;
  final String? universityId,
      collegeId,
      departmentId,
      yearId,
      seasonId,
      categoryId,
      subjectId;

  Details({
    this.teacher,
    this.durationSeconds,
    this.description,
    this.introVideoUrl,
    this.discussionGroupUrl,
    this.telegramUrl,
    this.studentsCount,
    this.year,
    this.season,
    this.lecturesCount,
    this.videosCount,
    this.filesCount,
    this.questionsCount,
    this.seasonId,
    this.universityId,
    this.collegeId,
    this.departmentId,
    this.yearId,
    this.categoryId,
    this.subjectId,
    this.expiresAt,
  });

  Details copyWith({
    Teacher? teacher,
    int? durationSeconds,
    String? description,
    String? introVideoUrl,
    String? discussionGroupUrl,
    String? telegramUrl,
    int? studentsCount,
    Season? year,
    Season? season,
    int? lecturesCount,
    int? videosCount,
    int? filesCount,
    int? questionsCount,
    String? universityId,
    String? categoryId,
    collegeId,
    subjectId,
    departmentId,
    yearId,
    seasonId,
    DateTime? expiresAt,
  }) => Details(
    teacher: teacher ?? this.teacher,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    description: description ?? this.description,
    introVideoUrl: introVideoUrl ?? this.introVideoUrl,
    discussionGroupUrl: discussionGroupUrl ?? this.discussionGroupUrl,
    telegramUrl: telegramUrl ?? this.telegramUrl,
    studentsCount: studentsCount ?? this.studentsCount,
    year: year ?? this.year,
    season: season ?? this.season,
    lecturesCount: lecturesCount ?? this.lecturesCount,
    videosCount: videosCount ?? this.videosCount,
    filesCount: filesCount ?? this.filesCount,
    questionsCount: questionsCount ?? this.questionsCount,
    universityId: universityId ?? this.universityId,
    collegeId: collegeId ?? this.collegeId,
    departmentId: departmentId ?? this.departmentId,
    yearId: yearId ?? this.yearId,
    seasonId: seasonId ?? this.seasonId,
    subjectId: subjectId ?? this.subjectId,
    categoryId: categoryId ?? this.categoryId,
    expiresAt: expiresAt ?? this.expiresAt,
  );

  factory Details.fromJson(Map<String, dynamic> json) => Details(
    teacher: json["teacher"] == null ? null : Teacher.fromJson(json["teacher"]),
    durationSeconds: (json["duration"] ?? json["durationSeconds"]) is num
        ? ((json["duration"] ?? json["durationSeconds"]) as num).toInt()
        : null,
    description: json["description"],
    introVideoUrl: json["introVideoUrl"],
    discussionGroupUrl: json["discussionGroupUrl"],
    telegramUrl: json["telegramUrl"] as String?,
    studentsCount: json["studentsCount"],
    year: json["year"] == null ? null : Season.fromJson(json["year"]),
    season: json["season"] == null ? null : Season.fromJson(json["season"]),
    lecturesCount: json["lecturesCount"],
    videosCount: json["videosCount"],
    filesCount: json["filesCount"],
    questionsCount: json["questionsCount"],
    universityId: json["universityId"],
    yearId: json["yearId"],
    collegeId: json["collegeId"],
    departmentId: json["departmentId"],
    seasonId: json["seasonId"],
    subjectId: json["subjectId"],
    categoryId: json["categoryId"],
    expiresAt: DateTime.tryParse(json["expiresAt"].toString()),
  );

  Map<String, dynamic> toJson() => {
    "teacher": teacher?.toJson(),
    "durationSeconds": durationSeconds,
    "description": description,
    "introVideoUrl": introVideoUrl,
    "discussionGroupUrl": discussionGroupUrl,
    "telegramUrl": telegramUrl,
    "studentsCount": studentsCount,
    "year": year?.toJson(),
    "season": season?.toJson(),
    "lecturesCount": lecturesCount,
    "videosCount": videosCount,
    "filesCount": filesCount,
    "subjectId": subjectId,
    "questionsCount": questionsCount,
    "expiresAt": expiresAt,
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
