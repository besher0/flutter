import 'package:coursaty_student_and_teacher/features/app/presentation/bloc/app_bloc.dart';
import 'package:coursaty_student_and_teacher/services/localization_service.dart';
import 'package:coursaty_student_and_teacher/services/service_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/common/constant/design/constant_design.dart';
import 'core/routes/router.dart';
import 'core/security/screen_capture_policy.dart';
import 'core/theme/app_theme.dart';

class CoursatyApp extends StatefulWidget {
  const CoursatyApp({super.key});

  @override
  State<CoursatyApp> createState() => _CoursatyAppState();
}

class _CoursatyAppState extends State<CoursatyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSecurity();
    });
  }

  void _initializeSecurity() async {
    await ScreenCapturePolicy.instance.resetToAllowed();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ScreenCapturePolicy.instance.refresh();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: kDesignSize,
      minTextAdapt: true,
      builder: (context, child) {
        return LocalizationService(
          child: ServiceProvider(
            child: Builder(
              builder: (context) {
                final isLightTheme = context
                    .watch<AppBloc>()
                    .state
                    .isThemeLight;
                return MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  title: "كورساتي",
                  locale: context.locale,
                  theme: isLightTheme ? AppTheme.light : AppTheme.dark,
                  builder: (context, child) {
                    return MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(textScaler: TextScaler.noScaling),
                      child: child!,
                    );
                  },
                  supportedLocales: context.supportedLocales,
                  localizationsDelegates: context.localizationDelegates,
                  routerConfig: GRouter.router,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
