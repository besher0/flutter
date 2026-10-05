// To parse this JSON data, do
//
//     final getAllowedSubjectsResponseModel = getAllowedSubjectsResponseModelFromJson(jsonString);

import 'dart:convert';

GetAllowedSubjectsResponseModel getAllowedSubjectsResponseModelFromJson(
  String str,
) => GetAllowedSubjectsResponseModel.fromJson(json.decode(str));

String getAllowedSubjectsResponseModelToJson(
  GetAllowedSubjectsResponseModel data,
) => json.encode(data.toJson());

class GetAllowedSubjectsResponseModel {
  final List<Subject>? subjects;

  GetAllowedSubjectsResponseModel({this.subjects});

  GetAllowedSubjectsResponseModel copyWith({List<Subject>? subjects}) =>
      GetAllowedSubjectsResponseModel(subjects: subjects ?? this.subjects);

  factory GetAllowedSubjectsResponseModel.fromJson(Map<String, dynamic> json) =>
      GetAllowedSubjectsResponseModel(
        subjects: json["subjects"] == null
            ? []
            : List<Subject>.from(
                json["subjects"]!.map((x) => Subject.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "subjects": subjects == null
        ? []
        : List<dynamic>.from(subjects!.map((x) => x.toJson())),
  };
}

class Subject {
  final String? id;
  final String? subjectName;
  final bool? isProgram;
  final String? imageUrl;
  final String? collegeId;
  final String? collegeYearId;
  final String? seasonId;
  final dynamic departmentId;
  final AcademicYear? season;
  final AcademicYear? academicYear;

  Subject({
    this.id,
    this.subjectName,
    this.isProgram,
    this.imageUrl,
    this.collegeId,
    this.collegeYearId,
    this.seasonId,
    this.departmentId,
    this.season,
    this.academicYear,
  });

  Subject copyWith({
    String? id,
    String? subjectName,
    bool? isProgram,
    String? imageUrl,
    String? collegeId,
    String? collegeYearId,
    String? seasonId,
    dynamic departmentId,
    AcademicYear? season,
    AcademicYear? academicYear,
  }) => Subject(
    id: id ?? this.id,
    subjectName: subjectName ?? this.subjectName,
    isProgram: isProgram ?? this.isProgram,
    imageUrl: imageUrl ?? this.imageUrl,
    collegeId: collegeId ?? this.collegeId,
    collegeYearId: collegeYearId ?? this.collegeYearId,
    seasonId: seasonId ?? this.seasonId,
    departmentId: departmentId ?? this.departmentId,
    season: season ?? this.season,
    academicYear: academicYear ?? this.academicYear,
  );

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
    id: json["id"],
    subjectName: json["subjectName"],
    isProgram: json["isProgram"],
    imageUrl: json["imageUrl"],
    collegeId: json["collegeId"],
    collegeYearId: json["collegeYearId"],
    seasonId: json["seasonId"],
    departmentId: json["departmentId"],
    season: json["season"] == null
        ? null
        : AcademicYear.fromJson(json["season"]),
    academicYear: json["academicYear"] == null
        ? null
        : AcademicYear.fromJson(json["academicYear"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "subjectName": subjectName,
    "isProgram": isProgram,
    "imageUrl": imageUrl,
    "collegeId": collegeId,
    "collegeYearId": collegeYearId,
    "seasonId": seasonId,
    "departmentId": departmentId,
    "season": season?.toJson(),
    "academicYear": academicYear?.toJson(),
  };
}

class AcademicYear {
  final String? id;
  final String? name;
  final int? number;

  AcademicYear({this.id, this.name, this.number});

  AcademicYear copyWith({String? id, String? name, int? number}) =>
      AcademicYear(
        id: id ?? this.id,
        name: name ?? this.name,
        number: number ?? this.number,
      );

  factory AcademicYear.fromJson(Map<String, dynamic> json) =>
      AcademicYear(id: json["id"], name: json["name"], number: json["number"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name, "number": number};
}
