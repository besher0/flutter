// To parse this JSON data, do
//
//     final courseRatingModel = courseRatingModelFromJson(jsonString);

import 'dart:convert';

CourseRatingModel courseRatingModelFromJson(String str) =>
    CourseRatingModel.fromJson(json.decode(str));

String courseRatingModelToJson(CourseRatingModel data) =>
    json.encode(data.toJson());

class CourseRatingModel {
  final String? courseId;
  final double? averageRating;
  final int? totalRatings;
  final bool? isRatedByUser;
  final dynamic myRating;

  CourseRatingModel({
    this.courseId,
    this.averageRating,
    this.totalRatings,
    this.isRatedByUser,
    this.myRating,
  });

  CourseRatingModel copyWith({
    String? courseId,
    double? averageRating,
    int? totalRatings,
    bool? isRatedByUser,
    dynamic myRating,
  }) => CourseRatingModel(
    courseId: courseId ?? this.courseId,
    averageRating: averageRating ?? this.averageRating,
    totalRatings: totalRatings ?? this.totalRatings,
    isRatedByUser: isRatedByUser ?? this.isRatedByUser,
    myRating: myRating ?? this.myRating,
  );

  factory CourseRatingModel.fromJson(Map<String, dynamic> json) =>
      CourseRatingModel(
        courseId: json["courseId"],
        averageRating: json["averageRating"]?.toDouble(),
        totalRatings: json["totalRatings"],
        isRatedByUser: json["isRatedByUser"],
        myRating: json["myRating"],
      );

  Map<String, dynamic> toJson() => {
    "courseId": courseId,
    "averageRating": averageRating,
    "totalRatings": totalRatings,
    "isRatedByUser": isRatedByUser,
    "myRating": myRating,
  };
}
