import 'package:coursaty_student_and_teacher/features/courses/data/model/course_model.dart';
import 'package:coursaty_student_and_teacher/features/home/data/models/filtered_subjects_response_model.dart';
import 'package:coursaty_student_and_teacher/features/home/data/models/home_response_model.dart';
import 'package:coursaty_student_and_teacher/features/home/data/models/teacher_summary_response_model.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/api/client_config.dart';
import '../../../../core/api/detect_server.dart';
import '../../../../core/api/methods/get.dart';
import '../../../../core/common/constant/configuration/url_routes.dart';
import '../../domain/usecases/search_usecase.dart';
import '../models/advertisement_model.dart';
import '../models/search_response_model.dart';

@injectable
class HomeRemoteDatasource {
  Future<List<Advertisement>> getAdvertisements() async {
    final GetClient<List<Advertisement>> getAdvertisements = GetClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        endpoint: EndPoints.getAdvertisementsEp,
        response: ResponseValue(
          fromJson: (data) => advertisementFromJson(data),
        ),
      ),
    );
    return getAdvertisements();
  }

  Future<HomeResponseModel> getHomeContent(int limit) async {
    final GetClient<HomeResponseModel> getHomeContent = GetClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        endpoint: EndPoints.getHomeContentEp,
        queryParameters: {"limit": limit.toString()},
        response: ResponseValue(
          fromJson: (data) => HomeResponseModel.fromJson(data),
        ),
      ),
    );
    return getHomeContent();
  }

  Future<SearchResponseModel> search(SearchParams params) async {
    final GetClient<SearchResponseModel> getHomeContent = GetClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        endpoint: EndPoints.search,
        queryParameters: params.map,
        response: ResponseValue(
          fromJson: (data) => SearchResponseModel.fromJson(data),
        ),
      ),
    );
    return getHomeContent();
  }

  Future<List<Program>> getAllPrograms(Map<String, dynamic> data) async {
    final GetClient<List<Program>> getAllPrograms = GetClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        endpoint: EndPoints.getAllProgramsEP,
        queryParameters: data,
        response: ResponseValue(
          fromJson: (data) => List<Program>.from(
            data["programs"].map((x) => Program.fromJson(x)),
          ),
        ),
      ),
    );
    return getAllPrograms();
  }

  Future<List<CourseModel>> getMyCourses(bool getActive) async {
    final GetClient<List<CourseModel>> getMyCourses = GetClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        endpoint: getActive
            ? EndPoints.getMyActiveCourses
            : EndPoints.getMyInActiveCourses,
        response: ResponseValue(
          fromJson: (data) => coursesListFromJson(data['courses']),
        ),
      ),
    );
    return getMyCourses();
  }

  Future<TeacherSummaryResponseModel> getTeacherSummary() async {
    final GetClient<TeacherSummaryResponseModel> getTeacherSummary = GetClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        endpoint: EndPoints.getTeacherSummaryEp,
        response: ResponseValue(
          fromJson: (data) => TeacherSummaryResponseModel.fromJson(data),
        ),
      ),
    );
    return getTeacherSummary();
  }

  Future<StudentSubjectsModel> getSubjectsWithFiltering(
    String collegeYearId,
  ) async {
    final GetClient<StudentSubjectsModel> getSubjectsWithFiltering = GetClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        endpoint: EndPoints.getFilteredSubjectsEP,
        // queryParameters: {"collegeYearId": collegeYearId.toString()},
        response: ResponseValue(
          fromJson: (data) => StudentSubjectsModel.fromJson(data),
        ),
      ),
    );
    return getSubjectsWithFiltering();
  }
}
