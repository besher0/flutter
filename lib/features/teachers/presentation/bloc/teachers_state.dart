part of 'teachers_bloc.dart';

class TeachersState {
  final Status getMyLikedTeachers, getRevenues;
  final Status getTeachersStatus;
  final Map<String, Status> interactionsStatus;
  final String errorMessage;

  final TeachersResponseModel? teachers;

  final List<Teacher> likedTeachers;

  final PaginationModel<CourseModel> teacherCourses;
  final Teacher? teacherDetails;
  final Status affiliationsStatus;
  final List<TeacherAffiliationsResponseModel> affiliations;
  final TeacherRevenueModel? teacherRevenueModel;
  final PaginationModel<Withdrawal> withdrawalsPagination;
  final TeacherWithdrawalModel? teacherWithdrawalModel;

  TeachersState({
    this.getRevenues = Status.init,
    this.getMyLikedTeachers = Status.init,
    this.getTeachersStatus = Status.init,
    this.affiliationsStatus = Status.init,
    this.interactionsStatus = const {},
    this.errorMessage = '',
    this.teachers,
    this.teacherDetails,
    this.likedTeachers = const [],
    this.affiliations = const [],
    this.teacherCourses = const PaginationModel.init(),
    this.teacherRevenueModel,
    this.withdrawalsPagination = const PaginationModel.init(),
    this.teacherWithdrawalModel,
  });

  TeachersState copyWith({
    final Status? getMyLikedTeachers,
    final Status? getTeachersStatus,
    final Status? getRevenues,
    final Map<String, Status>? interactionsStatus,
    final String? errorMessage,

    final TeachersResponseModel? teachers,
    final TeacherRevenueModel? teacherRevenueModel,
    final PaginationModel<Withdrawal>? withdrawalsPagination,
    final TeacherWithdrawalModel? teacherWithdrawalModel,
    final List<Teacher>? likedTeachers,
    final Teacher? teacherDetails,
    final Status? affiliationsStatus,
    final List<TeacherAffiliationsResponseModel>? affiliations,
    final PaginationModel<CourseModel>? teacherCourses,
  }) => TeachersState(
    getTeachersStatus: getTeachersStatus ?? this.getTeachersStatus,
    getMyLikedTeachers: getMyLikedTeachers ?? this.getMyLikedTeachers,
    interactionsStatus: interactionsStatus ?? this.interactionsStatus,
    errorMessage: errorMessage ?? this.errorMessage,
    teachers: teachers ?? this.teachers,
    likedTeachers: likedTeachers ?? this.likedTeachers,
    teacherCourses: teacherCourses ?? this.teacherCourses,
    teacherDetails: teacherDetails ?? this.teacherDetails,
    affiliationsStatus: affiliationsStatus ?? this.affiliationsStatus,
    affiliations: affiliations ?? this.affiliations,
    getRevenues: getRevenues ?? this.getRevenues,
    teacherRevenueModel: teacherRevenueModel ?? this.teacherRevenueModel,
    withdrawalsPagination: withdrawalsPagination ?? this.withdrawalsPagination,
    teacherWithdrawalModel:
        teacherWithdrawalModel ?? this.teacherWithdrawalModel,
  );
}
