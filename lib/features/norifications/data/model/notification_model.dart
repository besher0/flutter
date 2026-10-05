// To parse this JSON data, do
//
//     final notificationsModel = notificationsModelFromJson(jsonString);

import 'dart:convert';

List<Notification> notificationsModelFromJson(List<dynamic> data) =>
    List<Notification>.from(data.map((x) => Notification.fromJson(x)));

String notificationsModelToJson(List<Notification> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Notification {
  final String? id;
  final String? title;
  final String? description;
  final String? status;
  final String? createdById;
  final String? collegeId;
  final dynamic departmentId;
  final String? approvedById;
  final DateTime? approvedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final CreatedBy? createdBy;
  final College? college;
  final dynamic department;
  final String? link;

  Notification({
    this.id,
    this.title,
    this.description,
    this.link,
    this.status,
    this.createdById,
    this.collegeId,
    this.departmentId,
    this.approvedById,
    this.approvedAt,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.college,
    this.department,
  });

  Notification copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    String? createdById,
    String? collegeId,
    dynamic departmentId,
    String? approvedById,
    String? link,
    DateTime? approvedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    CreatedBy? createdBy,
    College? college,
    dynamic department,
  }) => Notification(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    status: status ?? this.status,
    createdById: createdById ?? this.createdById,
    collegeId: collegeId ?? this.collegeId,
    departmentId: departmentId ?? this.departmentId,
    approvedById: approvedById ?? this.approvedById,
    approvedAt: approvedAt ?? this.approvedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    createdBy: createdBy ?? this.createdBy,
    college: college ?? this.college,
    department: department ?? this.department,
    link: link ?? this.link,
  );

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    status: json["status"],
    createdById: json["createdById"],
    collegeId: json["collegeId"],
    departmentId: json["departmentId"],
    approvedById: json["approvedById"],
    link: json["link"],
    approvedAt: json["approvedAt"] == null
        ? null
        : DateTime.parse(json["approvedAt"]),
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
    createdBy: json["createdBy"] == null
        ? null
        : CreatedBy.fromJson(json["createdBy"]),
    college: json["college"] == null ? null : College.fromJson(json["college"]),
    department: json["department"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "status": status,
    "createdById": createdById,
    "collegeId": collegeId,
    "departmentId": departmentId,
    "link": link,
    "approvedById": approvedById,
    "approvedAt": approvedAt?.toIso8601String(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "createdBy": createdBy?.toJson(),
    "college": college?.toJson(),
    "department": department,
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

class CreatedBy {
  final String? id;
  final String? phone;
  final String? password;
  final String? userableId;
  final String? userableType;
  final String? gender;
  final String? fcmToken;
  final String? status;
  final DateTime? createdAt;

  CreatedBy({
    this.id,
    this.phone,
    this.password,
    this.userableId,
    this.userableType,
    this.gender,
    this.fcmToken,
    this.status,
    this.createdAt,
  });

  CreatedBy copyWith({
    String? id,
    String? phone,
    String? password,
    String? userableId,
    String? userableType,
    String? gender,
    String? fcmToken,
    String? status,
    DateTime? createdAt,
  }) => CreatedBy(
    id: id ?? this.id,
    phone: phone ?? this.phone,
    password: password ?? this.password,
    userableId: userableId ?? this.userableId,
    userableType: userableType ?? this.userableType,
    gender: gender ?? this.gender,
    fcmToken: fcmToken ?? this.fcmToken,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );

  factory CreatedBy.fromJson(Map<String, dynamic> json) => CreatedBy(
    id: json["id"],
    phone: json["phone"],
    password: json["password"],
    userableId: json["userableId"],
    userableType: json["userableType"],
    gender: json["gender"],
    fcmToken: json["fcmToken"],
    status: json["status"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "phone": phone,
    "password": password,
    "userableId": userableId,
    "userableType": userableType,
    "gender": gender,
    "fcmToken": fcmToken,
    "status": status,
    "createdAt": createdAt?.toIso8601String(),
  };
}
