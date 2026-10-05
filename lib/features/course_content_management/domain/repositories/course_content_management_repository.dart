import 'package:coursaty_student_and_teacher/features/course_content_management/data/models/seasons_model.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/upsert_course_usecase.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/delete_from_course_usecase.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/upsert_file_usecase.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/upsert_lecture_usecase.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/upsert_video_usecase.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/lecture_details_model.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/allowed_subjects_model.dart';
import '../usecases/delete_video_segment_usecase.dart';
import '../usecases/upsert_question_usecase.dart';
import '../usecases/upsert_video_segment_usecase.dart';

abstract class CourseContentManagementRepository {
  Future<Either<Failure, GetAllowedSubjectsResponseModel>> getAllowedSubjects();

  Future<Either<Failure, List<SeasonsModel>>> getAllSeasons();

  Future<Either<Failure, List<Segment>>> getAllVideoSegments(String videoId);

  Future<Either<Failure, bool>> deleteVideoSegment(
    DeleteVideoSegmentParams params,
  );

  Future<Either<Failure, bool>> createCourse(UpsertCourseParams params);

  Future<Either<Failure, bool>> deleteFromCourse(DeleteFromCourseParams params);

  Future<Either<Failure, bool>> upsertLecture(UpsertLectureParams params);

  Future<Either<Failure, bool>> upsertVideo(UpsertVideoParams params);

  Future<Either<Failure, bool>> upsertFile(UpsertFileParams params);

  Future<Either<Failure, bool>> upsertQuestion(UpsertQuestionParams params);

  Future<Either<Failure, bool>> upsertVideoSegment(
    UpsertVideoSegmentParams params,
  );
}
