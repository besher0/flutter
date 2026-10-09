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

  ValueNotifier<bool> uploadCompleted = ValueNotifier(false);

  Future<bool> _uploadVideoUsingTusForCourse({required XFile video}) async {
    final path = video.path;
    Map<String, double> progresses = Map.of(state.uploadingProgress);
    if (!progresses.containsKey(path)) {
      progresses[path] = 0;
      emit(state.copyWith(uploadingProgress: progresses));
    }
    // Shared across uploads; a previous success must not mark this one done.
    uploadCompleted.value = false;
    if (tuscInitResponse[path] == null) {
      var response;
      try {
        response = await Dio(
          BaseOptions(
            contentType: 'application/json',
            responseType: ResponseType.json,
            headers: {
              HttpHeaders.authorizationHeader:
                  "Bearer ${GetIt.I<PrefsRepository>().token}",
              HttpHeaders.acceptHeader: 'application/json',
            },
          ),
        ).post(MasterUrlRoutes.baseUrl + EndPoints.initTusEp);
      } catch (e, st) {
        log(e.toString());
        log(st.toString());
      }
      if (response == null || response.statusCode != 201) {
        return false;
      }
      tuscInitResponse[path] = TusInitResponseModel.fromJson(response.data);
    }
    if (tuscClients[path] == null) {
      tuscClients[path] = TusClient(
        url: BunnyUrlRoutes.baseUrl + BunnyEndPoints.uploadVideoTusEP,

        /// Required
        file: video,

        cache: TusPersistentCache(directory.path),

        headers: tuscInitResponse[path]!.upload!.headers!.toJson(),
      );
    }
    if ((await tuscClients[path]!.canResume())) {
      print('can resumeeeeeee ${tuscClients[path]!.resumingEnabled}');
      try {
        await tuscClients[path]!.resumeUpload();
      } catch (e) {
        print(e.toString());
        return false;
      }
    } else {
      try {
        await tuscClients[path]!.startUpload(
          onProgress: (count, total, progress) {
            Map<String, double> progresses = Map.of(state.uploadingProgress);
            progresses[path] = (count / total * 100);
            emit(state.copyWith(uploadingProgress: progresses));
            print(
              'Progress: $count of $total | ${(count / total * 100).toInt()}%',
            );
          },

          /// response: the http response of the last chunkSize uploaded
          onComplete: (response) {
            print('uploadCompleted');
            uploadCompleted.value = true;
          },
          onTimeout: () {
            print('Upload timed out');
            uploadingVideos[path] = null;
          },
          onError: (error) {
            print(error.toString());
            uploadingVideos[path] = null;
          },
        );
      } catch (e, st) {
        print(e);
        print(st);
        uploadingVideos[path] = null;
      }
    }
    print('uploadCompleted ${uploadCompleted.value}');
    if (uploadCompleted.value) {
      await Dio(
            BaseOptions(
              contentType: 'application/json',
              responseType: ResponseType.json,
              headers: {
                HttpHeaders.authorizationHeader:
                    "Bearer ${GetIt.I<PrefsRepository>().token}",
                HttpHeaders.acceptHeader: 'application/json',
              },
            ),
          )
          .post(
            MasterUrlRoutes.baseUrl + EndPoints.completeTusEp,
            data: {"videoId": tuscInitResponse[path]!.upload!.videoId},
          )
          .then((response) {
            log(response.data.toString());
            log(response.headers.toString());
            uploadingVideos[path] = UploadVideoResponseModel.fromJson(
              response.data,
            );
          })
          .catchError((error) {
            print('error $error');
          })
          .onError((e, st) {
            print('e $e');
            print('st $st');
          });
    }
    return uploadingVideos[path] != null;
  }

  void cancelVideoUpload({required XFile video}) {
    final path = video.path;
    if (tuscClients[path] == null) {
      return;
    }
    uploadingVideos[path] = null;
    tuscInitResponse[path] = null;
    tuscClients[path]!.cancelUpload();
  }

  FutureOr<void> _onUpsertVideoEvent(
    UpsertVideoEvent event,
    Emitter<CourseContentManagementState> emit,
  ) async {
    upsertVideoParams = event.params;
    bool success = true;
    emit(state.copyWith(upsertLecture: Status.loading));
    if (state.currentlyUploadingFile != null) {
      success = await _uploadVideoUsingTusForCourse(
        video: state.currentlyUploadingFile!,
      );
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
          errorMessage: "حدث خطأ ما , تحقق من الاتصال بالانترنت",
          upsertLecture: Status.failure,
          uploadingProgress: progresses,
          resetCurrentlyUploadingFile: success,
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
