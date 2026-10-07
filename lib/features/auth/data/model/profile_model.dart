// To parse this JSON data, do
//
//     final profileModel = profileModelFromJson(jsonString);

import 'dart:convert';

import 'auth_model.dart';

ProfileModel profileModelFromJson(String str) =>
    ProfileModel.fromJson(json.decode(str));

String profileModelToJson(ProfileModel data) => json.encode(data.toJson());

class ProfileModel {
  final User? user;
  final Student? student;
  final Teacher? teacher;

  ProfileModel({this.user, this.student, this.teacher});

  ProfileModel copyWith({User? user, Student? student, Teacher? teacher}) =>
      ProfileModel(
        user: user ?? this.user,
        student: student ?? this.student,
        teacher: teacher ?? this.teacher,
      );

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    student: json["student"] == null ? null : Student.fromJson(json["student"]),
    teacher: json["teacher"] == null ? null : Teacher.fromJson(json["teacher"]),
  );

  Map<String, dynamic> toJson() => {
    "user": user?.toJson(),
    "student": student?.toJson(),
    "teacher": teacher?.toJson(),
  };
}

class Teacher {
  final String? id;
  final String? name;
  final String? description;
  final String? image;
  final String? instagramUrl;
  final int? likesCount;
  final DateTime? createdAt;
  final Count? count;

  Teacher({
    this.id,
    this.name,
    this.description,
    this.image,
    this.likesCount,
    this.createdAt,
    this.count,
    this.instagramUrl,
  });

  Teacher copyWith({
    String? id,
    String? name,
    String? description,
    String? instagramUrl,
    String? image,
    int? likesCount,
    DateTime? createdAt,
    Count? count,
  }) => Teacher(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    image: image ?? this.image,
    likesCount: likesCount ?? this.likesCount,
    createdAt: createdAt ?? this.createdAt,
    count: count ?? this.count,
    instagramUrl: instagramUrl ?? this.instagramUrl,
  );

  factory Teacher.fromJson(Map<String, dynamic> json) => Teacher(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    image: json["image"],
    instagramUrl: json["instagramUrl"],
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
    "instagramUrl": instagramUrl,
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

class Student {
  final String? id;
  final String? name;
  final String? universityNumber;
  final String? universityId;
  final String? provinceId;
  final String? collegeId;
  final String? departmentId;
  final String? collegeYearId;
  final DateTime? createdAt;
  final CollegeYear? collegeYear;
  final String? department;
  final College? college;
  final Province? university;
  final Province? province;
  final bool? isActive;

  Student({
    this.id,
    this.name,
    this.universityNumber,
    this.universityId,
    this.provinceId,
    this.collegeId,
    this.departmentId,
    this.collegeYearId,
    this.createdAt,
    this.collegeYear,
    this.department,
    this.college,
    this.university,
    this.province,
    this.isActive,
  });

  Student copyWith({
    String? id,
    String? name,
    String? universityNumber,
    String? universityId,
    String? provinceId,
    String? collegeId,
    String? departmentId,
    String? collegeYearId,
    DateTime? createdAt,
    CollegeYear? collegeYear,
    String? department,
    College? college,
    Province? university,
    Province? province,
    bool? isActive,
  }) => Student(
    id: id ?? this.id,
    name: name ?? this.name,
    universityNumber: universityNumber ?? this.universityNumber,
    universityId: universityId ?? this.universityId,
    provinceId: provinceId ?? this.provinceId,
    collegeId: collegeId ?? this.collegeId,
    departmentId: departmentId ?? this.departmentId,
    collegeYearId: collegeYearId ?? this.collegeYearId,
    createdAt: createdAt ?? this.createdAt,
    collegeYear: collegeYear ?? this.collegeYear,
    department: department ?? this.department,
    college: college ?? this.college,
    university: university ?? this.university,
    province: province ?? this.province,
    isActive: isActive ?? this.isActive,
  );

  factory Student.fromJson(Map<String, dynamic> json) => Student(
    id: json["id"],
    name: json["name"],
    universityNumber: json["universityNumber"],
    universityId: json["universityId"],
    provinceId: json["provinceId"],
    collegeId: json["collegeId"],
    departmentId: json["departmentId"],
    collegeYearId: json["collegeYearId"],
    isActive: json["isActive"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    collegeYear: json["collegeYear"] == null
        ? null
        : CollegeYear.fromJson(json["collegeYear"]),
    department: json["department"] == null ? null : json["department"]["name"],
    college: json["college"] == null ? null : College.fromJson(json["college"]),
    university: json["university"] == null
        ? null
        : Province.fromJson(json["university"]),
    province: json["province"] == null
        ? null
        : Province.fromJson(json["province"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "universityNumber": universityNumber,
    "universityId": universityId,
    "provinceId": provinceId,
    "collegeId": collegeId,
    "departmentId": departmentId,
    "collegeYearId": collegeYearId,
    "isActive": isActive,
    "createdAt": createdAt?.toIso8601String(),
    "collegeYear": collegeYear?.toJson(),
    "department": department,
    "college": college?.toJson(),
    "university": university?.toJson(),
    "province": province?.toJson(),
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

class CollegeYear {
  final String? id;
  final String? collegeId;
  final dynamic departmentId;
  final String? academicYearId;
  final bool? isActive;
  final AcademicYear? academicYear;

  CollegeYear({
    this.id,
    this.collegeId,
    this.departmentId,
    this.academicYearId,
    this.isActive,
    this.academicYear,
  });

  CollegeYear copyWith({
    String? id,
    String? collegeId,
    dynamic departmentId,
    String? academicYearId,
    bool? isActive,
    AcademicYear? academicYear,
  }) => CollegeYear(
    id: id ?? this.id,
    collegeId: collegeId ?? this.collegeId,
    departmentId: departmentId ?? this.departmentId,
    academicYearId: academicYearId ?? this.academicYearId,
    isActive: isActive ?? this.isActive,
    academicYear: academicYear ?? this.academicYear,
  );

  factory CollegeYear.fromJson(Map<String, dynamic> json) => CollegeYear(
    id: json["id"],
    collegeId: json["collegeId"],
    departmentId: json["departmentId"],
    academicYearId: json["academicYearId"],
    isActive: json["isActive"],
    academicYear: json["academicYear"] == null
        ? null
        : AcademicYear.fromJson(json["academicYear"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "collegeId": collegeId,
    "departmentId": departmentId,
    "academicYearId": academicYearId,
    "isActive": isActive,
    "academicYear": academicYear?.toJson(),
  };
}

class AcademicYear {
  final String? id;
  final int? yearNumber;
  final String? yearName;

  AcademicYear({this.id, this.yearNumber, this.yearName});

  AcademicYear copyWith({String? id, int? yearNumber, String? yearName}) =>
      AcademicYear(
        id: id ?? this.id,
        yearNumber: yearNumber ?? this.yearNumber,
        yearName: yearName ?? this.yearName,
      );

  factory AcademicYear.fromJson(Map<String, dynamic> json) => AcademicYear(
    id: json["id"],
    yearNumber: json["yearNumber"],
    yearName: json["yearName"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "yearNumber": yearNumber,
    "yearName": yearName,
  };
}

class Province {
  final String? id;
  final String? name;
  final DateTime? createdAt;
  final String? provinceId;

  Province({this.id, this.name, this.createdAt, this.provinceId});

  Province copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    String? provinceId,
  }) => Province(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    provinceId: provinceId ?? this.provinceId,
  );

  factory Province.fromJson(Map<String, dynamic> json) => Province(
    id: json["id"],
    name: json["name"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    provinceId: json["provinceId"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "createdAt": createdAt?.toIso8601String(),
    "provinceId": provinceId,
  };
}
