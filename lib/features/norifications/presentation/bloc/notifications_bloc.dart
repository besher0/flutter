import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:coursaty_student_and_teacher/core/use_case/use_case.dart';
import 'package:coursaty_student_and_teacher/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:coursaty_student_and_teacher/features/norifications/domain/use_case/add_notification_usecase.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';

import '../../../../core/enums/request_status.dart';
import '../../../home/presentation/bloc/home_bloc.dart';
import '../../data/model/notification_model.dart';
import '../../domain/use_case/get_notifications_use_case.dart';

part 'notifications_event.dart';

part 'notifications_state.dart';

@LazySingleton()
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final AddNotificationUsecase addNotificationUsecase;

  NotificationsBloc(
    this.getNotificationsUseCase, {
    required this.addNotificationUsecase,
  }) : super(NotificationsState()) {
    on<GetNotificationsEvent>(
      (event, emit) => _onGetNotificationsEvent(event, emit),
    );
    on<ClearNotificationState>(_onClearState);
    on<AddNotificationEvent>(_onAddNotificationEvent);
  }

  FutureOr<void> _onGetNotificationsEvent(
    GetNotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(getNotificationsStatus: Status.loading));
    final res = await getNotificationsUseCase(NoParams());
    res.fold(
      (l) => emit(
        state.copyWith(
          getNotificationsStatus: Status.failure,
          errorMessage: l.message,
        ),
      ),
      (r) => emit(
        state.copyWith(getNotificationsStatus: Status.loaded, notifications: r),
      ),
    );
  }

  FutureOr<void> _onClearState(
    ClearNotificationState event,
    Emitter<NotificationsState> emit,
  ) {
    emit(NotificationsState());
  }

  FutureOr<void> _onAddNotificationEvent(
    AddNotificationEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(addNotificationsStatus: Status.loading));
    final res = await addNotificationUsecase(event.params);
    res.fold(
      (l) => emit(
        state.copyWith(
          addNotificationsStatus: Status.failure,
          errorMessage: l.message,
        ),
      ),
      (r) {
        GetIt.I<HomeBloc>().add(AddPendingNotificationEvent(notification: r));
        emit(state.copyWith(addNotificationsStatus: Status.loaded));
        add(GetNotificationsEvent());
      },
    );
  }
}
