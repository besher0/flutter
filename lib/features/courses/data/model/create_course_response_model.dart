// To parse this JSON data, do
//
//     final createCourseResponseModel = createCourseResponseModelFromJson(jsonString);

import 'dart:convert';

CreateCourseResponseModel createCourseResponseModelFromJson(String str) =>
    CreateCourseResponseModel.fromJson(json.decode(str));

String createCourseResponseModelToJson(CreateCourseResponseModel data) =>
    json.encode(data.toJson());

class CreateCourseResponseModel {
  final String? id;
  final String? teacherId;
  final String? subjectId;
  final String? collegeYearId;
  final String? seasonId;
  final String? universityId;
  final String? collegeId;
  final dynamic departmentId;
  final String? categoryId;
  final String? name;
  final String? description;
  final String? imageUrl;
  final String? price;
  final String? courseDiscountPercentage;
  final int? duration;
  final bool? isFree;
  final DateTime? expiresAt;
  final String? introVideoUrl;
  final String? discussionGroupUrl;
  final String? telegramUrl;
  final String? status;
  final String? teacherPercentage;
  final dynamic approvedById;
  final dynamic approvedAt;
  final DateTime? createdAt;

  CreateCourseResponseModel({
    this.id,
    this.teacherId,
    this.subjectId,
    this.collegeYearId,
    this.seasonId,
    this.universityId,
    this.collegeId,
    this.departmentId,
    this.categoryId,
    this.name,
    this.description,
    this.imageUrl,
    this.price,
    this.courseDiscountPercentage,
    this.duration,
    this.isFree,
    this.expiresAt,
    this.introVideoUrl,
    this.discussionGroupUrl,
    this.telegramUrl,
    this.status,
    this.teacherPercentage,
    this.approvedById,
    this.approvedAt,
    this.createdAt,
  });

  CreateCourseResponseModel copyWith({
    String? id,
    String? teacherId,
    String? subjectId,
    String? collegeYearId,
    String? seasonId,
    String? universityId,
    String? collegeId,
    dynamic departmentId,
    String? categoryId,
    String? name,
    String? description,
    String? imageUrl,
    String? price,
    String? courseDiscountPercentage,
    int? duration,
    bool? isFree,
    DateTime? expiresAt,
    String? introVideoUrl,
    String? discussionGroupUrl,
    String? telegramUrl,
    String? status,
    String? teacherPercentage,
    dynamic approvedById,
    dynamic approvedAt,
    DateTime? createdAt,
  }) => CreateCourseResponseModel(
    id: id ?? this.id,
    teacherId: teacherId ?? this.teacherId,
    subjectId: subjectId ?? this.subjectId,
    collegeYearId: collegeYearId ?? this.collegeYearId,
    seasonId: seasonId ?? this.seasonId,
    universityId: universityId ?? this.universityId,
    collegeId: collegeId ?? this.collegeId,
    departmentId: departmentId ?? this.departmentId,
    categoryId: categoryId ?? this.categoryId,
    name: name ?? this.name,
    description: description ?? this.description,
    imageUrl: imageUrl ?? this.imageUrl,
    price: price ?? this.price,
    courseDiscountPercentage:
        courseDiscountPercentage ?? this.courseDiscountPercentage,
    duration: duration ?? this.duration,
    isFree: isFree ?? this.isFree,
    expiresAt: expiresAt ?? this.expiresAt,
    introVideoUrl: introVideoUrl ?? this.introVideoUrl,
    discussionGroupUrl: discussionGroupUrl ?? this.discussionGroupUrl,
    telegramUrl: telegramUrl ?? this.telegramUrl,
    status: status ?? this.status,
    teacherPercentage: teacherPercentage ?? this.teacherPercentage,
    approvedById: approvedById ?? this.approvedById,
    approvedAt: approvedAt ?? this.approvedAt,
    createdAt: createdAt ?? this.createdAt,
  );

  factory CreateCourseResponseModel.fromJson(Map<String, dynamic> json) =>
      CreateCourseResponseModel(
        id: json["id"],
        teacherId: json["teacherId"],
        subjectId: json["subjectId"],
        collegeYearId: json["collegeYearId"],
        seasonId: json["seasonId"],
        universityId: json["universityId"],
        collegeId: json["collegeId"],
        departmentId: json["departmentId"],
        categoryId: json["categoryId"],
        name: json["name"],
        description: json["description"],
        imageUrl: json["imageUrl"],
        price: json["price"],
        courseDiscountPercentage: json["courseDiscountPercentage"],
        duration: json["duration"],
        isFree: json["isFree"],
        expiresAt: json["expiresAt"] == null
            ? null
            : DateTime.parse(json["expiresAt"]),
        introVideoUrl: json["introVideoUrl"],
        discussionGroupUrl: json["discussionGroupUrl"],
        telegramUrl: json["telegramUrl"] as String?,
        status: json["status"],
        teacherPercentage: json["teacherPercentage"],
        approvedById: json["approvedById"],
        approvedAt: json["approvedAt"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "teacherId": teacherId,
    "subjectId": subjectId,
    "collegeYearId": collegeYearId,
    "seasonId": seasonId,
    "universityId": universityId,
    "collegeId": collegeId,
    "departmentId": departmentId,
    "categoryId": categoryId,
    "name": name,
    "description": description,
    "imageUrl": imageUrl,
    "price": price,
    "courseDiscountPercentage": courseDiscountPercentage,
    "duration": duration,
    "isFree": isFree,
    "expiresAt": expiresAt?.toIso8601String(),
    "introVideoUrl": introVideoUrl,
    "discussionGroupUrl": discussionGroupUrl,
    "telegramUrl": telegramUrl,
    "status": status,
    "teacherPercentage": teacherPercentage,
    "approvedById": approvedById,
    "approvedAt": approvedAt,
    "createdAt": createdAt?.toIso8601String(),
  };
}
