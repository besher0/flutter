import 'package:coursaty_student_and_teacher/core/api/api.dart';
import 'package:coursaty_student_and_teacher/core/error/failures.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/data/models/allowed_subjects_model.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/data/models/seasons_model.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/data/sources/course_content_management_datasource.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/delete_video_segment_usecase.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/upsert_course_usecase.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/delete_from_course_usecase.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/upsert_file_usecase.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/upsert_lecture_usecase.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/upsert_question_usecase.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/upsert_video_segment_usecase.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/upsert_video_usecase.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/lecture_details_model.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/course_content_management_repository.dart';

@LazySingleton(as: CourseContentManagementRepository)
class CourseContentManagementRepositoryImpl
    extends CourseContentManagementRepository
    with HandlingExceptionRequest {
  CourseContentManagementRepositoryImpl(this.datasource);

  final CourseContentManagementDatasource datasource;

  @override
  Future<Either<Failure, GetAllowedSubjectsResponseModel>>
  getAllowedSubjects() {
    return handlingExceptionRequest(tryCall: datasource.getAllowedSubjects);
  }

  @override
  Future<Either<Failure, bool>> createCourse(UpsertCourseParams params) {
    return handlingExceptionRequest(
      tryCall: () => datasource.createCourse(params),
    );
  }

  @override
  Future<Either<Failure, bool>> deleteFromCourse(
    DeleteFromCourseParams params,
  ) {
    return handlingExceptionRequest(
      tryCall: () => datasource.deleteFromCourse(params),
    );
  }

  @override
  Future<Either<Failure, bool>> upsertLecture(UpsertLectureParams params) {
    return handlingExceptionRequest(
      tryCall: () => datasource.upsertLecture(params),
    );
  }

  @override
  Future<Either<Failure, List<SeasonsModel>>> getAllSeasons() {
    return handlingExceptionRequest(tryCall: () => datasource.getAllSeasons());
  }

  @override
  Future<Either<Failure, bool>> upsertVideo(UpsertVideoParams params) {
    return handlingExceptionRequest(
      tryCall: () => datasource.upsertVideo(params),
    );
  }

  @override
  Future<Either<Failure, bool>> upsertFile(UpsertFileParams params) {
    return handlingExceptionRequest(
      tryCall: () => datasource.upsertFile(params),
    );
  }

  @override
  Future<Either<Failure, bool>> upsertQuestion(UpsertQuestionParams params) {
    return handlingExceptionRequest(
      tryCall: () => datasource.upsertQuestion(params),
    );
  }

  @override
  Future<Either<Failure, bool>> upsertVideoSegment(
    UpsertVideoSegmentParams params,
  ) {
    return handlingExceptionRequest(
      tryCall: () => datasource.upsertVideoSegment(params),
    );
  }

  @override
  Future<Either<Failure, List<Segment>>> getAllVideoSegments(String videoId) {
    return handlingExceptionRequest(
      tryCall: () => datasource.getAllVideoSegments(videoId),
    );
  }

  @override
  Future<Either<Failure, bool>> deleteVideoSegment(
    DeleteVideoSegmentParams params,
  ) {
    return handlingExceptionRequest(
      tryCall: () => datasource.deleteVideoSegment(params),
    );
  }
}
