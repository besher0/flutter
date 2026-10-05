// To parse this JSON data, do
//
//     final searchResponseModel = searchResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:coursaty_student_and_teacher/features/courses/data/model/course_model.dart';
import 'package:coursaty_student_and_teacher/features/teachers/data/model/teacher_model.dart'
    hide College;

import '../../../courses/data/model/course_details_model.dart' hide Teacher;

SearchResponseModel searchResponseModelFromJson(String str) =>
    SearchResponseModel.fromJson(json.decode(str));

String searchResponseModelToJson(SearchResponseModel data) =>
    json.encode(data.toJson());

class SearchResponseModel {
  final String? query;
  final List<SubjectModel>? subjects;
  final List<SubjectModel>? programs;
  final List<Teacher>? teachers;
  final List<CourseModel>? courses;

  SearchResponseModel({
    this.query,
    this.subjects,
    this.programs,
    this.teachers,
    this.courses,
  });

  SearchResponseModel copyWith({
    String? query,
    final List<SubjectModel>? subjects,
    final List<SubjectModel>? programs,
    final List<Teacher>? teachers,
    List<CourseModel>? courses,
  }) => SearchResponseModel(
    query: query ?? this.query,
    subjects: subjects ?? this.subjects,
    programs: programs ?? this.programs,
    teachers: teachers ?? this.teachers,
    courses: courses ?? this.courses,
  );

  factory SearchResponseModel.fromJson(Map<String, dynamic> json) =>
      SearchResponseModel(
        query: json["query"],
        subjects: json["subjects"] == null
            ? []
            : List<SubjectModel>.from(
                json["subjects"]!.map((x) => SubjectModel.fromJson(x)),
              ),
        programs: json["programs"] == null
            ? []
            : List<SubjectModel>.from(
                json["programs"]!.map((x) => SubjectModel.fromJson(x)),
              ),
        teachers: json["teachers"] == null
            ? []
            : List<Teacher>.from(
                json["teachers"]!.map((x) => Teacher.fromJson(x)),
              ),
        courses: json["courses"]['data'] == null
            ? []
            : List<CourseModel>.from(
                json["courses"]['data']!.map((x) => CourseModel.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "query": query,
    "subjects": subjects == null
        ? []
        : List<dynamic>.from(subjects!.map((x) => x.toJson())),
    "programs": programs == null
        ? []
        : List<dynamic>.from(programs!.map((x) => x.toJson())),
    "teachers": teachers == null
        ? []
        : List<dynamic>.from(teachers!.map((x) => x.toJson())),
    "courses": courses == null
        ? []
        : List<dynamic>.from(courses!.map((x) => x.toJson())),
  };
}

class SubjectModel {
  final String? id;
  final String? name;
  final bool? isProgram;
  final String? imageUrl;
  final College? college;
  final dynamic department;
  final Season? year;
  final Season? season;
  final Teacher? teacher;

  SubjectModel({
    this.id,
    this.name,
    this.isProgram,
    this.imageUrl,
    this.college,
    this.department,
    this.year,
    this.season,
    this.teacher,
  });

  SubjectModel copyWith({
    String? id,
    String? name,
    bool? isProgram,
    String? imageUrl,
    College? college,
    dynamic department,
    Season? year,
    Season? season,
    Teacher? teacher,
  }) => SubjectModel(
    id: id ?? this.id,
    name: name ?? this.name,
    isProgram: isProgram ?? this.isProgram,
    imageUrl: imageUrl ?? this.imageUrl,
    college: college ?? this.college,
    department: department ?? this.department,
    year: year ?? this.year,
    season: season ?? this.season,
    teacher: teacher ?? this.teacher,
  );

  factory SubjectModel.fromJson(Map<String, dynamic> json) => SubjectModel(
    id: json["id"],
    name: json["name"],
    isProgram: json["isProgram"],
    imageUrl: json["imageUrl"],
    college: json["college"] == null ? null : College.fromJson(json["college"]),
    department: json["department"],
    year: json["year"] == null ? null : Season.fromJson(json["year"]),
    season: json["season"] == null ? null : Season.fromJson(json["season"]),
    teacher: json["teacher"] == null ? null : Teacher.fromJson(json["teacher"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "isProgram": isProgram,
    "imageUrl": imageUrl,
    "college": college?.toJson(),
    "department": department,
    "year": year?.toJson(),
    "season": season?.toJson(),
    "teacher": teacher?.toJson(),
  };
}
