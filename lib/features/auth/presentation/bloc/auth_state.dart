part of 'auth_bloc.dart';

class AuthState {
  final Status changePassword;
  final Status updateStudent;
  final Status profileStatus;
  final Status updateProfileStatus;
  final Status authStatus;
  final Status getUniversities;
  final Status getColleges;
  final Status getDepartments;
  final Status getYears;
  final Status createUser; // student or teacher
  final AuthModel? authModel;
  final ProfileModel? profileModel;
  final String errorMessage;
  final Status getOrCreateGuest;
  final GuestAccountModel? guestAccountModel;
  final bool isNotFoundGuestError;
  final Failure? failure;

  final List<UniversitiesResponseModel>? universitiesResponseModel;
  final List<CollegesResponseModel>? collegesResponseModel;
  final List<DepartmentsResponseModel>? departmentsResponseModel;
  final List<AcademicYearsResponseModel>? academicYearsResponseModel;

  AuthState({
    this.changePassword = Status.init,
    this.getOrCreateGuest = Status.init,
    this.updateProfileStatus = Status.init,
    this.updateStudent = Status.init,
    this.profileStatus = Status.init,
    this.authStatus = Status.init,

    this.createUser = Status.init,
    this.getUniversities = Status.init,
    this.getDepartments = Status.init,
    this.getColleges = Status.init,
    this.getYears = Status.init,
    this.profileModel,
    this.authModel,
    this.failure,
    this.errorMessage = '',
    this.universitiesResponseModel,
    this.collegesResponseModel,
    this.departmentsResponseModel,
    this.academicYearsResponseModel,
    this.guestAccountModel,
    this.isNotFoundGuestError = false,
  });

  AuthState copyWith({
    final Status? changePassword,
    final Status? updateStudent,
    final Status? updateProfileStatus,
    final Status? profileStatus,
    final Status? authStatus,
    final Status? getUniversities,
    final Status? getColleges,
    final Status? getDepartments,
    final Status? getYears,
    final Status? createUser, // student or teacher
    final AuthModel? authModel,
    final ProfileModel? profileModel,
    final String? errorMessage,
    final Failure? failure,

    final List<UniversitiesResponseModel>? universitiesResponseModel,
    final List<CollegesResponseModel>? collegesResponseModel,
    final List<DepartmentsResponseModel>? departmentsResponseModel,
    final List<AcademicYearsResponseModel>? academicYearsResponseModel,
    final Status? getOrCreateGuest,
    final GuestAccountModel? guestAccountModel,
    final bool? isNotFoundGuestError,
  }) {
    return AuthState(
      changePassword: changePassword ?? this.changePassword,
      isNotFoundGuestError: isNotFoundGuestError ?? this.isNotFoundGuestError,
      guestAccountModel: guestAccountModel ?? this.guestAccountModel,
      getOrCreateGuest: getOrCreateGuest ?? this.getOrCreateGuest,
      profileStatus: profileStatus ?? this.profileStatus,
      profileModel: profileModel ?? this.profileModel,
      authModel: authModel ?? this.authModel,
      updateProfileStatus: updateProfileStatus ?? this.updateProfileStatus,
      authStatus: authStatus ?? this.authStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      createUser: createUser ?? this.createUser,
      getYears: getYears ?? this.getYears,
      failure: failure ?? this.failure,
      updateStudent: updateStudent ?? this.updateStudent,

      getDepartments: getDepartments ?? this.getDepartments,
      getUniversities: getUniversities ?? this.getUniversities,
      getColleges: getColleges ?? this.getColleges,
      universitiesResponseModel:
          universitiesResponseModel ?? this.universitiesResponseModel,
      collegesResponseModel:
          collegesResponseModel ?? this.collegesResponseModel,
      departmentsResponseModel:
          departmentsResponseModel ?? this.departmentsResponseModel,
      academicYearsResponseModel:
          academicYearsResponseModel ?? this.academicYearsResponseModel,
    );
  }
}
