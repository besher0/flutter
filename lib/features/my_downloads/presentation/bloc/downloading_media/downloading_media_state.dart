part of 'downloading_media_bloc.dart';

class DownloadingMediaState {
  final Map<String, double> downloadingProcesses;
  final Map<String, bool> downloadingStatus;
  final int currentDownloadingTasks;
  final int currentDownloadingImagesTasks;

  DownloadingMediaState({
    this.downloadingProcesses = const {},
    this.downloadingStatus = const {},
    this.currentDownloadingTasks = 0,
    this.currentDownloadingImagesTasks = 0,
  });

  DownloadingMediaState copyWith({
    final Map<String, double>? downloadingProcesses,
    final Map<String, bool>? downloadingStatus,
    final int? currentDownloadingTasks,
    final int? currentDownloadingImagesTasks,
  }) {
    return DownloadingMediaState(
      downloadingProcesses: downloadingProcesses ?? this.downloadingProcesses,
      downloadingStatus: downloadingStatus ?? this.downloadingStatus,
      currentDownloadingImagesTasks:
          currentDownloadingImagesTasks ?? this.currentDownloadingImagesTasks,
      currentDownloadingTasks:
          currentDownloadingTasks ?? this.currentDownloadingTasks,
    );
  }
}
