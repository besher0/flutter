import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:coursaty_student_and_teacher/core/use_case/use_case.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';

import '../../../../core/enums/request_status.dart';
import '../../data/model/sale_point_model.dart';
import '../../domain/use_case/get_sales_points_use_case.dart';

part 'sales_points_event.dart';

part 'sales_points_state.dart';

@LazySingleton()
class SalesPointsBloc extends Bloc<SalesPointsEvent, SalesPointsState> {
  final GetSalesPointsUseCase getSalesPointsUseCase;

  SalesPointsBloc(this.getSalesPointsUseCase) : super(SalesPointsState()) {
    on<GetSalesPointsEvent>((event, emit) => _onSalesPointsEvent(event, emit));
    on<ClearSalesPointsState>(_onClearState);
  }

  FutureOr<void> _onSalesPointsEvent(
    GetSalesPointsEvent event,
    Emitter<SalesPointsState> emit,
  ) async {
    emit(state.copyWith(getSalesPointsStatus: Status.loading));
    final res = await getSalesPointsUseCase(NoParams());
    res.fold(
      (l) => emit(
        state.copyWith(
          getSalesPointsStatus: Status.failure,
          errorMessage: l.message,
        ),
      ),
      (r) => emit(
        state.copyWith(getSalesPointsStatus: Status.loaded, salesPoints: r),
      ),
    );
  }

  FutureOr<void> _onClearState(
    ClearSalesPointsState event,
    Emitter<SalesPointsState> emit,
  ) {
    emit(SalesPointsState());
  }
}
