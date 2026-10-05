import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:coursaty_student_and_teacher/core/enums/request_status.dart';
import 'package:coursaty_student_and_teacher/core/models/pagination_model.dart';
import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_model.dart';
import 'package:coursaty_student_and_teacher/features/home/data/models/filtered_subjects_response_model.dart';
import 'package:coursaty_student_and_teacher/features/home/data/models/home_response_model.dart';
import 'package:coursaty_student_and_teacher/features/home/data/models/search_response_model.dart';
import 'package:coursaty_student_and_teacher/features/home/data/models/teacher_summary_response_model.dart';
import 'package:coursaty_student_and_teacher/features/home/domain/usecases/get_advertisements_usecase.dart';
import 'package:coursaty_student_and_teacher/features/home/domain/usecases/get_all_programs_usecase.dart';
import 'package:coursaty_student_and_teacher/features/home/domain/usecases/get_home_content_usecase.dart';
import 'package:coursaty_student_and_teacher/features/home/domain/usecases/get_my_courses_usecase.dart';
import 'package:coursaty_student_and_teacher/features/home/domain/usecases/get_subjects_with_filtering_usecase.dart';
import 'package:coursaty_student_and_teacher/features/home/domain/usecases/get_teacher_summary_usecase.dart';
import 'package:coursaty_student_and_teacher/features/home/domain/usecases/search_usecase.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/presentation/bloc/my_downloads_bloc.dart';
import 'package:coursaty_student_and_teacher/features/norifications/data/model/notification_model.dart';
import 'package:coursaty_student_and_teacher/features/teachers/data/model/teacher_model.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../../core/common/helper/helper_functions.dart';
import '../../../../core/use_case/use_case.dart';

part 'home_event.dart';

part 'home_state.dart';

@LazySingleton()
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(
    this.getAdvertisementsUsecase,
    this.getHomeContentUsecase, {
    required this.getAllProgramsUsecase,
    required this.getSubjectsWithFilteringUsecase,
    required this.getMyCoursesUsecase,
    required this.getTeacherSummaryUsecase,
    required this.searchUsecase,
  }) : super(HomeState()) {
    on<HomeEvent>((event, emit) {});
    on<GetAdvertisementsEvent>(_onGetAdvertisementsEvent);
    on<GetHomeContentEvent>(_onGetHomeContentEvent);
    on<GetSubjectsWithFilteringEvent>(_onGetSubjectsWithFilteringEvent);
    on<GetMyActiveCourses>(_onGetMyActiveCourses);
    on<GetMyInActiveCourses>(_onGetMyInActiveCourses);
    on<ClearHomeState>(_onClearState);
    on<DeleteOutDatedCoursesEvent>(_onDeleteOutDatedCoursesEvent);
    on<GetTeacherSummaryEvent>(_onGetTeacherSummaryEvent);
    on<AddPendingNotificationEvent>(_onAddPendingNotificationEvent);
    on<GetAllPrograms>(_onGetAllPrograms);
    on<SearchEvent>(_onSearchEvent);
    on<ChangeCurrentScreenEvent>(_onChangeCurrentScreenEvent);
    on<ClearSearchResultsEvent>(_onClearSearchResultsEvent);
  }

  EventTransformer<T> restartableDebounce<T>({
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return (events, mapper) {
      return restartable<T>().call(events.debounce(duration), mapper);
    };
  }

  final GetTeacherSummaryUsecase getTeacherSummaryUsecase;

  final GetAdvertisementsUsecase getAdvertisementsUsecase;
  final GetHomeContentUsecase getHomeContentUsecase;
  final GetAllProgramsUsecase getAllProgramsUsecase;
  final GetSubjectsWithFilteringUsecase getSubjectsWithFilteringUsecase;
  final GetMyCoursesUsecase getMyCoursesUsecase;
  final SearchUsecase searchUsecase;

  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();
  FutureOr<void> _onGetAdvertisementsEvent(
    GetAdvertisementsEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(getAdvertisements: Status.loading));
    final res = await getAdvertisementsUsecase(NoParams());
    res.fold(
      (l) => emit(
        state.copyWith(
          getAdvertisements: Status.failure,
          errorMessage: l.message,
        ),
      ),
      (r) => emit(
        state.copyWith(getAdvertisements: Status.loaded, advertisements: r),
      ),
    );
  }

  FutureOr<void> _onGetHomeContentEvent(
    GetHomeContentEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(getHomeContent: Status.loading));
    final res = await getHomeContentUsecase(15);
    res.fold(
      (l) => emit(
        state.copyWith(getHomeContent: Status.failure, errorMessage: l.message),
      ),
      (r) => emit(
        state.copyWith(getHomeContent: Status.loaded, homeResponseModel: r),
      ),
    );
  }

  FutureOr<void> _onGetSubjectsWithFilteringEvent(
    GetSubjectsWithFilteringEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(getSubjectsWithFiltering: Status.loading));
    final res = await getSubjectsWithFilteringUsecase(
      GetIt.I<PrefsRepository>().yearCollegeId!,
    );
    res.fold(
      (l) => emit(
        state.copyWith(
          getSubjectsWithFiltering: Status.failure,
          errorMessage: l.message,
        ),
      ),
      (r) => emit(
        state.copyWith(
          getSubjectsWithFiltering: Status.loaded,
          studentSubjectsModel: r,
        ),
      ),
    );
  }

  FutureOr<void> _onGetMyActiveCourses(
    GetMyActiveCourses event,
    Emitter<HomeState> emit,
  ) async {
    if (_prefsRepository.isGuest) {
      return;
    }
    final List<CourseModel> courses = GetIt.I<MyDownloadsBloc>().state.courses;
    emit(state.copyWith(getActiveCourses: Status.loading));
    if ((await HelperFunctions.lostInternetConnection())) {
      emit(
        state.copyWith(getActiveCourses: Status.loaded, activeCourses: courses),
      );
      return;
    }
    emit(state.copyWith(getActiveCourses: Status.loading));
    final res = await getMyCoursesUsecase(true);
    res.fold(
      (l) => emit(
        state.copyWith(
          getActiveCourses: Status.failure,
          errorMessage: l.message,
        ),
      ),
      (r) {
        emit(state.copyWith(getActiveCourses: Status.loaded, activeCourses: r));
        GetIt.I<MyDownloadsBloc>().add(SaveCoursesInLocalEvent(r));
      },
    );
  }

  FutureOr<void> _onGetMyInActiveCourses(
    GetMyInActiveCourses event,
    Emitter<HomeState> emit,
  ) async {
    if (_prefsRepository.isGuest) {
      return;
    }
    emit(state.copyWith(getActiveCourses: Status.loading));
    if ((await HelperFunctions.lostInternetConnection())) {
      emit(
        state.copyWith(getActiveCourses: Status.loaded, inActiveCourses: []),
      );
      return;
    }
    emit(state.copyWith(getInActiveCourses: Status.loading));
    final res = await getMyCoursesUsecase(false);
    res.fold(
      (l) => emit(
        state.copyWith(
          getInActiveCourses: Status.failure,
          errorMessage: l.message,
        ),
      ),
      (r) => emit(
        state.copyWith(getInActiveCourses: Status.loaded, inActiveCourses: r),
      ),
    );
  }

  FutureOr<void> _onClearState(ClearHomeState event, Emitter<HomeState> emit) {
    emit(HomeState());
  }

  FutureOr<void> _onDeleteOutDatedCoursesEvent(
    DeleteOutDatedCoursesEvent event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(isDeleting: true));
    List<CourseModel> activeCourses = List.of(state.activeCourses);
    activeCourses.removeWhere((course) {
      bool willRemoved =
          course.subscriptionExpiresAt != null &&
          !DateTime.now().difference(course.subscriptionExpiresAt!).isNegative;
      if (willRemoved) {
        final courseId = course.id!;
        GetIt.I<MyDownloadsBloc>().add(
          DeleteEveryThingRelatedToCourse(courseId),
        );
      }
      return willRemoved;
    });
    emit(state.copyWith(isDeleting: false));
  }

  FutureOr<void> _onGetTeacherSummaryEvent(
    GetTeacherSummaryEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(getTeacherSummary: Status.loading));
    final res = await getTeacherSummaryUsecase(NoParams());
    res.fold(
      (l) => emit(
        state.copyWith(
          getTeacherSummary: Status.failure,
          errorMessage: l.message,
        ),
      ),
      (r) => emit(
        state.copyWith(
          getTeacherSummary: Status.loaded,
          teacherSummaryResponseModel: r,
        ),
      ),
    );
  }

  FutureOr<void> _onAddPendingNotificationEvent(
    AddPendingNotificationEvent event,
    Emitter<HomeState> emit,
  ) {
    emit(
      state.copyWith(
        counterToForceUpdate: state.counterToForceUpdate + 1,
        teacherSummaryResponseModel: state.teacherSummaryResponseModel
            ?.copyWith(
              pendingNotifications: [
                event.notification,
                ...(state.teacherSummaryResponseModel!.pendingNotifications ??
                    []),
              ],
            ),
      ),
    );
  }

  FutureOr<void> _onGetAllPrograms(
    GetAllPrograms event,
    Emitter<HomeState> emit,
  ) async {
    if (state.allPrograms.isLoading) {
      return;
    }

    if (!event.reset && state.allPrograms.hasReachedMax) {
      return;
    }
    emit(
      state.copyWith(
        allPrograms: state.allPrograms.copyWith(
          paginationStatus: PaginationStatus.loading,
          page: event.reset ? 1 : null,
          hasReachedMax: event.reset ? false : null,
          items: event.reset ? [] : null,
        ),
      ),
    );
    final response = await getAllProgramsUsecase(
      GetAllProgramsParams(page: state.allPrograms.page, limit: kPageSize),
    );

    response.fold(
      (l) {
        emit(
          state.copyWith(
            allPrograms: state.allPrograms.copyWith(
              paginationStatus: PaginationStatus.failure,
            ),
            errorMessage: l.message,
          ),
        );
      },
      (r) {
        emit(
          state.copyWith(
            allPrograms: state.allPrograms.copyWith(
              paginationStatus: PaginationStatus.success,
              items: [...state.allPrograms.items, ...r],
              hasReachedMax: r.length < kPageSize,
              page: state.allPrograms.page + 1,
            ),
          ),
        );
      },
    );
  }

  FutureOr<void> _onSearchEvent(
    SearchEvent event,
    Emitter<HomeState> emit,
  ) async {
    final hasReachedMax = state.courses.hasReachedMax;

    if (!event.reset && hasReachedMax) {
      return;
    }

    emit(
      state.copyWith(
        subjects: event.reset ? [] : null,
        programs: event.reset ? [] : null,
        teachers: event.reset ? [] : null,
        courses: state.courses.copyWith(
          paginationStatus: PaginationStatus.loading,
          page: event.reset ? 1 : null,
          hasReachedMax: event.reset ? false : null,
          items: event.reset ? [] : null,
        ),
      ),
    );

    final response = await searchUsecase(
      SearchParams(
        query: event.query,
        page: state.courses.page,
        limit: kPageSize,
      ),
    );

    response.fold(
      (l) {
        emit(
          state.copyWith(
            courses: state.courses.copyWith(
              paginationStatus: PaginationStatus.failure,
            ),
            errorMessage: l.message,
          ),
        );
      },
      (r) {
        emit(
          state.copyWith(
            courses: state.courses.copyWith(
              paginationStatus: PaginationStatus.success,
              items: [...state.courses.items, ...(r.courses ?? [])],
              hasReachedMax: (r.courses?.length ?? 0) < kPageSize,
              page: state.courses.page + 1,
            ),

            teachers: r.teachers,

            subjects: r.subjects,
            programs: r.programs,
          ),
        );
      },
    );
  }

  FutureOr<void> _onChangeCurrentScreenEvent(
    ChangeCurrentScreenEvent event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(newPageInHome: event.newPage));
  }

  FutureOr<void> _onClearSearchResultsEvent(
    ClearSearchResultsEvent event,
    Emitter<HomeState> emit,
  ) {
    emit(
      state.copyWith(
        courses: PaginationModel.init(),
        subjects: [],
        programs: [],
        teachers: [],
      ),
    );
  }
}
