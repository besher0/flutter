import 'package:coursaty_student_and_teacher/features/auth/data/model/academic_years_model.dart';
import 'package:coursaty_student_and_teacher/features/auth/data/model/colleges_model.dart';
import 'package:coursaty_student_and_teacher/features/auth/data/model/departments_model.dart';
import 'package:coursaty_student_and_teacher/features/auth/data/model/guest_account_model.dart';
import 'package:coursaty_student_and_teacher/features/auth/data/model/universities_model.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../data/model/auth_model.dart';
import '../../data/model/profile_model.dart';
import '../use_case/change_password_usecase.dart';
import '../use_case/edit_profile_usecase.dart';

abstract class AuthRepository {
  Future<Either<Failure, ProfileModel>> getProfile();

  Future<Either<Failure, bool>> deleteAccount();
  Future<Either<Failure, bool>> editProfile(UpdateProfileParams params);
  Future<Either<Failure, bool>> changePassword(ChangePasswordParams params);

  Future<Either<Failure, AuthModel>> signUp(Map<String, dynamic> data);

  Future<Either<Failure, AuthModel>> logIn(Map<String, dynamic> data);

  Future<Either<Failure, String>> createStudent(Map<String, dynamic> data);

  Future<Either<Failure, bool>> updateStudent(Map<String, dynamic> data);

  Future<Either<Failure, String>> createTeacher(Map<String, dynamic> data);

  Future<Either<Failure, GuestAccountModel>> createGuestAccount(
    Map<String, dynamic> data,
  );

  Future<Either<Failure, List<UniversitiesResponseModel>>> getUniversities();

  Future<Either<Failure, GuestAccountModel>> getGuestAccount(String deviceId);

  Future<Either<Failure, List<CollegesResponseModel>>> getColleges(
    String? universityId,
  );

  Future<Either<Failure, List<DepartmentsResponseModel>>> getDepartments(
    String collegeId,
  );

  Future<Either<Failure, List<AcademicYearsResponseModel>>> getAcademicYears(
    String collegeId,
  );
}
