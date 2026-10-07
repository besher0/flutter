// To parse this JSON data, do
//
//     final lectureDetailsModel = lectureDetailsModelFromJson(jsonString);

import 'dart:convert';

import 'package:coursaty_student_and_teacher/features/teachers/data/model/teacher_model.dart';

LectureDetailsModel lectureDetailsModelFromJson(String str) =>
    LectureDetailsModel.fromJson(json.decode(str));

String lectureDetailsModelToJson(LectureDetailsModel data) =>
    json.encode(data.toJson());

class LectureDetailsModel {
  final Lecture? lecture;
  final List<FileElement>? files;
  final List<Video>? videos;
  final List<QuestionModel>? questions;
  final Teacher? teacher;
  final String? courseImageUrl;

  LectureDetailsModel({
    this.lecture,
    this.files,
    this.videos,
    this.questions,
    this.teacher,
    this.courseImageUrl,
  });

  LectureDetailsModel copyWith({
    Lecture? lecture,
    List<FileElement>? files,
    List<Video>? videos,
    List<QuestionModel>? questions,
    Teacher? teacher,
    String? courseImageUrl,
  }) => LectureDetailsModel(
    lecture: lecture ?? this.lecture,
    files: files ?? this.files,
    videos: videos ?? this.videos,
    questions: questions ?? this.questions,
    teacher: teacher ?? this.teacher,
    courseImageUrl: courseImageUrl ?? this.courseImageUrl,
  );

  factory LectureDetailsModel.fromJson(
    Map<String, dynamic> json,
  ) => LectureDetailsModel(
    lecture: json["lecture"] == null ? null : Lecture.fromJson(json["lecture"]),
    teacher: json["teacher"] == null ? null : Teacher.fromJson(json["teacher"]),
    files: json["files"] == null
        ? []
        : List<FileElement>.from(
            json["files"]!.map((x) => FileElement.fromJson(x)),
          ),
    videos: json["videos"] == null
        ? []
        : List<Video>.from(json["videos"]!.map((x) => Video.fromJson(x))),
    questions: json["questions"] == null
        ? []
        : List<QuestionModel>.from(
            json["questions"]!.map((x) => QuestionModel.fromJson(x)),
          ),
    courseImageUrl: json["course"]["imageurl"],
  );

  Map<String, dynamic> toJson() => {
    "lecture": lecture?.toJson(),
    "teacher": teacher?.toJson(),
    "course": {"imageurl": courseImageUrl},
    "files": files == null
        ? []
        : List<dynamic>.from(files!.map((x) => x.toJson())),
    "videos": videos == null
        ? []
        : List<dynamic>.from(videos!.map((x) => x.toJson())),
    "questions": questions == null
        ? []
        : List<dynamic>.from(questions!.map((x) => x.toJson())),
  };
}

class FileElement {
  final String? id;
  final String? lectureId;
  final String? fileName;
  final String? fileUrl;
  final String? fileType;
  final bool? isFree;
  final bool? locked;
  final int? sortOrder;
  final String? size;

  FileElement({
    this.id,
    this.lectureId,
    this.fileName,
    this.fileUrl,
    this.fileType,
    this.isFree,
    this.locked,
    this.sortOrder,
    this.size,
  });

  FileElement copyWith({
    String? id,
    String? lectureId,
    String? fileName,
    String? fileUrl,
    String? fileType,
    bool? isFree,
    bool? locked,
    String? size,
    int? sortOrder,
  }) => FileElement(
    id: id ?? this.id,
    lectureId: lectureId ?? this.lectureId,
    fileName: fileName ?? this.fileName,
    fileUrl: fileUrl ?? this.fileUrl,
    fileType: fileType ?? this.fileType,
    isFree: isFree ?? this.isFree,
    locked: locked ?? this.locked,
    size: size ?? this.size,
    sortOrder: sortOrder ?? this.sortOrder,
  );

  factory FileElement.fromJson(Map<String, dynamic> json) => FileElement(
    id: json["id"],
    lectureId: json["lectureId"],
    fileName: json["fileName"],
    fileUrl: json["fileUrl"],
    fileType: json["fileType"],
    isFree: json["isFree"],
    locked: json["locked"],
    size: json["size"],
    sortOrder: json["sortOrder"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "lectureId": lectureId,
    "fileName": fileName,
    "fileUrl": fileUrl,
    "fileType": fileType,
    "isFree": isFree,
    "size": size,
    "locked": locked,
    "sortOrder": sortOrder,
  };
}

class Lecture {
  final String? id;
  final String? title;
  final String? description;
  final String? imageUrl;

  Lecture({this.id, this.title, this.description, this.imageUrl});

  Lecture copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
  }) => Lecture(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    imageUrl: imageUrl ?? this.imageUrl,
  );

  factory Lecture.fromJson(Map<String, dynamic> json) => Lecture(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    imageUrl: json["imageUrl"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "imageUrl": imageUrl,
  };
}

class Video {
  final String? id;
  final String? lectureId;
  final String? videoName;
  final String? videoUrl;
  final String? videoSize;
  final String? description;
  final int? durationSeconds;
  final int? viewsCount;
  final bool? isFree;
  final bool? offlineDownloadEnabled;
  final int? contentVersion;
  final List<Segment>? segments;
  final bool? locked;
  final int? sortOrder;

  Video({
    this.id,
    this.lectureId,
    this.videoName,
    this.videoUrl,
    this.description,
    this.durationSeconds,
    this.viewsCount,
    this.isFree,
    this.offlineDownloadEnabled,
    this.contentVersion,
    this.segments,
    this.locked,
    this.videoSize,
    this.sortOrder,
  });

  Video copyWith({
    String? id,
    String? lectureId,
    String? videoName,
    String? videoUrl,
    String? description,
    String? videoSize,
    int? durationSeconds,
    int? viewsCount,
    bool? isFree,
    bool? offlineDownloadEnabled,
    int? contentVersion,
    int? sortOrder,
    List<Segment>? segments,
    bool? locked,
  }) => Video(
    id: id ?? this.id,
    lectureId: lectureId ?? this.lectureId,
    videoName: videoName ?? this.videoName,
    videoUrl: videoUrl ?? this.videoUrl,
    videoSize: videoSize ?? this.videoSize,
    description: description ?? this.description,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    viewsCount: viewsCount ?? this.viewsCount,
    isFree: isFree ?? this.isFree,
    offlineDownloadEnabled:
        offlineDownloadEnabled ?? this.offlineDownloadEnabled,
    contentVersion: contentVersion ?? this.contentVersion,
    segments: segments ?? this.segments,
    locked: locked ?? this.locked,
    sortOrder: sortOrder ?? this.sortOrder,
  );

  factory Video.fromJson(Map<String, dynamic> json) => Video(
    id: json["id"],
    lectureId: json["lectureId"],
    videoName: json["videoName"],
    videoUrl: json["videoUrl"],
    videoSize: json["size"],
    description: json["description"],
    durationSeconds: int.tryParse(json["durationSeconds"].toString()),
    viewsCount: json["viewsCount"],
    isFree: json["isFree"],
    offlineDownloadEnabled: json["offlineDownloadEnabled"],
    contentVersion: (json["contentVersion"] as num?)?.toInt(),
    segments: json["segments"] == null
        ? []
        : List<Segment>.from(json["segments"]!.map((x) => Segment.fromJson(x))),
    locked: json["locked"],
    sortOrder: json["sortOrder"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "lectureId": lectureId,
    "videoName": videoName,
    "videoUrl": videoUrl,
    "description": description,
    "size": videoSize,
    "durationSeconds": durationSeconds,
    "viewsCount": viewsCount,
    "isFree": isFree,
    "offlineDownloadEnabled": offlineDownloadEnabled,
    "contentVersion": contentVersion,
    "sortOrder": sortOrder,
    "segments": segments == null
        ? []
        : List<dynamic>.from(segments!.map((x) => x.toJson())),
    "locked": locked,
  };
}

List<Segment> segmentsModelFromJson(List<dynamic> data) =>
    List<Segment>.from(data.map((x) => Segment.fromJson(x)));

class Segment {
  final String? id;
  final String? videoId;
  final String? segmentName;
  final int? startSeconds;
  final int? endSeconds;
  final int? sortOrder;
  final DateTime? createdAt;

  Segment({
    this.id,
    this.videoId,
    this.segmentName,
    this.startSeconds,
    this.endSeconds,
    this.sortOrder,
    this.createdAt,
  });

  Segment copyWith({
    String? id,
    String? videoId,
    String? segmentName,
    int? startSeconds,
    int? endSeconds,
    int? sortOrder,
    DateTime? createdAt,
  }) => Segment(
    id: id ?? this.id,
    videoId: videoId ?? this.videoId,
    segmentName: segmentName ?? this.segmentName,
    startSeconds: startSeconds ?? this.startSeconds,
    endSeconds: endSeconds ?? this.endSeconds,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );

  factory Segment.fromJson(Map<String, dynamic> json) => Segment(
    id: json["id"],
    videoId: json["videoId"],
    segmentName: json["segmentName"],
    startSeconds: json["startSeconds"],
    endSeconds: json["endSeconds"],
    sortOrder: json["sortOrder"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "videoId": videoId,
    "segmentName": segmentName,
    "startSeconds": startSeconds,
    "endSeconds": endSeconds,
    "sortOrder": sortOrder,
    "createdAt": createdAt?.toIso8601String(),
  };
}

class QuestionModel {
  final String? id;
  final String? lectureId;
  final String? questionText;
  final String? imageUrl;
  final String? explanation;
  final String? questionType;
  final int? points;
  final int? sortOrder;
  final List<Option>? options;

  QuestionModel({
    this.id,
    this.lectureId,
    this.questionText,
    this.imageUrl,
    this.explanation,
    this.questionType,
    this.points,
    this.sortOrder,
    this.options,
  });

  QuestionModel copyWith({
    String? id,
    String? lectureId,
    String? questionText,
    String? imageUrl,
    String? explanation,
    String? questionType,
    int? points,
    int? sortOrder,
    List<Option>? options,
  }) => QuestionModel(
    id: id ?? this.id,
    lectureId: lectureId ?? this.lectureId,
    questionText: questionText ?? this.questionText,
    imageUrl: imageUrl ?? this.imageUrl,
    explanation: explanation ?? this.explanation,
    questionType: questionType ?? this.questionType,
    points: points ?? this.points,
    sortOrder: sortOrder ?? this.sortOrder,
    options: options ?? this.options,
  );

  factory QuestionModel.fromJson(Map<String, dynamic> json) => QuestionModel(
    id: json["id"],
    lectureId: json["lectureId"],
    questionText: json["questionText"],
    imageUrl: json["imageUrl"],
    explanation: json["explanation"],
    questionType: json["questionType"],
    points: json["points"],
    sortOrder: json["sortOrder"],
    options: json["options"] == null
        ? []
        : List<Option>.from(json["options"]!.map((x) => Option.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "lectureId": lectureId,
    "questionText": questionText,
    "imageUrl": imageUrl,
    "explanation": explanation,
    "questionType": questionType,
    "points": points,
    "sortOrder": sortOrder,
    "options": options == null
        ? []
        : List<dynamic>.from(options!.map((x) => x.toJson())),
  };
}

class Option {
  final String? id;
  final String? questionId;
  final String? optionText;
  final bool? isCorrect;
  final int? sortOrder;

  Option({
    this.id,
    this.questionId,
    this.optionText,
    this.isCorrect,
    this.sortOrder,
  });

  Option copyWith({
    String? id,
    String? questionId,
    String? optionText,
    bool? isCorrect,
    int? sortOrder,
  }) => Option(
    id: id ?? this.id,
    questionId: questionId ?? this.questionId,
    optionText: optionText ?? this.optionText,
    isCorrect: isCorrect ?? this.isCorrect,
    sortOrder: sortOrder ?? this.sortOrder,
  );

  factory Option.fromJson(Map<String, dynamic> json) => Option(
    id: json["id"],
    questionId: json["questionId"],
    optionText: json["optionText"],
    isCorrect: json["isCorrect"],
    sortOrder: json["sortOrder"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "questionId": questionId,
    "optionText": optionText,
    "isCorrect": isCorrect,
    "sortOrder": sortOrder,
  };
}
