part of 'subscription_bloc.dart';

sealed class SubscriptionEvent {}

class LoadCourseInterests extends SubscriptionEvent {}

class LoadCoursePaymentInfo extends SubscriptionEvent {
  LoadCoursePaymentInfo(this.courseId);
  final String courseId;
}

class SaveCourseInterest extends SubscriptionEvent {
  SaveCourseInterest({required this.courseId, required this.source});
  final String courseId;
  final InterestSource source;
}

class RemoveCourseInterest extends SubscriptionEvent {
  RemoveCourseInterest(this.courseId);
  final String courseId;
}

class SubmitSubscriptionReceipt extends SubscriptionEvent {
  SubmitSubscriptionReceipt({
    required this.courseId,
    required this.file,
    this.note,
  });
  final String courseId;
  final File file;
  final String? note;
}
