import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:coursaty_student_and_teacher/app/widgets/try_again_widget.dart';
import 'package:coursaty_student_and_teacher/core/common/helper/helper_functions.dart';
import 'package:coursaty_student_and_teacher/core/routes/router.dart';
import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:coursaty_student_and_teacher/core/utils/responsive_padding.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'app/widgets/coursaty_button.dart';
import 'core/common/constant/design/app_assets.dart';
import 'core/error/failures.dart';
import 'features/app/presentation/bloc/app_bloc.dart';
import 'features/app_links_navigations.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _duration = Duration(seconds: 2);
  final prefs = GetIt.I<PrefsRepository>();
  late final AppLinks _appLinks;
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleDeepLinks();
    });
  }

  void _handleDeepLinks() async {
    // if (GetIt.I<PrefsRepository>().token == null) return;

    _appLinks = AppLinks();

    // Listen for dynamic links while app is in foreground
    _appLinks.uriLinkStream.listen((uri) {
      navigateFromUri(uri);
    });

    // Handle app opened from terminated state
    final Uri? initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      navigateFromUri(initialUri);
      return;
    }
    _handleAppStartUp();
  }

  void _navigateToOnboarding() {
    if (!mounted) return;
    final onboardingSeen = prefs.onBoardingSeen ?? false;
    context.go(
      onboardingSeen
          ? GRouter.config.applicationRoutes.login
          : GRouter.config.applicationRoutes.onboarding,
    );
  }

  void _navigateToDownloads() {
    context.go(GRouter.config.applicationRoutes.downloads);
  }

  void _navigateToInActiveScreen(bool isStudent) {
    if (isStudent) {
      context.go(GRouter.config.applicationRoutes.blockedAccount);
    } else {
      context.go("${GRouter.config.applicationRoutes.signupSuccess}/true");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: BlocConsumer<AuthBloc, AuthState>(
          listenWhen: (p, c) => p.profileStatus != c.profileStatus,
          listener: (context, state) {
            if (state.profileStatus.isSuccess) {
              if (state.profileModel?.user?.isActive ?? true) {
                _navigateToHome();
              } else {
                _navigateToInActiveScreen(
                  state.profileModel?.user?.isStudent ?? true,
                );
              }
            }
          },
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                // Text(
                //   'COURSATY',
                //   style: GoogleFonts.cairo(
                //     fontSize: 24,
                //     fontWeight: FontWeight.w800,
                //     color: Theme.of(context).colorScheme.onSurface,
                //     letterSpacing: 4.56,
                //     height: 1.4,
                //   ),
                // ),
                if (state.profileStatus.isFailed) ...{
                  20.verticalSpace,
                  if (state.failure != null &&
                      state.failure is UnAuthorizedFailure)
                    CoursatyPrimaryButton(
                      label: "تسجيل الدخول",
                      onPressed: () {
                        context.go(GRouter.config.applicationRoutes.login);
                      },
                      margin: HWEdgeInsets.symmetric(horizontal: 20),
                    )
                  else
                    TryAgainWidget(onPress: _fetchProfile),
                },
                const SizedBox(height: 100),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogo() {
    final isThemeLight = context.read<AppBloc>().state.isThemeLight;
    return Image.asset(
      isThemeLight ? AppAssets.logo : AppAssets.logoDark,
      scale: 2,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Container(
        width: 0.8.sw,
        height: 0.5.sh,
        decoration: BoxDecoration(
          color: AppColors.primaryLightTrack,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.school_rounded,
          size: 80,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _handleAppStartUp() {
    final token = prefs.token;
    final isGuest = prefs.isGuest;
    final isStudent = prefs.isStudent ?? true;
    if (token == null) {
      if (isGuest) {
        _navigateToHome();
        return;
      }
      // first open of the app
      Timer(_duration, _navigateToOnboarding);
    } else {
      // there is a user
      if (isStudent) {
        // maybe open the app in offline mode
        _checkOfflineMode();
        return;
      }
      // is a teacher -> check activity status
      _fetchProfile();
    }
    BlocProvider.of<AuthBloc>(context).add(GetUniversitiesEvent());
  }

  Future<void> _checkOfflineMode() async {
    final bool isOffline = await HelperFunctions.lostInternetConnection();
    if (isOffline) {
      _navigateToDownloads();
    } else {
      _fetchProfile();
    }
  }

  void _fetchProfile() {
    BlocProvider.of<AuthBloc>(context).add(GetProfileEvent());
  }

  void _navigateToHome() {
    context.go(GRouter.config.applicationRoutes.home);
  }
}
