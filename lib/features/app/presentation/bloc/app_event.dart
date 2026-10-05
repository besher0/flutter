part of 'app_bloc.dart';

@immutable
sealed class AppEvent {}

class GetCustomerServiceEvent extends AppEvent {}

class ScanCodeEvent extends AppEvent {
  final String code;

  ScanCodeEvent(this.code);
}

class ClearAppState extends AppEvent {}

class ChangeThemeEvent extends AppEvent {}
