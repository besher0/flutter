// To parse this JSON data, do
//
//     final uploadFileResponseModel = uploadFileResponseModelFromJson(jsonString);

import 'dart:convert';

UploadFileResponseModel uploadFileResponseModelFromJson(String str) =>
    UploadFileResponseModel.fromJson(json.decode(str));

String uploadFileResponseModelToJson(UploadFileResponseModel data) =>
    json.encode(data.toJson());

class UploadFileResponseModel {
  final String? fileName;
  final String? fileUrl;

  UploadFileResponseModel({this.fileName, this.fileUrl});

  UploadFileResponseModel copyWith({String? fileName, String? fileUrl}) =>
      UploadFileResponseModel(
        fileName: fileName ?? this.fileName,
        fileUrl: fileUrl ?? this.fileUrl,
      );

  factory UploadFileResponseModel.fromJson(Map<String, dynamic> json) =>
      UploadFileResponseModel(
        fileName: json["fileName"],
        fileUrl: json["fileUrl"],
      );

  Map<String, dynamic> toJson() => {"fileName": fileName, "fileUrl": fileUrl};
}
