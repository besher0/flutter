// To parse this JSON data, do
//
//     final courseCategory = courseCategoryFromJson(jsonString);

import 'dart:convert';

List<CourseCategory> courseCategoryFromJson(List<dynamic> data) =>
    List<CourseCategory>.from(data.map((x) => CourseCategory.fromJson(x)));

String courseCategoryToJson(List<CourseCategory> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CourseCategory {
  final String? id;
  final String? name;
  final int? sortOrder;
  final bool? requiresAcademicLinks;
  final bool? isProgram;

  CourseCategory({
    this.id,
    this.name,
    this.sortOrder,
    this.requiresAcademicLinks,
    this.isProgram,
  });

  CourseCategory copyWith({
    String? id,
    String? name,
    int? sortOrder,
    bool? requiresAcademicLinks,
    bool? isProgram,
  }) => CourseCategory(
    id: id ?? this.id,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
    requiresAcademicLinks: requiresAcademicLinks ?? this.requiresAcademicLinks,
    isProgram: isProgram ?? this.isProgram,
  );

  factory CourseCategory.fromJson(Map<String, dynamic> json) => CourseCategory(
    id: json["id"],
    name: json["name"],
    sortOrder: json["sortOrder"],
    requiresAcademicLinks: json["requiresAcademicLinks"],
    isProgram: json["isProgram"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "sortOrder": sortOrder,
    "requiresAcademicLinks": requiresAcademicLinks,
    "isProgram": isProgram,
  };
}
