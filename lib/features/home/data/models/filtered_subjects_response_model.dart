// To parse this JSON data, do
//
//     final studentSubjectsModel = studentSubjectsModelFromJson(jsonString);

import 'dart:convert';

StudentSubjectsModel studentSubjectsModelFromJson(String str) =>
    StudentSubjectsModel.fromJson(json.decode(str));

String studentSubjectsModelToJson(StudentSubjectsModel data) =>
    json.encode(data.toJson());

class StudentSubjectsModel {
  final StudentSubjectsModelCollege? college;
  final Scope? scope;
  final Filters? filters;
  final List<Year>? years;
  final List<Subject>? subjects;

  StudentSubjectsModel({
    this.college,
    this.scope,
    this.filters,
    this.years,
    this.subjects,
  });

  StudentSubjectsModel copyWith({
    StudentSubjectsModelCollege? college,
    Scope? scope,
    Filters? filters,
    List<Year>? years,
    List<Subject>? subjects,
  }) => StudentSubjectsModel(
    college: college ?? this.college,
    scope: scope ?? this.scope,
    filters: filters ?? this.filters,
    years: years ?? this.years,
    subjects: subjects ?? this.subjects,
  );

  factory StudentSubjectsModel.fromJson(
    Map<String, dynamic> json,
  ) => StudentSubjectsModel(
    college: json["college"] == null
        ? null
        : StudentSubjectsModelCollege.fromJson(json["college"]),
    scope: json["scope"] == null ? null : Scope.fromJson(json["scope"]),
    filters: json["filters"] == null ? null : Filters.fromJson(json["filters"]),
    years: json["years"] == null
        ? []
        : List<Year>.from(json["years"]!.map((x) => Year.fromJson(x))),
    subjects: json["subjects"] == null
        ? []
        : List<Subject>.from(json["subjects"]!.map((x) => Subject.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "college": college?.toJson(),
    "scope": scope?.toJson(),
    "filters": filters?.toJson(),
    "years": years == null
        ? []
        : List<dynamic>.from(years!.map((x) => x.toJson())),
    "subjects": subjects == null
        ? []
        : List<dynamic>.from(subjects!.map((x) => x.toJson())),
  };
}

class StudentSubjectsModelCollege {
  final String? id;
  final String? name;
  final String? universityId;

  StudentSubjectsModelCollege({this.id, this.name, this.universityId});

  StudentSubjectsModelCollege copyWith({
    String? id,
    String? name,
    String? universityId,
  }) => StudentSubjectsModelCollege(
    id: id ?? this.id,
    name: name ?? this.name,
    universityId: universityId ?? this.universityId,
  );

  factory StudentSubjectsModelCollege.fromJson(Map<String, dynamic> json) =>
      StudentSubjectsModelCollege(
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

class Filters {
  final dynamic collegeYearId;
  final dynamic seasonId;

  Filters({this.collegeYearId, this.seasonId});

  Filters copyWith({dynamic collegeYearId, dynamic seasonId}) => Filters(
    collegeYearId: collegeYearId ?? this.collegeYearId,
    seasonId: seasonId ?? this.seasonId,
  );

  factory Filters.fromJson(Map<String, dynamic> json) =>
      Filters(collegeYearId: json["collegeYearId"], seasonId: json["seasonId"]);

  Map<String, dynamic> toJson() => {
    "collegeYearId": collegeYearId,
    "seasonId": seasonId,
  };
}

class Scope {
  final String? departmentId;
  final String? source;
  final String? studentCollegeYearId;

  Scope({this.departmentId, this.source, this.studentCollegeYearId});

  Scope copyWith({
    String? departmentId,
    String? source,
    String? studentCollegeYearId,
  }) => Scope(
    departmentId: departmentId ?? this.departmentId,
    source: source ?? this.source,
    studentCollegeYearId: studentCollegeYearId ?? this.studentCollegeYearId,
  );

  factory Scope.fromJson(Map<String, dynamic> json) => Scope(
    departmentId: json["departmentId"],
    source: json["source"],
    studentCollegeYearId: json["studentCollegeYearId"],
  );

  Map<String, dynamic> toJson() => {
    "departmentId": departmentId,
    "source": source,
    "studentCollegeYearId": studentCollegeYearId,
  };
}

class Subject {
  final String? id;
  final String? name;
  final bool? isProgram;
  final String? imageUrl;
  final String? teacherId;
  final String? teacherName;
  final SubjectCollege? college;
  final dynamic department;
  final YearClass? year;
  final YearClass? season;

  Subject({
    this.id,
    this.name,
    this.isProgram,
    this.imageUrl,
    this.teacherId,
    this.teacherName,
    this.college,
    this.department,
    this.year,
    this.season,
  });

  Subject copyWith({
    String? id,
    String? name,
    bool? isProgram,
    String? imageUrl,
    String? teacherId,
    String? teacherName,
    SubjectCollege? college,
    dynamic department,
    YearClass? year,
    YearClass? season,
  }) => Subject(
    id: id ?? this.id,
    name: name ?? this.name,
    isProgram: isProgram ?? this.isProgram,
    imageUrl: imageUrl ?? this.imageUrl,
    teacherId: teacherId ?? this.teacherId,
    teacherName: teacherName ?? this.teacherName,
    college: college ?? this.college,
    department: department ?? this.department,
    year: year ?? this.year,
    season: season ?? this.season,
  );

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
    id: json["id"],
    name: json["name"],
    isProgram: json["isProgram"],
    imageUrl: json["imageUrl"],
    teacherId: json["teacherId"],
    teacherName: json["teacherName"],
    college: json["college"] == null
        ? null
        : SubjectCollege.fromJson(json["college"]),
    department: json["department"],
    year: json["year"] == null ? null : YearClass.fromJson(json["year"]),
    season: json["season"] == null ? null : YearClass.fromJson(json["season"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "isProgram": isProgram,
    "imageUrl": imageUrl,
    "teacherId": teacherId,
    "teacherName": teacherName,
    "college": college?.toJson(),
    "department": department,
    "year": year?.toJson(),
    "season": season?.toJson(),
  };
}

class SubjectCollege {
  final String? id;
  final String? name;

  SubjectCollege({this.id, this.name});

  SubjectCollege copyWith({String? id, String? name}) =>
      SubjectCollege(id: id ?? this.id, name: name ?? this.name);

  factory SubjectCollege.fromJson(Map<String, dynamic> json) =>
      SubjectCollege(id: json["id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}

class YearClass {
  final String? id;
  final String? name;
  final int? number;

  YearClass({this.id, this.name, this.number});

  YearClass copyWith({String? id, String? name, int? number}) => YearClass(
    id: id ?? this.id,
    name: name ?? this.name,
    number: number ?? this.number,
  );

  factory YearClass.fromJson(Map<String, dynamic> json) =>
      YearClass(id: json["id"], name: json["name"], number: json["number"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name, "number": number};
}

class Year {
  final YearClass? year;
  final List<SeasonElement>? seasons;

  Year({this.year, this.seasons});

  Year copyWith({YearClass? year, List<SeasonElement>? seasons}) =>
      Year(year: year ?? this.year, seasons: seasons ?? this.seasons);

  factory Year.fromJson(Map<String, dynamic> json) => Year(
    year: json["year"] == null ? null : YearClass.fromJson(json["year"]),
    seasons: json["seasons"] == null
        ? []
        : List<SeasonElement>.from(
            json["seasons"]!.map((x) => SeasonElement.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "year": year?.toJson(),
    "seasons": seasons == null
        ? []
        : List<dynamic>.from(seasons!.map((x) => x.toJson())),
  };
}

class SeasonElement {
  final YearClass? season;
  final List<Subject>? subjects;

  SeasonElement({this.season, this.subjects});

  SeasonElement copyWith({YearClass? season, List<Subject>? subjects}) =>
      SeasonElement(
        season: season ?? this.season,
        subjects: subjects ?? this.subjects,
      );

  factory SeasonElement.fromJson(Map<String, dynamic> json) => SeasonElement(
    season: json["season"] == null ? null : YearClass.fromJson(json["season"]),
    subjects: json["subjects"] == null
        ? []
        : List<Subject>.from(json["subjects"]!.map((x) => Subject.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "season": season?.toJson(),
    "subjects": subjects == null
        ? []
        : List<dynamic>.from(subjects!.map((x) => x.toJson())),
  };
}
