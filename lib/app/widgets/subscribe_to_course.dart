import 'package:coursaty_student_and_teacher/core/common/constant/configuration/paid_content_policy.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/presentation/screens/payment_qr_screen.dart';
import 'package:flutter/material.dart';

/// Kept under its historic name so all locked-content entry points share the
/// new payment route without duplicating navigation logic.
Future<void> showSubscribeToCourseDialog(
  BuildContext context, {
  required String courseId,
}) async {
  // iPhone with paid content hidden: no purchase flow at all.
  if (PaidContentPolicy.hidePaid) return;
  await context.pushPage(PaymentQrScreen(courseId: courseId));
}
