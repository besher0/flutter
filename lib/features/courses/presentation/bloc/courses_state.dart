part of 'courses_bloc.dart';

class CoursesState {
  final Status getCourseDetailsStatus;
  final Status getLectureDetails;
  final Status rateCourseOrGetCourseRateStatus;
  final Status getCoursesCategories, getResolutions, upsertVideoInteraction;

  final PaginationModel<CourseModel> coursesOfYear;
  final PaginationModel<CourseInSubjectModel> coursesOfSubject;
  final PaginationModel<YearElement> coursesWithFiltering;
  final List<CourseModel>? programCourses;
  final LectureDetailsModel? lectureDetailsModel;
  final CourseDetailsModel? courseDetailsModel;
  final String errorMessage;
  final List<CourseCategory> coursesCategories;

  final CourseRatingModel? courseRatingModel;

  final PaginationModel<UniversityElement> teacherActiveCourses;
  final PaginationModel<UniversityElement> teacherExpiredCourses;
  final Status getTeacherCourseDetails, getCourseStatistics;

  final TeacherCourseDetailsResponseModel? teacherCourseDetailsResponseModel;
  final CourseStatisticsModel? courseStatisticsModel;
  final List<ResolutionModel> resolutions;
  final VideoInteractionModel? videoInteractionModel;

  CoursesState({
    this.getLectureDetails = Status.init,
    this.rateCourseOrGetCourseRateStatus = Status.init,
    this.getCourseDetailsStatus = Status.init,
    this.getCoursesCategories = Status.init,
    this.teacherCourseDetailsResponseModel,
    this.courseStatisticsModel,
    this.getTeacherCourseDetails = Status.init,
    this.getCourseStatistics = Status.init,
    this.getResolutions = Status.init,
    this.upsertVideoInteraction = Status.init,
    this.coursesCategories = const [],
    this.programCourses = const [],
    this.resolutions = const [],
    this.teacherActiveCourses = const PaginationModel.init(),
    this.teacherExpiredCourses = const PaginationModel.init(),
    this.coursesOfYear = const PaginationModel.init(),
    this.coursesOfSubject = const PaginationModel.init(),
    this.coursesWithFiltering = const PaginationModel.init(),
    this.lectureDetailsModel,
    this.courseRatingModel,
    this.courseDetailsModel,
    this.errorMessage = '',
    this.videoInteractionModel,
  });

  CoursesState copyWith({
    final Status? getCourseDetailsStatus,
    final Status? getLectureDetails,
    final Status? rateCourseOrGetCourseRateStatus,
    final Status? getCoursesCategories,
    final Status? upsertVideoInteraction,
    final VideoInteractionModel? videoInteractionModel,
    final PaginationModel<UniversityElement>? teacherActiveCourses,
    final PaginationModel<UniversityElement>? teacherExpiredCourses,
    final PaginationModel<CourseModel>? coursesOfYear,
    final List<CourseModel>? programCourses,
    final PaginationModel<CourseInSubjectModel>? coursesOfSubject,
    final PaginationModel<YearElement>? coursesWithFiltering,
    final LectureDetailsModel? lectureDetailsModel,
    final CourseDetailsModel? courseDetailsModel,
    final String? errorMessage,
    final List<CourseCategory>? coursesCategories,
    final CourseRatingModel? courseRatingModel,
    final TeacherCourseDetailsResponseModel? teacherCourseDetailsResponseModel,
    final CourseStatisticsModel? courseStatisticsModel,
    final Status? getTeacherCourseDetails,
    getCourseStatistics,
    getResolutions,
    final List<ResolutionModel>? resolutions,
    bool resetCourse = false,
    bool resetLecture = false,
  }) => CoursesState(
    getCourseDetailsStatus:
        getCourseDetailsStatus ?? this.getCourseDetailsStatus,
    getCourseStatistics: getCourseStatistics ?? this.getCourseStatistics,
    getTeacherCourseDetails:
        getTeacherCourseDetails ?? this.getTeacherCourseDetails,
    teacherCourseDetailsResponseModel:
        teacherCourseDetailsResponseModel ??
        this.teacherCourseDetailsResponseModel,
    courseStatisticsModel: courseStatisticsModel ?? this.courseStatisticsModel,
    coursesOfSubject: coursesOfSubject ?? this.coursesOfSubject,
    courseRatingModel: resetCourse
        ? null
        : courseRatingModel ?? this.courseRatingModel,
    courseDetailsModel: resetCourse
        ? null
        : courseDetailsModel ?? this.courseDetailsModel,
    getResolutions: getResolutions ?? this.getResolutions,
    programCourses: programCourses ?? this.programCourses,
    resolutions: resolutions ?? this.resolutions,
    rateCourseOrGetCourseRateStatus:
        rateCourseOrGetCourseRateStatus ?? this.rateCourseOrGetCourseRateStatus,
    getLectureDetails: getLectureDetails ?? this.getLectureDetails,
    videoInteractionModel: videoInteractionModel ?? this.videoInteractionModel,
    upsertVideoInteraction:
        upsertVideoInteraction ?? this.upsertVideoInteraction,
    coursesWithFiltering: coursesWithFiltering ?? this.coursesWithFiltering,
    lectureDetailsModel: resetLecture
        ? null
        : lectureDetailsModel ?? this.lectureDetailsModel,
    coursesCategories: coursesCategories ?? this.coursesCategories,
    getCoursesCategories: getCoursesCategories ?? this.getCoursesCategories,
    coursesOfYear: coursesOfYear ?? this.coursesOfYear,
    errorMessage: errorMessage ?? this.errorMessage,
    teacherActiveCourses: teacherActiveCourses ?? this.teacherActiveCourses,
    teacherExpiredCourses: teacherExpiredCourses ?? this.teacherExpiredCourses,
  );
}
