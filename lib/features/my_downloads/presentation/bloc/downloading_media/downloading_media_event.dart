part of 'downloading_media_bloc.dart';

@immutable
sealed class DownloadingMediaEvent {}

class DownloadFileEvent extends DownloadingMediaEvent {
  final String fileUrl;
  final String downloadUrl;
  final String? quality;
  final String fileType;
  final String? fileName;
  final String courseId;
  final String? lectureId;

  DownloadFileEvent({
    required this.fileUrl,
    required this.fileType,
    this.fileName,
    required this.courseId,
    required this.downloadUrl,
    this.quality,
    this.lectureId,
  });
}

class ClearState extends DownloadingMediaEvent {}

class CancelDownloadEvent extends DownloadingMediaEvent {
  final String fileUrl;
  final String fileType;
  final String? fileName;

  CancelDownloadEvent({
    required this.fileUrl,
    required this.fileType,
    this.fileName,
  });
}
