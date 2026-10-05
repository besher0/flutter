import 'package:coursaty_student_and_teacher/core/api/client_config.dart';
import 'package:coursaty_student_and_teacher/core/api/methods/delete.dart';
import 'package:coursaty_student_and_teacher/core/api/methods/get.dart';
import 'package:coursaty_student_and_teacher/core/api/methods/post.dart';
import 'package:coursaty_student_and_teacher/core/common/constant/configuration/url_routes.dart';
import 'package:coursaty_student_and_teacher/features/teachers/data/model/teacher_affilations_model.dart';
import 'package:coursaty_student_and_teacher/features/teachers/data/model/teacher_details_model.dart';
import 'package:coursaty_student_and_teacher/features/teachers/data/model/teacher_model.dart';
import 'package:coursaty_student_and_teacher/features/teachers/data/model/teacher_revenue_model.dart';
import 'package:coursaty_student_and_teacher/features/teachers/data/model/teacher_withdrawal_model.dart';
import 'package:coursaty_student_and_teacher/features/teachers/domain/use_case/add_or_remove_affiliations_usecase.dart';
import 'package:injectable/injectable.dart';

@injectable
class TeachersRemoteDataSource {
  Future<TeachersResponseModel> getTeachers() async {
    final GetClient<TeachersResponseModel> getTeachers = GetClient(
      requestPrams: RequestConfig(
        endpoint: EndPoints.getTeachersEP,
        response: ResponseValue(
          fromJson: (data) => TeachersResponseModel.fromJson(data),
        ),
      ),
    );

    return getTeachers();
  }

  Future<List<Teacher>> getLikedTeachers() async {
    final GetClient<List<Teacher>> getLikedTeachers = GetClient(
      requestPrams: RequestConfig(
        endpoint: EndPoints.getLikedTeachersEP,
        response: ResponseValue(
          fromJson: (data) => teachersListFromJson(data['teachers']),
        ),
      ),
    );

    return getLikedTeachers();
  }

  Future<List<TeacherAffiliationsResponseModel>>
  getTeacherAffiliations() async {
    final GetClient<List<TeacherAffiliationsResponseModel>>
    getTeacherAffiliations = GetClient(
      requestPrams: RequestConfig(
        endpoint: EndPoints.getTeacherAffiliations,
        response: ResponseValue(
          fromJson: (data) => teacherAffilationsResponseModelFromJson(data),
        ),
      ),
    );

    return getTeacherAffiliations();
  }

  Future<TeacherRevenueModel> getRevenue() async {
    final GetClient<TeacherRevenueModel> getRevenue = GetClient(
      requestPrams: RequestConfig(
        endpoint: EndPoints.getTeacherRevenues,
        response: ResponseValue(
          fromJson: (data) => TeacherRevenueModel.fromJson(data),
        ),
      ),
    );

    return getRevenue();
  }

  Future<TeacherWithdrawalModel> getTeacherWithdrawals(
    Map<String, dynamic> data,
  ) async {
    final GetClient<TeacherWithdrawalModel> getTeacherWithdrawals = GetClient(
      requestPrams: RequestConfig(
        endpoint: EndPoints.getTeacherWithdrawals,
        queryParameters: data,
        response: ResponseValue(
          fromJson: (data) => TeacherWithdrawalModel.fromJson(data),
        ),
      ),
    );

    return getTeacherWithdrawals();
  }

  Future<bool> addOrRemoveAffiliations(
    AddOrRemoveAffiliationsParams data,
  ) async {
    final PostClient<bool> addOrRemoveAffiliations = PostClient(
      requestPrams: RequestConfig(
        endpoint:
            "${EndPoints.getTeacherAffiliations}${data.isForDelete ? "/remove" : ""}",
        data: data.data,
        response: ResponseValue(returnValueOnSuccess: true),
      ),
    );

    return addOrRemoveAffiliations();
  }

  Future<bool> likeTeacher(Map<String, dynamic> data) async {
    final PostClient<bool> likeTeacher = PostClient(
      requestPrams: RequestConfig(
        endpoint: EndPoints.likeTeacherEp,
        data: data,
        response: ResponseValue(returnValueOnSuccess: true),
      ),
    );

    return likeTeacher();
  }

  Future<bool> unLikeTeacher(Map<String, dynamic> data) async {
    final DeleteClient<bool> unLikeTeacher = DeleteClient(
      requestPrams: RequestConfig(
        endpoint: EndPoints.likeTeacherEp,
        data: data,
        response: ResponseValue(returnValueOnSuccess: true),
      ),
    );

    return unLikeTeacher();
  }

  Future<TeacherDetailsResponseModel> getTeacherDetails(
    Map<String, dynamic> data,
  ) async {
    final GetClient<TeacherDetailsResponseModel> getTeacherDetails = GetClient(
      requestPrams: RequestConfig(
        endpoint: EndPoints.getTeacherDetails(id: data['id']),
        queryParameters: data,
        response: ResponseValue(
          fromJson: (data) => TeacherDetailsResponseModel.fromJson(data),
        ),
      ),
    );

    return getTeacherDetails();
  }
}
