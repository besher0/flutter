import 'package:coursaty_student_and_teacher/core/platform/app_platform.dart';
import 'package:coursaty_student_and_teacher/core/platform/app_layout.dart';
import 'package:coursaty_student_and_teacher/core/common/helper/show_message.dart';
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
    // await ScreenCapturePolicy.instance.resetToAllowed();
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
    // Phones scale the 375-wide design to the screen. A desktop window is
    // drawn 1:1 (its own size as the design size): scaling the phone design
    // to a 1280-wide window made everything about 3.4x too large.
    return LayoutBuilder(
      builder: (context, constraints) => _withScreenUtil(
        AppPlatform.isDesktop && constraints.biggest.isFinite
            ? AppLayout.contentSize(constraints.biggest)
            : kDesignSize,
      ),
    );
  }

  Widget _withScreenUtil(Size designSize) {
    return ScreenUtilInit(
      designSize: designSize,
      minTextAdapt: true,
      builder: (context, child) {
        if (AppPlatform.isDesktop) {
          // ScreenUtil measures the whole window, but the app is drawn in the
          // centred frame (DesktopFrame): measure the frame instead, so the
          // scale stays 1:1 and `1.sw` is the frame's width, not the window's.
          ScreenUtil.configure(
            data: MediaQueryData.fromView(
              View.of(context),
            ).copyWith(size: designSize),
            designSize: designSize,
          );
        }
        return LocalizationService(
          child: ServiceProvider(
            child: Builder(
              builder: (context) {
                final isLightTheme = context
                    .watch<AppBloc>()
                    .state
                    .isThemeLight;
                return MaterialApp.router(
                  scaffoldMessengerKey: AppMessenger.key,
                  scrollBehavior: const AppScrollBehavior(),
                  debugShowCheckedModeBanner: false,
                  title: "كورساتي",
                  locale: context.locale,
                  theme: isLightTheme ? AppTheme.light : AppTheme.dark,
                  builder: (context, child) {
                    return MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(textScaler: TextScaler.noScaling),
                      child: DesktopFrame(child: child!),
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
