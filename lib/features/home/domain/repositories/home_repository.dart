import 'package:coursaty_student_and_teacher/features/courses/data/model/course_model.dart';
import 'package:coursaty_student_and_teacher/features/home/data/models/filtered_subjects_response_model.dart';
import 'package:coursaty_student_and_teacher/features/home/data/models/teacher_summary_response_model.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/home_response_model.dart';
import '../../data/models/search_response_model.dart';
import '../usecases/search_usecase.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<Program>>> getAllPrograms(
    Map<String, dynamic> data,
  );

  Future<Either<Failure, StudentSubjectsModel>> getSubjectsWithFiltering(
    String collegeYearId,
  );

  Future<Either<Failure, TeacherSummaryResponseModel>> getTeacherSummary();
  Future<Either<Failure, List<Advertisement>>> getAdvertisements();
  Future<Either<Failure, List<CourseModel>>> getMyCourses(bool getActive);

  Future<Either<Failure, HomeResponseModel>> getHomeContent(int limit);
  Future<Either<Failure, SearchResponseModel>> search(SearchParams params);
}
