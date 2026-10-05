// To parse this JSON data, do
//
//     final homeResponseModel = homeResponseModelFromJson(jsonString);

import 'dart:convert';

HomeResponseModel homeResponseModelFromJson(String str) =>
    HomeResponseModel.fromJson(json.decode(str));

String homeResponseModelToJson(HomeResponseModel data) =>
    json.encode(data.toJson());

class HomeResponseModel {
  final HomeResponseModelCollege? college;
  final List<Advertisement>? advertisements;
  final List<HomeTeacher>? teachers;
  final List<Program>? subjects;
  final List<Program>? programs;

  HomeResponseModel({
    this.college,
    this.advertisements,
    this.teachers,
    this.subjects,
    this.programs,
  });

  HomeResponseModel copyWith({
    HomeResponseModelCollege? college,
    List<Advertisement>? advertisements,
    List<HomeTeacher>? teachers,
    List<Program>? subjects,
    List<Program>? programs,
  }) => HomeResponseModel(
    college: college ?? this.college,
    advertisements: advertisements ?? this.advertisements,
    teachers: teachers ?? this.teachers,
    subjects: subjects ?? this.subjects,
    programs: programs ?? this.programs,
  );

  factory HomeResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => HomeResponseModel(
    college: json["college"] == null
        ? null
        : HomeResponseModelCollege.fromJson(json["college"]),
    advertisements: json["advertisements"] == null
        ? []
        : List<Advertisement>.from(
            json["advertisements"]!.map((x) => Advertisement.fromJson(x)),
          ),
    teachers: json["teachers"] == null
        ? []
        : List<HomeTeacher>.from(
            json["teachers"]!.map((x) => HomeTeacher.fromJson(x)),
          ),
    subjects: json["subjects"] == null
        ? []
        : List<Program>.from(json["subjects"]!.map((x) => Program.fromJson(x))),
    programs: json["programs"] == null
        ? []
        : List<Program>.from(json["programs"]!.map((x) => Program.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "college": college?.toJson(),
    "advertisements": advertisements == null
        ? []
        : List<dynamic>.from(advertisements!.map((x) => x.toJson())),
    "teachers": teachers == null
        ? []
        : List<dynamic>.from(teachers!.map((x) => x.toJson())),
    "subjects": subjects == null
        ? []
        : List<dynamic>.from(subjects!.map((x) => x.toJson())),
    "programs": programs == null
        ? []
        : List<dynamic>.from(programs!.map((x) => x.toJson())),
  };
}

class Advertisement {
  final String? id;
  final String? collegeId;
  final String? title;
  final String? fullScreenImageUrl;
  final String? imageUrl;
  final String? videoUrl;
  final String? helperLink;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final College? college;

  Advertisement({
    this.id,
    this.collegeId,
    this.title,
    this.fullScreenImageUrl,
    this.imageUrl,
    this.videoUrl,
    this.helperLink,
    this.createdAt,
    this.updatedAt,
    this.college,
  });

  Advertisement copyWith({
    String? id,
    String? collegeId,
    String? title,
    String? fullScreenImageUrl,
    String? imageUrl,
    String? videoUrl,
    String? helperLink,
    DateTime? createdAt,
    DateTime? updatedAt,
    College? college,
  }) => Advertisement(
    id: id ?? this.id,
    collegeId: collegeId ?? this.collegeId,
    title: title ?? this.title,
    imageUrl: imageUrl ?? this.imageUrl,
    videoUrl: videoUrl ?? this.videoUrl,
    helperLink: helperLink ?? this.helperLink,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    fullScreenImageUrl: fullScreenImageUrl ?? this.fullScreenImageUrl,
    college: college ?? this.college,
  );

  factory Advertisement.fromJson(Map<String, dynamic> json) => Advertisement(
    id: json["id"],
    collegeId: json["collegeId"],
    title: json["title"],
    imageUrl: json["imageUrl"],
    fullScreenImageUrl: json["fullScreen_imageUrl"],
    videoUrl: json["videoUrl"],
    helperLink: json["helperLink"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
    college: json["college"] == null ? null : College.fromJson(json["college"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "collegeId": collegeId,
    "title": title,
    "imageUrl": imageUrl,
    "fullScreen_imageUrl": fullScreenImageUrl,
    "videoUrl": videoUrl,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "college": college?.toJson(),
  };
}

class College {
  final String? id;
  final String? universityId;
  final String? name;

  College({this.id, this.universityId, this.name});

  College copyWith({String? id, String? universityId, String? name}) => College(
    id: id ?? this.id,
    universityId: universityId ?? this.universityId,
    name: name ?? this.name,
  );

  factory College.fromJson(Map<String, dynamic> json) => College(
    id: json["id"],
    universityId: json["universityId"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "universityId": universityId,
    "name": name,
  };
}

class HomeResponseModelCollege {
  final String? id;
  final String? name;
  final String? universityId;

  HomeResponseModelCollege({this.id, this.name, this.universityId});

  HomeResponseModelCollege copyWith({
    String? id,
    String? name,
    String? universityId,
  }) => HomeResponseModelCollege(
    id: id ?? this.id,
    name: name ?? this.name,
    universityId: universityId ?? this.universityId,
  );

  factory HomeResponseModelCollege.fromJson(Map<String, dynamic> json) =>
      HomeResponseModelCollege(
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

class Program {
  final String? id;
  final String? name;
  final bool? isProgram;
  final ProgramCollege? college;
  final dynamic department;
  final Season? year;
  final Season? season;
  final String? image;
  final String? teacherName;

  Program({
    this.id,
    this.name,
    this.isProgram,
    this.college,
    this.department,
    this.year,
    this.season,
    this.image,
    this.teacherName,
  });

  Program copyWith({
    String? id,
    String? name,
    String? image,
    String? teacherName,
    bool? isProgram,
    ProgramCollege? college,
    dynamic department,
    Season? year,
    Season? season,
  }) => Program(
    id: id ?? this.id,
    name: name ?? this.name,
    isProgram: isProgram ?? this.isProgram,
    college: college ?? this.college,
    department: department ?? this.department,
    year: year ?? this.year,
    season: season ?? this.season,
    image: image ?? this.image,
    teacherName: teacherName ?? this.teacherName,
  );

  factory Program.fromJson(Map<String, dynamic> json) => Program(
    id: json["id"],
    name: json["name"],
    image: json["imageUrl"],
    isProgram: json["isProgram"],
    college: json["college"] == null
        ? null
        : ProgramCollege.fromJson(json["college"]),
    department: json["department"],
    teacherName: json["teacherName"],
    year: json["year"] == null ? null : Season.fromJson(json["year"]),
    season: json["season"] == null ? null : Season.fromJson(json["season"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "imageUrl": image,
    "isProgram": isProgram,
    "college": college?.toJson(),
    "department": department,
    "teacherName": teacherName,
    "year": year?.toJson(),
    "season": season?.toJson(),
  };
}

class ProgramCollege {
  final String? id;
  final String? name;

  ProgramCollege({this.id, this.name});

  ProgramCollege copyWith({String? id, String? name}) =>
      ProgramCollege(id: id ?? this.id, name: name ?? this.name);

  factory ProgramCollege.fromJson(Map<String, dynamic> json) =>
      ProgramCollege(id: json["id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name};
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

class HomeTeacher {
  final String? id;
  final String? name;
  final String? description;
  final String? image;
  final int? likesCount;
  final DateTime? createdAt;
  final Count? count;

  HomeTeacher({
    this.id,
    this.name,
    this.description,
    this.image,
    this.likesCount,
    this.createdAt,
    this.count,
  });

  HomeTeacher copyWith({
    String? id,
    String? name,
    String? description,
    String? image,
    int? likesCount,
    DateTime? createdAt,
    Count? count,
  }) => HomeTeacher(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    image: image ?? this.image,
    likesCount: likesCount ?? this.likesCount,
    createdAt: createdAt ?? this.createdAt,
    count: count ?? this.count,
  );

  factory HomeTeacher.fromJson(Map<String, dynamic> json) => HomeTeacher(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    image: json["image"],
    likesCount: json["likesCount"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    count: json["_count"] == null ? null : Count.fromJson(json["_count"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "image": image,
    "likesCount": likesCount,
    "createdAt": createdAt?.toIso8601String(),
    "_count": count?.toJson(),
  };
}

class Count {
  final int? courses;
  final int? teacherLikes;

  Count({this.courses, this.teacherLikes});

  Count copyWith({int? courses, int? teacherLikes}) => Count(
    courses: courses ?? this.courses,
    teacherLikes: teacherLikes ?? this.teacherLikes,
  );

  factory Count.fromJson(Map<String, dynamic> json) =>
      Count(courses: json["courses"], teacherLikes: json["teacherLikes"]);

  Map<String, dynamic> toJson() => {
    "courses": courses,
    "teacherLikes": teacherLikes,
  };
}
