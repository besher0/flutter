import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/routes/router.dart';

void navigateFromUri(Uri uri) {
  if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'teacher') {
    final id = uri.queryParameters['tid'];
    final name = uri.queryParameters['name'];
    if (id != null && name != null) {
      final route =
          '${GRouter.config.applicationRoutes.teacherDetails}/$id/$name';
      GRouter.router.push(route);
    }
  }

  if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'course') {
    final id = uri.queryParameters['cid'];
    if (id != null) {
      final route = '${GRouter.config.applicationRoutes.courseDetails}/$id';
      GRouter.router.push(route);
    }
  }

  if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'lecture') {
    final id = uri.queryParameters['lid'];
    final name = uri.queryParameters['name'];
    final cid = uri.queryParameters['cid'];
    final free = uri.queryParameters['fc'] != null;
    if (id != null && name != null && cid != null) {
      final route =
          '${GRouter.config.applicationRoutes.lectureDetails}/$id/$name/$cid/$free';
      GRouter.router.push(route);
    }
  }
}

void navigateFromUriForTeacher(Uri uri) {
  if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'teacher') {
    final id = uri.queryParameters['tid'];
    final name = uri.queryParameters['name'];
    if (id != null && name != null) {
      final route =
          '${GRouter.config.applicationRoutes.teacherDetails}/$id/$name';
      GRouter.router.push(route);
    }
  }

  if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'course') {
    final id = uri.queryParameters['cid'];
    if (id != null) {
      final route =
          '${GRouter.config.applicationRoutes.teacherCourseDetails}/$id';
      GRouter.router.push(route);
    }
  }

  if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'lecture') {
    final id = uri.queryParameters['lid'];
    final name = uri.queryParameters['name'];
    final cid = uri.queryParameters['cid'];
    final free = uri.queryParameters['fc'] != null;
    if (id != null && name != null && cid != null) {
      final route =
          '${GRouter.config.applicationRoutes.lectureDetailsForTeacher}/$id/$name/$cid/$free';
      GRouter.router.push(route);
    }
  }
}
