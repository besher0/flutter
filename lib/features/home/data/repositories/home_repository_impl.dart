import 'package:coursaty_student_and_teacher/core/api/api.dart';
import 'package:coursaty_student_and_teacher/core/error/failures.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_model.dart';
import 'package:coursaty_student_and_teacher/features/home/data/models/filtered_subjects_response_model.dart';
import 'package:coursaty_student_and_teacher/features/home/data/models/home_response_model.dart';
import 'package:coursaty_student_and_teacher/features/home/data/models/teacher_summary_response_model.dart';
import 'package:coursaty_student_and_teacher/features/home/domain/repositories/home_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/search_usecase.dart';
import '../models/search_response_model.dart';
import '../sources/home_remote_datasource.dart';

@LazySingleton(as: HomeRepository)
class HomeRepositoryImpl extends HomeRepository with HandlingExceptionRequest {
  final HomeRemoteDatasource homeRemoteDatasource;

  HomeRepositoryImpl(this.homeRemoteDatasource);

  @override
  Future<Either<Failure, List<Advertisement>>> getAdvertisements() {
    return handlingExceptionRequest(
      tryCall: homeRemoteDatasource.getAdvertisements,
    );
  }

  @override
  Future<Either<Failure, HomeResponseModel>> getHomeContent(int limit) {
    return handlingExceptionRequest(
      tryCall: () => homeRemoteDatasource.getHomeContent(limit),
    );
  }

  @override
  Future<Either<Failure, List<Program>>> getAllPrograms(
    Map<String, dynamic> data,
  ) {
    return handlingExceptionRequest(
      tryCall: () => homeRemoteDatasource.getAllPrograms(data),
    );
  }

  @override
  Future<Either<Failure, StudentSubjectsModel>> getSubjectsWithFiltering(
    String collegeYearId,
  ) {
    return handlingExceptionRequest(
      tryCall: () =>
          homeRemoteDatasource.getSubjectsWithFiltering(collegeYearId),
    );
  }

  @override
  Future<Either<Failure, List<CourseModel>>> getMyCourses(bool getActive) {
    return handlingExceptionRequest(
      tryCall: () => homeRemoteDatasource.getMyCourses(getActive),
    );
  }

  @override
  Future<Either<Failure, TeacherSummaryResponseModel>> getTeacherSummary() {
    return handlingExceptionRequest(
      tryCall: () => homeRemoteDatasource.getTeacherSummary(),
    );
  }

  @override
  Future<Either<Failure, SearchResponseModel>> search(SearchParams params) {
    return handlingExceptionRequest(
      tryCall: () => homeRemoteDatasource.search(params),
    );
  }
}
