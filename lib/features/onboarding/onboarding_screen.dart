import 'dart:async';

import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/core/routes/router.dart';
import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:coursaty_student_and_teacher/core/utils/responsive_padding.dart';
import 'package:coursaty_student_and_teacher/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:coursaty_student_and_teacher/features/auth/presentation/screens/create_guest_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/widgets/coursaty_button.dart';
import '../../core/common/constant/design/app_assets.dart';
import '../../core/common/helper/show_message.dart';
import '../../core/theme/app_colors.dart';

class _OnboardingPage {
  const _OnboardingPage({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

const _pages = [
  _OnboardingPage(
    title: 'كورسات جامعية وعملية، مصمّمة لتناسب وقتك وأسلوبك',
    subtitle: 'كورسات جامعية وعملية، مصمّمة لتناسب وقتك وأسلوبك.',
  ),
  _OnboardingPage(
    title: 'موادك الجامعية… بطريقة أذكى',
    subtitle: 'شرح مبسّط، مراجعات، وتمارين بتفهمك المادة مو تحفظك.',
  ),
  _OnboardingPage(
    title: 'بلّش رحلتك للتخرج... اليوم',
    subtitle: 'أنشئ حسابك وابدأ أول كورس خلال دقائق.',
  ),
];

/// Onboarding: 3-page carousel, dots, "التسجيل" / "تسجيل الدخول", "أكمل التصفّح كزائر".
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  void initTimer() {
    _timer?.cancel();
    _timer = Timer(Duration(seconds: 5), () {
      _goToSignUp(forTeacher: true);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void makeOnBoardingSeen() {
    GetIt.I<PrefsRepository>().setOnBoardingSeen(true);
  }

  void markUserAsGuest() {
    GetIt.I<PrefsRepository>().setIsGuest(true);
  }

  void _goToSignUp({bool forTeacher = false}) {
    makeOnBoardingSeen();
    context.go("${GRouter.config.applicationRoutes.signup}/$forTeacher");
  }

  void _goToLogin() {
    makeOnBoardingSeen();
    context.go(GRouter.config.applicationRoutes.login);
  }

  void _guestSuccess() {
    makeOnBoardingSeen();
    markUserAsGuest();
    context.go(GRouter.config.applicationRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Column(
            children: [
              Spacer(),
              Expanded(
                flex: 2,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return _OnboardingPageView(
                      title: page.title,
                      subtitle: page.subtitle,
                      imagePlaceholder: _buildImagePlaceholder(index),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildDots(),
                    const SizedBox(height: 35),
                    Row(
                      children: [
                        Expanded(
                          child: CoursatyPrimaryButton(
                            label: 'إنشاء الحساب',
                            onPressed: _goToSignUp,
                            onTapDown: (_) {
                              initTimer();
                            },
                            onTapUp: (_) {
                              _timer?.cancel();
                            },
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: CoursatySecondaryButton(
                            label: 'تسجيل الدخول',
                            color: AppColors.secondary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                            onPressed: _goToLogin,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    BlocConsumer<AuthBloc, AuthState>(
                      buildWhen: (p, c) =>
                          p.getOrCreateGuest != c.getOrCreateGuest,
                      listenWhen: (p, c) =>
                          p.getOrCreateGuest != c.getOrCreateGuest,
                      listener: (context, state) {
                        if (state.getOrCreateGuest.isSuccess) {
                          _guestSuccess();
                        } else if (state.getOrCreateGuest.isFailed &&
                            state.isNotFoundGuestError) {
                          context.pushPage(CreateGuestScreen());
                        }
                      },
                      builder: (context, state) {
                        return state.getOrCreateGuest.isLoading
                            ? Center(child: CoursatyAppLoader())
                            : InkWell(
                                onTap: () {
                                  BlocProvider.of<AuthBloc>(
                                    context,
                                  ).add(GetGuestEvent());
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  spacing: 10,
                                  children: [
                                    Text(
                                      'أكمل التصفّح كزائر',
                                      style: GoogleFonts.cairo(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: context.colorScheme.primary,
                                      ),
                                    ),
                                    Container(
                                      padding: HWEdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.arrow_forward_ios,
                                          size: 12,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 7.5,
          height: 7.5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i == _currentPage
                ? Theme.of(context).colorScheme.primary
                : AppColors.primaryLightTrack,
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(int index) {
    final asset = index == 0
        ? AppAssets.onboarding1
        : (index == 1 ? AppAssets.onboarding2 : AppAssets.onboarding3);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Image.asset(
          asset,
          height: 220,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.primaryLightTrack.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              index == 0
                  ? Icons.menu_book_rounded
                  : (index == 1
                        ? Icons.auto_awesome
                        : Icons.rocket_launch_rounded),
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({
    required this.title,
    required this.subtitle,
    required this.imagePlaceholder,
  });

  final String title;
  final String subtitle;
  final Widget imagePlaceholder;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 24),
          imagePlaceholder,
          const SizedBox(height: 32),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textBody,
            ),
          ),
        ],
      ),
    );
  }
}
