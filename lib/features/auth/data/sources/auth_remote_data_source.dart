import 'package:coursaty_student_and_teacher/core/api/methods/delete.dart';
import 'package:coursaty_student_and_teacher/core/api/methods/get.dart';
import 'package:coursaty_student_and_teacher/core/common/constant/configuration/url_routes.dart';
import 'package:coursaty_student_and_teacher/features/auth/data/model/academic_years_model.dart';
import 'package:coursaty_student_and_teacher/features/auth/data/model/colleges_model.dart';
import 'package:coursaty_student_and_teacher/features/auth/data/model/departments_model.dart';
import 'package:coursaty_student_and_teacher/features/auth/data/model/guest_account_model.dart';
import 'package:coursaty_student_and_teacher/features/auth/data/model/profile_model.dart';
import 'package:coursaty_student_and_teacher/features/auth/data/model/universities_model.dart';
import 'package:coursaty_student_and_teacher/features/auth/domain/use_case/change_password_usecase.dart';
import 'package:coursaty_student_and_teacher/features/auth/domain/use_case/edit_profile_usecase.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/api/client_config.dart';
import '../../../../core/api/detect_server.dart';
import '../../../../core/api/methods/patch.dart';
import '../../../../core/api/methods/post.dart';
import '../model/auth_model.dart';

@injectable
class AuthRemoteDataSource {
  Future<AuthModel> logIn(Map<String, dynamic> data) {
    final PostClient<AuthModel> logIn = PostClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        data: data,
        endpoint: EndPoints.loginEp,
        response: ResponseValue(fromJson: (data) => AuthModel.fromJson(data)),
      ),
    );

    return logIn();
  }

  Future<AuthModel> signUp(Map<String, dynamic> data) {
    final PostClient<AuthModel> signUp = PostClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        data: data,
        endpoint: EndPoints.signUpEP,
        response: ResponseValue(fromJson: (data) => AuthModel.fromJson(data)),
      ),
    );

    return signUp();
  }

  Future<String> createStudent(Map<String, dynamic> data) {
    final PostClient<String> createStudent = PostClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        data: data,
        endpoint: EndPoints.createStudentEp,
        response: ResponseValue(fromJson: (data) => data['id']),
      ),
    );

    return createStudent();
  }

  Future<bool> updateStudent(Map<String, dynamic> data) {
    final PatchClient<bool> updateStudent = PatchClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        data: data,
        endpoint: EndPoints.updateStudentEp,
        response: ResponseValue(fromJson: (data) => true),
      ),
    );

    return updateStudent();
  }

  Future<bool> editProfile(UpdateProfileParams params) {
    final PatchClient<bool> editProfile = PatchClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        data: params.data,
        endpoint: EndPoints.profileEP,
        response: ResponseValue(fromJson: (data) => true),
      ),
    );

    return editProfile();
  }

  Future<bool> changePassword(ChangePasswordParams params) {
    final PatchClient<bool> changePassword = PatchClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        data: params.data,
        endpoint: EndPoints.changePasswordEP,
        response: ResponseValue(returnValueOnSuccess: true),
      ),
    );

    return changePassword();
  }

  Future<bool> deleteAccount() {
    final DeleteClient<bool> deleteAccount = DeleteClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        endpoint: EndPoints.profileEP,
        response: ResponseValue(returnValueOnSuccess: true),
      ),
    );

    return deleteAccount();
  }

  Future<String> createTeacher(Map<String, dynamic> data) {
    final PostClient<String> createTeacher = PostClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        data: data,
        endpoint: EndPoints.createTeacherEp,
        response: ResponseValue(fromJson: (data) => data['id']),
      ),
    );

    return createTeacher();
  }

  Future<GuestAccountModel> createGuestAccount(Map<String, dynamic> data) {
    final PostClient<GuestAccountModel> createGuestAccount = PostClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        data: data,
        endpoint: EndPoints.guestEP,
        response: ResponseValue(
          fromJson: (data) => GuestAccountModel.fromJson(data),
        ),
      ),
    );

    return createGuestAccount();
  }

  Future<GuestAccountModel> getGuestAccount(String deviceId) {
    final PostClient<GuestAccountModel> getGuestAccount = PostClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        endpoint: "${EndPoints.guestEP}/$deviceId",
        response: ResponseValue(
          fromJson: (data) => GuestAccountModel.fromJson(data),
        ),
      ),
    );
    return getGuestAccount();
  }

  Future<List<UniversitiesResponseModel>> getUniversities() {
    final GetClient<List<UniversitiesResponseModel>> getUniversities =
        GetClient(
          serverName: ServerName.master,
          requestPrams: RequestConfig(
            endpoint: EndPoints.getUniversitiesEp,
            response: ResponseValue(
              fromJson: (data) => universitiesResponseModelFromJson(data),
            ),
          ),
        );

    return getUniversities();
  }

  Future<ProfileModel> getProfile() {
    final GetClient<ProfileModel> getProfile = GetClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        endpoint: EndPoints.profileEP,
        response: ResponseValue(
          fromJson: (data) => ProfileModel.fromJson(data),
        ),
      ),
    );

    return getProfile();
  }

  Future<List<CollegesResponseModel>> getColleges(String? universityId) {
    final GetClient<List<CollegesResponseModel>> getColleges = GetClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        endpoint: EndPoints.getCollegesEp,
        queryParameters: universityId == null
            ? null
            : {"universityId": universityId},
        response: ResponseValue(
          fromJson: (data) => collegesResponseModelFromJson(data),
        ),
      ),
    );

    return getColleges();
  }

  Future<List<DepartmentsResponseModel>> getDepartments(String collegeId) {
    final GetClient<List<DepartmentsResponseModel>> getDepartments = GetClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        endpoint: EndPoints.getDepartmentsEP,
        queryParameters: {"collegeId": collegeId},
        response: ResponseValue(
          fromJson: (data) => departmentsResponseModelFromJson(data),
        ),
      ),
    );

    return getDepartments();
  }

  Future<List<AcademicYearsResponseModel>> getAcademicYears(String collegeId) {
    final GetClient<List<AcademicYearsResponseModel>> getAcademicYears =
        GetClient(
          serverName: ServerName.master,
          requestPrams: RequestConfig(
            endpoint: EndPoints.getYearsEp,
            queryParameters: {"collegeId": collegeId},
            response: ResponseValue(
              fromJson: (data) => academicYearsResponseModelFromJson(data),
            ),
          ),
        );

    return getAcademicYears();
  }
}
