// To parse this JSON data, do
//
//     final authModel = authModelFromJson(jsonString);

import 'dart:convert';

AuthModel authModelFromJson(String str) => AuthModel.fromJson(json.decode(str));

String authModelToJson(AuthModel data) => json.encode(data.toJson());

class AuthModel {
  final String? accessToken;
  final User? user;

  AuthModel({this.accessToken, this.user});

  AuthModel copyWith({String? accessToken, User? user}) => AuthModel(
    accessToken: accessToken ?? this.accessToken,
    user: user ?? this.user,
  );

  factory AuthModel.fromJson(Map<String, dynamic> json) => AuthModel(
    accessToken: json["accessToken"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "accessToken": accessToken,
    "user": user?.toJson(),
  };
}

class User {
  final String? id;
  final String? phone;
  final String? password;
  final String? userableId;
  final String? userableType;
  final String? gender;
  final String? fcmToken;
  final String? status; // "active"
  final DateTime? createdAt;

  User({
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

  User copyWith({
    String? id,
    String? phone,
    String? password,
    String? userableId,
    String? userableType,
    String? gender,
    String? fcmToken,
    String? status,
    DateTime? createdAt,
  }) => User(
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

  factory User.fromJson(Map<String, dynamic> json) => User(
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

  bool get isActive => status?.toLowerCase() == "active";

  bool get isStudent => userableType?.toLowerCase() == "STUDENT";
}
