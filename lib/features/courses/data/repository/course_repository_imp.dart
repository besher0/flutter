import 'package:coursaty_student_and_teacher/core/api/api.dart';
import 'package:coursaty_student_and_teacher/core/error/failures.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_category.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_statistcis_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/get_teacher_courses_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/lecture_details_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/video_interaction_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/domain/use_case/get_courses_with_filtering_usecase.dart';
import 'package:coursaty_student_and_teacher/features/courses/domain/use_case/get_lecture_details_usecase.dart';
import 'package:coursaty_student_and_teacher/features/courses/domain/use_case/get_teacher_courses_usecase.dart';
import 'package:coursaty_student_and_teacher/features/courses/domain/use_case/toggle_video_interaction_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repository/courses_repository.dart';
import '../../domain/use_case/get_course_details_use_case.dart';
import '../../domain/use_case/get_courses_by_subject_use_case.dart';
import '../../domain/use_case/get_courses_by_year_use_case.dart';
import '../model/course_details_model.dart';
import '../model/course_model.dart';
import '../model/course_rating.dart';
import '../model/courses_of_subject_response_model.dart';
import '../model/resulotion_model.dart';
import '../model/teacher_course_details_model.dart';
import '../source/courses_remote_data_source.dart';

@LazySingleton(as: CoursesRepository)
class CoursesRepositoryImp extends CoursesRepository
    with HandlingExceptionRequest {
  final CoursesRemoteDataSource remoteDataSource;

  CoursesRepositoryImp(this.remoteDataSource);

  @override
  Future<Either<Failure, CourseDetailsModel>> getCourseDetails(
    ParamGetCourseDetails param,
  ) => handlingExceptionRequest(
    tryCall: () => remoteDataSource.getCourseDetails(param),
  );

  @override
  Future<Either<Failure, bool>> rateCourse(Map<String, dynamic> data) =>
      handlingExceptionRequest(
        tryCall: () => remoteDataSource.rateCourse(data),
      );

  @override
  Future<Either<Failure, CoursesOfSubjectResponseModel>> getCoursesBySubject(
    ParamGetCoursesBySubject params,
  ) => handlingExceptionRequest(
    tryCall: () => remoteDataSource.getCoursesBySubject(params),
  );

  // @override
  // Future<Either<Failure, List<CourseModel>>> getCoursesByTeacher({
  //   required int teacherId,
  //   required int universityId,
  // }) => handlingExceptionRequest(
  //   tryCall: () => remoteDataSource.getCoursesByTeacher(
  //     teacherId: teacherId,
  //     universityId: universityId,
  //   ),
  // );

  @override
  Future<Either<Failure, List<CourseModel>>> getCoursesByYear(
    ParamGetCoursesByYear param,
  ) => handlingExceptionRequest(
    tryCall: () => remoteDataSource.getCoursesByYear(param),
  );

  @override
  Future<Either<Failure, List<CourseCategory>>> getCoursesCategories() {
    return handlingExceptionRequest(
      tryCall: remoteDataSource.getCoursesCategories,
    );
  }

  @override
  Future<Either<Failure, CoursesResponseModel>> getCoursesWithFiltering(
    ParamGetCoursesWithFilters params,
  ) {
    return handlingExceptionRequest(
      tryCall: () => remoteDataSource.getCoursesWithFiltering(params),
    );
  }

  @override
  Future<Either<Failure, LectureDetailsModel>> getLectureDetails(
    GetLectureDetailsParams param,
  ) {
    return handlingExceptionRequest(
      tryCall: () => remoteDataSource.getLectureDetails(param),
    );
  }

  @override
  Future<Either<Failure, CourseRatingModel>> getCourseRating(String id) {
    return handlingExceptionRequest(
      tryCall: () => remoteDataSource.getCourseRating(id),
    );
  }

  @override
  Future<Either<Failure, TeacherCoursesResponseModel>> getTeacherCourses(
    GetTeacherCoursesParams params,
  ) {
    return handlingExceptionRequest(
      tryCall: () => remoteDataSource.getTeacherCourses(params),
    );
  }

  @override
  Future<Either<Failure, CourseStatisticsModel>> getCourseStatistics(
    ParamGetCourseDetails param,
  ) {
    return handlingExceptionRequest(
      tryCall: () => remoteDataSource.getCourseStatistics(param),
    );
  }

  @override
  Future<Either<Failure, TeacherCourseDetailsResponseModel>>
  getTeacherCourseDetails(ParamGetCourseDetails param) {
    return handlingExceptionRequest(
      tryCall: () => remoteDataSource.getTeacherCourseDetails(param),
    );
  }

  @override
  Future<Either<Failure, List<ResolutionModel>>> getVideoResolutions(
    String videoId,
  ) {
    return handlingExceptionRequest(
      tryCall: () => remoteDataSource.getVideoResolutions(videoId),
    );
  }

  @override
  Future<Either<Failure, VideoInteractionModel>> getVideoInteractions(
    String id,
  ) {
    return handlingExceptionRequest(
      tryCall: () => remoteDataSource.getVideoInteractions(id),
    );
  }

  @override
  Future<Either<Failure, bool>> toggleVideoInteraction(
    ToggleVideoInteractionParams params,
  ) {
    return handlingExceptionRequest(
      tryCall: () => remoteDataSource.toggleVideoInteraction(params),
    );
  }
}
