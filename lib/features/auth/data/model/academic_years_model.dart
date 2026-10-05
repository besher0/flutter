// To parse this JSON data, do
//
//     final academicYearsResponseModel = academicYearsResponseModelFromJson(jsonString);

import 'dart:convert';

List<AcademicYearsResponseModel> academicYearsResponseModelFromJson(
  List<dynamic> data,
) => List<AcademicYearsResponseModel>.from(
  data.map((x) => AcademicYearsResponseModel.fromJson(x)),
);

String academicYearsResponseModelToJson(
  List<AcademicYearsResponseModel> data,
) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AcademicYearsResponseModel {
  final String? id;
  final String? collegeId;
  final String? academicYearId;
  final bool? isActive;
  final AcademicYear? academicYear;

  AcademicYearsResponseModel({
    this.id,
    this.collegeId,
    this.academicYearId,
    this.isActive,
    this.academicYear,
  });

  AcademicYearsResponseModel copyWith({
    String? id,
    String? collegeId,
    String? academicYearId,
    bool? isActive,
    AcademicYear? academicYear,
  }) => AcademicYearsResponseModel(
    id: id ?? this.id,
    collegeId: collegeId ?? this.collegeId,
    academicYearId: academicYearId ?? this.academicYearId,
    isActive: isActive ?? this.isActive,
    academicYear: academicYear ?? this.academicYear,
  );

  factory AcademicYearsResponseModel.fromJson(Map<String, dynamic> json) =>
      AcademicYearsResponseModel(
        id: json["id"],
        collegeId: json["collegeId"],
        academicYearId: json["academicYearId"],
        isActive: json["isActive"],
        academicYear: json["academicYear"] == null
            ? null
            : AcademicYear.fromJson(json["academicYear"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "collegeId": collegeId,
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
