import 'package:coursaty_student_and_teacher/features/courses/data/model/course_category.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_statistcis_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/get_teacher_courses_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/lecture_details_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/video_interaction_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/domain/use_case/get_lecture_details_usecase.dart';
import 'package:coursaty_student_and_teacher/features/courses/domain/use_case/get_teacher_courses_usecase.dart';
import 'package:coursaty_student_and_teacher/features/courses/domain/use_case/toggle_video_interaction_usecase.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../data/model/course_details_model.dart';
import '../../data/model/course_rating.dart';
import '../../data/model/courses_of_subject_response_model.dart';
import '../../data/model/resulotion_model.dart';
import '../../data/model/teacher_course_details_model.dart';
import '../use_case/get_course_details_use_case.dart';
import '../use_case/get_courses_by_subject_use_case.dart';
import '../use_case/get_courses_by_year_use_case.dart';
import '../use_case/get_courses_with_filtering_usecase.dart';

abstract class CoursesRepository {
  Future<Either<Failure, CoursesOfSubjectResponseModel>> getCoursesBySubject(
    ParamGetCoursesBySubject params,
  );

  Future<Either<Failure, CoursesResponseModel>> getCoursesWithFiltering(
    ParamGetCoursesWithFilters params,
  );

  Future<Either<Failure, List<CourseCategory>>> getCoursesCategories();

  Future<Either<Failure, List<ResolutionModel>>> getVideoResolutions(
    String videoId,
  );

  Future<Either<Failure, TeacherCoursesResponseModel>> getTeacherCourses(
    GetTeacherCoursesParams params,
  );

  Future<Either<Failure, List<CourseModel>>> getCoursesByYear(
    ParamGetCoursesByYear param,
  );

  Future<Either<Failure, CourseDetailsModel>> getCourseDetails(
    ParamGetCourseDetails param,
  );

  Future<Either<Failure, TeacherCourseDetailsResponseModel>>
  getTeacherCourseDetails(ParamGetCourseDetails param);

  Future<Either<Failure, CourseStatisticsModel>> getCourseStatistics(
    ParamGetCourseDetails param,
  );

  Future<Either<Failure, LectureDetailsModel>> getLectureDetails(
    GetLectureDetailsParams param,
  );

  Future<Either<Failure, bool>> rateCourse(Map<String, dynamic> data);

  Future<Either<Failure, bool>> toggleVideoInteraction(
    ToggleVideoInteractionParams params,
  );

  Future<Either<Failure, VideoInteractionModel>> getVideoInteractions(
    String id,
  );

  Future<Either<Failure, CourseRatingModel>> getCourseRating(String id);
}
