part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

class GetAdvertisementsEvent extends HomeEvent {}

class GetHomeContentEvent extends HomeEvent {}

class GetAllPrograms extends HomeEvent {
  final bool reset;

  GetAllPrograms({this.reset = false});
}

class GetSubjectsWithFilteringEvent extends HomeEvent {
  GetSubjectsWithFilteringEvent();
}

class ClearHomeState extends HomeEvent {}

class ClearSearchResultsEvent extends HomeEvent {}

class GetMyActiveCourses extends HomeEvent {}

class GetMyInActiveCourses extends HomeEvent {}

class DeleteOutDatedCoursesEvent extends HomeEvent {}

class SearchEvent extends HomeEvent {
  final bool reset;
  final String query;

  SearchEvent({this.reset = false, required this.query});
}

// teacher
class GetTeacherSummaryEvent extends HomeEvent {}

class AddPendingNotificationEvent extends HomeEvent {
  final Notification notification;

  AddPendingNotificationEvent({required this.notification});
}

class ChangeCurrentScreenEvent extends HomeEvent {
  final int newPage;
  ChangeCurrentScreenEvent({required this.newPage});
}
