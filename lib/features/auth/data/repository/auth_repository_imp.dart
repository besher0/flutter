import 'package:coursaty_student_and_teacher/core/api/api.dart';
import 'package:coursaty_student_and_teacher/core/error/failures.dart';
import 'package:coursaty_student_and_teacher/features/auth/data/model/academic_years_model.dart';
import 'package:coursaty_student_and_teacher/features/auth/data/model/colleges_model.dart';
import 'package:coursaty_student_and_teacher/features/auth/data/model/departments_model.dart';
import 'package:coursaty_student_and_teacher/features/auth/data/model/profile_model.dart';
import 'package:coursaty_student_and_teacher/features/auth/data/model/universities_model.dart';
import 'package:coursaty_student_and_teacher/features/auth/domain/use_case/change_password_usecase.dart';
import 'package:coursaty_student_and_teacher/features/auth/domain/use_case/edit_profile_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repository/auth_repository.dart';
import '../model/auth_model.dart';
import '../model/guest_account_model.dart';
import '../sources/auth_remote_data_source.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImp extends AuthRepository with HandlingExceptionRequest {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImp(this.remoteDataSource);

  @override
  Future<Either<Failure, AuthModel>> logIn(Map<String, dynamic> data) =>
      handlingExceptionRequest(tryCall: () => remoteDataSource.logIn(data));

  @override
  Future<Either<Failure, AuthModel>> signUp(Map<String, dynamic> data) =>
      handlingExceptionRequest(tryCall: () => remoteDataSource.signUp(data));

  @override
  Future<Either<Failure, String>> createStudent(Map<String, dynamic> data) =>
      handlingExceptionRequest(
        tryCall: () => remoteDataSource.createStudent(data),
      );

  @override
  Future<Either<Failure, String>> createTeacher(Map<String, dynamic> data) =>
      handlingExceptionRequest(
        tryCall: () => remoteDataSource.createTeacher(data),
      );

  @override
  Future<Either<Failure, List<AcademicYearsResponseModel>>> getAcademicYears(
    String collegeId,
  ) => handlingExceptionRequest(
    tryCall: () => remoteDataSource.getAcademicYears(collegeId),
  );

  @override
  Future<Either<Failure, List<CollegesResponseModel>>> getColleges(
    String? universityId,
  ) => handlingExceptionRequest(
    tryCall: () => remoteDataSource.getColleges(universityId),
  );

  @override
  Future<Either<Failure, List<DepartmentsResponseModel>>> getDepartments(
    String collegeId,
  ) => handlingExceptionRequest(
    tryCall: () => remoteDataSource.getDepartments(collegeId),
  );

  @override
  Future<Either<Failure, List<UniversitiesResponseModel>>> getUniversities() =>
      handlingExceptionRequest(
        tryCall: () => remoteDataSource.getUniversities(),
      );

  @override
  Future<Either<Failure, ProfileModel>> getProfile() {
    return handlingExceptionRequest(
      tryCall: () => remoteDataSource.getProfile(),
    );
  }

  @override
  Future<Either<Failure, bool>> updateStudent(Map<String, dynamic> data) {
    return handlingExceptionRequest(
      tryCall: () => remoteDataSource.updateStudent(data),
    );
  }

  @override
  Future<Either<Failure, bool>> editProfile(UpdateProfileParams params) {
    return handlingExceptionRequest(
      tryCall: () => remoteDataSource.editProfile(params),
    );
  }

  @override
  Future<Either<Failure, GuestAccountModel>> createGuestAccount(
    Map<String, dynamic> data,
  ) {
    return handlingExceptionRequest(
      tryCall: () => remoteDataSource.createGuestAccount(data),
    );
  }

  @override
  Future<Either<Failure, GuestAccountModel>> getGuestAccount(String deviceId) {
    return handlingExceptionRequest(
      tryCall: () => remoteDataSource.getGuestAccount(deviceId),
    );
  }

  @override
  Future<Either<Failure, bool>> changePassword(ChangePasswordParams params) {
    return handlingExceptionRequest(
      tryCall: () => remoteDataSource.changePassword(params),
    );
  }

  @override
  Future<Either<Failure, bool>> deleteAccount() {
    return handlingExceptionRequest(
      tryCall: () => remoteDataSource.deleteAccount(),
    );
  }
}
