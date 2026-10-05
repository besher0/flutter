import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/presentation/bloc/course_content_management_bloc.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/screens/courses_screen.dart';
import 'package:coursaty_student_and_teacher/features/home/presentation/bloc/home_bloc.dart';
import 'package:coursaty_student_and_teacher/features/home/presentation/pages/home_content.dart';
import 'package:coursaty_student_and_teacher/features/home/presentation/pages/subscriptions_screen.dart';
import 'package:coursaty_student_and_teacher/features/home/presentation/pages/teacher/teacher_home_page.dart';
import 'package:coursaty_student_and_teacher/features/sales_points/presentation/bloc/sales_points_bloc.dart';
import '../../../../core/common/constant/configuration/feature_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/widgets/closing_app_dialog.dart';
import '../../../../app/widgets/title_app_bar.dart';
import '../../../../core/routes/router.dart';
import '../../../app/presentation/bloc/app_bloc.dart';
import '../../../auth/domain/use_case/edit_profile_usecase.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../teachers/presentation/screens/teacher_profile.dart';
import '../../../courses/presentation/bloc/courses_bloc.dart';
import '../../../courses/presentation/screens/teacher/teacher_courses_page.dart';
import '../../../my_downloads/presentation/pages/downloads_screen.dart';
import '../widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();
  final ValueNotifier<String> currentSelectedCategory = ValueNotifier('all');
  final ValueNotifier<bool> openSearch = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    if (_prefsRepository.isStudent) {
      if (SubscriptionFeatureFlags.showLegacySubscriptionMethods) {
        BlocProvider.of<SalesPointsBloc>(context).add(GetSalesPointsEvent());
      }
      BlocProvider.of<HomeBloc>(context).add(GetMyActiveCourses());
      BlocProvider.of<HomeBloc>(context).add(GetMyInActiveCourses());
      BlocProvider.of<HomeBloc>(context).add(GetAdvertisementsEvent());
      BlocProvider.of<HomeBloc>(context).add(GetHomeContentEvent());
      BlocProvider.of<AppBloc>(context).add(GetCustomerServiceEvent());
      BlocProvider.of<CoursesBloc>(context).add(GetCoursesCategoriesEvent());
      BlocProvider.of<CoursesBloc>(
        context,
      ).add(GetCoursesWithFilteringEvent(filter: 'all', reset: true));
    } else {
      BlocProvider.of<CourseContentManagementBloc>(
        context,
      ).add(GetAllSeasonsEvent());
      BlocProvider.of<HomeBloc>(context).add(GetTeacherSummaryEvent());
      BlocProvider.of<CoursesBloc>(
        context,
      ).add(GetTeacherCourses(getActive: true, reset: true));
      BlocProvider.of<CoursesBloc>(
        context,
      ).add(GetTeacherCourses(getActive: false, reset: true));
    }
    // update fcm token
    BlocProvider.of<AuthBloc>(
      context,
    ).add(UpdateProfileEvent(params: UpdateProfileParams()));
  }

  void _closeApp() {
    SystemNavigator.pop();
  }

  @override
  void dispose() {
    currentSelectedCategory.dispose();
    openSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = _prefsRepository.isStudent;
    final pages = (isStudent
        ? [
            HomeContent(openSearch: openSearch),
            CoursesScreen(currentSelectedCategory: currentSelectedCategory),
            SubscriptionsScreen(),
            DownloadsScreen(),
          ]
        : [
            TeacherHomePage(
              goToCourses: () {
                setState(() {
                  _navIndex = 1;
                });
              },
            ),
            TeacherCoursesPage(),
            TeacherProfile(),
          ]);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, __) async {
        if (didPop) return;
        if (_navIndex == 0) {
          if (openSearch.value) {
            openSearch.value = false;
            return;
          }
          final shouldClose = await showClosingConfirm(context);
          if (shouldClose == true) {
            _closeApp();
          }
        } else {
          setState(() {
            _navIndex = 0;
          });
        }
      },
      child: BlocListener<HomeBloc, HomeState>(
        listenWhen: (p, c) => p.newPageInHome != c.newPageInHome,
        listener: (context, state) {
          if (state.newPageInHome != null) {
            setState(() {
              _navIndex = state.newPageInHome!;
            });
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: isStudent
              ? null
              : TitleAppBar(
                  title: '',
                  displayName: true,
                  onBellTap: () {
                    context.push(
                      GRouter.config.applicationRoutes.notifications,
                    );
                  },
                ),
          bottomNavigationBar: CoursatyBottomNavBar(
            currentIndex: _navIndex,
            isStudent: isStudent,
            onTap: (i) {
              if (i == 0 && openSearch.value) {
                openSearch.value = false;
                return;
              }
              setState(() => _navIndex = i);
            },
          ),
          body: pages[_navIndex],
        ),
      ),
    );
  }
}
