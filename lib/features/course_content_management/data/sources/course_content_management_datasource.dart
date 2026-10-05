import 'package:coursaty_student_and_teacher/core/api/client_config.dart';
import 'package:coursaty_student_and_teacher/core/api/methods/delete.dart';
import 'package:coursaty_student_and_teacher/core/api/methods/get.dart';
import 'package:coursaty_student_and_teacher/core/api/methods/patch.dart';
import 'package:coursaty_student_and_teacher/core/api/methods/post.dart';
import 'package:coursaty_student_and_teacher/core/common/constant/configuration/url_routes.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/data/models/seasons_model.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/upsert_course_usecase.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/delete_from_course_usecase.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/upsert_file_usecase.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/upsert_lecture_usecase.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/domain/usecases/upsert_video_usecase.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/lecture_details_model.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/delete_video_segment_usecase.dart';
import '../../domain/usecases/upsert_question_usecase.dart';
import '../../domain/usecases/upsert_video_segment_usecase.dart';
import '../models/allowed_subjects_model.dart';

@injectable
class CourseContentManagementDatasource {
  Future<GetAllowedSubjectsResponseModel> getAllowedSubjects() {
    final GetClient<GetAllowedSubjectsResponseModel> getAllowedSubjects =
        GetClient(
          requestPrams: RequestConfig(
            endpoint: EndPoints.getAllowedSubjectsEP,
            response: ResponseValue(
              fromJson: (json) =>
                  GetAllowedSubjectsResponseModel.fromJson(json),
            ),
          ),
        );
    return getAllowedSubjects();
  }

  Future<List<SeasonsModel>> getAllSeasons() {
    final GetClient<List<SeasonsModel>> getAllSeasons = GetClient(
      requestPrams: RequestConfig(
        endpoint: EndPoints.getAllSeasonsEP,
        response: ResponseValue(fromJson: (json) => seasonsModelFromJson(json)),
      ),
    );
    return getAllSeasons();
  }

  Future<List<Segment>> getAllVideoSegments(String videoId) {
    final GetClient<List<Segment>> getAllVideoSegments = GetClient(
      requestPrams: RequestConfig(
        endpoint: EndPoints.getVideoSegmentsEP(videoId: videoId),
        response: ResponseValue(
          fromJson: (json) => segmentsModelFromJson(json),
        ),
      ),
    );
    return getAllVideoSegments();
  }

  Future<bool> deleteVideoSegment(DeleteVideoSegmentParams params) {
    final DeleteClient<bool> deleteVideoSegment = DeleteClient(
      requestPrams: RequestConfig(
        endpoint: EndPoints.deleteVideoSegmentsEP(
          videoId: params.videoId,
          id: params.segmentId,
        ),
        response: ResponseValue(returnValueOnSuccess: true),
      ),
    );
    return deleteVideoSegment();
  }

  Future<bool> createCourse(UpsertCourseParams params) {
    if (params.courseId != null) {
      final PatchClient<bool> createCourse = PatchClient(
        requestPrams: RequestConfig(
          endpoint: '${EndPoints.createCourseEP}/${params.courseId!}',
          data: params.map,
          response: ResponseValue(returnValueOnSuccess: true),
        ),
      );
      return createCourse();
    } else {
      final PostClient<bool> createCourse = PostClient(
        requestPrams: RequestConfig(
          endpoint: EndPoints.createCourseEP,
          data: params.map,
          response: ResponseValue(returnValueOnSuccess: true),
        ),
      );
      return createCourse();
    }
  }

  Future<bool> deleteFromCourse(DeleteFromCourseParams params) {
    final DeleteClient<bool> deleteFromCourse = DeleteClient(
      requestPrams: RequestConfig(
        endpoint: params.endpoint,
        response: ResponseValue(returnValueOnSuccess: true),
      ),
    );
    return deleteFromCourse();
  }

  Future<bool> upsertLecture(UpsertLectureParams params) {
    if (params.lectureId != null) {
      final PatchClient<bool> upsertLecture = PatchClient(
        requestPrams: RequestConfig(
          endpoint: "${EndPoints.createLecture}/${params.lectureId!}",
          response: ResponseValue(returnValueOnSuccess: true),
          data: params.data,
        ),
      );
      return upsertLecture();
    } else {
      final PostClient<bool> upsertLecture = PostClient(
        requestPrams: RequestConfig(
          endpoint: EndPoints.createLecture,
          response: ResponseValue(returnValueOnSuccess: true),
          data: params.data,
        ),
      );
      return upsertLecture();
    }
  }

  Future<bool> upsertVideo(UpsertVideoParams params) {
    if (params.videoId != null) {
      final PatchClient<bool> upsertVideo = PatchClient(
        requestPrams: RequestConfig(
          endpoint: EndPoints.editVideo(id: params.videoId!),
          response: ResponseValue(returnValueOnSuccess: true),
          data: params.data(),
        ),
      );
      return upsertVideo();
    } else {
      final PostClient<bool> upsertVideo = PostClient(
        requestPrams: RequestConfig(
          endpoint: EndPoints.createVideo,
          response: ResponseValue(returnValueOnSuccess: true),
          data: params.data(),
        ),
      );
      return upsertVideo();
    }
  }

  Future<bool> upsertFile(UpsertFileParams params) {
    if (params.fileId != null) {
      final PatchClient<bool> upsertFile = PatchClient(
        requestPrams: RequestConfig(
          endpoint: EndPoints.editFile(id: params.fileId!),
          response: ResponseValue(returnValueOnSuccess: true),
          data: params.data,
        ),
      );
      return upsertFile();
    } else {
      final PostClient<bool> upsertFile = PostClient(
        requestPrams: RequestConfig(
          endpoint: EndPoints.createFileEP,
          response: ResponseValue(returnValueOnSuccess: true),
          data: params.data,
        ),
      );
      return upsertFile();
    }
  }

  Future<bool> upsertQuestion(UpsertQuestionParams params) {
    if (params.questionId != null) {
      final PatchClient<bool> upsertQuestion = PatchClient(
        requestPrams: RequestConfig(
          endpoint: EndPoints.editQuestion(id: params.questionId!),
          response: ResponseValue(returnValueOnSuccess: true),
          data: params.data,
        ),
      );
      return upsertQuestion();
    } else {
      final PostClient<bool> upsertQuestion = PostClient(
        requestPrams: RequestConfig(
          endpoint: EndPoints.createQuestionEP(lectureId: params.lectureId),
          response: ResponseValue(returnValueOnSuccess: true),
          data: params.data,
        ),
      );
      return upsertQuestion();
    }
  }

  Future<bool> upsertVideoSegment(UpsertVideoSegmentParams params) {
    if (params.segmentId != null) {
      final PatchClient<bool> upsertVideoSegment = PatchClient(
        requestPrams: RequestConfig(
          endpoint: EndPoints.editVideoSegment(
            id: params.segmentId!,
            videoId: params.videoId,
          ),
          response: ResponseValue(returnValueOnSuccess: true),
          data: params.data,
        ),
      );
      return upsertVideoSegment();
    } else {
      final PostClient<bool> upsertVideoSegment = PostClient(
        requestPrams: RequestConfig(
          endpoint: EndPoints.createVideoSegmentEP(videoId: params.videoId),
          response: ResponseValue(returnValueOnSuccess: true),
          data: params.data,
        ),
      );
      return upsertVideoSegment();
    }
  }
}
