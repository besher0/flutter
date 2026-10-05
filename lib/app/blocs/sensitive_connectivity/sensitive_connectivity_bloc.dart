import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/api/handling_exception.dart';
import '../../../core/common/helper/show_message.dart';

part 'sensitive_connectivity_event.dart';
part 'sensitive_connectivity_state.dart';

@injectable
class SensitiveConnectivityBloc
    extends Bloc<SensitiveConnectivityEvent, SensitiveConnectivityState>
    with HandlingExceptionRequest {
  SensitiveConnectivityBloc() : super(ConnectivityOfflineState()) {
    on<ChangeConnectivityEvent>(_onCheckConnectivity);
  }

  void _onCheckConnectivity(
    ChangeConnectivityEvent event,
    Emitter<SensitiveConnectivityState> emit,
  ) async {
    prettyPrinterI(
      "***|| 🌐 ${event.connectivityResult.name.toUpperCase()} 🌐 ||***",
    );

    if (event.connectivityResult == ConnectivityResult.mobile) {
      showMessage(
        "استعدت الاتصال بالانترنت",
        foreGroundColor: Colors.green,
        timeShowing: Toast.LENGTH_SHORT,
      );
      emit(ConnectivityCellularState());
    } else if (event.connectivityResult == ConnectivityResult.wifi) {
      showMessage(
        "استعدت الاتصال بالانترنت",
        foreGroundColor: Colors.green,
        timeShowing: Toast.LENGTH_SHORT,
      );
      emit(ConnectivityWifiState());
    } else if (event.connectivityResult == ConnectivityResult.none) {
      showMessage(
        "فقدت الاتصال بالانترنت",
        foreGroundColor: Colors.red,
        timeShowing: Toast.LENGTH_LONG,
      );
      emit(ConnectivityOfflineState());
    }
  }
}
