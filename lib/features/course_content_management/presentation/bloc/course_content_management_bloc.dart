import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/delete_video_segment_usecase.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/get_video_segements_usecase.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/upsert_file_usecase.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/upsert_question_usecase.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/upsert_video_segment_usecase.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/upsert_video_usecase.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/lecture_details_model.dart';
import 'package:dio/dio.dart' hide Headers;
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tusc/tusc.dart' hide Headers;
import 'package:bloc/bloc.dart';
import 'package:coursaty_student_and_teacher/core/enums/request_status.dart';
import 'package:coursaty_student_and_teacher/core/use_case/use_case.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/data/models/allowed_subjects_model.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/data/models/seasons_model.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/upsert_course_usecase.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/delete_from_course_usecase.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/get_allowed_subjects_usecase.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/get_seasons_usecase.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/upsert_lecture_usecase.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/bloc/courses_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import '../../../../core/common/constant/configuration/bunny_url_routes.dart';
import '../../../../core/common/constant/configuration/url_routes.dart';
import '../../../../core/storage/prefs_repository.dart';
import '../../../common/data/models/upload_file_response_model.dart';
import '../../../common/domain/usecases/upload_file_usecase.dart';
import '../../data/models/tus_upload_response_model.dart';
import '../../data/models/upload_video_response_model.dart';
import '../../data/services/resumable_video_upload.dart';
import 'package:path_provider/path_provider.dart';

part 'course_content_management_event.dart';

part 'course_content_management_state.dart';

@LazySingleton()
class CourseContentManagementBloc
    extends Bloc<CourseContentManagementEvent, CourseContentManagementState> {
  CourseContentManagementBloc({
    required this.getAllowedSubjectsUsecase,
    required this.upsertCourseUsecase,
    required this.upsertLectureUsecase,
    required this.deleteFromCourseUsecase,
    required this.getSeasonsUsecase,
    required this.uploadFileUsecase,
    required this.upsertVideoUsecase,
    required this.upsertFileUsecase,
    required this.upsertQuestionUsecase,
    required this.upsertVideoSegmentUsecase,
    required this.getVideoSegementsUsecase,
    required this.deleteVideoSegmentUsecase,
  }) : super(CourseContentManagementState()) {
    getDirectory();
    on<CourseContentManagementEvent>((event, emit) {});
    on<GetAllowedSubjects>(_onGetAllowedSubjects);
    on<UpsertCourseEvent>(_onUpsertCourseEvent);
    on<ClearContentManagementState>(_onClearContentManagementState);
    on<DeleteLectureEvent>(_onDeleteLectureEvent);
    on<UpsertLectureEvent>(_onUpsertLectureEvent);
    on<GetAllSeasonsEvent>(_onGetAllSeasonsEvent);
    on<UpsertVideoEvent>(_onUpsertVideoEvent);
    on<VideoSelectedEvent>(_onVideoSelectedEvent);
    on<CancelVideoUploadEvent>(_onCancelVideoUploadEvent);
    on<UpsertFileEvent>(_onUpsertFileEvent);
    on<UpsertQuestionEvent>(_onUpsertQuestionEvent);
    on<UpsertVideoSegmentEvent>(_onUpsertVideoSegmentEvent);
    on<GetVideoSegmentsEvent>(_onGetVideoSegmentsEvent);
    on<DeleteVideoSegmentsEvent>(_onDeleteVideoSegmentsEvent);
    on<DeleteFromLectureEvent>(_onDeleteFromLectureEvent);
    on<DeleteQuestionEvent>(_onDeleteQuestionEvent);
  }

  void getDirectory() async {
    directory = await getApplicationDocumentsDirectory();
  }

  late final Directory directory;
  UpsertVideoParams? upsertVideoParams;

  final GetAllowedSubjectsUsecase getAllowedSubjectsUsecase;
  final UpsertCourseUsecase upsertCourseUsecase;

  final UpsertLectureUsecase upsertLectureUsecase;
  final DeleteFromCourseUsecase deleteFromCourseUsecase;

  final GetSeasonsUsecase getSeasonsUsecase;
  final UploadFileUsecase uploadFileUsecase;

  final UpsertFileUsecase upsertFileUsecase;
  final UpsertQuestionUsecase upsertQuestionUsecase;
  final UpsertVideoSegmentUsecase upsertVideoSegmentUsecase;
  final GetVideoSegementsUsecase getVideoSegementsUsecase;
  final DeleteVideoSegmentUsecase deleteVideoSegmentUsecase;

  final UpsertVideoUsecase upsertVideoUsecase;
  Map<String, UploadVideoResponseModel?> uploadingVideos = {};
  Map<String, TusInitResponseModel?> tuscInitResponse = {};
  Map<String, TusClient?> tuscClients = {};

  FutureOr<void> _onGetAllowedSubjects(
    GetAllowedSubjects event,
    Emitter<CourseContentManagementState> emit,
  ) async {
    emit(state.copyWith(getAllowedSubjects: Status.loading));

    final response = await getAllowedSubjectsUsecase(NoParams());
    response.fold(
      (l) {
        emit(
          state.copyWith(
            getAllowedSubjects: Status.failure,
            errorMessage: l.message,
          ),
        );
      },
      (r) {
        emit(
          state.copyWith(
            getAllowedSubjects: Status.loaded,
            getAllowedSubjectsResponseModel: r,
          ),
        );
      },
    );
  }

  FutureOr<void> _onUpsertCourseEvent(
    UpsertCourseEvent event,
    Emitter<CourseContentManagementState> emit,
  ) async {
    emit(state.copyWith(createCourse: Status.loading));
    UploadFileResponseModel? uploadFileResponseModel;
    if (event.image != null) {
      final res = await uploadFileUsecase(UploadFileParams(file: event.image!));
      res.fold(
        (l) {
          emit(
            state.copyWith(
              createCourse: Status.failure,
              errorMessage: l.message,
            ),
          );
        },
        (r) {
          uploadFileResponseModel = r;
          log(r.toJson().toString());
          event.params.imageUrl = uploadFileResponseModel!.fileUrl;
        },
      );
    }
    if (event.image != null && uploadFileResponseModel == null) {
      emit(
        state.copyWith(
          createCourse: Status.failure,
          errorMessage: "حدث خطأ ما",
        ),
      );
      return;
    }
    final response = await upsertCourseUsecase(event.params);
    response.fold(
      (l) {
        emit(
          state.copyWith(createCourse: Status.failure, errorMessage: l.message),
        );
      },
      (r) {
        emit(state.copyWith(createCourse: Status.loaded));
      },
    );
  }

  FutureOr<void> _onClearContentManagementState(
    ClearContentManagementState event,
    Emitter<CourseContentManagementState> emit,
  ) {
    emit(CourseContentManagementState());
  }

  FutureOr<void> _onDeleteLectureEvent(
    DeleteLectureEvent event,
    Emitter<CourseContentManagementState> emit,
  ) async {
    emit(state.copyWith(deleteFromCourseTransaction: Status.loading));

    final response = await deleteFromCourseUsecase(event.params);
    response.fold(
      (l) {
        emit(
          state.copyWith(
            deleteFromCourseTransaction: Status.failure,
            errorMessage: l.message,
          ),
        );
      },
      (r) {
        emit(state.copyWith(deleteFromCourseTransaction: Status.loaded));
      },
    );
  }

  FutureOr<void> _onUpsertLectureEvent(
    UpsertLectureEvent event,
    Emitter<CourseContentManagementState> emit,
  ) async {
    emit(state.copyWith(upsertCourse: Status.loading));

    final response = await upsertLectureUsecase(event.params);
    response.fold(
      (l) {
        emit(
          state.copyWith(upsertCourse: Status.failure, errorMessage: l.message),
        );
      },
      (r) {
        emit(state.copyWith(upsertCourse: Status.loaded));
      },
    );
  }

  FutureOr<void> _onGetAllSeasonsEvent(
    GetAllSeasonsEvent event,
    Emitter<CourseContentManagementState> emit,
  ) async {
    emit(state.copyWith(getAllSeasons: Status.loading));

    final response = await getSeasonsUsecase(NoParams());
    response.fold(
      (l) {
        emit(
          state.copyWith(
            getAllSeasons: Status.failure,
            errorMessage: l.message,
          ),
        );
      },
      (r) {
        emit(state.copyWith(getAllSeasons: Status.loaded, seasons: r));
      },
    );
  }

  /// One resumable upload per selected file, kept after a failure so that
  /// pressing save again continues from where it stopped.
  final Map<String, ResumableVideoUpload> _uploads = {};
  final Set<String> _cancelledUploads = {};

  Dio _apiClient() => Dio(
    BaseOptions(
      contentType: 'application/json',
      responseType: ResponseType.json,
      headers: {
        HttpHeaders.authorizationHeader:
            "Bearer ${GetIt.I<PrefsRepository>().token}",
        HttpHeaders.acceptHeader: 'application/json',
      },
    ),
  );

  /// Renews the signed TUS headers after they expired (long interruption).
  Future<Map<String, String>?> _refreshTusHeaders(String path) async {
    final videoId = tuscInitResponse[path]?.upload?.videoId;
    if (videoId == null) return null;
    final response = await _apiClient().post(
      MasterUrlRoutes.baseUrl + EndPoints.refreshTusEp,
      data: {"videoId": videoId},
    );
    if (response.statusCode != 200 && response.statusCode != 201) return null;
    final refreshed = TusInitResponseModel.fromJson(response.data);
    tuscInitResponse[path] = refreshed;
    return refreshed.upload?.headers?.toJson().map(
      (key, value) => MapEntry(key, value.toString()),
    );
  }

  Future<bool> _uploadVideoUsingTusForCourse({required XFile video}) async {
    final path = video.path;
    _cancelledUploads.remove(path);
    Map<String, double> progresses = Map.of(state.uploadingProgress);
    if (!progresses.containsKey(path)) {
      // Unknown until the server reports the offset (a resumed upload is not
      // at 0%): the screen shows a spinner meanwhile.
      progresses[path] = -1;
      emit(state.copyWith(uploadingProgress: progresses));
    }
    if (tuscInitResponse[path] == null) {
      Response? response;
      try {
        response = await _apiClient().post(
          MasterUrlRoutes.baseUrl + EndPoints.initTusEp,
        );
      } catch (e, st) {
        log(e.toString());
        log(st.toString());
      }
      if (response == null || response.statusCode != 201) {
        return false;
      }
      tuscInitResponse[path] = TusInitResponseModel.fromJson(response.data);
    }
    if (_cancelledUploads.contains(path)) return false;

    final upload = _uploads[path] ??= ResumableVideoUpload(
      headers: tuscInitResponse[path]!.upload!.headers!.toJson().map(
        (key, value) => MapEntry(key, value.toString()),
      ),
      refreshHeaders: () => _refreshTusHeaders(path),
      createClient: ({required uploadUrl, required headers}) => TusClient(
        url: BunnyUrlRoutes.baseUrl + BunnyEndPoints.uploadVideoTusEP,
        // Continue the same upload instead of creating a new one.
        uploadUrl: uploadUrl,
        file: video,
        cache: TusPersistentCache(directory.path),
        headers: headers,
        chunkSize: 1024 * 1024,
        timeout: const Duration(seconds: 60),
      ),
    );

    final outcome = await upload.run(
      onProgress: (percent) {
        if (isClosed || _cancelledUploads.contains(path)) return;
        final progresses = Map.of(state.uploadingProgress);
        progresses[path] = percent;
        emit(state.copyWith(uploadingProgress: progresses));
      },
      onStatus: (message) {
        if (isClosed || _cancelledUploads.contains(path)) return;
        if (message == state.uploadStatusMessage) return;
        emit(
          state.copyWith(
            uploadStatusMessage: message,
            resetUploadStatusMessage: message == null,
          ),
        );
      },
    );
    if (outcome != VideoUploadOutcome.completed) return false;

    try {
      final response = await _apiClient().post(
        MasterUrlRoutes.baseUrl + EndPoints.completeTusEp,
        data: {"videoId": tuscInitResponse[path]!.upload!.videoId},
      );
      uploadingVideos[path] = UploadVideoResponseModel.fromJson(response.data);
    } catch (e) {
      // The bytes are on Bunny; saving again only repeats this step.
      log('complete upload failed: $e');
      return false;
    }
    _uploads.remove(path);
    return uploadingVideos[path] != null;
  }

  void cancelVideoUpload({required XFile video}) {
    final path = video.path;
    _cancelledUploads.add(path);
    _uploads.remove(path)?.cancel();
    uploadingVideos[path] = null;
    tuscInitResponse[path] = null;
  }

  FutureOr<void> _onCancelVideoUploadEvent(
    CancelVideoUploadEvent event,
    Emitter<CourseContentManagementState> emit,
  ) {
    final file = state.currentlyUploadingFile;
    if (file == null) return null;
    cancelVideoUpload(video: file);
    final progresses = Map.of(state.uploadingProgress)..remove(file.path);
    emit(
      state.copyWith(
        uploadingProgress: progresses,
        upsertLecture: Status.init,
        resetUploadStatusMessage: true,
      ),
    );
  }

  FutureOr<void> _onUpsertVideoEvent(
    UpsertVideoEvent event,
    Emitter<CourseContentManagementState> emit,
  ) async {
    upsertVideoParams = event.params;
    bool success = true;
    emit(state.copyWith(upsertLecture: Status.loading));
    if (state.currentlyUploadingFile != null) {
      final path = state.currentlyUploadingFile!.path;
      success = await _uploadVideoUsingTusForCourse(
        video: state.currentlyUploadingFile!,
      );
      // Cancelled by the teacher: the cancel event already reset the screen.
      if (!success && _cancelledUploads.contains(path)) return;
    }
    if (success) {
      final uploadingFile = state.currentlyUploadingFile;
      if (uploadingFile != null) {
        // The stable play URL carries the Bunny GUID. The signed MP4 fallback
        // URL is often null right after upload (MP4 fallback is disabled
        // library-wide) and expires anyway, so it must not be persisted.
        final uploaded = uploadingVideos[uploadingFile.path];
        final stableUrl = uploaded?.videoUrl ?? uploaded?.streamPlayUrl;
        if (stableUrl == null || stableUrl.isEmpty) {
          Map<String, double> progresses = Map.of(state.uploadingProgress);
          progresses.remove(uploadingFile.path);
          emit(
            state.copyWith(
              errorMessage: "تعذر إكمال رفع الفيديو، أعد المحاولة",
              upsertLecture: Status.failure,
              uploadingProgress: progresses,
            ),
          );
          return;
        }
        event.params.videoUrl = stableUrl;
      }
      final response = await upsertVideoUsecase(event.params);
      response.fold(
        (l) {
          emit(
            state.copyWith(
              upsertLecture: Status.failure,
              errorMessage: l.message,
            ),
          );
        },
        (r) {
          Map<String, double> progresses = Map.of(state.uploadingProgress);
          // Metadata-only edits have no file in flight.
          final uploadedPath = state.currentlyUploadingFile?.path;
          if (uploadedPath != null) progresses.remove(uploadedPath);
          upsertVideoParams = null;
          emit(
            state.copyWith(
              upsertLecture: Status.loaded,
              uploadingProgress: progresses,
              resetCurrentlyUploadingFile: true,
            ),
          );
        },
      );
      return;
    }
    if (state.currentlyUploadingFile != null) {
      Map<String, double> progresses = Map.of(state.uploadingProgress);
      progresses.remove(state.currentlyUploadingFile!.path);
      emit(
        state.copyWith(
          errorMessage:
              "تعذر إكمال رفع الفيديو. تحقق من الاتصال واضغط حفظ لاستكمال الرفع من حيث توقف",
          upsertLecture: Status.failure,
          uploadingProgress: progresses,
          resetCurrentlyUploadingFile: success,
          resetUploadStatusMessage: true,
        ),
      );
    }
  }

  FutureOr<void> _onVideoSelectedEvent(
    VideoSelectedEvent event,
    Emitter<CourseContentManagementState> emit,
  ) {
    if (state.currentlyUploadingFile != null) {
      cancelVideoUpload(video: state.currentlyUploadingFile!);
    }
    emit(
      state.copyWith(
        currentlyUploadingFile: event.file,
        resetCurrentlyUploadingFile: event.file == null,
      ),
    );
  }

  FutureOr<void> _onUpsertVideoSegmentEvent(
    UpsertVideoSegmentEvent event,
    Emitter<CourseContentManagementState> emit,
  ) async {
    emit(state.copyWith(upsertVideoSegment: Status.loading));

    final response = await upsertVideoSegmentUsecase(event.params);
    response.fold(
      (l) {
        emit(
          state.copyWith(
            upsertVideoSegment: Status.failure,
            errorMessage: l.message,
          ),
        );
      },
      (r) {
        add(GetVideoSegmentsEvent(event.params.videoId));
      },
    );
  }

  FutureOr<void> _onUpsertFileEvent(
    UpsertFileEvent event,
    Emitter<CourseContentManagementState> emit,
  ) async {
    emit(state.copyWith(upsertLecture: Status.loading));
    UploadFileResponseModel? uploadFileResponseModel;
    if (event.file != null) {
      final res = await uploadFileUsecase(
        UploadFileParams(file: File(event.file!.path)),
      );
      res.fold(
        (l) {
          emit(
            state.copyWith(
              upsertLecture: Status.failure,
              errorMessage: l.message,
            ),
          );
        },
        (r) {
          uploadFileResponseModel = r;
          event.params.fileUrl = uploadFileResponseModel!.fileUrl;
        },
      );
    }
    if (event.file != null && uploadFileResponseModel == null) {
      emit(
        state.copyWith(
          upsertLecture: Status.failure,
          errorMessage: "حدث خطأ ما",
        ),
      );
      return;
    }
    final response = await upsertFileUsecase(event.params);
    response.fold(
      (l) {
        emit(
          state.copyWith(
            upsertLecture: Status.failure,
            errorMessage: l.message,
          ),
        );
      },
      (r) {
        emit(state.copyWith(upsertLecture: Status.loaded));
      },
    );
  }

  FutureOr<void> _onUpsertQuestionEvent(
    UpsertQuestionEvent event,
    Emitter<CourseContentManagementState> emit,
  ) async {
    emit(state.copyWith(upsertLecture: Status.loading));
    UploadFileResponseModel? uploadFileResponseModel;
    if (event.file != null) {
      final res = await uploadFileUsecase(
        UploadFileParams(file: File(event.file!.path)),
      );
      res.fold(
        (l) {
          emit(
            state.copyWith(
              upsertLecture: Status.failure,
              errorMessage: l.message,
            ),
          );
        },
        (r) {
          uploadFileResponseModel = r;
          event.params.imageUrl = uploadFileResponseModel!.fileUrl;
        },
      );
    }
    if (event.file != null && uploadFileResponseModel == null) {
      emit(
        state.copyWith(
          upsertLecture: Status.failure,
          errorMessage: "حدث خطأ ما",
        ),
      );
      return;
    }
    final response = await upsertQuestionUsecase(event.params);
    response.fold(
      (l) {
        emit(
          state.copyWith(
            upsertLecture: Status.failure,
            errorMessage: l.message,
          ),
        );
      },
      (r) {
        emit(state.copyWith(upsertLecture: Status.loaded));
      },
    );
  }

  FutureOr<void> _onGetVideoSegmentsEvent(
    GetVideoSegmentsEvent event,
    Emitter<CourseContentManagementState> emit,
  ) async {
    emit(state.copyWith(upsertVideoSegment: Status.loading));

    final response = await getVideoSegementsUsecase(event.videoId);
    response.fold(
      (l) {
        emit(
          state.copyWith(
            upsertVideoSegment: Status.failure,
            errorMessage: l.message,
          ),
        );
      },
      (r) {
        emit(
          state.copyWith(upsertVideoSegment: Status.loaded, videoSegments: r),
        );
      },
    );
  }

  FutureOr<void> _onDeleteVideoSegmentsEvent(
    DeleteVideoSegmentsEvent event,
    Emitter<CourseContentManagementState> emit,
  ) async {
    emit(state.copyWith(upsertVideoSegment: Status.loading));

    final response = await deleteVideoSegmentUsecase(event.params);
    response.fold(
      (l) {
        emit(
          state.copyWith(
            upsertVideoSegment: Status.failure,
            errorMessage: l.message,
          ),
        );
      },
      (r) {
        add(GetVideoSegmentsEvent(event.params.videoId));
      },
    );
  }

  FutureOr<void> _onDeleteQuestionEvent(
    DeleteQuestionEvent event,
    Emitter<CourseContentManagementState> emit,
  ) async {
    List<String> currentlyDeletingQuestionsIds = List.of(
      state.currentlyDeletingQuestionsIds,
    );
    currentlyDeletingQuestionsIds.add(event.params.id);
    emit(
      state.copyWith(
        deleteFromLectureTransaction: Status.loading,
        currentlyDeletingQuestionsIds: currentlyDeletingQuestionsIds,
      ),
    );

    final response = await deleteFromCourseUsecase(event.params);
    response.fold(
      (l) {
        currentlyDeletingQuestionsIds = List.of(
          state.currentlyDeletingQuestionsIds,
        );
        currentlyDeletingQuestionsIds.remove(event.params.id);
        emit(
          state.copyWith(
            deleteFromLectureTransaction: Status.failure,
            errorMessage: l.message,
            currentlyDeletingQuestionsIds: currentlyDeletingQuestionsIds,
          ),
        );
      },
      (r) {
        currentlyDeletingQuestionsIds = List.of(
          state.currentlyDeletingQuestionsIds,
        );
        currentlyDeletingQuestionsIds.remove(event.params.id);
        GetIt.I<CoursesBloc>().add(
          RemoveQuestionFromLecture(questionId: event.params.id),
        );
        emit(
          state.copyWith(
            deleteFromLectureTransaction: Status.loaded,
            currentlyDeletingQuestionsIds: currentlyDeletingQuestionsIds,
          ),
        );
      },
    );
  }

  FutureOr<void> _onDeleteFromLectureEvent(
    DeleteFromLectureEvent event,
    Emitter<CourseContentManagementState> emit,
  ) async {
    emit(state.copyWith(upsertLecture: Status.loading));

    final response = await deleteFromCourseUsecase(event.params);
    response.fold(
      (l) {
        emit(
          state.copyWith(
            upsertLecture: Status.failure,
            errorMessage: l.message,
          ),
        );
      },
      (r) {
        emit(state.copyWith(upsertLecture: Status.loaded));
      },
    );
  }
}
