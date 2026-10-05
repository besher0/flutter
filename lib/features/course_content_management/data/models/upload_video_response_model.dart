// To parse this JSON data, do
//
//     final uploadVideoResponseModel = uploadVideoResponseModelFromJson(jsonString);

import 'dart:convert';

UploadVideoResponseModel uploadVideoResponseModelFromJson(String str) =>
    UploadVideoResponseModel.fromJson(json.decode(str));

String uploadVideoResponseModelToJson(UploadVideoResponseModel data) =>
    json.encode(data.toJson());

class UploadVideoResponseModel {
  final String? guid;
  final String? title;
  final String? videoUrl;
  final String? downloadUrl;
  final String? storageVideoUrl;
  final String? embedUrl;
  final String? streamPlayUrl;
  final String? streamPlaylistUrl;
  final String? streamFallbackUrl;
  final dynamic availableResolutions;
  final dynamic mp4Resolutions;
  final String? preferredResolution;
  final dynamic preferredResolutionUrl;

  UploadVideoResponseModel({
    this.guid,
    this.title,
    this.videoUrl,
    this.downloadUrl,
    this.storageVideoUrl,
    this.embedUrl,
    this.streamPlayUrl,
    this.streamPlaylistUrl,
    this.streamFallbackUrl,
    this.availableResolutions,
    this.mp4Resolutions,
    this.preferredResolution,
    this.preferredResolutionUrl,
  });

  UploadVideoResponseModel copyWith({
    String? guid,
    String? title,
    String? videoUrl,
    String? downloadUrl,
    String? storageVideoUrl,
    String? embedUrl,
    String? streamPlayUrl,
    String? streamPlaylistUrl,
    String? streamFallbackUrl,
    dynamic availableResolutions,
    dynamic mp4Resolutions,
    String? preferredResolution,
    dynamic preferredResolutionUrl,
  }) => UploadVideoResponseModel(
    guid: guid ?? this.guid,
    title: title ?? this.title,
    videoUrl: videoUrl ?? this.videoUrl,
    downloadUrl: downloadUrl ?? this.downloadUrl,
    storageVideoUrl: storageVideoUrl ?? this.storageVideoUrl,
    embedUrl: embedUrl ?? this.embedUrl,
    streamPlayUrl: streamPlayUrl ?? this.streamPlayUrl,
    streamPlaylistUrl: streamPlaylistUrl ?? this.streamPlaylistUrl,
    streamFallbackUrl: streamFallbackUrl ?? this.streamFallbackUrl,
    availableResolutions: availableResolutions ?? this.availableResolutions,
    mp4Resolutions: mp4Resolutions ?? this.mp4Resolutions,
    preferredResolution: preferredResolution ?? this.preferredResolution,
    preferredResolutionUrl:
        preferredResolutionUrl ?? this.preferredResolutionUrl,
  );

  factory UploadVideoResponseModel.fromJson(Map<String, dynamic> json) =>
      UploadVideoResponseModel(
        guid: json["guid"],
        title: json["title"],
        videoUrl: json["videoUrl"],
        downloadUrl: json["downloadUrl"],
        storageVideoUrl: json["storageVideoUrl"],
        embedUrl: json["embedUrl"],
        streamPlayUrl: json["streamPlayUrl"],
        streamPlaylistUrl: json["streamPlaylistUrl"],
        streamFallbackUrl: json["streamFallbackUrl"],
        availableResolutions: json["availableResolutions"],
        mp4Resolutions: json["mp4Resolutions"],
        preferredResolution: json["preferredResolution"],
        preferredResolutionUrl: json["preferredResolutionUrl"],
      );

  Map<String, dynamic> toJson() => {
    "guid": guid,
    "title": title,
    "videoUrl": videoUrl,
    "downloadUrl": downloadUrl,
    "storageVideoUrl": storageVideoUrl,
    "embedUrl": embedUrl,
    "streamPlayUrl": streamPlayUrl,
    "streamPlaylistUrl": streamPlaylistUrl,
    "streamFallbackUrl": streamFallbackUrl,
    "availableResolutions": availableResolutions,
    "mp4Resolutions": mp4Resolutions,
    "preferredResolution": preferredResolution,
    "preferredResolutionUrl": preferredResolutionUrl,
  };
}
