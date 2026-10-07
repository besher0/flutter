// To parse this JSON data, do
//
//     final courseDetailsModel = courseDetailsModelFromJson(jsonString);

import 'dart:convert';

CourseDetailsModel courseDetailsModelFromJson(String str) =>
    CourseDetailsModel.fromJson(json.decode(str));

String courseDetailsModelToJson(CourseDetailsModel data) =>
    json.encode(data.toJson());

class CourseDetailsModel {
  final Course? course;
  final Details? details;
  final List<Lecture>? lectures;

  final DateTime? subscriptionExpiresAt, subscribedAt;

  CourseDetailsModel({
    this.course,
    this.details,
    this.lectures,
    this.subscriptionExpiresAt,
    this.subscribedAt,
  });

  CourseDetailsModel copyWith({
    Course? course,
    Details? details,
    List<Lecture>? lectures,
    DateTime? subscriptionExpiresAt,
    subscribedAt,
  }) => CourseDetailsModel(
    course: course ?? this.course,
    details: details ?? this.details,
    lectures: lectures ?? this.lectures,
    subscriptionExpiresAt: subscriptionExpiresAt ?? this.subscriptionExpiresAt,
    subscribedAt: subscribedAt ?? this.subscribedAt,
  );

  factory CourseDetailsModel.fromJson(
    Map<String, dynamic> json,
  ) => CourseDetailsModel(
    course: json["course"] == null ? null : Course.fromJson(json["course"]),
    details: json["details"] == null ? null : Details.fromJson(json["details"]),
    lectures: json["lectures"] == null
        ? []
        : List<Lecture>.from(json["lectures"]!.map((x) => Lecture.fromJson(x))),
    subscriptionExpiresAt: json['subscriptionExpiresAt'] == null
        ? null
        : DateTime.parse(json['subscriptionExpiresAt']),
    subscribedAt: json['subscribedAt'] == null
        ? null
        : DateTime.parse(json['subscribedAt']),
  );

  Map<String, dynamic> toJson() => {
    "course": course?.toJson(),
    "details": details?.toJson(),
    "subscriptionExpiresAt": subscriptionExpiresAt?.toIso8601String(),
    "subscribedAt": subscribedAt?.toIso8601String(),
    "lectures": lectures == null
        ? []
        : List<dynamic>.from(lectures!.map((x) => x.toJson())),
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
  final String? paymentQrUrl;
  final String? telegramUrl;

  Course({
    this.id,
    this.imageUrl,
    this.name,
    this.basePrice,
    this.discountedPrice,
    this.isFree,
    this.locked,
    this.paymentQrUrl,
    this.telegramUrl,
  });

  Course copyWith({
    String? id,
    String? imageUrl,
    String? name,
    int? basePrice,
    int? durationInCourseDetails,
    int? discountedPrice,
    bool? isFree,
    bool? locked,
    String? paymentQrUrl,
    String? telegramUrl,
  }) => Course(
    id: id ?? this.id,
    imageUrl: imageUrl ?? this.imageUrl,
    name: name ?? this.name,
    basePrice: basePrice ?? this.basePrice,
    discountedPrice: discountedPrice ?? this.discountedPrice,
    isFree: isFree ?? this.isFree,
    locked: locked ?? this.locked,
    paymentQrUrl: paymentQrUrl ?? this.paymentQrUrl,
    telegramUrl: telegramUrl ?? this.telegramUrl,
  );

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    id: json["id"],
    imageUrl: json["imageUrl"],
    name: json["name"],
    basePrice: json["basePrice"],
    discountedPrice: json["discountedPrice"],
    isFree: json["isFree"],
    locked: json["locked"],
    paymentQrUrl: json["paymentQrUrl"],
    telegramUrl: json["telegramUrl"] as String?,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "imageUrl": imageUrl,
    "name": name,
    "basePrice": basePrice,
    "discountedPrice": discountedPrice,
    "isFree": isFree,
    "locked": locked,
    "paymentQrUrl": paymentQrUrl,
    "telegramUrl": telegramUrl,
  };
}

class Details {
  final Teacher? teacher;
  final String? description;
  final String? introVideoUrl;
  final String? discussionGroupUrl;
  final String? instagramUrl;
  final int? studentsCount;
  final int? duration;
  final Season? year;
  final Season? season;
  final int? lecturesCount;
  final int? videosCount;
  final int? filesCount;
  final int? questionsCount;
  final DateTime? expiresAt;
  final bool? isExpired;

  Details({
    this.teacher,
    this.description,
    this.studentsCount,
    this.year,
    this.duration,
    this.instagramUrl,
    this.season,
    this.lecturesCount,
    this.videosCount,
    this.filesCount,
    this.questionsCount,
    this.introVideoUrl,
    this.discussionGroupUrl,
    this.expiresAt,
    this.isExpired,
  });

  Details copyWith({
    Teacher? teacher,
    String? description,
    String? introVideoUrl,
    String? discussionGroupUrl,
    String? instagramUrl,
    int? duration,
    int? studentsCount,
    Season? year,
    Season? season,
    int? lecturesCount,
    int? videosCount,
    int? filesCount,
    int? questionsCount,
    DateTime? expiresAt,
    bool? isExpired,
  }) => Details(
    discussionGroupUrl: discussionGroupUrl ?? this.discussionGroupUrl,
    teacher: teacher ?? this.teacher,
    introVideoUrl: introVideoUrl ?? this.introVideoUrl,
    description: description ?? this.description,
    studentsCount: studentsCount ?? this.studentsCount,
    expiresAt: expiresAt ?? this.expiresAt,
    isExpired: isExpired ?? this.isExpired,
    instagramUrl: instagramUrl ?? this.instagramUrl,
    duration: duration ?? this.duration,
    year: year ?? this.year,
    season: season ?? this.season,
    lecturesCount: lecturesCount ?? this.lecturesCount,
    videosCount: videosCount ?? this.videosCount,
    filesCount: filesCount ?? this.filesCount,
    questionsCount: questionsCount ?? this.questionsCount,
  );

  factory Details.fromJson(Map<String, dynamic> json) => Details(
    teacher: json["teacher"] == null ? null : Teacher.fromJson(json["teacher"]),
    description: json["description"],
    studentsCount: json["studentsCount"],
    duration: json["duration"],
    instagramUrl: json["instagramUrl"],
    year: json["year"] == null ? null : Season.fromJson(json["year"]),
    expiresAt: json["expiresAt"] == null
        ? null
        : DateTime.parse(json["expiresAt"]),
    isExpired: json["isExpired"],
    season: json["season"] == null ? null : Season.fromJson(json["season"]),
    lecturesCount: json["lecturesCount"],
    videosCount: json["videosCount"],
    filesCount: json["filesCount"],
    questionsCount: json["questionsCount"],
    introVideoUrl: json["introVideoUrl"],
    discussionGroupUrl: json["discussionGroupUrl"],
  );

  Map<String, dynamic> toJson() => {
    "teacher": teacher?.toJson(),
    "discussionGroupUrl": discussionGroupUrl,
    "description": description,
    "introVideoUrl": introVideoUrl,
    "studentsCount": studentsCount,
    "instagramUrl": instagramUrl,
    "year": year?.toJson(),
    "season": season?.toJson(),
    "lecturesCount": lecturesCount,
    "videosCount": videosCount,
    "filesCount": filesCount,
    "questionsCount": questionsCount,
    "expiresAt": expiresAt?.toIso8601String(),
    "isExpired": isExpired,
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

class Lecture {
  final String? id;
  final String? title;
  final String? description;
  final String? imageUrl;
  final int? videosCount;
  final int? filesCount;
  final int? questionsCount;
  final int? sortOrder;

  Lecture({
    this.id,
    this.title,
    this.description,
    this.imageUrl,
    this.videosCount,
    this.filesCount,
    this.questionsCount,
    this.sortOrder,
  });

  Lecture copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    int? videosCount,
    int? filesCount,
    int? questionsCount,
    int? sortOrder,
  }) => Lecture(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    imageUrl: imageUrl ?? this.imageUrl,
    videosCount: videosCount ?? this.videosCount,
    filesCount: filesCount ?? this.filesCount,
    questionsCount: questionsCount ?? this.questionsCount,
    sortOrder: sortOrder ?? this.sortOrder,
  );

  factory Lecture.fromJson(Map<String, dynamic> json) => Lecture(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    imageUrl: json["imageUrl"],
    videosCount: json["videosCount"],
    filesCount: json["filesCount"],
    questionsCount: json["questionsCount"],
    sortOrder: json["sortOrder"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "imageUrl": imageUrl,
    "videosCount": videosCount,
    "filesCount": filesCount,
    "questionsCount": questionsCount,
    "sortOrder": sortOrder,
  };
}
