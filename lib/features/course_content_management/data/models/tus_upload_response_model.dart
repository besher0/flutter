// To parse this JSON data, do
//
//     final tusInitResponseModel = tusInitResponseModelFromJson(jsonString);

import 'dart:convert';

TusInitResponseModel tusInitResponseModelFromJson(String str) =>
    TusInitResponseModel.fromJson(json.decode(str));

String tusInitResponseModelToJson(TusInitResponseModel data) =>
    json.encode(data.toJson());

class TusInitResponseModel {
  final String? title;
  final Upload? upload;

  TusInitResponseModel({this.title, this.upload});

  TusInitResponseModel copyWith({String? title, Upload? upload}) =>
      TusInitResponseModel(
        title: title ?? this.title,
        upload: upload ?? this.upload,
      );

  factory TusInitResponseModel.fromJson(Map<String, dynamic> json) =>
      TusInitResponseModel(
        title: json["title"],
        upload: json["upload"] == null ? null : Upload.fromJson(json["upload"]),
      );

  Map<String, dynamic> toJson() => {"title": title, "upload": upload?.toJson()};
}

class Upload {
  final String? videoId;
  final String? endpoint;
  final String? libraryId;
  final int? authorizationExpire;
  final String? authorizationSignature;
  final Headers? headers;

  Upload({
    this.videoId,
    this.endpoint,
    this.libraryId,
    this.authorizationExpire,
    this.authorizationSignature,
    this.headers,
  });

  Upload copyWith({
    String? videoId,
    String? endpoint,
    String? libraryId,
    int? authorizationExpire,
    String? authorizationSignature,
    Headers? headers,
  }) => Upload(
    videoId: videoId ?? this.videoId,
    endpoint: endpoint ?? this.endpoint,
    libraryId: libraryId ?? this.libraryId,
    authorizationExpire: authorizationExpire ?? this.authorizationExpire,
    authorizationSignature:
        authorizationSignature ?? this.authorizationSignature,
    headers: headers ?? this.headers,
  );

  factory Upload.fromJson(Map<String, dynamic> json) => Upload(
    videoId: json["videoId"],
    endpoint: json["endpoint"],
    libraryId: json["libraryId"],
    authorizationExpire: json["authorizationExpire"],
    authorizationSignature: json["authorizationSignature"],
    headers: json["headers"] == null ? null : Headers.fromJson(json["headers"]),
  );

  Map<String, dynamic> toJson() => {
    "videoId": videoId,
    "endpoint": endpoint,
    "libraryId": libraryId,
    "authorizationExpire": authorizationExpire,
    "authorizationSignature": authorizationSignature,
    "headers": headers?.toJson(),
  };
}

class Headers {
  final String? authorizationSignature;
  final String? authorizationExpire;
  final String? videoId;
  final String? libraryId;

  Headers({
    this.authorizationSignature,
    this.authorizationExpire,
    this.videoId,
    this.libraryId,
  });

  Headers copyWith({
    String? authorizationSignature,
    String? authorizationExpire,
    String? videoId,
    String? libraryId,
  }) => Headers(
    authorizationSignature:
        authorizationSignature ?? this.authorizationSignature,
    authorizationExpire: authorizationExpire ?? this.authorizationExpire,
    videoId: videoId ?? this.videoId,
    libraryId: libraryId ?? this.libraryId,
  );

  factory Headers.fromJson(Map<String, dynamic> json) => Headers(
    authorizationSignature: json["AuthorizationSignature"],
    authorizationExpire: json["AuthorizationExpire"],
    videoId: json["VideoId"],
    libraryId: json["LibraryId"],
  );

  Map<String, dynamic> toJson() => {
    "AuthorizationSignature": authorizationSignature,
    "AuthorizationExpire": authorizationExpire,
    "VideoId": videoId,
    "LibraryId": libraryId,
  };
}
