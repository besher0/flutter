import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/encrypted_hls_download_service.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/presentation/bloc/my_downloads_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import '../../../../../core/common/helper/show_message.dart';

part 'downloading_media_event.dart';

part 'downloading_media_state.dart';

@LazySingleton()
class DownloadingMediaBloc
    extends Bloc<DownloadingMediaEvent, DownloadingMediaState> {
  DownloadingMediaBloc(
    this._prefsRepository,
    this._encryptedHlsDownloadService,
    this._client,
  ) : super(DownloadingMediaState()) {
    _fetchAppDirectory();
    _encryptedHlsDownloadService.cleanupLegacyPlaintextDownloads();
    on<DownloadingMediaEvent>((event, emit) {});
    on<DownloadFileEvent>(_onDownloadFileEvent);
    on<ClearState>(_onClearState);
    on<CancelDownloadEvent>(_onCancelDownloadEvent);
  }

  String _redactLogMessage(String message) {
    return message
        .replaceAll(
          RegExp(r'https?://[^\s]+', caseSensitive: false),
          '<redacted-url>',
        )
        .replaceAll(
          RegExp(
            r'(jwt|token|signature|signedPayload|downloadUrl)[^,\s]*',
            caseSensitive: false,
          ),
          '<redacted-secret>',
        );
  }

  final PrefsRepository _prefsRepository;
  final EncryptedHlsDownloadService _encryptedHlsDownloadService;
  final Dio _client;

  bool appDirFetched = false;
  Directory? appDir;
  final Map<String, CancelToken> _cancelTokens = {};
  final Map<String, String> _currentQualityPerVideo = {};

  static Future<Directory?> get _getAppDirectory async {
    return await getApplicationDocumentsDirectory();
  }

  String _getFileSuffix(String type) {
    switch (type) {
      case "video":
        return ".mp4";
      case "file":
        return ".pdf";
      default:
        return ".png";
    }
  }

  String _getDownloadDirectorySuffix(String type) {
    return "${type}s";
  }

  Future<String> _getPathFromFile({
    required String url,
    required String fileType,
    required String fileName,
  }) async {
    if (!appDirFetched) {
      await _fetchAppDirectory();
    }
    return '${appDir!.path}/${_getDownloadDirectorySuffix(fileType)}/$fileName${_getFileSuffix(fileType)}';
  }

  Future<void> _downloadFileWithResume({
    required String courseId,
    required String url,
    String? originalUrlForVideo,
    String? quality,
    required String filePath,
    required String fileType,
  }) async {
    Map<String, bool> downloadingStatuses;
    final tempPath = '$filePath.temp'; // use temp file for download
    final fileKey = originalUrlForVideo ?? url;
    final tempFile = File(tempPath);
    final existingBytes = tempFile.existsSync() ? tempFile.lengthSync() : 0;
    if (existingBytes == 0) {
      _cancelTokens[filePath] = CancelToken();
    }
    try {
      final response = await _client.get<ResponseBody>(
        url,
        cancelToken: _cancelTokens[filePath],
        options: Options(
          responseType: ResponseType.stream,
          headers: {if (existingBytes > 0) 'Range': 'bytes=$existingBytes-'},
        ),
      );

      final contentLength = response.headers.map['content-length'] != null
          ? int.tryParse(response.headers.map['content-length']!.first) ?? 0
          : 0;

      final totalBytes = existingBytes + contentLength;
      var downloaded = existingBytes;
      final directory = tempFile.parent;

      if (!(await directory.exists())) {
        await directory.create(recursive: true);
      }
      final sink = tempFile.openWrite(mode: FileMode.writeOnlyAppend);
      response.data!.stream.listen(
        (chunk) {
          downloaded += chunk.length;
          sink.add(chunk);
          final progress = (downloaded / totalBytes * 100);
          Map<String, double> downloadingProgress = Map.of(
            state.downloadingProcesses,
          );
          downloadingProgress[fileKey] = progress;
          emit(state.copyWith(downloadingProcesses: downloadingProgress));
        },
        onDone: () async {
          await sink.flush();
          await sink.close();
          if (!(await tempFile.exists())) return;
          final plainBytes = await tempFile.readAsBytes();
          final finalFile = File(filePath);
          await finalFile.writeAsBytes(plainBytes);
          try {
            await tempFile.delete(); // remove temp file
          } catch (e) {
            debugPrint(e.toString());
          }
          downloadingStatuses = Map.of(state.downloadingStatus);
          Map<String, double> downloadingProgress = Map.of(
            state.downloadingProcesses,
          );
          downloadingStatuses.remove(fileKey);
          downloadingProgress.remove(fileKey);
          GetIt.I<MyDownloadsBloc>().add(
            SaveReferenceOfDownloadedFile(
              fileUrl: fileKey,
              localFilePath: filePath,
              courseId: courseId,
            ),
          );
          if (quality != null) {
            _prefsRepository.setQuality(fileKey, quality);
          }
          emit(
            state.copyWith(
              downloadingStatus: downloadingStatuses,
              downloadingProcesses: downloadingProgress,
              currentDownloadingTasks: state.currentDownloadingTasks - 1,
              currentDownloadingImagesTasks:
                  state.currentDownloadingImagesTasks -
                  (fileType == 'image' ? 1 : 0),
            ),
          );
        },
        cancelOnError: true,
        onError: (e) {
          _handleError(fileKey, fileType, e);
        },
      );
    } catch (e, stackTrace) {
      _handleError(fileKey, fileType, e, stackTrace);
    }
  }

  void _handleError(
    String fileKey,
    String fileType,
    dynamic e, [
    StackTrace? stackTrace,
  ]) {
    Map<String, bool> downloadingStatuses;
    downloadingStatuses = Map.of(state.downloadingStatus);
    Map<String, double> downloadingProgress = Map.of(
      state.downloadingProcesses,
    );
    downloadingStatuses.remove(fileKey);
    downloadingProgress.remove(fileKey);
    emit(
      state.copyWith(
        downloadingStatus: downloadingStatuses,
        downloadingProcesses: downloadingProgress,
        currentDownloadingTasks: state.currentDownloadingTasks - 1,
        currentDownloadingImagesTasks:
            state.currentDownloadingImagesTasks - (fileType == 'image' ? 1 : 0),
      ),
    );
    final message = e is Error
        ? e.toString().split(': ').skip(1).join(': ')
        : e.toString();
    log(
      'Download failed: type=${e.runtimeType}, message=${_redactLogMessage(message)}',
      stackTrace: stackTrace,
    );
    if (e is DioException &&
        e.message == "The request was manually cancelled by the user.") {
      return;
    }
    showMessage("حدثت مشكلة أثناء التحميل");
  }

  Future<void> _onDownloadFileEvent(
    DownloadFileEvent event,
    Emitter<DownloadingMediaState> emit,
  ) async {
    if (_prefsRepository.isGuest || _prefsRepository.token == null) {
      showMessage('سجّل الدخول لتحميل الفيديو');
      return;
    }
    final url = event.fileUrl;
    Map<String, bool> downloadingStatuses = Map.of(state.downloadingStatus);
    Map<String, double> downloadingProgress = Map.of(
      state.downloadingProcesses,
    );
    downloadingStatuses[url] = true;
    print('state.currentDownloadingTasks ${state.currentDownloadingTasks}');
    emit(
      state.copyWith(
        downloadingStatus: downloadingStatuses,
        currentDownloadingTasks: state.currentDownloadingTasks + 1,
        currentDownloadingImagesTasks:
            state.currentDownloadingImagesTasks +
            (event.fileType == 'image' ? 1 : 0),
      ),
    );
    if (event.fileType == 'video') {
      _cancelTokens[url] = CancelToken();
      try {
        await _encryptedHlsDownloadService.download(
          videoId: event.fileUrl,
          courseId: event.courseId,
          lectureId: event.lectureId ?? '',
          preferredResolution: event.quality ?? '720p',
          cancelToken: _cancelTokens[url],
          onProgress: (progress) {
            final downloadingProgress = Map<String, double>.of(
              state.downloadingProcesses,
            );
            downloadingProgress[url] = progress;
            emit(state.copyWith(downloadingProcesses: downloadingProgress));
          },
        );
        downloadingStatuses = Map.of(state.downloadingStatus);
        downloadingProgress = Map.of(state.downloadingProcesses);
        downloadingStatuses.remove(url);
        downloadingProgress.remove(url);
        GetIt.I<MyDownloadsBloc>().add(
          SaveReferenceOfDownloadedFile(
            fileUrl: url,
            localFilePath: 'secure-hls://$url',
            courseId: event.courseId,
          ),
        );
        if (event.quality != null) {
          _prefsRepository.setQuality(url, event.quality!);
        }
        emit(
          state.copyWith(
            downloadingStatus: downloadingStatuses,
            downloadingProcesses: downloadingProgress,
            currentDownloadingTasks: state.currentDownloadingTasks - 1,
          ),
        );
      } catch (e, stackTrace) {
        _handleError(url, event.fileType, e, stackTrace);
      } finally {
        _cancelTokens.remove(url);
      }
      return;
    }
    String name;
    if (event.fileType == "video") {
      name =
          "${event.fileName ?? url.hashCode}_${event.quality ?? 'default'}_${DateTime.now().toString()}";
    } else {
      name =
          (event.fileName ?? url.split('/').last.split('.').first) +
          DateTime.now().toString();
    }
    String filePath = await _getPathFromFile(
      url: url,
      fileType: event.fileType,
      fileName: name,
    );
    bool exist = await File(filePath).exists();
    if (exist) {
      GetIt.I<MyDownloadsBloc>().add(
        SaveReferenceOfDownloadedFile(
          courseId: event.courseId,
          fileUrl: url,
          localFilePath: filePath,
        ),
      );
      downloadingProgress.remove(url);
      downloadingStatuses.remove(url);
      if (event.quality != null) {
        _prefsRepository.setQuality(url, event.quality!);
      }
      emit(
        state.copyWith(
          downloadingStatus: downloadingStatuses,
          downloadingProcesses: downloadingProgress,
          currentDownloadingTasks: state.currentDownloadingTasks - 1,
          currentDownloadingImagesTasks:
              state.currentDownloadingImagesTasks -
              (event.fileType == 'image' ? 1 : 0),
        ),
      );

      return;
    }
    if (event.fileType == 'video') {
      final previousQuality = _currentQualityPerVideo[url];

      final qualityChanged =
          previousQuality != null && previousQuality != event.quality;

      if (qualityChanged) {
        final oldPath = await _getPathFromFile(
          url: url,
          fileType: event.fileType,
          fileName: "${event.fileName ?? url.hashCode}_$previousQuality",
        );

        final oldTemp = File("$oldPath.temp");

        if (await oldTemp.exists()) {
          await oldTemp.delete();
        }

        final oldFile = File(oldPath);

        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      }
      _currentQualityPerVideo[url] = event.quality!;
    }
    _downloadFileWithResume(
      url: event.downloadUrl,
      originalUrlForVideo: event.fileType == 'video' ? url : null,
      filePath: filePath,
      fileType: event.fileType,
      courseId: event.courseId,
      quality: event.quality,
    );
  }

  Future<void> _fetchAppDirectory() async {
    if (appDirFetched) return;
    // Get path to save the encrypted file
    appDir = await _getAppDirectory;
    appDirFetched = true;
  }

  FutureOr<void> _onClearState(
    ClearState event,
    Emitter<DownloadingMediaState> emit,
  ) {
    emit(DownloadingMediaState());
  }

  FutureOr<void> _onCancelDownloadEvent(
    CancelDownloadEvent event,
    Emitter<DownloadingMediaState> emit,
  ) async {
    final url = event.fileUrl;
    Map<String, bool> downloadingStatuses = Map.of(state.downloadingStatus);
    Map<String, double> downloadingProgress = Map.of(
      state.downloadingProcesses,
    );
    downloadingStatuses.remove(url);
    downloadingProgress.remove(url);
    String name;
    if (event.fileType == "video") {
      name =
          "${event.fileName ?? event.fileUrl.hashCode}_${_currentQualityPerVideo[event.fileUrl] ?? 'default'}";
    } else {
      name =
          event.fileName ??
          event.fileUrl.split('/').last.split('.').first +
              DateTime.now().toString();
    }
    String filePath = await _getPathFromFile(
      url: event.fileUrl,
      fileType: event.fileType,
      fileName: name,
    );
    (_cancelTokens[filePath] ?? _cancelTokens[url])?.cancel();
    _cancelTokens.remove(filePath);
    _cancelTokens.remove(url);
    final tempPath = '$filePath.temp';
    try {
      File(tempPath).delete();
    } catch (e) {}
    try {
      File(filePath).delete();
    } catch (e) {}
    if (event.fileType == 'video') {
      await _encryptedHlsDownloadService.deleteVideo(event.fileUrl);
    }

    emit(
      state.copyWith(
        downloadingStatus: downloadingStatuses,
        downloadingProcesses: downloadingProgress,
        currentDownloadingTasks: state.currentDownloadingTasks - 1,
        currentDownloadingImagesTasks:
            state.currentDownloadingImagesTasks -
            (event.fileType == 'image' ? 1 : 0),
      ),
    );
    GetIt.I<MyDownloadsBloc>().add(
      DeleteReferenceOfDownloadedFile(fileUrl: url),
    );
  }
}
