part of 'subscription_bloc.dart';

class SubscriptionState {
  const SubscriptionState({
    this.interestsStatus = Status.init,
    this.paymentInfoStatus = Status.init,
    this.saveInterestStatus = Status.init,
    this.removeInterestStatus = Status.init,
    this.receiptStatus = Status.init,
    this.interests = const [],
    this.paymentInfo,
    this.lastCreatedInterest,
    this.lastSubmittedRequest,
    this.uploadProgress = 0,
    this.errorMessage = '',
  });

  final Status interestsStatus;
  final Status paymentInfoStatus;
  final Status saveInterestStatus;
  final Status removeInterestStatus;
  final Status receiptStatus;
  final List<CourseInterest> interests;
  final CoursePaymentInfo? paymentInfo;
  final CourseInterest? lastCreatedInterest;
  final SubscriptionRequestSummary? lastSubmittedRequest;
  final double uploadProgress;
  final String errorMessage;

  SubscriptionState copyWith({
    Status? interestsStatus,
    Status? paymentInfoStatus,
    Status? saveInterestStatus,
    Status? removeInterestStatus,
    Status? receiptStatus,
    List<CourseInterest>? interests,
    CoursePaymentInfo? paymentInfo,
    CourseInterest? lastCreatedInterest,
    SubscriptionRequestSummary? lastSubmittedRequest,
    double? uploadProgress,
    String? errorMessage,
  }) => SubscriptionState(
    interestsStatus: interestsStatus ?? this.interestsStatus,
    paymentInfoStatus: paymentInfoStatus ?? this.paymentInfoStatus,
    saveInterestStatus: saveInterestStatus ?? this.saveInterestStatus,
    removeInterestStatus: removeInterestStatus ?? this.removeInterestStatus,
    receiptStatus: receiptStatus ?? this.receiptStatus,
    interests: interests ?? this.interests,
    paymentInfo: paymentInfo ?? this.paymentInfo,
    lastCreatedInterest: lastCreatedInterest ?? this.lastCreatedInterest,
    lastSubmittedRequest: lastSubmittedRequest ?? this.lastSubmittedRequest,
    uploadProgress: uploadProgress ?? this.uploadProgress,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}
