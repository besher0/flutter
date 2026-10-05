// To parse this JSON data, do
//
//     final videoInteractionModel = videoInteractionModelFromJson(jsonString);

import 'dart:convert';

VideoInteractionModel videoInteractionModelFromJson(String str) =>
    VideoInteractionModel.fromJson(json.decode(str));

String videoInteractionModelToJson(VideoInteractionModel data) =>
    json.encode(data.toJson());

class VideoInteractionModel {
  final String? videoId;
  final int? likesCount;
  final bool? isLikedByUser;

  VideoInteractionModel({this.videoId, this.likesCount, this.isLikedByUser});

  VideoInteractionModel copyWith({
    String? videoId,
    int? likesCount,
    bool? isLikedByUser,
  }) => VideoInteractionModel(
    videoId: videoId ?? this.videoId,
    likesCount: likesCount ?? this.likesCount,
    isLikedByUser: isLikedByUser ?? this.isLikedByUser,
  );

  factory VideoInteractionModel.fromJson(Map<String, dynamic> json) =>
      VideoInteractionModel(
        videoId: json["videoId"],
        likesCount: json["likesCount"],
        isLikedByUser: json["isLikedByUser"],
      );

  Map<String, dynamic> toJson() => {
    "videoId": videoId,
    "likesCount": likesCount,
    "isLikedByUser": isLikedByUser,
  };
}
