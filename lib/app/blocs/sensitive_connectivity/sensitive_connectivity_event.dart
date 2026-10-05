part of 'sensitive_connectivity_bloc.dart';

@immutable
abstract class SensitiveConnectivityEvent {
  const SensitiveConnectivityEvent();
}

class ChangeConnectivityEvent extends SensitiveConnectivityEvent {
  final ConnectivityResult connectivityResult;

  const ChangeConnectivityEvent({required this.connectivityResult});
}
