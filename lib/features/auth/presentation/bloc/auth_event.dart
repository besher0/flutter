part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class SignUpEvent extends AuthEvent {
  final ParamSignUp params;

  SignUpEvent({required this.params});
}

class LogInEvent extends AuthEvent {
  final ParamLogIn params;

  LogInEvent({required this.params});
}

class ChangePasswordEvent extends AuthEvent {
  final ChangePasswordParams params;

  ChangePasswordEvent({required this.params});
}

class UpdateStudentEvent extends AuthEvent {
  final UpdateStudentParams params;

  UpdateStudentEvent({required this.params});
}

class GetUniversitiesEvent extends AuthEvent {}

class GetProfileEvent extends AuthEvent {}

class GetCollegesEvent extends AuthEvent {
  final String? universityId;

  GetCollegesEvent({this.universityId});
}

class GetDepartmentsEvent extends AuthEvent {
  final String collegeId;

  GetDepartmentsEvent({required this.collegeId});
}

class GetAcademicYearsEvent extends AuthEvent {
  final String collegeId;

  GetAcademicYearsEvent({required this.collegeId});
}

class UpdateProfileEvent extends AuthEvent {
  final UpdateProfileParams params;
  final XFile? image;

  UpdateProfileEvent({required this.params, this.image});
}

class ClearAuthState extends AuthEvent {}

class CreateGuestEvent extends AuthEvent {
  final CreateGuestAccountParams params;

  CreateGuestEvent({required this.params});
}

class GetGuestEvent extends AuthEvent {}

class DeleteAccountEvent extends AuthEvent {}
