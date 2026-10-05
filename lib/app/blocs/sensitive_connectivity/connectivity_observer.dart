import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../core/storage/prefs_repository.dart';
import 'sensitive_connectivity_bloc.dart';

class ConnectivityObserver {
  static ConnectivityResult previousEvent = ConnectivityResult.other;
  static ConnectivityResult? currentEvent;

  static ConnectivityObserver? instance;
  static PrefsRepository prefs = GetIt.I<PrefsRepository>();

  static void createInstance(BuildContext context) {
    instance ??= ConnectivityObserver();
    Connectivity().onConnectivityChanged.listen((event) {
      currentEvent = event.first;
      if (Enum.compareByName(previousEvent, event.first) == 0 ||
          ((event.first == ConnectivityResult.mobile ||
                  event.first == ConnectivityResult.wifi) &&
              previousEvent == ConnectivityResult.other)) {
        return;
      }
      previousEvent = event.first;
      if (context.mounted) {
        BlocProvider.of<SensitiveConnectivityBloc>(
          context,
        ).add(ChangeConnectivityEvent(connectivityResult: event.first));
      }
    });
  }
}
