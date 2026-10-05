part of 'notifications_bloc.dart';

@immutable
sealed class NotificationsEvent {}

class GetNotificationsEvent extends NotificationsEvent {
  GetNotificationsEvent();
}

class ClearNotificationState extends NotificationsEvent {}

class AddNotificationEvent extends NotificationsEvent {
  final AddNotificationParams params;

  AddNotificationEvent({required this.params});
}
