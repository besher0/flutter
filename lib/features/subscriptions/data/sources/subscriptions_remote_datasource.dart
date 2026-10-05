import 'dart:io';

import 'package:coursaty_student_and_teacher/core/api/client_config.dart';
import 'package:coursaty_student_and_teacher/core/api/detect_server.dart';
import 'package:coursaty_student_and_teacher/core/api/methods/delete.dart';
import 'package:coursaty_student_and_teacher/core/api/methods/get.dart';
import 'package:coursaty_student_and_teacher/core/api/methods/post.dart';
import 'package:coursaty_student_and_teacher/core/common/constant/configuration/url_routes.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/course_interest_model.dart';

@injectable
class SubscriptionsRemoteDatasource {
  Future<List<CourseInterest>> getInterests() {
    return GetClient<List<CourseInterest>>(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        endpoint: EndPoints.getCourseInterests,
        response: ResponseValue(
          fromJson: (data) {
            final list = data is Map<String, dynamic>
                ? data['interests']
                : data;
            return (list as List<dynamic>? ?? const [])
                .whereType<Map<String, dynamic>>()
                .map(CourseInterest.fromJson)
                .toList();
          },
        ),
      ),
    )();
  }

  Future<CoursePaymentInfo> getCoursePaymentInfo(String courseId) {
    return GetClient<CoursePaymentInfo>(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        endpoint: EndPoints.getCourseDetails(id: courseId),
        response: ResponseValue(
          fromJson: (data) => CoursePaymentInfo.fromJson(data),
        ),
      ),
    )();
  }

  Future<CourseInterest> createInterest(
    String courseId,
    InterestSource source,
  ) {
    return PostClient<CourseInterest>(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        endpoint: EndPoints.courseInterest(courseId),
        data: {'source': source.apiValue},
        response: ResponseValue(
          fromJson: (data) => CourseInterest.fromJson(
            data is Map<String, dynamic> &&
                    data['interest'] is Map<String, dynamic>
                ? data['interest'] as Map<String, dynamic>
                : data as Map<String, dynamic>,
          ),
        ),
      ),
    )();
  }

  Future<bool> removeInterest(String courseId) {
    return DeleteClient<bool>(
      serverName: ServerName.master,
      requestPrams: RequestConfig(
        endpoint: EndPoints.courseInterest(courseId),
        response: ResponseValue(returnValueOnSuccess: true),
      ),
    )();
  }

  Future<SubscriptionRequestSummary> submitReceipt({
    required String courseId,
    required File file,
    String? note,
    ProgressCallback? onSendProgress,
  }) async {
    final formData = FormData.fromMap({
      'courseId': courseId,
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.uri.pathSegments.last,
      ),
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
    });
    return PostClient<SubscriptionRequestSummary>(
      serverName: ServerName.master,
      onSendProgress: onSendProgress,
      requestPrams: RequestConfig(
        endpoint: EndPoints.createSubscriptionRequestWithReceipt,
        data: formData,
        response: ResponseValue(
          fromJson: (data) {
            final request =
                data is Map<String, dynamic> &&
                    data['subscriptionRequest'] is Map<String, dynamic>
                ? data['subscriptionRequest'] as Map<String, dynamic>
                : data is Map<String, dynamic> &&
                      data['request'] is Map<String, dynamic>
                ? data['request'] as Map<String, dynamic>
                : data as Map<String, dynamic>;
            return SubscriptionRequestSummary.fromJson(request);
          },
        ),
      ),
    )();
  }
}
