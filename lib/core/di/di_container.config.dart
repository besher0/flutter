// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:logger/logger.dart' as _i974;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../app/blocs/sensitive_connectivity/sensitive_connectivity_bloc.dart'
    as _i980;
import '../../features/app/data/repositories/app_repository_impl.dart' as _i111;
import '../../features/app/data/sources/app_remote_datasource.dart' as _i979;
import '../../features/app/domain/repository/app_repository.dart' as _i544;
import '../../features/app/domain/usecases/get_customer_service_usecase.dart'
    as _i418;
import '../../features/app/domain/usecases/scan_code_usecase.dart' as _i618;
import '../../features/app/presentation/bloc/app_bloc.dart' as _i120;
import '../../features/auth/data/repository/auth_repository_imp.dart' as _i794;
import '../../features/auth/data/sources/auth_remote_data_source.dart' as _i874;
import '../../features/auth/domain/repository/auth_repository.dart' as _i961;
import '../../features/auth/domain/use_case/change_password_usecase.dart'
    as _i607;
import '../../features/auth/domain/use_case/create_guest_account_usecase.dart'
    as _i875;
import '../../features/auth/domain/use_case/delete_account_usecase.dart'
    as _i812;
import '../../features/auth/domain/use_case/edit_profile_usecase.dart' as _i418;
import '../../features/auth/domain/use_case/get_academic_years_usecase.dart'
    as _i207;
import '../../features/auth/domain/use_case/get_colleges_usecase.dart' as _i74;
import '../../features/auth/domain/use_case/get_departments_usecase.dart'
    as _i939;
import '../../features/auth/domain/use_case/get_guest_account_usecase.dart'
    as _i413;
import '../../features/auth/domain/use_case/get_profile_usecase.dart' as _i634;
import '../../features/auth/domain/use_case/get_universities_usecase.dart'
    as _i451;
import '../../features/auth/domain/use_case/log_in_use_case.dart' as _i153;
import '../../features/auth/domain/use_case/sign_up_use_case.dart' as _i426;
import '../../features/auth/domain/use_case/update_student_usecase.dart'
    as _i477;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;
import '../../features/common/data/repositories/upload_file_repository_impl.dart'
    as _i975;
import '../../features/common/data/sources/upload_file_remote_datasource.dart'
    as _i729;
import '../../features/common/domain/repositories/upload_file_repository.dart'
    as _i587;
import '../../features/common/domain/usecases/upload_file_usecase.dart'
    as _i942;
import '../../features/course_content_management/data/repositories/course_content_management_repository_impl.dart'
    as _i1;
import '../../features/course_content_management/data/sources/course_content_management_datasource.dart'
    as _i91;
import '../../features/course_content_management/domain/repositories/course_content_management_repository.dart'
    as _i599;
import '../../features/course_content_management/domain/usecases/delete_from_course_usecase.dart'
    as _i577;
import '../../features/course_content_management/domain/usecases/delete_video_segment_usecase.dart'
    as _i442;
import '../../features/course_content_management/domain/usecases/get_allowed_subjects_usecase.dart'
    as _i791;
import '../../features/course_content_management/domain/usecases/get_seasons_usecase.dart'
    as _i48;
import '../../features/course_content_management/domain/usecases/get_video_segements_usecase.dart'
    as _i525;
import '../../features/course_content_management/domain/usecases/upsert_course_usecase.dart'
    as _i1003;
import '../../features/course_content_management/domain/usecases/upsert_file_usecase.dart'
    as _i294;
import '../../features/course_content_management/domain/usecases/upsert_lecture_usecase.dart'
    as _i232;
import '../../features/course_content_management/domain/usecases/upsert_question_usecase.dart'
    as _i1069;
import '../../features/course_content_management/domain/usecases/upsert_video_segment_usecase.dart'
    as _i212;
import '../../features/course_content_management/domain/usecases/upsert_video_usecase.dart'
    as _i459;
import '../../features/course_content_management/presentation/bloc/course_content_management_bloc.dart'
    as _i747;
import '../../features/courses/data/repository/course_repository_imp.dart'
    as _i353;
import '../../features/courses/data/source/courses_remote_data_source.dart'
    as _i712;
import '../../features/courses/domain/repository/courses_repository.dart'
    as _i604;
import '../../features/courses/domain/use_case/get_course_details_use_case.dart'
    as _i706;
import '../../features/courses/domain/use_case/get_course_rating_usecase.dart'
    as _i97;
import '../../features/courses/domain/use_case/get_course_statistics_usecase.dart'
    as _i178;
import '../../features/courses/domain/use_case/get_course_teacher_details_usecase.dart'
    as _i391;
import '../../features/courses/domain/use_case/get_courses_by_subject_use_case.dart'
    as _i452;
import '../../features/courses/domain/use_case/get_courses_by_year_use_case.dart'
    as _i119;
import '../../features/courses/domain/use_case/get_courses_categories_usecase.dart'
    as _i670;
import '../../features/courses/domain/use_case/get_courses_with_filtering_usecase.dart'
    as _i260;
import '../../features/courses/domain/use_case/get_lecture_details_usecase.dart'
    as _i78;
import '../../features/courses/domain/use_case/get_teacher_courses_usecase.dart'
    as _i640;
import '../../features/courses/domain/use_case/get_video_interactions_usecase.dart'
    as _i855;
import '../../features/courses/domain/use_case/get_video_resolutions_usecase.dart'
    as _i67;
import '../../features/courses/domain/use_case/rate_course_use_case.dart'
    as _i1068;
import '../../features/courses/domain/use_case/toggle_video_interaction_usecase.dart'
    as _i1042;
import '../../features/courses/presentation/bloc/courses_bloc.dart' as _i836;
import '../../features/home/data/repositories/home_repository_impl.dart'
    as _i76;
import '../../features/home/data/sources/home_remote_datasource.dart' as _i230;
import '../../features/home/domain/repositories/home_repository.dart' as _i0;
import '../../features/home/domain/usecases/get_advertisements_usecase.dart'
    as _i942;
import '../../features/home/domain/usecases/get_all_programs_usecase.dart'
    as _i860;
import '../../features/home/domain/usecases/get_home_content_usecase.dart'
    as _i68;
import '../../features/home/domain/usecases/get_my_courses_usecase.dart'
    as _i337;
import '../../features/home/domain/usecases/get_subjects_with_filtering_usecase.dart'
    as _i432;
import '../../features/home/domain/usecases/get_teacher_summary_usecase.dart'
    as _i345;
import '../../features/home/domain/usecases/search_usecase.dart' as _i587;
import '../../features/home/presentation/bloc/home_bloc.dart' as _i202;
import '../../features/my_downloads/presentation/bloc/downloading_media/downloading_media_bloc.dart'
    as _i575;
import '../../features/my_downloads/presentation/bloc/my_downloads_bloc.dart'
    as _i722;
import '../../features/norifications/data/repository/notifications_repository_imp.dart'
    as _i688;
import '../../features/norifications/data/source/notifications_remote_data_source.dart'
    as _i189;
import '../../features/norifications/domain/repository/notifications_repository.dart'
    as _i1038;
import '../../features/norifications/domain/use_case/add_notification_usecase.dart'
    as _i978;
import '../../features/norifications/domain/use_case/get_notifications_use_case.dart'
    as _i736;
import '../../features/norifications/presentation/bloc/notifications_bloc.dart'
    as _i658;
import '../../features/sales_points/data/repository/sales_points_repository_imp.dart'
    as _i724;
import '../../features/sales_points/data/source/sales_points_remote_data_source.dart'
    as _i1053;
import '../../features/sales_points/domain/repository/sales_points_repository.dart'
    as _i670;
import '../../features/sales_points/domain/use_case/get_sales_points_use_case.dart'
    as _i55;
import '../../features/sales_points/presentation/bloc/sales_points_bloc.dart'
    as _i526;
import '../../features/subscriptions/data/repositories/subscriptions_repository_impl.dart'
    as _i268;
import '../../features/subscriptions/data/sources/subscriptions_remote_datasource.dart'
    as _i980;
import '../../features/subscriptions/domain/repositories/subscriptions_repository.dart'
    as _i297;
import '../../features/subscriptions/domain/usecases/create_course_interest_usecase.dart'
    as _i337;
import '../../features/subscriptions/domain/usecases/get_course_interests_usecase.dart'
    as _i964;
import '../../features/subscriptions/domain/usecases/get_course_payment_info_usecase.dart'
    as _i587;
import '../../features/subscriptions/domain/usecases/remove_course_interest_usecase.dart'
    as _i969;
import '../../features/subscriptions/domain/usecases/submit_subscription_receipt_usecase.dart'
    as _i728;
import '../../features/subscriptions/presentation/bloc/subscription_bloc.dart'
    as _i152;
import '../../features/teachers/data/repository/teachers_repository_imp.dart'
    as _i32;
import '../../features/teachers/data/source/teachers_remote_data_source.dart'
    as _i1058;
import '../../features/teachers/domain/repository/teachers_repository.dart'
    as _i837;
import '../../features/teachers/domain/use_case/add_or_remove_affiliations_usecase.dart'
    as _i659;
import '../../features/teachers/domain/use_case/get_liked_teachers_usecase.dart'
    as _i159;
import '../../features/teachers/domain/use_case/get_revenue_usecase.dart'
    as _i805;
import '../../features/teachers/domain/use_case/get_teacher_affilations_usecase.dart'
    as _i1064;
import '../../features/teachers/domain/use_case/get_teacher_details_usecase.dart'
    as _i404;
import '../../features/teachers/domain/use_case/get_teachers_use_case.dart'
    as _i798;
import '../../features/teachers/domain/use_case/get_withdrawals_usecase.dart'
    as _i857;
import '../../features/teachers/domain/use_case/like_teacher_use_case.dart'
    as _i81;
import '../../features/teachers/domain/use_case/unlike_teacher_usecase.dart'
    as _i1037;
import '../../features/teachers/presentation/bloc/teachers_bloc.dart' as _i988;
import '../storage/prefs_repository.dart' as _i866;
import 'di_container.dart' as _i198;

// initializes the registration of main-scope dependencies inside of GetIt
Future<_i174.GetIt> $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) async {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  final appModule = _$AppModule();
  gh.factory<_i980.SensitiveConnectivityBloc>(
    () => _i980.SensitiveConnectivityBloc(),
  );
  gh.factory<_i361.BaseOptions>(() => appModule.dioOption);
  gh.factory<_i979.AppRemoteDatasource>(() => _i979.AppRemoteDatasource());
  gh.factory<_i874.AuthRemoteDataSource>(() => _i874.AuthRemoteDataSource());
  gh.factory<_i729.UploadFileRemoteDatasource>(
    () => _i729.UploadFileRemoteDatasource(),
  );
  gh.factory<_i91.CourseContentManagementDatasource>(
    () => _i91.CourseContentManagementDatasource(),
  );
  gh.factory<_i712.CoursesRemoteDataSource>(
    () => _i712.CoursesRemoteDataSource(),
  );
  gh.factory<_i230.HomeRemoteDatasource>(() => _i230.HomeRemoteDatasource());
  gh.factory<_i189.NotificationsRemoteDataSource>(
    () => _i189.NotificationsRemoteDataSource(),
  );
  gh.factory<_i1053.SalesPointsRemoteDataSource>(
    () => _i1053.SalesPointsRemoteDataSource(),
  );
  gh.factory<_i980.SubscriptionsRemoteDatasource>(
    () => _i980.SubscriptionsRemoteDatasource(),
  );
  gh.factory<_i1058.TeachersRemoteDataSource>(
    () => _i1058.TeachersRemoteDataSource(),
  );
  gh.singleton<_i974.Logger>(() => appModule.logger);
  await gh.singletonAsync<_i460.SharedPreferences>(
    () => appModule.sharedPreferences,
    preResolve: true,
  );
  await gh.singletonAsync<_i866.PrefsRepository>(
    () => appModule.prefsRepository,
    preResolve: true,
  );
  gh.singleton<_i722.MyDownloadsBloc>(() => _i722.MyDownloadsBloc());
  gh.lazySingleton<_i575.DownloadingMediaBloc>(
    () => _i575.DownloadingMediaBloc(),
  );
  gh.lazySingleton<_i599.CourseContentManagementRepository>(
    () => _i1.CourseContentManagementRepositoryImpl(
      gh<_i91.CourseContentManagementDatasource>(),
    ),
  );
  gh.lazySingleton<_i0.HomeRepository>(
    () => _i76.HomeRepositoryImpl(gh<_i230.HomeRemoteDatasource>()),
  );
  gh.factory<_i942.GetAdvertisementsUsecase>(
    () => _i942.GetAdvertisementsUsecase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i860.GetAllProgramsUsecase>(
    () => _i860.GetAllProgramsUsecase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i68.GetHomeContentUsecase>(
    () => _i68.GetHomeContentUsecase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i337.GetMyCoursesUsecase>(
    () => _i337.GetMyCoursesUsecase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i432.GetSubjectsWithFilteringUsecase>(
    () => _i432.GetSubjectsWithFilteringUsecase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i345.GetTeacherSummaryUsecase>(
    () => _i345.GetTeacherSummaryUsecase(gh<_i0.HomeRepository>()),
  );
  gh.factory<_i587.SearchUsecase>(
    () => _i587.SearchUsecase(gh<_i0.HomeRepository>()),
  );
  gh.lazySingleton<_i587.UploadFileRepository>(
    () =>
        _i975.UploadFileRepositoryImpl(gh<_i729.UploadFileRemoteDatasource>()),
  );
  gh.factory<_i577.DeleteFromCourseUsecase>(
    () => _i577.DeleteFromCourseUsecase(
      gh<_i599.CourseContentManagementRepository>(),
    ),
  );
  gh.factory<_i442.DeleteVideoSegmentUsecase>(
    () => _i442.DeleteVideoSegmentUsecase(
      gh<_i599.CourseContentManagementRepository>(),
    ),
  );
  gh.factory<_i791.GetAllowedSubjectsUsecase>(
    () => _i791.GetAllowedSubjectsUsecase(
      gh<_i599.CourseContentManagementRepository>(),
    ),
  );
  gh.factory<_i48.GetSeasonsUsecase>(
    () => _i48.GetSeasonsUsecase(gh<_i599.CourseContentManagementRepository>()),
  );
  gh.factory<_i525.GetVideoSegementsUsecase>(
    () => _i525.GetVideoSegementsUsecase(
      gh<_i599.CourseContentManagementRepository>(),
    ),
  );
  gh.factory<_i1003.UpsertCourseUsecase>(
    () => _i1003.UpsertCourseUsecase(
      gh<_i599.CourseContentManagementRepository>(),
    ),
  );
  gh.factory<_i294.UpsertFileUsecase>(
    () =>
        _i294.UpsertFileUsecase(gh<_i599.CourseContentManagementRepository>()),
  );
  gh.factory<_i232.UpsertLectureUsecase>(
    () => _i232.UpsertLectureUsecase(
      gh<_i599.CourseContentManagementRepository>(),
    ),
  );
  gh.factory<_i1069.UpsertQuestionUsecase>(
    () => _i1069.UpsertQuestionUsecase(
      gh<_i599.CourseContentManagementRepository>(),
    ),
  );
  gh.factory<_i212.UpsertVideoSegmentUsecase>(
    () => _i212.UpsertVideoSegmentUsecase(
      gh<_i599.CourseContentManagementRepository>(),
    ),
  );
  gh.factory<_i459.UpsertVideoUsecase>(
    () =>
        _i459.UpsertVideoUsecase(gh<_i599.CourseContentManagementRepository>()),
  );
  gh.lazySingleton<_i604.CoursesRepository>(
    () => _i353.CoursesRepositoryImp(gh<_i712.CoursesRemoteDataSource>()),
  );
  gh.lazySingleton<_i670.SalesPointsRepository>(
    () => _i724.SalesPointsRepositoryImp(
      gh<_i1053.SalesPointsRemoteDataSource>(),
    ),
  );
  gh.lazySingleton<_i544.AppRepository>(
    () => _i111.AppRepositoryImpl(gh<_i979.AppRemoteDatasource>()),
  );
  gh.lazySingleton<_i202.HomeBloc>(
    () => _i202.HomeBloc(
      gh<_i942.GetAdvertisementsUsecase>(),
      gh<_i68.GetHomeContentUsecase>(),
      getAllProgramsUsecase: gh<_i860.GetAllProgramsUsecase>(),
      getSubjectsWithFilteringUsecase:
          gh<_i432.GetSubjectsWithFilteringUsecase>(),
      getMyCoursesUsecase: gh<_i337.GetMyCoursesUsecase>(),
      getTeacherSummaryUsecase: gh<_i345.GetTeacherSummaryUsecase>(),
      searchUsecase: gh<_i587.SearchUsecase>(),
    ),
  );
  gh.lazySingleton<_i837.TeachersRepository>(
    () => _i32.TeachersRepositoryImp(gh<_i1058.TeachersRemoteDataSource>()),
  );
  gh.singleton<_i361.Dio>(
    () => appModule.dio(gh<_i361.BaseOptions>(), gh<_i974.Logger>()),
  );
  gh.lazySingleton<_i961.AuthRepository>(
    () => _i794.AuthRepositoryImp(gh<_i874.AuthRemoteDataSource>()),
  );
  gh.factory<_i942.UploadFileUsecase>(
    () => _i942.UploadFileUsecase(gh<_i587.UploadFileRepository>()),
  );
  gh.factory<_i55.GetSalesPointsUseCase>(
    () => _i55.GetSalesPointsUseCase(gh<_i670.SalesPointsRepository>()),
  );
  gh.factory<_i418.GetCustomerServiceUsecase>(
    () => _i418.GetCustomerServiceUsecase(gh<_i544.AppRepository>()),
  );
  gh.factory<_i618.ScanCodeUsecase>(
    () => _i618.ScanCodeUsecase(gh<_i544.AppRepository>()),
  );
  gh.lazySingleton<_i1038.NotificationsRepository>(
    () => _i688.NotificationsRepositoryImp(
      gh<_i189.NotificationsRemoteDataSource>(),
    ),
  );
  gh.factory<_i978.AddNotificationUsecase>(
    () => _i978.AddNotificationUsecase(gh<_i1038.NotificationsRepository>()),
  );
  gh.factory<_i736.GetNotificationsUseCase>(
    () => _i736.GetNotificationsUseCase(gh<_i1038.NotificationsRepository>()),
  );
  gh.factory<_i659.AddOrRemoveAffiliationsUsecase>(
    () => _i659.AddOrRemoveAffiliationsUsecase(gh<_i837.TeachersRepository>()),
  );
  gh.factory<_i159.GetLikedTeachersUsecase>(
    () => _i159.GetLikedTeachersUsecase(gh<_i837.TeachersRepository>()),
  );
  gh.factory<_i805.GetRevenueUsecase>(
    () => _i805.GetRevenueUsecase(gh<_i837.TeachersRepository>()),
  );
  gh.factory<_i1064.GetTeacherAffiliationsUsecase>(
    () => _i1064.GetTeacherAffiliationsUsecase(gh<_i837.TeachersRepository>()),
  );
  gh.factory<_i404.GetTeacherDetailsUsecase>(
    () => _i404.GetTeacherDetailsUsecase(gh<_i837.TeachersRepository>()),
  );
  gh.factory<_i798.GetTeachersUseCase>(
    () => _i798.GetTeachersUseCase(gh<_i837.TeachersRepository>()),
  );
  gh.factory<_i857.GetWithdrawalsUsecase>(
    () => _i857.GetWithdrawalsUsecase(gh<_i837.TeachersRepository>()),
  );
  gh.factory<_i81.LikeTeacherUseCase>(
    () => _i81.LikeTeacherUseCase(gh<_i837.TeachersRepository>()),
  );
  gh.factory<_i1037.UnlikeTeacherUsecase>(
    () => _i1037.UnlikeTeacherUsecase(gh<_i837.TeachersRepository>()),
  );
  gh.lazySingleton<_i297.SubscriptionsRepository>(
    () => _i268.SubscriptionsRepositoryImpl(
      gh<_i980.SubscriptionsRemoteDatasource>(),
    ),
  );
  gh.lazySingleton<_i988.TeachersBloc>(
    () => _i988.TeachersBloc(
      getTeachersUseCase: gh<_i798.GetTeachersUseCase>(),
      getLikedTeachersUsecase: gh<_i159.GetLikedTeachersUsecase>(),
      getTeacherDetailsUsecase: gh<_i404.GetTeacherDetailsUsecase>(),
      likeTeacherUseCase: gh<_i81.LikeTeacherUseCase>(),
      unlikeTeacherUsecase: gh<_i1037.UnlikeTeacherUsecase>(),
      getTeacherAffiliationsUsecase: gh<_i1064.GetTeacherAffiliationsUsecase>(),
      addOrRemoveAffiliationsUsecase:
          gh<_i659.AddOrRemoveAffiliationsUsecase>(),
      getWithdrawalsUsecase: gh<_i857.GetWithdrawalsUsecase>(),
      getRevenueUsecase: gh<_i805.GetRevenueUsecase>(),
    ),
  );
  gh.factory<_i607.ChangePasswordUsecase>(
    () => _i607.ChangePasswordUsecase(gh<_i961.AuthRepository>()),
  );
  gh.factory<_i875.CreateGuestAccountUsecase>(
    () => _i875.CreateGuestAccountUsecase(gh<_i961.AuthRepository>()),
  );
  gh.factory<_i812.DeleteAccountUsecase>(
    () => _i812.DeleteAccountUsecase(gh<_i961.AuthRepository>()),
  );
  gh.factory<_i418.EditProfileUsecase>(
    () => _i418.EditProfileUsecase(gh<_i961.AuthRepository>()),
  );
  gh.factory<_i207.GetAcademicYearsUsecase>(
    () => _i207.GetAcademicYearsUsecase(gh<_i961.AuthRepository>()),
  );
  gh.factory<_i74.GetCollegesUsecase>(
    () => _i74.GetCollegesUsecase(gh<_i961.AuthRepository>()),
  );
  gh.factory<_i939.GetDepartmentsUsecase>(
    () => _i939.GetDepartmentsUsecase(gh<_i961.AuthRepository>()),
  );
  gh.factory<_i413.GetGuestAccountUsecase>(
    () => _i413.GetGuestAccountUsecase(gh<_i961.AuthRepository>()),
  );
  gh.factory<_i634.GetProfileUsecase>(
    () => _i634.GetProfileUsecase(gh<_i961.AuthRepository>()),
  );
  gh.factory<_i451.GetUniversitiesUsecase>(
    () => _i451.GetUniversitiesUsecase(gh<_i961.AuthRepository>()),
  );
  gh.factory<_i153.LogInUseCase>(
    () => _i153.LogInUseCase(gh<_i961.AuthRepository>()),
  );
  gh.factory<_i426.SignUpUseCase>(
    () => _i426.SignUpUseCase(gh<_i961.AuthRepository>()),
  );
  gh.factory<_i477.UpdateStudentUsecase>(
    () => _i477.UpdateStudentUsecase(gh<_i961.AuthRepository>()),
  );
  gh.factory<_i706.GetCourseDetailsUseCase>(
    () => _i706.GetCourseDetailsUseCase(gh<_i604.CoursesRepository>()),
  );
  gh.factory<_i97.GetCourseRatingUsecase>(
    () => _i97.GetCourseRatingUsecase(gh<_i604.CoursesRepository>()),
  );
  gh.factory<_i178.GetCourseStatisticsUsecase>(
    () => _i178.GetCourseStatisticsUsecase(gh<_i604.CoursesRepository>()),
  );
  gh.factory<_i391.GetCourseTeacherDetailsUsecase>(
    () => _i391.GetCourseTeacherDetailsUsecase(gh<_i604.CoursesRepository>()),
  );
  gh.factory<_i452.GetCoursesBySubjectUseCase>(
    () => _i452.GetCoursesBySubjectUseCase(gh<_i604.CoursesRepository>()),
  );
  gh.factory<_i119.GetCoursesByYearUseCase>(
    () => _i119.GetCoursesByYearUseCase(gh<_i604.CoursesRepository>()),
  );
  gh.factory<_i670.GetCoursesCategoriesUsecase>(
    () => _i670.GetCoursesCategoriesUsecase(gh<_i604.CoursesRepository>()),
  );
  gh.factory<_i260.GetCoursesWithFilteringUsecase>(
    () => _i260.GetCoursesWithFilteringUsecase(gh<_i604.CoursesRepository>()),
  );
  gh.factory<_i78.GetLectureDetailsUsecase>(
    () => _i78.GetLectureDetailsUsecase(gh<_i604.CoursesRepository>()),
  );
  gh.factory<_i640.GetTeacherCoursesUsecase>(
    () => _i640.GetTeacherCoursesUsecase(gh<_i604.CoursesRepository>()),
  );
  gh.factory<_i855.GetVideoInteractionsUsecase>(
    () => _i855.GetVideoInteractionsUsecase(gh<_i604.CoursesRepository>()),
  );
  gh.factory<_i67.GetVideoResolutionsUsecase>(
    () => _i67.GetVideoResolutionsUsecase(gh<_i604.CoursesRepository>()),
  );
  gh.factory<_i1068.RateCourseUseCase>(
    () => _i1068.RateCourseUseCase(gh<_i604.CoursesRepository>()),
  );
  gh.factory<_i1042.ToggleVideoInteractionUsecase>(
    () => _i1042.ToggleVideoInteractionUsecase(gh<_i604.CoursesRepository>()),
  );
  gh.lazySingleton<_i747.CourseContentManagementBloc>(
    () => _i747.CourseContentManagementBloc(
      getAllowedSubjectsUsecase: gh<_i791.GetAllowedSubjectsUsecase>(),
      upsertCourseUsecase: gh<_i1003.UpsertCourseUsecase>(),
      upsertLectureUsecase: gh<_i232.UpsertLectureUsecase>(),
      deleteFromCourseUsecase: gh<_i577.DeleteFromCourseUsecase>(),
      getSeasonsUsecase: gh<_i48.GetSeasonsUsecase>(),
      uploadFileUsecase: gh<_i942.UploadFileUsecase>(),
      upsertVideoUsecase: gh<_i459.UpsertVideoUsecase>(),
      upsertFileUsecase: gh<_i294.UpsertFileUsecase>(),
      upsertQuestionUsecase: gh<_i1069.UpsertQuestionUsecase>(),
      upsertVideoSegmentUsecase: gh<_i212.UpsertVideoSegmentUsecase>(),
      getVideoSegementsUsecase: gh<_i525.GetVideoSegementsUsecase>(),
      deleteVideoSegmentUsecase: gh<_i442.DeleteVideoSegmentUsecase>(),
    ),
  );
  gh.lazySingleton<_i526.SalesPointsBloc>(
    () => _i526.SalesPointsBloc(gh<_i55.GetSalesPointsUseCase>()),
  );
  gh.factory<_i337.CreateCourseInterestUsecase>(
    () =>
        _i337.CreateCourseInterestUsecase(gh<_i297.SubscriptionsRepository>()),
  );
  gh.factory<_i964.GetCourseInterestsUsecase>(
    () => _i964.GetCourseInterestsUsecase(gh<_i297.SubscriptionsRepository>()),
  );
  gh.factory<_i587.GetCoursePaymentInfoUsecase>(
    () =>
        _i587.GetCoursePaymentInfoUsecase(gh<_i297.SubscriptionsRepository>()),
  );
  gh.factory<_i969.RemoveCourseInterestUsecase>(
    () =>
        _i969.RemoveCourseInterestUsecase(gh<_i297.SubscriptionsRepository>()),
  );
  gh.factory<_i728.SubmitSubscriptionReceiptUsecase>(
    () => _i728.SubmitSubscriptionReceiptUsecase(
      gh<_i297.SubscriptionsRepository>(),
    ),
  );
  gh.lazySingleton<_i152.SubscriptionBloc>(
    () => _i152.SubscriptionBloc(
      gh<_i964.GetCourseInterestsUsecase>(),
      gh<_i587.GetCoursePaymentInfoUsecase>(),
      gh<_i337.CreateCourseInterestUsecase>(),
      gh<_i969.RemoveCourseInterestUsecase>(),
      gh<_i728.SubmitSubscriptionReceiptUsecase>(),
    ),
  );
  gh.lazySingleton<_i658.NotificationsBloc>(
    () => _i658.NotificationsBloc(
      gh<_i736.GetNotificationsUseCase>(),
      addNotificationUsecase: gh<_i978.AddNotificationUsecase>(),
    ),
  );
  gh.lazySingleton<_i120.AppBloc>(
    () => _i120.AppBloc(
      scanCodeUsecase: gh<_i618.ScanCodeUsecase>(),
      getCustomerServiceUsecase: gh<_i418.GetCustomerServiceUsecase>(),
    ),
  );
  gh.lazySingleton<_i836.CoursesBloc>(
    () => _i836.CoursesBloc(
      getSubjectCoursesUseCase: gh<_i452.GetCoursesBySubjectUseCase>(),
      getCourseDetailsUseCase: gh<_i706.GetCourseDetailsUseCase>(),
      getLectureDetailsUsecase: gh<_i78.GetLectureDetailsUsecase>(),
      getCoursesWithFilteringUsecase:
          gh<_i260.GetCoursesWithFilteringUsecase>(),
      rateCourseUseCase: gh<_i1068.RateCourseUseCase>(),
      getCoursesCategoriesUsecase: gh<_i670.GetCoursesCategoriesUsecase>(),
      getCoursesByYearUseCase: gh<_i119.GetCoursesByYearUseCase>(),
      getCourseRatingUsecase: gh<_i97.GetCourseRatingUsecase>(),
      getTeacherCoursesUsecase: gh<_i640.GetTeacherCoursesUsecase>(),
      getCourseTeacherDetailsUsecase:
          gh<_i391.GetCourseTeacherDetailsUsecase>(),
      getCourseStatisticsUsecase: gh<_i178.GetCourseStatisticsUsecase>(),
      getVideoResolutionsUsecase: gh<_i67.GetVideoResolutionsUsecase>(),
      getVideoInteractionsUsecase: gh<_i855.GetVideoInteractionsUsecase>(),
      toggleVideoInteractionUsecase: gh<_i1042.ToggleVideoInteractionUsecase>(),
    ),
  );
  gh.lazySingleton<_i797.AuthBloc>(
    () => _i797.AuthBloc(
      gh<_i153.LogInUseCase>(),
      gh<_i426.SignUpUseCase>(),
      gh<_i451.GetUniversitiesUsecase>(),
      gh<_i74.GetCollegesUsecase>(),
      gh<_i939.GetDepartmentsUsecase>(),
      gh<_i207.GetAcademicYearsUsecase>(),
      gh<_i634.GetProfileUsecase>(),
      gh<_i418.EditProfileUsecase>(),
      createGuestAccountUsecase: gh<_i875.CreateGuestAccountUsecase>(),
      getGuestAccountUsecase: gh<_i413.GetGuestAccountUsecase>(),
      updateStudentUsecase: gh<_i477.UpdateStudentUsecase>(),
      uploadFileUsecase: gh<_i942.UploadFileUsecase>(),
      changePasswordUsecase: gh<_i607.ChangePasswordUsecase>(),
      deleteAccountUsecase: gh<_i812.DeleteAccountUsecase>(),
    ),
  );
  return getIt;
}

class _$AppModule extends _i198.AppModule {}
