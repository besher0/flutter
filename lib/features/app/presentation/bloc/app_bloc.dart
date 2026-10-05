import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:coursaty_student_and_teacher/core/enums/request_status.dart';
import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:coursaty_student_and_teacher/core/use_case/use_case.dart';
import 'package:coursaty_student_and_teacher/features/app/data/models/customer_service_model.dart';
import 'package:coursaty_student_and_teacher/features/app/domain/usecases/get_customer_service_usecase.dart';
import 'package:coursaty_student_and_teacher/features/app/domain/usecases/scan_code_usecase.dart';
import 'package:coursaty_student_and_teacher/features/home/presentation/bloc/home_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';

part 'app_event.dart';

part 'app_state.dart';

@LazySingleton()
class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc({
    required this.scanCodeUsecase,
    required this.getCustomerServiceUsecase,
  }) : super(
         AppState(
           isThemeLight: GetIt.I<PrefsRepository>().isLightTheme ?? true,
         ),
       ) {
    on<AppEvent>((event, emit) {});
    on<ScanCodeEvent>(_onScanCodeEvent);
    on<ClearAppState>(_onClearAppState);
    on<ChangeThemeEvent>(_onChangeThemeEvent);
    on<GetCustomerServiceEvent>(_onGetCustomerServiceEvent);
  }

  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();
  final ScanCodeUsecase scanCodeUsecase;
  final GetCustomerServiceUsecase getCustomerServiceUsecase;

  FutureOr<void> _onScanCodeEvent(
    ScanCodeEvent event,
    Emitter<AppState> emit,
  ) async {
    emit(state.copyWith(scanCode: Status.loading));
    final response = await scanCodeUsecase(event.code);

    response.fold(
      (l) {
        emit(state.copyWith(scanCode: Status.failure, errorMessage: l.message));
      },
      (r) {
        emit(
          state.copyWith(scanCode: Status.loaded, currentScannedCourseId: r),
        );
        GetIt.I<HomeBloc>().add(GetMyActiveCourses());
        GetIt.I<HomeBloc>().add(GetMyInActiveCourses());
      },
    );
  }

  FutureOr<void> _onClearAppState(ClearAppState event, Emitter<AppState> emit) {
    emit(AppState());
  }

  FutureOr<void> _onChangeThemeEvent(
    ChangeThemeEvent event,
    Emitter<AppState> emit,
  ) {
    _prefsRepository.setIsLightTheme(!state.isThemeLight);
    emit(state.copyWith(isThemeLight: !state.isThemeLight));
  }

  FutureOr<void> _onGetCustomerServiceEvent(
    GetCustomerServiceEvent event,
    Emitter<AppState> emit,
  ) async {
    emit(state.copyWith(getCustomerService: Status.loading));
    final response = await getCustomerServiceUsecase(NoParams());

    response.fold(
      (l) {
        emit(
          state.copyWith(
            getCustomerService: Status.failure,
            errorMessage: l.message,
          ),
        );
      },
      (r) {
        emit(
          state.copyWith(
            getCustomerService: Status.loaded,
            customerServiceModel: r,
          ),
        );
      },
    );
  }
}
