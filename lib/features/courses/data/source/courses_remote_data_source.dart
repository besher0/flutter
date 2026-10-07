import 'package:coursaty_student_and_teacher/features/courses/data/model/course_category.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_details_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_statistcis_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/get_teacher_courses_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/lecture_details_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/video_interaction_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/domain/use_case/get_lecture_details_usecase.dart';
import 'package:coursaty_student_and_teacher/features/courses/domain/use_case/get_teacher_courses_usecase.dart';
import 'package:coursaty_student_and_teacher/features/courses/domain/use_case/toggle_video_interaction_usecase.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/api/client_config.dart';
import '../../../../core/api/detect_server.dart';
import '../../../../core/api/methods/get.dart';
import '../../../../core/api/methods/post.dart';
import '../../../../core/common/constant/configuration/url_routes.dart';
import '../../domain/use_case/get_course_details_use_case.dart';
import '../../domain/use_case/get_courses_by_subject_use_case.dart';
import '../../domain/use_case/get_courses_by_year_use_case.dart';
import '../../domain/use_case/get_courses_with_filtering_usecase.dart';
import '../model/course_rating.dart';
import '../model/courses_of_subject_response_model.dart';
import '../model/resulotion_model.dart';
import '../model/teacher_course_details_model.dart';

@injectable
class CoursesRemoteDataSource {
  Future<List<CourseCategory>> getCoursesCategories() async {
    final GetClient<List<CourseCategory>> getCoursesCategories = GetClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        endpoint: EndPoints.getCoursesCategoriesEP,
        response: ResponseValue(
          fromJson: (data) => [
            CourseCategory(id: "all", name: "الكل"),
            CourseCategory(id: "popular", name: "الأكثر اشتراكاً"),
            CourseCategory(id: "free", name: "مجانية"),
            ...courseCategoryFromJson(data["categories"]),
          ],
        ),
      ),
    );
    return getCoursesCategories();
  }

  Future<bool> rateCourse(Map<String, dynamic> data) async {
    final PostClient<bool> rateCourse = PostClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        endpoint: EndPoints.rateEp,
        data: data,
        response: ResponseValue(returnValueOnSuccess: true),
      ),
    );
    return rateCourse();
  }

  Future<CourseRatingModel> getCourseRating(String id) async {
    final GetClient<CourseRatingModel> getCourseRating = GetClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        endpoint: EndPoints.getCourseRating(id: id),
        response: ResponseValue(
          fromJson: (json) => CourseRatingModel.fromJson(json),
        ),
      ),
    );
    return getCourseRating();
  }

  Future<CoursesResponseModel> getCoursesWithFiltering(
    ParamGetCoursesWithFilters params,
  ) async {
    final GetClient<CoursesResponseModel> getCoursesWithFiltering = GetClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        endpoint: EndPoints.getCoursesWithFiltering,
        queryParameters: {
          'limit': params.limit.toString(),
          'page': params.page.toString(),
          if (params.categoryId != null) ...{'categoryId': params.categoryId},
          if (params.filter != null) ...{'filter': params.filter},
        },
        response: ResponseValue(
          fromJson: (data) => CoursesResponseModel.fromJson(data),
        ),
      ),
    );
    return getCoursesWithFiltering();
  }

  Future<TeacherCoursesResponseModel> getTeacherCourses(
    GetTeacherCoursesParams params,
  ) async {
    final GetClient<TeacherCoursesResponseModel> getTeacherCourses = GetClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        endpoint: EndPoints.getTeacherCoursesEP(getActive: params.getActive),
        queryParameters: {
          'limit': params.limit.toString(),
          'page': params.page.toString(),
        },
        response: ResponseValue(
          fromJson: (data) => TeacherCoursesResponseModel.fromJson(data),
        ),
      ),
    );
    return getTeacherCourses();
  }

  Future<CourseDetailsModel> getCourseDetails(
    ParamGetCourseDetails param,
  ) async {
    final GetClient<CourseDetailsModel> getCourseDetails = GetClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        endpoint: EndPoints.getCourseDetails(id: param.courseId),
        response: ResponseValue(
          fromJson: (data) => CourseDetailsModel.fromJson(data),
        ),
      ),
    );
    return getCourseDetails();
  }

  Future<TeacherCourseDetailsResponseModel> getTeacherCourseDetails(
    ParamGetCourseDetails param,
  ) async {
    final GetClient<TeacherCourseDetailsResponseModel> getTeacherCourseDetails =
        GetClient(
          serverName: ServerName.master,
          requestPrams: RequestConfig(
            endpoint: EndPoints.getCourseDetails(id: param.courseId),
            response: ResponseValue(
              fromJson: (data) =>
                  TeacherCourseDetailsResponseModel.fromJson(data),
            ),
          ),
        );
    return getTeacherCourseDetails();
  }

  Future<List<ResolutionModel>> getVideoResolutions(String videoId) async {
    final GetClient<List<ResolutionModel>> getVideoResolutions = GetClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        endpoint: EndPoints.getVideoResolutions(id: videoId),
        response: ResponseValue(
          fromJson: (data) => resolutionModelFromJson(
            data["playlistResolutions"] ??
                data["availableResolutions"] ??
                data["mp4Resolutions"] ??
                const [],
          ),
        ),
      ),
    );
    return getVideoResolutions();
  }

  Future<CourseStatisticsModel> getCourseStatistics(
    ParamGetCourseDetails param,
  ) async {
    final GetClient<CourseStatisticsModel> getCourseStatistics = GetClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        endpoint: EndPoints.getCourseStatistics(id: param.courseId),
        response: ResponseValue(
          fromJson: (data) => CourseStatisticsModel.fromJson(data),
        ),
      ),
    );
    return getCourseStatistics();
  }

  Future<bool> toggleVideoInteraction(
    ToggleVideoInteractionParams params,
  ) async {
    final PostClient<bool> toggleVideoInteraction = PostClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        endpoint: EndPoints.createVideoLikeEP,
        data: params.data,
        response: ResponseValue(returnValueOnSuccess: true),
      ),
    );
    return toggleVideoInteraction();
  }

  Future<VideoInteractionModel> getVideoInteractions(String id) async {
    final GetClient<VideoInteractionModel> getVideoInteractions = GetClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        endpoint: EndPoints.getVideoLikes(id: id),
        response: ResponseValue(
          fromJson: (data) => VideoInteractionModel.fromJson(data),
        ),
      ),
    );
    return getVideoInteractions();
  }

  Future<LectureDetailsModel> getLectureDetails(
    GetLectureDetailsParams param,
  ) async {
    final GetClient<LectureDetailsModel> getLectureDetails = GetClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        endpoint: EndPoints.getLectureDetails(id: param.lectureId),
        response: ResponseValue(
          fromJson: (data) => LectureDetailsModel.fromJson(data),
        ),
      ),
    );
    return getLectureDetails();
  }

  Future<List<CourseModel>> getCoursesByYear(
    ParamGetCoursesByYear param,
  ) async {
    final GetClient<List<CourseModel>> getCoursesByYear = GetClient(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        queryParameters: {
          "page": param.page.toString(),
          "limit": param.limit.toString(),
        },
        endpoint: EndPoints.getCourseByYear(id: param.yearId),
        response: ResponseValue(fromJson: (data) => coursesListFromJson(data)),
      ),
    );
    return getCoursesByYear();
  }

  Future<CoursesOfSubjectResponseModel> getCoursesBySubject(
    ParamGetCoursesBySubject params,
  ) async {
    final GetClient<CoursesOfSubjectResponseModel> getCoursesBySubject =
        GetClient(
          serverName: ServerName.master,
          requestPrams: RequestConfig(
            endpoint: EndPoints.getCourseBySubject(id: params.subjectId),
            queryParameters: {
              "page": params.page.toString(),
              "limit": params.limit.toString(),
            },
            response: ResponseValue(
              fromJson: (data) => CoursesOfSubjectResponseModel.fromJson(data),
            ),
          ),
        );
    return getCoursesBySubject();
  }
}
