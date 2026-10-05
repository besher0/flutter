part of 'teachers_bloc.dart';

@immutable
sealed class TeachersEvent {}

class GetLikedTeachersEvent extends TeachersEvent {}

class GetTeachersEvent extends TeachersEvent {}

class GetRevenuesEvent extends TeachersEvent {}

class GetWithdrawalsEvent extends TeachersEvent {
  final bool reset;
  GetWithdrawalsEvent({required this.reset});
}

class LikeTeacherEvent extends TeachersEvent {
  final String teacherId;

  LikeTeacherEvent({required this.teacherId});
}

class UnLikeTeacherEvent extends TeachersEvent {
  final String teacherId;

  UnLikeTeacherEvent({required this.teacherId});
}

class ClearTeachersState extends TeachersEvent {}

class GetTeacherDetailsEvent extends TeachersEvent {
  final String teacherId;
  final bool reset;

  GetTeacherDetailsEvent({required this.teacherId, this.reset = false});
}

class GetTeacherAffiliations extends TeachersEvent {}

class AddOrDeleteTeacherAffiliations extends TeachersEvent {
  final AddOrRemoveAffiliationsParams params;

  AddOrDeleteTeacherAffiliations({required this.params});
}
