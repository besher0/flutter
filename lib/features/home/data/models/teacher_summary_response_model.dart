// To parse this JSON data, do
//
//     final teacherSummaryResponseModel = teacherSummaryResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:coursaty_student_and_teacher/features/norifications/data/model/notification_model.dart';

TeacherSummaryResponseModel teacherSummaryResponseModelFromJson(String str) =>
    TeacherSummaryResponseModel.fromJson(json.decode(str));

String teacherSummaryResponseModelToJson(TeacherSummaryResponseModel data) =>
    json.encode(data.toJson());

class TeacherSummaryResponseModel {
  final String? teacherName;
  final int? monthNumber;
  final double? monthlyEarnings;
  final int? coursesCount;
  final double? averageCourseRating;
  final int? studentsCount;
  final int? likesCount;
  final List<Course>? courses;
  final SPagination? coursesPagination;
  final List<Notification>? pendingNotifications;
  final SPagination? pendingNotificationsPagination;

  TeacherSummaryResponseModel({
    this.teacherName,
    this.monthNumber,
    this.monthlyEarnings,
    this.coursesCount,
    this.averageCourseRating,
    this.studentsCount,
    this.likesCount,
    this.courses,
    this.coursesPagination,
    this.pendingNotifications,
    this.pendingNotificationsPagination,
  });

  TeacherSummaryResponseModel copyWith({
    String? teacherName,
    int? monthNumber,
    double? monthlyEarnings,
    int? coursesCount,
    double? averageCourseRating,
    int? studentsCount,
    int? likesCount,
    List<Course>? courses,
    SPagination? coursesPagination,
    List<Notification>? pendingNotifications,
    SPagination? pendingNotificationsPagination,
  }) => TeacherSummaryResponseModel(
    teacherName: teacherName ?? this.teacherName,
    monthNumber: monthNumber ?? this.monthNumber,
    monthlyEarnings: monthlyEarnings ?? this.monthlyEarnings,
    coursesCount: coursesCount ?? this.coursesCount,
    averageCourseRating: averageCourseRating ?? this.averageCourseRating,
    studentsCount: studentsCount ?? this.studentsCount,
    likesCount: likesCount ?? this.likesCount,
    courses: courses ?? this.courses,
    coursesPagination: coursesPagination ?? this.coursesPagination,
    pendingNotifications: pendingNotifications ?? this.pendingNotifications,
    pendingNotificationsPagination:
        pendingNotificationsPagination ?? this.pendingNotificationsPagination,
  );

  factory TeacherSummaryResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => TeacherSummaryResponseModel(
    teacherName: json["teacherName"],
    monthNumber: json["monthNumber"],
    monthlyEarnings: json["monthlyEarnings"]?.toDouble(),
    coursesCount: json["coursesCount"],
    averageCourseRating: json["averageCourseRating"]?.toDouble(),
    studentsCount: json["studentsCount"],
    likesCount: json["likesCount"],
    courses: json["courses"] == null
        ? []
        : List<Course>.from(json["courses"]!.map((x) => Course.fromJson(x))),
    coursesPagination: json["coursesPagination"] == null
        ? null
        : SPagination.fromJson(json["coursesPagination"]),
    pendingNotifications: json["pendingNotifications"] == null
        ? []
        : List<Notification>.from(
            json["pendingNotifications"]!.map((x) => Notification.fromJson(x)),
          ),
    pendingNotificationsPagination:
        json["pendingNotificationsPagination"] == null
        ? null
        : SPagination.fromJson(json["pendingNotificationsPagination"]),
  );

  Map<String, dynamic> toJson() => {
    "teacherName": teacherName,
    "monthNumber": monthNumber,
    "monthlyEarnings": monthlyEarnings,
    "coursesCount": coursesCount,
    "averageCourseRating": averageCourseRating,
    "studentsCount": studentsCount,
    "likesCount": likesCount,
    "courses": courses == null
        ? []
        : List<dynamic>.from(courses!.map((x) => x.toJson())),
    "coursesPagination": coursesPagination?.toJson(),
    "pendingNotifications": pendingNotifications == null
        ? []
        : List<dynamic>.from(pendingNotifications!.map((x) => x.toJson())),
    "pendingNotificationsPagination": pendingNotificationsPagination?.toJson(),
  };
}

class Course {
  final String? id;
  final String? name;
  final String? imageUrl;
  final int? duration;
  final Season? season;
  final Season? year;
  final int? studentsCount;

  Course({
    this.id,
    this.name,
    this.imageUrl,
    this.duration,
    this.season,
    this.year,
    this.studentsCount,
  });

  Course copyWith({
    String? id,
    String? name,
    String? imageUrl,
    int? duration,
    Season? season,
    Season? year,
    int? studentsCount,
  }) => Course(
    id: id ?? this.id,
    name: name ?? this.name,
    imageUrl: imageUrl ?? this.imageUrl,
    duration: duration ?? this.duration,
    season: season ?? this.season,
    year: year ?? this.year,
    studentsCount: studentsCount ?? this.studentsCount,
  );

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    id: json["id"],
    name: json["name"],
    imageUrl: json["imageUrl"],
    duration: json["duration"],
    season: json["season"] == null ? null : Season.fromJson(json["season"]),
    year: json["year"] == null ? null : Season.fromJson(json["year"]),
    studentsCount: json["studentsCount"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "imageUrl": imageUrl,
    "duration": duration,
    "season": season?.toJson(),
    "year": year?.toJson(),
    "studentsCount": studentsCount,
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

class SPagination {
  final int? page;
  final int? limit;
  final int? total;

  SPagination({this.page, this.limit, this.total});

  SPagination copyWith({int? page, int? limit, int? total}) => SPagination(
    page: page ?? this.page,
    limit: limit ?? this.limit,
    total: total ?? this.total,
  );

  factory SPagination.fromJson(Map<String, dynamic> json) => SPagination(
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
