part of 'home_bloc.dart';

class HomeState {
  final Status getSubjectsWithFiltering;
  final Status getHomeContent;
  final Status getAdvertisements;
  final Status getActiveCourses;
  final Status getInActiveCourses;
  final List<Advertisement> advertisements;
  final String errorMessage;
  final HomeResponseModel? homeResponseModel;
  final StudentSubjectsModel? studentSubjectsModel;

  final List<CourseModel> activeCourses;
  final List<CourseModel> inActiveCourses;
  final bool isDeleting;
  final PaginationModel<Program> allPrograms;

  // teacher
  final Status getTeacherSummary;
  final TeacherSummaryResponseModel? teacherSummaryResponseModel;
  final int counterToForceUpdate;

  final PaginationModel<CourseModel> courses;

  final List<Teacher> teachers;
  final List<SubjectModel> subjects, programs;
  final int? newPageInHome;

  HomeState({
    this.errorMessage = '',
    this.advertisements = const [],
    this.activeCourses = const [],
    this.inActiveCourses = const [],
    this.getAdvertisements = Status.init,
    this.getHomeContent = Status.init,
    this.getSubjectsWithFiltering = Status.init,
    this.homeResponseModel,
    this.getActiveCourses = Status.init,
    this.getInActiveCourses = Status.init,
    this.getTeacherSummary = Status.init,
    this.studentSubjectsModel,
    this.teacherSummaryResponseModel,
    this.isDeleting = false,
    this.counterToForceUpdate = 0,
    this.allPrograms = const PaginationModel.init(),
    this.courses = const PaginationModel.init(),
    this.teachers = const [],
    this.subjects = const [],
    this.programs = const [],
    this.newPageInHome,
  });

  HomeState copyWith({
    final Status? getHomeContent,
    final Status? getAdvertisements,
    final Status? getSubjectsWithFiltering,
    final Status? getActiveCourses,
    final Status? getInActiveCourses,
    final List<Advertisement>? advertisements,
    final String? errorMessage,
    final HomeResponseModel? homeResponseModel,
    final StudentSubjectsModel? studentSubjectsModel,
    final List<CourseModel>? activeCourses,
    final bool? isDeleting,
    final List<CourseModel>? inActiveCourses,
    final Status? getTeacherSummary,
    final TeacherSummaryResponseModel? teacherSummaryResponseModel,
    final int? counterToForceUpdate,
    final PaginationModel<Program>? allPrograms,
    final PaginationModel<CourseModel>? courses,
    final List<Teacher>? teachers,
    final List<SubjectModel>? subjects,
    final List<SubjectModel>? programs,
    final int? newPageInHome,
  }) {
    return HomeState(
      courses: courses ?? this.courses,
      newPageInHome: newPageInHome ?? this.newPageInHome,
      subjects: subjects ?? this.subjects,
      teachers: teachers ?? this.teachers,
      programs: programs ?? this.programs,
      allPrograms: allPrograms ?? this.allPrograms,
      errorMessage: errorMessage ?? this.errorMessage,
      getTeacherSummary: getTeacherSummary ?? this.getTeacherSummary,
      teacherSummaryResponseModel:
          teacherSummaryResponseModel ?? this.teacherSummaryResponseModel,
      isDeleting: isDeleting ?? this.isDeleting,
      getAdvertisements: getAdvertisements ?? this.getAdvertisements,
      getSubjectsWithFiltering:
          getSubjectsWithFiltering ?? this.getSubjectsWithFiltering,
      advertisements: advertisements ?? this.advertisements,
      getHomeContent: getHomeContent ?? this.getHomeContent,
      homeResponseModel: homeResponseModel ?? this.homeResponseModel,
      getActiveCourses: getActiveCourses ?? this.getActiveCourses,
      getInActiveCourses: getInActiveCourses ?? this.getInActiveCourses,
      activeCourses: activeCourses ?? this.activeCourses,
      inActiveCourses: inActiveCourses ?? this.inActiveCourses,
      studentSubjectsModel: studentSubjectsModel ?? this.studentSubjectsModel,
      counterToForceUpdate: counterToForceUpdate ?? this.counterToForceUpdate,
    );
  }
}
