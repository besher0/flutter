import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:coursaty_student_and_teacher/core/models/pagination_model.dart';
import 'package:coursaty_student_and_teacher/core/use_case/use_case.dart';
import 'package:coursaty_student_and_teacher/features/teachers/data/model/teacher_affilations_model.dart';
import 'package:coursaty_student_and_teacher/features/teachers/data/model/teacher_details_model.dart';
import 'package:coursaty_student_and_teacher/features/teachers/data/model/teacher_model.dart';
import 'package:coursaty_student_and_teacher/features/teachers/data/model/teacher_revenue_model.dart';
import 'package:coursaty_student_and_teacher/features/teachers/data/model/teacher_withdrawal_model.dart';
import 'package:coursaty_student_and_teacher/features/teachers/domain/use_case/add_or_remove_affiliations_usecase.dart';
import 'package:coursaty_student_and_teacher/features/teachers/domain/use_case/get_liked_teachers_usecase.dart';
import 'package:coursaty_student_and_teacher/features/teachers/domain/use_case/get_revenue_usecase.dart';
import 'package:coursaty_student_and_teacher/features/teachers/domain/use_case/get_teacher_affilations_usecase.dart';
import 'package:coursaty_student_and_teacher/features/teachers/domain/use_case/get_teacher_details_usecase.dart';
import 'package:coursaty_student_and_teacher/features/teachers/domain/use_case/get_withdrawals_usecase.dart';
import 'package:coursaty_student_and_teacher/features/teachers/domain/use_case/like_teacher_use_case.dart';
import 'package:coursaty_student_and_teacher/features/teachers/domain/use_case/unlike_teacher_usecase.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';

import '../../../../core/enums/request_status.dart';
import '../../domain/use_case/get_teachers_use_case.dart';

part 'teachers_event.dart';

part 'teachers_state.dart';

@LazySingleton()
class TeachersBloc extends Bloc<TeachersEvent, TeachersState> {
  final GetTeachersUseCase getTeachersUseCase;
  final GetLikedTeachersUsecase getLikedTeachersUsecase;
  final GetTeacherDetailsUsecase getTeacherDetailsUsecase;
  final LikeTeacherUseCase likeTeacherUseCase;
  final UnlikeTeacherUsecase unlikeTeacherUsecase;
  final GetTeacherAffiliationsUsecase getTeacherAffiliationsUsecase;
  final AddOrRemoveAffiliationsUsecase addOrRemoveAffiliationsUsecase;

  final GetWithdrawalsUsecase getWithdrawalsUsecase;
  final GetRevenueUsecase getRevenueUsecase;

  TeachersBloc({
    required this.getTeachersUseCase,
    required this.getLikedTeachersUsecase,
    required this.getTeacherDetailsUsecase,
    required this.likeTeacherUseCase,
    required this.unlikeTeacherUsecase,
    required this.getTeacherAffiliationsUsecase,
    required this.addOrRemoveAffiliationsUsecase,
    required this.getWithdrawalsUsecase,
    required this.getRevenueUsecase,
  }) : super(TeachersState()) {
    on<GetTeachersEvent>((event, emit) => _onGetTeachersEvent(event, emit));
    on<GetLikedTeachersEvent>(_onGetLikedTeachersEvent);
    on<LikeTeacherEvent>(_onLikeTeacherEvent);
    on<UnLikeTeacherEvent>(_onUnLikeTeacherEvent);
    on<GetTeacherDetailsEvent>(_onGetTeacherDetailsEvent);
    on<ClearTeachersState>(_onClearState);
    on<AddOrDeleteTeacherAffiliations>(_onAddOrDeleteTeacherAffiliations);
    on<GetTeacherAffiliations>(_onGetTeacherAffiliations);
    on<GetRevenuesEvent>(_onGetRevenuesEvent);
    on<GetWithdrawalsEvent>(_onGetWithdrawalsEvent);
  }

  FutureOr<void> _onGetTeachersEvent(
    GetTeachersEvent event,
    Emitter<TeachersState> emit,
  ) async {
    emit(state.copyWith(getTeachersStatus: Status.loading));
    final res = await getTeachersUseCase(NoParams());
    res.fold(
      (l) => emit(
        state.copyWith(
          getTeachersStatus: Status.failure,
          errorMessage: l.message,
        ),
      ),
      (r) =>
          emit(state.copyWith(getTeachersStatus: Status.loaded, teachers: r)),
    );
  }

  FutureOr<void> _onGetLikedTeachersEvent(
    GetLikedTeachersEvent event,
    Emitter<TeachersState> emit,
  ) async {
    emit(state.copyWith(getMyLikedTeachers: Status.loading));
    final res = await getLikedTeachersUsecase(NoParams());
    res.fold(
      (l) => emit(
        state.copyWith(
          getMyLikedTeachers: Status.failure,
          errorMessage: l.message,
        ),
      ),
      (r) => emit(
        state.copyWith(getMyLikedTeachers: Status.loaded, likedTeachers: r),
      ),
    );
  }

  FutureOr<void> _onLikeTeacherEvent(
    LikeTeacherEvent event,
    Emitter<TeachersState> emit,
  ) async {
    Map<String, Status> data = Map.of(state.interactionsStatus);
    data[event.teacherId] = Status.loading;
    emit(state.copyWith(interactionsStatus: data));
    final res = await likeTeacherUseCase(
      ParamLikeTeacherUseCase(teacherId: event.teacherId),
    );
    res.fold(
      (l) {
        data = Map.of(state.interactionsStatus);
        data[event.teacherId] = Status.failure;
        emit(state.copyWith(interactionsStatus: data, errorMessage: l.message));
      },
      (r) {
        data = Map.of(state.interactionsStatus);
        data[event.teacherId] = Status.loaded;
        add(GetLikedTeachersEvent());
        emit(
          state.copyWith(
            interactionsStatus: data,
            teacherDetails: state.teacherDetails?.copyWith(
              likesCount: (state.teacherDetails?.likesCount ?? 0) + 1,
            ),
          ),
        );
      },
    );
  }

  FutureOr<void> _onUnLikeTeacherEvent(
    UnLikeTeacherEvent event,
    Emitter<TeachersState> emit,
  ) async {
    Map<String, Status> data = Map.of(state.interactionsStatus);
    data[event.teacherId] = Status.loading;
    emit(state.copyWith(interactionsStatus: data));
    final res = await unlikeTeacherUsecase(
      ParamUnLikeTeacherUseCase(teacherId: event.teacherId),
    );
    res.fold(
      (l) {
        data = Map.of(state.interactionsStatus);
        data[event.teacherId] = Status.failure;
        emit(state.copyWith(interactionsStatus: data, errorMessage: l.message));
      },
      (r) {
        data = Map.of(state.interactionsStatus);
        data[event.teacherId] = Status.loaded;
        List<Teacher> likedTeachers = List.of(state.likedTeachers);
        likedTeachers.removeWhere((item) => item.id == event.teacherId);
        emit(
          state.copyWith(
            interactionsStatus: data,
            likedTeachers: likedTeachers,
            teacherDetails: state.teacherDetails?.copyWith(
              likesCount: (state.teacherDetails?.likesCount ?? 0) - 1,
            ),
          ),
        );
      },
    );
  }

  FutureOr<void> _onGetTeacherDetailsEvent(
    GetTeacherDetailsEvent event,
    Emitter<TeachersState> emit,
  ) async {
    if (state.teacherCourses.isLoading) {
      return;
    }
    if (!event.reset && state.teacherCourses.hasReachedMax) {
      return;
    }
    emit(
      state.copyWith(
        teacherCourses: state.teacherCourses.copyWith(
          paginationStatus: PaginationStatus.loading,
          page: event.reset ? 1 : null,
          hasReachedMax: event.reset ? false : null,
          items: event.reset ? [] : null,
        ),
      ),
    );
    final response = await getTeacherDetailsUsecase(
      TeacherDetailsParams(
        teacherId: event.teacherId,
        page: state.teacherCourses.page,
        limit: kPageSize,
      ),
    );

    response.fold(
      (l) {
        emit(
          state.copyWith(
            teacherCourses: state.teacherCourses.copyWith(
              paginationStatus: PaginationStatus.failure,
            ),
            errorMessage: l.message,
          ),
        );
      },
      (r) {
        emit(
          state.copyWith(
            teacherDetails: r.teacher,
            teacherCourses: state.teacherCourses.copyWith(
              paginationStatus: PaginationStatus.success,
              items: [
                ...state.teacherCourses.items,
                ...(r.courses?.data ?? []),
              ],
              hasReachedMax: (r.courses?.data?.length ?? 0) < kPageSize,
              page: state.teacherCourses.page,
            ),
          ),
        );
      },
    );
  }

  FutureOr<void> _onClearState(
    ClearTeachersState event,
    Emitter<TeachersState> emit,
  ) {
    emit(TeachersState());
  }

  FutureOr<void> _onAddOrDeleteTeacherAffiliations(
    AddOrDeleteTeacherAffiliations event,
    Emitter<TeachersState> emit,
  ) async {
    emit(state.copyWith(affiliationsStatus: Status.loading));
    final res = await addOrRemoveAffiliationsUsecase(event.params);
    res.fold(
      (l) => emit(
        state.copyWith(
          affiliationsStatus: Status.failure,
          errorMessage: l.message,
        ),
      ),
      (r) {
        add(GetTeacherAffiliations());
      },
    );
  }

  FutureOr<void> _onGetTeacherAffiliations(
    GetTeacherAffiliations event,
    Emitter<TeachersState> emit,
  ) async {
    emit(state.copyWith(affiliationsStatus: Status.loading));
    final res = await getTeacherAffiliationsUsecase(NoParams());
    res.fold(
      (l) => emit(
        state.copyWith(
          affiliationsStatus: Status.failure,
          errorMessage: l.message,
        ),
      ),
      (r) => emit(
        state.copyWith(affiliationsStatus: Status.loaded, affiliations: r),
      ),
    );
  }

  FutureOr<void> _onGetRevenuesEvent(
    GetRevenuesEvent event,
    Emitter<TeachersState> emit,
  ) async {
    emit(state.copyWith(getRevenues: Status.loading));
    final res = await getRevenueUsecase(NoParams());
    res.fold(
      (l) => emit(
        state.copyWith(getRevenues: Status.failure, errorMessage: l.message),
      ),
      (r) => emit(
        state.copyWith(getRevenues: Status.loaded, teacherRevenueModel: r),
      ),
    );
  }

  FutureOr<void> _onGetWithdrawalsEvent(
    GetWithdrawalsEvent event,
    Emitter<TeachersState> emit,
  ) async {
    if (state.withdrawalsPagination.isLoading) {
      return;
    }
    if (!event.reset && state.withdrawalsPagination.hasReachedMax) {
      return;
    }
    emit(
      state.copyWith(
        withdrawalsPagination: state.withdrawalsPagination.copyWith(
          paginationStatus: PaginationStatus.loading,
          page: event.reset ? 1 : null,
          hasReachedMax: event.reset ? false : null,
          items: event.reset ? [] : null,
        ),
      ),
    );
    final response = await getWithdrawalsUsecase(
      GetWithdrawalsParams(
        page: state.withdrawalsPagination.page,
        limit: kPageSize,
      ),
    );

    response.fold(
      (l) {
        emit(
          state.copyWith(
            teacherCourses: state.teacherCourses.copyWith(
              paginationStatus: PaginationStatus.failure,
            ),
            errorMessage: l.message,
          ),
        );
      },
      (r) {
        emit(
          state.copyWith(
            teacherWithdrawalModel: state.teacherWithdrawalModel ?? r,
            withdrawalsPagination: state.withdrawalsPagination.copyWith(
              paginationStatus: PaginationStatus.success,
              items: [
                ...state.withdrawalsPagination.items,
                ...(r.withdrawals ?? []),
              ],
              hasReachedMax: (r.withdrawals?.length ?? 0) < kPageSize,
              page: state.withdrawalsPagination.page,
            ),
          ),
        );
      },
    );
  }
}
