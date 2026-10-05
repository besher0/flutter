part of 'course_content_management_bloc.dart';

class CourseContentManagementState {
  final Status getAllowedSubjects,
      createCourse,
      upsertLecture,
      upsertVideoSegment,
      upsertCourse,
      deleteFromCourseTransaction,
      deleteFromLectureTransaction,
      getAllSeasons;
  final GetAllowedSubjectsResponseModel? getAllowedSubjectsResponseModel;

  final String errorMessage;
  final List<SeasonsModel> seasons;
  final List<Segment> videoSegments;
  final Map<String, double> uploadingProgress;
  final XFile? currentlyUploadingFile;
  final List<String> currentlyDeletingQuestionsIds;

  CourseContentManagementState({
    this.getAllowedSubjects = Status.init,
    this.createCourse = Status.init,
    this.upsertVideoSegment = Status.init,
    this.upsertLecture = Status.init,
    this.upsertCourse = Status.init,
    this.getAllSeasons = Status.init,
    this.deleteFromLectureTransaction = Status.init,
    this.deleteFromCourseTransaction = Status.init,
    this.getAllowedSubjectsResponseModel,
    this.errorMessage = '',
    this.seasons = const [],
    this.videoSegments = const [],
    this.currentlyDeletingQuestionsIds = const [],
    this.uploadingProgress = const {},
    this.currentlyUploadingFile,
  });

  CourseContentManagementState copyWith({
    final Status? getAllowedSubjects,
    final Status? createCourse,
    upsertLecture,
    upsertCourse,
    upsertVideoSegment,
    deleteFromCourseTransaction,
    deleteFromLectureTransaction,
    getAllSeasons,
    final GetAllowedSubjectsResponseModel? getAllowedSubjectsResponseModel,
    final String? errorMessage,
    final List<SeasonsModel>? seasons,
    final List<Segment>? videoSegments,
    final Map<String, double>? uploadingProgress,
    final XFile? currentlyUploadingFile,
    final List<String>? currentlyDeletingQuestionsIds,
    bool resetCurrentlyUploadingFile = false,
  }) {
    return CourseContentManagementState(
      getAllowedSubjects: getAllowedSubjects ?? this.getAllowedSubjects,
      createCourse: createCourse ?? this.createCourse,
      errorMessage: errorMessage ?? this.errorMessage,
      upsertVideoSegment: upsertVideoSegment ?? this.upsertVideoSegment,
      seasons: seasons ?? this.seasons,
      videoSegments: videoSegments ?? this.videoSegments,
      upsertLecture: upsertLecture ?? this.upsertLecture,
      upsertCourse: upsertCourse ?? this.upsertCourse,
      getAllSeasons: getAllSeasons ?? this.getAllSeasons,
      currentlyDeletingQuestionsIds:
          currentlyDeletingQuestionsIds ?? this.currentlyDeletingQuestionsIds,
      currentlyUploadingFile: resetCurrentlyUploadingFile
          ? null
          : (currentlyUploadingFile ?? this.currentlyUploadingFile),
      uploadingProgress: uploadingProgress ?? this.uploadingProgress,
      deleteFromCourseTransaction:
          deleteFromCourseTransaction ?? this.deleteFromCourseTransaction,
      deleteFromLectureTransaction:
          deleteFromLectureTransaction ?? this.deleteFromLectureTransaction,
      getAllowedSubjectsResponseModel:
          getAllowedSubjectsResponseModel ??
          this.getAllowedSubjectsResponseModel,
    );
  }
}
