part of 'sensitive_connectivity_bloc.dart';

abstract class SensitiveConnectivityState {
  const SensitiveConnectivityState();
}

class SensitiveConnectivityInitial extends SensitiveConnectivityState {}

class ConnectivityWifiState extends SensitiveConnectivityState {}

class ConnectivityCellularState extends SensitiveConnectivityState {}

class ConnectivityOfflineState extends SensitiveConnectivityState {}
