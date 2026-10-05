import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:coursaty_student_and_teacher/core/common/helper/helper_functions.dart';
import 'package:coursaty_student_and_teacher/core/models/pagination_model.dart';
import 'package:coursaty_student_and_teacher/core/use_case/use_case.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_category.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_rating.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_statistcis_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/get_teacher_courses_model.dart'
    hide YearElement;
import 'package:coursaty_student_and_teacher/features/courses/data/model/lecture_details_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/video_interaction_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/domain/use_case/get_course_rating_usecase.dart';
import 'package:coursaty_student_and_teacher/features/courses/domain/use_case/get_course_statistics_usecase.dart';
import 'package:coursaty_student_and_teacher/features/courses/domain/use_case/get_course_teacher_details_usecase.dart';
import 'package:coursaty_student_and_teacher/features/courses/domain/use_case/get_courses_by_year_use_case.dart';
import 'package:coursaty_student_and_teacher/features/courses/domain/use_case/get_courses_categories_usecase.dart';
import 'package:coursaty_student_and_teacher/features/courses/domain/use_case/get_courses_with_filtering_usecase.dart';
import 'package:coursaty_student_and_teacher/features/courses/domain/use_case/get_lecture_details_usecase.dart';
import 'package:coursaty_student_and_teacher/features/courses/domain/use_case/get_teacher_courses_usecase.dart';
import 'package:coursaty_student_and_teacher/features/courses/domain/use_case/get_video_interactions_usecase.dart';
import 'package:coursaty_student_and_teacher/features/courses/domain/use_case/get_video_resolutions_usecase.dart';
import 'package:coursaty_student_and_teacher/features/courses/domain/use_case/toggle_video_interaction_usecase.dart';
import 'package:coursaty_student_and_teacher/features/home/presentation/bloc/home_bloc.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/presentation/bloc/my_downloads_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:injectable_generator/utils.dart';
import 'package:meta/meta.dart';

import '../../../../core/enums/request_status.dart';
import '../../data/model/course_details_model.dart';
import '../../data/model/course_model.dart';
import '../../data/model/courses_of_subject_response_model.dart';
import '../../data/model/resulotion_model.dart';
import '../../data/model/teacher_course_details_model.dart';
import '../../domain/use_case/get_course_details_use_case.dart';
import '../../domain/use_case/get_courses_by_subject_use_case.dart';
import '../../domain/use_case/rate_course_use_case.dart';

part 'courses_event.dart';

part 'courses_state.dart';

@LazySingleton()
class CoursesBloc extends Bloc<CoursesEvent, CoursesState> {
  final GetCoursesBySubjectUseCase getSubjectCoursesUseCase;
  final GetCourseDetailsUseCase getCourseDetailsUseCase;
  final GetLectureDetailsUsecase getLectureDetailsUsecase;
  final GetCoursesWithFilteringUsecase getCoursesWithFilteringUsecase;
  final RateCourseUseCase rateCourseUseCase;
  final GetCoursesCategoriesUsecase getCoursesCategoriesUsecase;
  final GetCoursesByYearUseCase getCoursesByYearUseCase;
  final GetCourseRatingUsecase getCourseRatingUsecase;
  final GetTeacherCoursesUsecase getTeacherCoursesUsecase;

  final GetCourseTeacherDetailsUsecase getCourseTeacherDetailsUsecase;
  final GetCourseStatisticsUsecase getCourseStatisticsUsecase;

  final GetVideoResolutionsUsecase getVideoResolutionsUsecase;
  final GetVideoInteractionsUsecase getVideoInteractionsUsecase;
  final ToggleVideoInteractionUsecase toggleVideoInteractionUsecase;

  CoursesBloc({
    required this.getSubjectCoursesUseCase,
    required this.getCourseDetailsUseCase,
    required this.getLectureDetailsUsecase,
    required this.getCoursesWithFilteringUsecase,
    required this.rateCourseUseCase,
    required this.getCoursesCategoriesUsecase,
    required this.getCoursesByYearUseCase,
    required this.getCourseRatingUsecase,
    required this.getTeacherCoursesUsecase,
    required this.getCourseTeacherDetailsUsecase,
    required this.getCourseStatisticsUsecase,
    required this.getVideoResolutionsUsecase,
    required this.getVideoInteractionsUsecase,
    required this.toggleVideoInteractionUsecase,
  }) : super(CoursesState()) {
    on<GetCoursesBySubjectEvent>(
      (event, emit) => _onGetSubjectCoursesEvent(event, emit),
    );
    on<GetCourseDetailsEvent>(_onGetCourseDetailsEvent);
    on<GetCoursesWithFilteringEvent>(_onGetCoursesWithFilteringEvent);
    on<GetLectureDetailsEvent>(_onGetLectureDetailsEvent);
    on<RateCourseEvent>((event, emit) => _onRateCourseEvent(event, emit));
    on<GetCoursesCategoriesEvent>(_onGetCoursesCategoriesEvent);
    on<GetCoursesByYearEvent>(_onGetCoursesByYearEvent);
    on<GetCourseRating>(_onGetCourseRating);
    on<ClearCoursesState>(_onClearState);
    on<GetTeacherCourses>(_onGetTeacherCourses);
    on<GetCourseStatisticsEvent>(_onGetCourseStatisticsEvent);
    on<GetTeacherCourseDetailsEvent>(_onGetTeacherCourseDetailsEvent);
    on<GetVideoResolutionsEvent>(_onGetVideoResolutionsEvent);
    on<RemoveQuestionFromLecture>(_onRemoveQuestionFromLecture);
    on<GetVideoInteractionsEvent>(_onGetVideoInteractionsEvent);
    on<ToggleVideoInteractionEvent>(_onToggleVideoInteractionEvent);
  }

  FutureOr<void> _onGetCoursesCategoriesEvent(
    GetCoursesCategoriesEvent event,
    Emitter<CoursesState> emit,
  ) async {
    emit(state.copyWith(getCoursesCategories: Status.loading));
    final res = await getCoursesCategoriesUsecase(NoParams());
    res.fold(
      (l) => emit(
        state.copyWith(
          getCoursesCategories: Status.failure,
          errorMessage: l.message,
        ),
      ),
      (r) => emit(
        state.copyWith(
          getCoursesCategories: Status.loaded,
          coursesCategories: r,
        ),
      ),
    );
  }

  FutureOr<void> _onGetSubjectCoursesEvent(
    GetCoursesBySubjectEvent event,
    Emitter<CoursesState> emit,
  ) async {
    if (state.coursesOfSubject.isLoading) {
      return;
    }

    if (!event.reset && state.coursesOfSubject.hasReachedMax) {
      return;
    }
    emit(
      state.copyWith(
        coursesOfSubject: state.coursesOfSubject.copyWith(
          paginationStatus: PaginationStatus.loading,
          page: event.reset ? 1 : null,
          hasReachedMax: event.reset ? false : null,
          items: event.reset ? [] : null,
        ),
      ),
    );
    final response = await getSubjectCoursesUseCase(
      ParamGetCoursesBySubject(
        event.subjectId,
        page: state.coursesOfSubject.page,
        limit: kPageSize,
      ),
    );

    response.fold(
      (l) {
        emit(
          state.copyWith(
            coursesOfSubject: state.coursesOfSubject.copyWith(
              paginationStatus: PaginationStatus.failure,
            ),
            errorMessage: l.message,
          ),
        );
      },
      (r) {
        emit(
          state.copyWith(
            coursesOfSubject: state.coursesOfSubject.copyWith(
              paginationStatus: PaginationStatus.success,
              items: [
                ...state.coursesOfSubject.items,
                ...(r.courses?.data ?? []),
              ],
              hasReachedMax: (r.courses?.data?.length ?? 0) < kPageSize,
              page: state.coursesOfSubject.page,
            ),
          ),
        );
      },
    );
  }

  FutureOr<void> _onGetCoursesWithFilteringEvent(
    GetCoursesWithFilteringEvent event,
    Emitter<CoursesState> emit,
  ) async {
    if (state.coursesWithFiltering.isLoading) {
      return;
    }

    if (!event.reset && state.coursesWithFiltering.hasReachedMax) {
      return;
    }
    emit(
      state.copyWith(
        programCourses: event.reset ? [] : null,
        coursesWithFiltering: state.coursesWithFiltering.copyWith(
          paginationStatus: PaginationStatus.loading,
          page: event.reset ? 1 : null,
          hasReachedMax: event.reset ? false : null,
          items: event.reset ? [] : null,
        ),
      ),
    );
    final response = await getCoursesWithFilteringUsecase(
      ParamGetCoursesWithFilters(
        page: state.coursesWithFiltering.page,
        limit: kPageSize,
        categoryId: event.categoryId,
        filter: event.filter,
      ),
    );

    response.fold(
      (l) {
        emit(
          state.copyWith(
            coursesWithFiltering: state.coursesWithFiltering.copyWith(
              paginationStatus: PaginationStatus.failure,
            ),
            errorMessage: l.message,
          ),
        );
      },
      (r) {
        emit(
          state.copyWith(
            programCourses: [
              ...(state.programCourses ?? []),
              ...(r.courses ?? []),
            ],
            coursesWithFiltering: state.coursesWithFiltering.copyWith(
              paginationStatus: PaginationStatus.success,
              items: [...state.coursesWithFiltering.items, ...(r.years ?? [])],
              hasReachedMax: (r.years?.length ?? 0) < kPageSize,
              page: state.coursesWithFiltering.page,
            ),
          ),
        );
      },
    );
  }

  FutureOr<void> _onGetCourseDetailsEvent(
    GetCourseDetailsEvent event,
    Emitter<CoursesState> emit,
  ) async {
    final CourseDetailsModel? storedCourse = GetIt.I<MyDownloadsBloc>()
        .state
        .courseIdToCourseDetailsReferences[event.courseId];
    emit(state.copyWith(getCourseDetailsStatus: Status.loading));
    if ((await HelperFunctions.lostInternetConnection()) &&
        storedCourse != null) {
      emit(
        state.copyWith(
          getCourseDetailsStatus: Status.loaded,
          courseDetailsModel: storedCourse,
        ),
      );
      return;
    }
    final res = await getCourseDetailsUseCase(
      ParamGetCourseDetails(courseId: event.courseId),
    );
    res.fold(
      (l) => emit(
        state.copyWith(
          getCourseDetailsStatus: Status.failure,
          errorMessage: l.message,
          resetCourse: true,
        ),
      ),
      (r) {
        final activeCourses = GetIt.I<HomeBloc>().state.activeCourses;
        final coursePurchased = activeCourses.indexWhere(
          (item) => item.id == event.courseId,
        );
        final courseFree = (r.course?.isFree ?? false);
        if (coursePurchased != -1 || courseFree) {
          GetIt.I<MyDownloadsBloc>().add(
            SaveCourseDetailsInLocalEvent(
              courseDetailsModel: r.copyWith(
                subscriptionExpiresAt: coursePurchased == -1
                    ? null
                    : activeCourses[coursePurchased].subscriptionExpiresAt,
                subscribedAt: coursePurchased == -1
                    ? null
                    : activeCourses[coursePurchased].subscribedAt,
              ),
            ),
          );
        }
        emit(
          state.copyWith(
            getCourseDetailsStatus: Status.loaded,
            courseDetailsModel: r,
          ),
        );
      },
    );
  }

  FutureOr<void> _onGetLectureDetailsEvent(
    GetLectureDetailsEvent event,
    Emitter<CoursesState> emit,
  ) async {
    final LectureDetailsModel? storedLecture = GetIt.I<MyDownloadsBloc>()
        .state
        .lectureIdToLectureDetailsReferences[event.lectureId];
    emit(state.copyWith(getLectureDetails: Status.loading));
    if ((await HelperFunctions.lostInternetConnection()) &&
        storedLecture != null) {
      emit(
        state.copyWith(
          getLectureDetails: Status.loaded,
          lectureDetailsModel: storedLecture,
        ),
      );
      return;
    }
    emit(state.copyWith(getLectureDetails: Status.loading, resetLecture: true));
    final res = await getLectureDetailsUsecase(
      GetLectureDetailsParams(lectureId: event.lectureId),
    );
    res.fold(
      (l) => emit(
        state.copyWith(
          getLectureDetails: Status.failure,
          errorMessage: l.message,
        ),
      ),
      (r) {
        final purchasedCourses =
            GetIt.I<MyDownloadsBloc>().state.courseIdToCourseDetailsReferences;
        final courseOfLecturePurchased = purchasedCourses.values.any(
          (item) => item.course?.id == event.courseId,
        );
        bool containFreeContent = false;
        containFreeContent =
            r.files?.any((item) {
              if (item.isFree ?? false) {
                return true;
              }
              return false;
            }) ??
            false;
        containFreeContent |=
            (r.videos?.any((item) {
              if (item.isFree ?? false) {
                return true;
              }
              return false;
            }) ??
            false);
        if (courseOfLecturePurchased || containFreeContent) {
          GetIt.I<MyDownloadsBloc>().add(
            SaveLectureDetailsInLocalEvent(
              lectureDetailsModel: r,
              courseId: event.courseId,
            ),
          );
        }
        emit(
          state.copyWith(
            getLectureDetails: Status.loaded,
            lectureDetailsModel: r,
          ),
        );
      },
    );
  }

  FutureOr<void> _onRateCourseEvent(
    RateCourseEvent event,
    Emitter<CoursesState> emit,
  ) async {
    emit(state.copyWith(rateCourseOrGetCourseRateStatus: Status.loading));
    final res = await rateCourseUseCase(
      ParamRateCourse(courseId: event.courseId, stars: event.stars),
    );
    res.fold(
      (l) => emit(
        state.copyWith(
          rateCourseOrGetCourseRateStatus: Status.failure,
          errorMessage: l.message,
        ),
      ),
      (r) => add(GetCourseRating(courseId: event.courseId)),
    );
  }

  FutureOr<void> _onGetCoursesByYearEvent(
    GetCoursesByYearEvent event,
    Emitter<CoursesState> emit,
  ) async {
    if (state.coursesOfYear.isLoading) {
      return;
    }

    if (!event.reset && state.coursesOfYear.hasReachedMax) {
      return;
    }
    emit(
      state.copyWith(
        coursesOfYear: state.coursesOfYear.copyWith(
          paginationStatus: PaginationStatus.loading,
          page: event.reset ? 1 : null,
          hasReachedMax: event.reset ? false : null,
          items: event.reset ? [] : null,
        ),
      ),
    );
    final response = await getCoursesByYearUseCase(
      ParamGetCoursesByYear(
        event.yearId,
        page: state.coursesOfYear.page,
        limit: kPageSize,
      ),
    );

    response.fold(
      (l) {
        emit(
          state.copyWith(
            coursesOfYear: state.coursesOfYear.copyWith(
              paginationStatus: PaginationStatus.failure,
            ),
            errorMessage: l.message,
          ),
        );
      },
      (r) {
        emit(
          state.copyWith(
            coursesOfYear: state.coursesOfYear.copyWith(
              paginationStatus: PaginationStatus.success,
              items: [...state.coursesOfYear.items, ...r],
              hasReachedMax: r.length < kPageSize,
              page: state.coursesOfYear.page,
            ),
          ),
        );
      },
    );
  }

  FutureOr<void> _onClearState(
    ClearCoursesState event,
    Emitter<CoursesState> emit,
  ) {
    emit(CoursesState());
  }

  FutureOr<void> _onGetCourseRating(
    GetCourseRating event,
    Emitter<CoursesState> emit,
  ) async {
    emit(state.copyWith(rateCourseOrGetCourseRateStatus: Status.loading));
    final res = await getCourseRatingUsecase(event.courseId);
    res.fold(
      (l) => emit(
        state.copyWith(
          rateCourseOrGetCourseRateStatus: Status.failure,
          errorMessage: l.message,
        ),
      ),
      (r) => emit(
        state.copyWith(
          rateCourseOrGetCourseRateStatus: Status.loaded,
          courseRatingModel: r,
        ),
      ),
    );
  }

  FutureOr<void> _onGetTeacherCourses(
    GetTeacherCourses event,
    Emitter<CoursesState> emit,
  ) async {
    if (state.teacherActiveCourses.isLoading && event.getActive) {
      return;
    }
    if (state.teacherExpiredCourses.isLoading && !event.getActive) {
      return;
    }
    if (!event.reset &&
        (state.teacherActiveCourses.hasReachedMax && event.getActive)) {
      return;
    }
    if (!event.reset &&
        (state.teacherExpiredCourses.hasReachedMax && !event.getActive)) {
      return;
    }
    emit(
      state.copyWith(
        teacherActiveCourses: event.getActive
            ? state.teacherActiveCourses.copyWith(
                paginationStatus: PaginationStatus.loading,
                page: event.reset ? 1 : null,
                hasReachedMax: event.reset ? false : null,
                items: event.reset ? [] : null,
              )
            : null,
        teacherExpiredCourses: !event.getActive
            ? state.teacherExpiredCourses.copyWith(
                paginationStatus: PaginationStatus.loading,
                page: event.reset ? 1 : null,
                hasReachedMax: event.reset ? false : null,
                items: event.reset ? [] : null,
              )
            : null,
      ),
    );
    final response = await getTeacherCoursesUsecase(
      GetTeacherCoursesParams(
        getActive: event.getActive,
        page: event.getActive
            ? state.teacherActiveCourses.page
            : state.teacherExpiredCourses.page,
        limit: kPageSize,
      ),
    );

    response.fold(
      (l) {
        emit(
          state.copyWith(
            teacherActiveCourses: event.getActive
                ? state.teacherActiveCourses.copyWith(
                    paginationStatus: PaginationStatus.failure,
                  )
                : null,
            teacherExpiredCourses: !event.getActive
                ? state.teacherExpiredCourses.copyWith(
                    paginationStatus: PaginationStatus.failure,
                  )
                : null,
            errorMessage: l.message,
          ),
        );
      },
      (r) {
        emit(
          state.copyWith(
            teacherActiveCourses: event.getActive
                ? event.reset
                      ? state.teacherActiveCourses.copyWith(
                          paginationStatus: PaginationStatus.success,
                          items: r.universities ?? [],
                          hasReachedMax: (r.pagination?.total ?? 0) < kPageSize,
                          page: state.teacherActiveCourses.page + 1,
                        )
                      : _getPaginatedCourses(state.teacherActiveCourses, r)
                : null,
            teacherExpiredCourses: !event.getActive
                ? event.reset
                      ? state.teacherExpiredCourses.copyWith(
                          paginationStatus: PaginationStatus.success,
                          items: r.universities ?? [],
                          hasReachedMax: (r.pagination?.total ?? 0) < kPageSize,
                          page: state.teacherExpiredCourses.page + 1,
                        )
                      : _getPaginatedCourses(state.teacherExpiredCourses, r)
                : null,
          ),
        );
      },
    );
  }

  PaginationModel<UniversityElement>? _getPaginatedCourses(
    PaginationModel<UniversityElement> teacherCourses,
    TeacherCoursesResponseModel r,
  ) {
    return teacherCourses.copyWith(
      items: teacherCourses.items.map((item) {
        return item.copyWith(
          years: item.years?.map((year) {
            return year.copyWith(
              courses: [
                ...(year.courses ?? []),
                ...(r.universities
                        ?.firstWhereOrNull(
                          (i) => i.university?.id == item.university?.id,
                        )
                        ?.years
                        ?.firstWhereOrNull((j) => j.year?.id == year.year?.id)
                        ?.courses ??
                    []),
              ],
            );
          }).toList(),
        );
      }).toList(),
      hasReachedMax: (r.pagination?.total ?? 0) < kPageSize,
      page: teacherCourses.page + 1,
      paginationStatus: PaginationStatus.success,
    );
  }

  FutureOr<void> _onGetTeacherCourseDetailsEvent(
    GetTeacherCourseDetailsEvent event,
    Emitter<CoursesState> emit,
  ) async {
    emit(state.copyWith(getTeacherCourseDetails: Status.loading));
    final res = await getCourseTeacherDetailsUsecase(
      ParamGetCourseDetails(courseId: event.courseId),
    );
    res.fold(
      (l) => emit(
        state.copyWith(
          getTeacherCourseDetails: Status.failure,
          errorMessage: l.message,
        ),
      ),
      (r) {
        emit(
          state.copyWith(
            getTeacherCourseDetails: Status.loaded,
            teacherCourseDetailsResponseModel: r,
          ),
        );
      },
    );
  }

  FutureOr<void> _onGetCourseStatisticsEvent(
    GetCourseStatisticsEvent event,
    Emitter<CoursesState> emit,
  ) async {
    emit(state.copyWith(getCourseStatistics: Status.loading));
    final res = await getCourseStatisticsUsecase(
      ParamGetCourseDetails(courseId: event.courseId),
    );
    res.fold(
      (l) => emit(
        state.copyWith(
          getCourseStatistics: Status.failure,
          errorMessage: l.message,
        ),
      ),
      (r) {
        emit(
          state.copyWith(
            getCourseStatistics: Status.loaded,
            courseStatisticsModel: r,
          ),
        );
      },
    );
  }

  FutureOr<void> _onGetVideoResolutionsEvent(
    GetVideoResolutionsEvent event,
    Emitter<CoursesState> emit,
  ) async {
    emit(state.copyWith(getResolutions: Status.loading, resolutions: []));
    final res = await getVideoResolutionsUsecase(event.videoId);
    res.fold(
      (l) => emit(
        state.copyWith(getResolutions: Status.failure, errorMessage: l.message),
      ),
      (r) {
        emit(state.copyWith(getResolutions: Status.loaded, resolutions: r));
      },
    );
  }

  FutureOr<void> _onRemoveQuestionFromLecture(
    RemoveQuestionFromLecture event,
    Emitter<CoursesState> emit,
  ) {
    List<QuestionModel> questions = List.of(
      state.lectureDetailsModel?.questions ?? [],
    );
    questions.removeWhere((item) => item.id == event.questionId);
    emit(
      state.copyWith(
        lectureDetailsModel: state.lectureDetailsModel?.copyWith(
          questions: questions,
        ),
      ),
    );
  }

  FutureOr<void> _onGetVideoInteractionsEvent(
    GetVideoInteractionsEvent event,
    Emitter<CoursesState> emit,
  ) async {
    emit(state.copyWith(upsertVideoInteraction: Status.loading));
    final res = await getVideoInteractionsUsecase(event.videoId);
    res.fold(
      (l) => emit(
        state.copyWith(
          upsertVideoInteraction: Status.failure,
          errorMessage: l.message,
        ),
      ),
      (r) {
        emit(
          state.copyWith(
            upsertVideoInteraction: Status.loaded,
            videoInteractionModel: r,
          ),
        );
      },
    );
  }

  FutureOr<void> _onToggleVideoInteractionEvent(
    ToggleVideoInteractionEvent event,
    Emitter<CoursesState> emit,
  ) async {
    emit(state.copyWith(upsertVideoInteraction: Status.loading));
    final res = await toggleVideoInteractionUsecase(
      ToggleVideoInteractionParams(videoId: event.videoId, isLiked: "true"),
    );
    res.fold(
      (l) => emit(
        state.copyWith(
          upsertVideoInteraction: Status.failure,
          errorMessage: l.message,
        ),
      ),
      (r) {
        add(GetVideoInteractionsEvent(event.videoId));
      },
    );
  }
}
