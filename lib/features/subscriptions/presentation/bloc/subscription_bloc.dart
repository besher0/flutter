import 'dart:async';
import 'dart:io';

import 'package:coursaty_student_and_teacher/core/enums/request_status.dart';
import 'package:coursaty_student_and_teacher/core/use_case/use_case.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/data/models/course_interest_model.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/domain/usecases/create_course_interest_usecase.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/domain/usecases/get_course_interests_usecase.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/domain/usecases/get_course_payment_info_usecase.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/domain/usecases/remove_course_interest_usecase.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/domain/usecases/submit_subscription_receipt_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'subscription_event.dart';
part 'subscription_state.dart';

@LazySingleton()
class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  SubscriptionBloc(
    this._getInterests,
    this._getPaymentInfo,
    this._createInterest,
    this._removeInterest,
    this._submitReceipt,
  ) : super(const SubscriptionState()) {
    on<LoadCourseInterests>(_onLoadInterests);
    on<LoadCoursePaymentInfo>(_onLoadPaymentInfo);
    on<SaveCourseInterest>(_onSaveInterest);
    on<RemoveCourseInterest>(_onRemoveInterest);
    on<SubmitSubscriptionReceipt>(_onSubmitReceipt);
  }

  final GetCourseInterestsUsecase _getInterests;
  final GetCoursePaymentInfoUsecase _getPaymentInfo;
  final CreateCourseInterestUsecase _createInterest;
  final RemoveCourseInterestUsecase _removeInterest;
  final SubmitSubscriptionReceiptUsecase _submitReceipt;

  Future<void> _onLoadInterests(
    LoadCourseInterests event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(state.copyWith(interestsStatus: Status.loading));
    final result = await _getInterests(NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          interestsStatus: Status.failure,
          errorMessage: failure.message,
        ),
      ),
      (interests) => emit(
        state.copyWith(interestsStatus: Status.loaded, interests: interests),
      ),
    );
  }

  Future<void> _onLoadPaymentInfo(
    LoadCoursePaymentInfo event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(state.copyWith(paymentInfoStatus: Status.loading));
    final result = await _getPaymentInfo(event.courseId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          paymentInfoStatus: Status.failure,
          errorMessage: failure.message,
        ),
      ),
      (info) => emit(
        state.copyWith(paymentInfoStatus: Status.loaded, paymentInfo: info),
      ),
    );
  }

  Future<void> _onSaveInterest(
    SaveCourseInterest event,
    Emitter<SubscriptionState> emit,
  ) async {
    if (state.saveInterestStatus.isLoading) return;
    emit(state.copyWith(saveInterestStatus: Status.loading));
    final result = await _createInterest(
      CreateCourseInterestParams(
        courseId: event.courseId,
        source: event.source,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          saveInterestStatus: Status.failure,
          errorMessage: failure.message,
        ),
      ),
      (interest) {
        final interests = [...state.interests];
        final index = interests.indexWhere(
          (item) => item.courseId == interest.courseId,
        );
        if (index == -1) {
          interests.insert(0, interest);
        } else {
          interests[index] = interest;
        }
        emit(
          state.copyWith(
            saveInterestStatus: Status.loaded,
            interests: interests,
            lastCreatedInterest: interest,
          ),
        );
      },
    );
  }

  Future<void> _onRemoveInterest(
    RemoveCourseInterest event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(state.copyWith(removeInterestStatus: Status.loading));
    final result = await _removeInterest(event.courseId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          removeInterestStatus: Status.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          removeInterestStatus: Status.loaded,
          interests: state.interests
              .where((interest) => interest.courseId != event.courseId)
              .toList(),
        ),
      ),
    );
  }

  Future<void> _onSubmitReceipt(
    SubmitSubscriptionReceipt event,
    Emitter<SubscriptionState> emit,
  ) async {
    if (state.receiptStatus.isLoading) return;
    emit(state.copyWith(receiptStatus: Status.loading, uploadProgress: 0));
    final result = await _submitReceipt(
      SubmitSubscriptionReceiptParams(
        courseId: event.courseId,
        file: event.file,
        note: event.note,
        onSendProgress: (sent, total) {
          if (total > 0 && !isClosed) {
            emit(state.copyWith(uploadProgress: sent / total));
          }
        },
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          receiptStatus: Status.failure,
          errorMessage: failure.message,
        ),
      ),
      (request) {
        final interests = state.interests.map((interest) {
          return interest.courseId == event.courseId
              ? interest.copyWith(pendingRequest: request)
              : interest;
        }).toList();
        emit(
          state.copyWith(
            receiptStatus: Status.loaded,
            uploadProgress: 1,
            interests: interests,
            lastSubmittedRequest: request,
          ),
        );
      },
    );
  }
}
