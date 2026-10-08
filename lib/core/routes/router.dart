import 'package:coursaty_student_and_teacher/application_run_in_simulator_page.dart';
import 'package:coursaty_student_and_teacher/core/routes/router_config.dart';
import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:coursaty_student_and_teacher/features/app/presentation/pages/about_app_screen.dart';
import 'package:coursaty_student_and_teacher/features/app/presentation/pages/contact_us_screen.dart';
import 'package:coursaty_student_and_teacher/features/app/presentation/pages/customer_service_screen.dart';
import 'package:coursaty_student_and_teacher/features/auth/presentation/screens/change_password_page.dart';
import 'package:coursaty_student_and_teacher/features/auth/presentation/screens/edit_profile_screen.dart';
import 'package:coursaty_student_and_teacher/features/auth/presentation/screens/login_screen.dart';
import 'package:coursaty_student_and_teacher/features/auth/presentation/screens/signup_screen.dart';
import 'package:coursaty_student_and_teacher/features/auth/presentation/screens/signup_success_screen.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/presentation/pages/add_course_page.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/presentation/pages/select_subject_page.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/course_details_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/lecture_details_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/screens/course_details_screen.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/screens/courses_by_year_screen.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/screens/lecture_details_screen.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/screens/teacher/teacher_course_details_page.dart';
import 'package:coursaty_student_and_teacher/features/home/presentation/pages/home_screen.dart';
import 'package:coursaty_student_and_teacher/features/home/presentation/pages/programs_screen.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/presentation/pages/downloads_screen.dart';
import 'package:coursaty_student_and_teacher/features/norifications/presentation/screens/notifications_screen.dart';
import 'package:coursaty_student_and_teacher/features/onboarding/onboarding_screen.dart';
import 'package:coursaty_student_and_teacher/features/sales_points/data/model/sale_point_model.dart';
import 'package:coursaty_student_and_teacher/features/sales_points/presentation/screens/point_of_sale_detail_screen.dart';
import 'package:coursaty_student_and_teacher/features/sales_points/presentation/screens/points_of_sale_list_screen.dart';
import 'package:coursaty_student_and_teacher/features/teachers/presentation/screens/teacher_detail_screen.dart';
import 'package:coursaty_student_and_teacher/features/teachers/presentation/screens/teachers_screen.dart';
import 'package:coursaty_student_and_teacher/fraud_date_page.dart';
import 'package:coursaty_student_and_teacher/main.dart';
import 'package:coursaty_student_and_teacher/services/device_info_service.dart';
import 'package:coursaty_student_and_teacher/the_device_is_rooted_page.dart';
import 'package:flutter/material.dart';
import '../common/constant/configuration/feature_flags.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../blocked_account_page.dart';
import '../../features/auth/presentation/screens/change_university_screen.dart';
import '../../features/courses/presentation/screens/courses_by_subject_screen.dart';
import '../../features/courses/presentation/screens/teacher/teacher_lecture_details_page.dart';
import '../../features/home/presentation/pages/subjects_screen.dart';
import '../../features/my_downloads/presentation/pages/downloaded_course_details.dart';
import '../../features/my_downloads/presentation/pages/downloaded_lecture_details.dart';
import '../../features/norifications/presentation/screens/add_notification_page.dart';
import '../../features/norifications/presentation/screens/teacher_notifications_screen.dart';
import '../../services/check_device_root_service.dart';
import '../../splash_screen.dart';
import 'error_screen.dart';

class GRouter {
  static GoRouter get router => _router;

  static RouterConfiguration get config => _config;

  static final RouterConfiguration _config = RouterConfiguration.init();

  static final GoRouter _router = GoRouter(
    redirect: (BuildContext context, GoRouterState state) {
      if (state.fullPath?.isEmpty ?? true) {
        return _config.applicationRoutes.splash;
      }
      if (!SubscriptionFeatureFlags.showLegacySubscriptionMethods &&
          (state.matchedLocation == _config.applicationRoutes.pointsOfSale ||
              state.matchedLocation ==
                  _config.applicationRoutes.pointOfSaleDetails)) {
        return _config.applicationRoutes.home;
      }
      final prefs = GetIt.I<PrefsRepository>();
      if ((!prefs.isGuest && prefs.token != null) ||
          !_requiresAuthentication(state.matchedLocation)) {
        return null;
      }
      return _config.applicationRoutes.login;
    },
    routes: <RouteBase>[
      /// Splash
      GoRoute(
        path: _config.applicationRoutes.splash,
        pageBuilder: (context, state) {
          final bool isSimulator =
              !DeviceInfoService.isRealDevice ||
              (MediaQuery.sizeOf(context).width > 650 && kIsAndroid);
          final bool rooted = CheckDeviceRootService.isDeviceHasRoot;
          // final bool outDated = false;
          //DateTime.now().difference(DateTime(2026, 5, 25)).inDays > 3;
          return _builderPage(
            child:
                // outDated
                //     ? OutdatedApp()
                //     :
                isDateFraud
                ? FraudDatePage()
                : isSimulator
                ? ApplicationRunInSimulatorPage()
                : rooted
                ? TheDeviceIsRootedPage(isRooted: rooted)
                : const SplashScreen(),
            state: state,
          );
        },
      ),

      /// Onboarding
      GoRoute(
        path: _config.applicationRoutes.onboarding,
        pageBuilder: (context, state) =>
            _builderPage(child: const OnboardingScreen(), state: state),
      ),

      /// Auth
      GoRoute(
        path: _config.applicationRoutes.login,
        pageBuilder: (context, state) =>
            _builderPage(child: const LoginScreen(), state: state),
      ),
      GoRoute(
        path: '${_config.applicationRoutes.signup}/:isForTeacher',
        pageBuilder: (context, state) => _builderPage(
          child: SignUpScreen(
            isForTeacher: bool.parse(state.pathParameters["isForTeacher"]!),
          ),
          state: state,
        ),
      ),
      GoRoute(
        path: "${_config.applicationRoutes.signupSuccess}/:isForTeacher",
        pageBuilder: (context, state) => _builderPage(
          child: SignUpSuccessScreen(
            isForTeacher: bool.parse(state.pathParameters["isForTeacher"]!),
          ),
          state: state,
        ),
      ),

      GoRoute(
        path: _config.applicationRoutes.blockedAccount,
        pageBuilder: (context, state) =>
            _builderPage(child: const BlockedAccountPage(), state: state),
      ),

      /// Main
      GoRoute(
        path: _config.applicationRoutes.home,
        pageBuilder: (context, state) =>
            _builderPage(child: const HomeScreen(), state: state),
      ),

      /// Features
      GoRoute(
        path: "${_config.applicationRoutes.courses}/:id",
        pageBuilder: (context, state) => _builderPage(
          child: CoursesByYearScreen(yearId: state.pathParameters['id']!),
          state: state,
        ),
      ),

      GoRoute(
        path: "${_config.applicationRoutes.coursesBySubject}/:id/:isForSubject",
        pageBuilder: (context, state) => _builderPage(
          child: CoursesBySubjectScreen(
            subjectId: state.pathParameters['id']!,
            isForSubject: bool.parse(state.pathParameters['isForSubject']!),
          ),
          state: state,
        ),
      ),

      GoRoute(
        path: "${_config.applicationRoutes.addCourse}/:id",
        pageBuilder: (context, state) => _builderPage(
          child: AddCoursePage(subjectId: state.pathParameters['id']!),
          state: state,
        ),
      ),

      GoRoute(
        path: _config.applicationRoutes.addNotification,
        pageBuilder: (context, state) =>
            _builderPage(child: AddNotificationPage(), state: state),
      ),
      GoRoute(
        path: _config.applicationRoutes.notifications,
        pageBuilder: (context, state) {
          final prefs = GetIt.I<PrefsRepository>();
          return _builderPage(
            child: prefs.isStudent
                ? const NotificationsScreen()
                : const TeacherNotificationsScreen(),
            state: state,
          );
        },
      ),
      GoRoute(
        path: _config.applicationRoutes.contactUs,
        pageBuilder: (context, state) =>
            _builderPage(child: ContactUsScreen(), state: state),
      ),

      GoRoute(
        path: _config.applicationRoutes.selectSubject,
        pageBuilder: (context, state) =>
            _builderPage(child: SelectSubjectPage(), state: state),
      ),
      GoRoute(
        path: _config.applicationRoutes.customerService,
        pageBuilder: (context, state) => _builderPage(
          child: CustomerServiceScreen(
            technical: state.uri.queryParameters['technical']!,
            contact: state.uri.queryParameters['contact']!,
          ),
          state: state,
        ),
      ),
      GoRoute(
        path: _config.applicationRoutes.downloads,
        pageBuilder: (context, state) =>
            _builderPage(child: const DownloadsScreen(), state: state),
      ),
      GoRoute(
        path: _config.applicationRoutes.allPrograms,
        pageBuilder: (context, state) =>
            _builderPage(child: const ProgramsScreen(), state: state),
      ),
      GoRoute(
        path: _config.applicationRoutes.aboutApp,
        pageBuilder: (context, state) =>
            _builderPage(child: const AboutAppScreen(), state: state),
      ),

      GoRoute(
        path: _config.applicationRoutes.pointOfSaleDetails,
        pageBuilder: (context, state) => _builderPage(
          child: PointOfSaleDetailScreen(salePoint: state.extra as SalePoint),
          state: state,
        ),
      ),
      GoRoute(
        path: _config.applicationRoutes.teachers,
        pageBuilder: (context, state) =>
            _builderPage(child: const TeachersScreen(), state: state),
      ),

      GoRoute(
        path: "${_config.applicationRoutes.teacherDetails}/:id/:name",
        pageBuilder: (context, state) => _builderPage(
          child: TeacherDetailScreen(
            teacherId: state.pathParameters['id']!,
            teacherName: state.pathParameters['name']!,
          ),
          state: state,
        ),
      ),

      GoRoute(
        path: "${_config.applicationRoutes.editProfile}/:isForTeacher",
        pageBuilder: (context, state) => _builderPage(
          child: EditProfileScreen(
            isForTeacher: bool.parse(state.pathParameters["isForTeacher"]!),
          ),
          state: state,
        ),
      ),
      GoRoute(
        path: _config.applicationRoutes.changePassword,
        pageBuilder: (context, state) =>
            _builderPage(child: ChangePasswordPage(), state: state),
      ),
      GoRoute(
        path: "${_config.applicationRoutes.changeUniversity}/:isForChangeYear",
        pageBuilder: (context, state) => _builderPage(
          child: ChangeUniversityScreen(
            isForChangeYear: bool.parse(
              state.pathParameters["isForChangeYear"]!,
            ),
          ),
          state: state,
        ),
      ),

      /// Course Flow
      GoRoute(
        path: "${_config.applicationRoutes.courseDetails}/:id",
        pageBuilder: (context, state) => _builderPage(
          child: CourseDetailsScreen(courseId: state.pathParameters['id']!),
          state: state,
        ),
      ),
      GoRoute(
        path: _config.applicationRoutes.downloadedCourseDetails,
        pageBuilder: (context, state) => _builderPage(
          child: DownloadedCourseDetails(
            course: state.extra as CourseDetailsModel,
          ),
          state: state,
        ),
      ),
      GoRoute(
        path: "${_config.applicationRoutes.teacherCourseDetails}/:id",
        pageBuilder: (context, state) => _builderPage(
          child: TeacherCourseDetailsPage(
            courseId: state.pathParameters['id']!,
          ),
          state: state,
        ),
      ),
      GoRoute(
        path:
            "${_config.applicationRoutes.lectureDetails}/:id/:name/:cid/:free",
        pageBuilder: (context, state) => _builderPage(
          child: LectureDetailsScreen(
            lectureId: state.pathParameters['id']!,
            lectureName: state.pathParameters['name']!,
            courseId: state.pathParameters['cid']!,
            isCourseFree: bool.parse(state.pathParameters['free']!),
          ),
          state: state,
        ),
      ),

      GoRoute(
        path: "${_config.applicationRoutes.downloadedLectureDetails}/:cid",
        pageBuilder: (context, state) => _builderPage(
          child: DownloadedLectureDetails(
            courseId: state.pathParameters['cid']!,
            lectureDetailsModel: state.extra as LectureDetailsModel,
          ),
          state: state,
        ),
      ),

      GoRoute(
        path:
            "${_config.applicationRoutes.lectureDetailsForTeacher}/:id/:name/:cid",
        pageBuilder: (context, state) => _builderPage(
          child: TeacherLectureDetailsPage(
            lectureId: state.pathParameters['id']!,
            lectureName: state.pathParameters['name']!,
            courseId: state.pathParameters['cid']!,
          ),
          state: state,
        ),
      ),
      GoRoute(
        path: _config.applicationRoutes.materials,
        pageBuilder: (context, state) =>
            _builderPage(child: MaterialsScreen(), state: state),
      ),

      /// Points of Sale
      GoRoute(
        path: _config.applicationRoutes.pointsOfSale,
        pageBuilder: (context, state) =>
            _builderPage(child: const PointsOfSaleListScreen(), state: state),
      ),
    ],

    errorBuilder: (context, state) => ErrorScreen(exception: state.error),
  );

  static Page<dynamic> _builderPage<T>({
    required Widget child,
    required GoRouterState state,
  }) {
    return MaterialPage<T>(child: child, key: state.pageKey);
  }

  static bool _requiresAuthentication(String location) {
    const protectedRoutes = [
      '/notifications',
      '/addNotification',
      '/downloads',
      '/edit_profile',
      '/change_password',
      '/change_university',
      '/select_subject',
      '/add_course',
      '/points_of_sale',
      '/point_of_sale_details',
      '/teacher_course_details',
      '/lecture_details_for_teacher',
      '/downloaded_course_details',
      '/downloaded_lecture_details',
    ];
    return protectedRoutes.any(
      (route) => location == route || location.startsWith('$route/'),
    );
  }
}
