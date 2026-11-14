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
          '${GRouter.config.applicationRoutes.lectureDetails}/$id/${Uri.encodeComponent(name)}/$cid/$free';
      GRouter.router.push(route);
    }
  }
}

/// A link opened inside the teacher app (its notifications): only a course
/// or a lesson page, in their teacher versions. Other links (a teacher's
/// profile…) are student pages and do nothing here.
void navigateFromUriForTeacher(Uri uri) {
  final page = uri.pathSegments.isEmpty ? null : uri.pathSegments.first;

  if (page == 'course') {
    final id = uri.queryParameters['cid'];
    if (id != null && id.isNotEmpty) {
      GRouter.router.push(
        '${GRouter.config.applicationRoutes.teacherCourseDetails}/$id',
      );
    }
    return;
  }

  if (page == 'lecture') {
    final id = uri.queryParameters['lid'];
    final name = uri.queryParameters['name'];
    final cid = uri.queryParameters['cid'];
    if (id != null && name != null && cid != null) {
      // The teacher's lesson route has no "free" segment, and the name is a
      // path segment: encoded, so a «/» in it cannot break the route.
      GRouter.router.push(
        '${GRouter.config.applicationRoutes.lectureDetailsForTeacher}'
        '/$id/${Uri.encodeComponent(name)}/$cid',
      );
    }
  }
}
