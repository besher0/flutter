part of 'notifications_bloc.dart';

class NotificationsState {
  final List<Notification> notifications;
  final String errorMessage;
  final Status getNotificationsStatus;
  final Status addNotificationsStatus;

  NotificationsState({
    this.notifications = const [],
    this.errorMessage = '',
    this.getNotificationsStatus = Status.init,
    this.addNotificationsStatus = Status.init,
  });

  NotificationsState copyWith({
    final List<Notification>? notifications,
    final String? errorMessage,
    final Status? addNotificationsStatus,
    final Status? getNotificationsStatus,
  }) => NotificationsState(
    notifications: notifications ?? this.notifications,
    getNotificationsStatus:
        getNotificationsStatus ?? this.getNotificationsStatus,
    addNotificationsStatus:
        addNotificationsStatus ?? this.addNotificationsStatus,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}
