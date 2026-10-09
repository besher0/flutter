import 'package:coursaty_student_and_teacher/features/app/presentation/bloc/app_bloc.dart';
import 'package:coursaty_student_and_teacher/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/presentation/bloc/course_content_management_bloc.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/bloc/courses_bloc.dart';
import 'package:coursaty_student_and_teacher/features/home/presentation/bloc/home_bloc.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/presentation/bloc/downloading_media/downloading_media_bloc.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/presentation/bloc/my_downloads_bloc.dart';
import 'package:coursaty_student_and_teacher/features/norifications/presentation/bloc/notifications_bloc.dart';
import 'package:coursaty_student_and_teacher/features/sales_points/presentation/bloc/sales_points_bloc.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/presentation/bloc/subscription_bloc.dart';
import 'package:coursaty_student_and_teacher/features/teachers/presentation/bloc/teachers_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../app/blocs/sensitive_connectivity/sensitive_connectivity_bloc.dart';
import '../core/di/di_container.dart';

class ServiceProvider extends StatelessWidget {
  final Widget child;

  const ServiceProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: SensitiveConnectivityBloc(),
      // Rebuilt after resetDependencies() so `context` and `GetIt` always
      // resolve to the same bloc instances.
      child: ValueListenableBuilder<int>(
        valueListenable: dependenciesGeneration,
        builder: (context, _, child) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: GetIt.I<AuthBloc>()),
            BlocProvider.value(value: GetIt.I<HomeBloc>()),
            BlocProvider.value(value: GetIt.I<TeachersBloc>()),
            BlocProvider.value(value: GetIt.I<CoursesBloc>()),
            BlocProvider.value(value: GetIt.I<AppBloc>()),
            BlocProvider.value(value: GetIt.I<CourseContentManagementBloc>()),
            BlocProvider.value(value: GetIt.I<DownloadingMediaBloc>()),
            BlocProvider.value(value: GetIt.I<MyDownloadsBloc>()),
            BlocProvider.value(value: GetIt.I<NotificationsBloc>()),
            BlocProvider.value(value: GetIt.I<SalesPointsBloc>()),
            BlocProvider.value(value: GetIt.I<SubscriptionBloc>()),
          ],
          child: child!,
        ),
        child: child,
      ),
    );
  }
}
