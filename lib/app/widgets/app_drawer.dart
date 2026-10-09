import 'package:coursaty_student_and_teacher/app/widgets/chip_widget.dart';
import 'package:coursaty_student_and_teacher/app/widgets/you_are_guest_dialog.dart';
import 'package:coursaty_student_and_teacher/core/common/helper/show_message.dart';
import 'package:coursaty_student_and_teacher/core/routes/router.dart';
import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:coursaty_student_and_teacher/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:coursaty_student_and_teacher/services/device_info_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/common/constant/design/app_assets.dart';
import '../../core/common/constant/configuration/feature_flags.dart';
import '../../core/theme/app_colors.dart';
import '../../features/app/presentation/bloc/app_bloc.dart';
import '../../features/auth/presentation/screens/create_guest_screen.dart';
import 'activate_code_dialog.dart';
import 'delete_account_dialog.dart';
import 'loading_indicator/coursaty_app_loader.dart';
import 'logout_confirmation_dialog.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

Future<void> showActivateCode(BuildContext context) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => const ActivateCodeDialog(),
  );
}

class _AppDrawerState extends State<AppDrawer> {
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();

  Future<void> _showLogoutConfirm(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => LogoutConfirmationDialog(),
    );
  }

  Future<void> _showDeleteAccountConfirm(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => DeleteAccountDialog(
        onConfirmed: () {
          signOut(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (p, c) => p.updateProfileStatus != c.updateProfileStatus,
      listener: (context, state) {
        if (state.updateProfileStatus.isFailed) {
          showMessage(state.errorMessage);
        }
        if (state.updateProfileStatus.isSuccess) {
          if (context.canPop()) {
            Navigator.pop(context);
          }
        }
      },
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (p, c) => p.updateStudent != c.updateStudent,
        listener: (context, state) {
          if (state.updateStudent.isFailed) {
            showMessage(state.errorMessage);
          }
          if (state.updateStudent.isSuccess) {
            clearAllBlocs();
            context.go(GRouter.config.kRootRoute);
          }
        },
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Drawer(
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 10),
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 26,
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      child: SvgPicture.asset(
                                        AppAssets.iconBoy,
                                        height: 26,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    BlocBuilder<AuthBloc, AuthState>(
                                      buildWhen: (p, c) =>
                                          p.updateProfileStatus !=
                                          c.updateProfileStatus,
                                      builder: (context, state) {
                                        return Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                prefsRepository.name ?? '',
                                                style: GoogleFonts.cairo(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                                  height: 1.4,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                prefsRepository.phone ?? '',
                                                style: GoogleFonts.cairo(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                  height: 1.4,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              if (!prefsRepository.isGuest)
                                InkWell(
                                  onTap: () {
                                    context.push(
                                      "${GRouter.config.applicationRoutes.editProfile}/false",
                                    );
                                  },
                                  child: SvgPicture.asset(
                                    AppAssets.iconEdit,
                                    height: 26,
                                  ),
                                ),
                            ],
                          ),
                          10.verticalSpace,
                          if (!prefsRepository.isGuest) ...{
                            BlocBuilder<AuthBloc, AuthState>(
                              buildWhen: (p, c) =>
                                  p.profileStatus != c.profileStatus,
                              builder: (context, state) {
                                if (state.profileModel == null) {
                                  return SizedBox.shrink();
                                }
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 5,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      spacing: 5,
                                      children: [
                                        if (state
                                                .profileModel!
                                                .student
                                                ?.university
                                                ?.name !=
                                            null)
                                          ChipWidget(
                                            text:
                                                state
                                                    .profileModel!
                                                    .student
                                                    ?.university
                                                    ?.name ??
                                                '',
                                            iconPath: AppAssets.iconLayers,
                                            iconColor: AppColors.primary,
                                          ),
                                        if (state
                                                .profileModel!
                                                .student
                                                ?.college
                                                ?.name !=
                                            null)
                                          ChipWidget(
                                            text:
                                                state
                                                    .profileModel!
                                                    .student
                                                    ?.college
                                                    ?.name ??
                                                '',
                                            iconColor: AppColors.secondary,
                                            iconPath: AppAssets.iconDocument,
                                          ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      spacing: 5,
                                      children: [
                                        if (state
                                                .profileModel!
                                                .student
                                                ?.department !=
                                            null)
                                          ChipWidget(
                                            text:
                                                state
                                                    .profileModel!
                                                    .student
                                                    ?.department ??
                                                '',
                                            iconColor: AppColors.secondary,
                                            iconPath: AppAssets.iconLayers,
                                          ),
                                        if (state
                                                .profileModel!
                                                .student
                                                ?.collegeYear
                                                ?.academicYear
                                                ?.yearName !=
                                            null)
                                          ChipWidget(
                                            text:
                                                state
                                                    .profileModel!
                                                    .student
                                                    ?.collegeYear
                                                    ?.academicYear
                                                    ?.yearName ??
                                                '',
                                            iconColor: AppColors.primary,
                                            iconPath: AppAssets.iconDocument,
                                          ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          },
                          Spacer(),
                          Divider(
                            height: 1,
                            color: AppColors.secondary.withValues(alpha: 0.15),
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 10,
                      child: ListView(
                        children: [
                          BlocConsumer<AppBloc, AppState>(
                            listener: (context, state) {},
                            builder: (context, state) {
                              return state.scanCode.isLoading
                                  ? CoursatyAppLoader()
                                  : _DrawerItem(
                                      icon: AppAssets.iconScanCose,
                                      iconColor: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      title: 'تفعيل كود',
                                      onTap: () async {
                                        if (prefsRepository.isGuest) {
                                          showGuestContentDialog(context);
                                          return;
                                        }
                                        showActivateCode(context);
                                      },
                                    );
                            },
                          ),
                          _DrawerItem(
                            icon: AppAssets.iconCategory,
                            iconColor: Theme.of(context).colorScheme.primary,
                            title: 'تغيير الجامعة',
                            onTap: () {
                              if (prefsRepository.isGuest) {
                                context.pushPage(
                                  CreateGuestScreen(forEdit: true),
                                );
                                return;
                              }
                              context.push(
                                "${GRouter.config.applicationRoutes.changeUniversity}/false",
                              );
                            },
                          ),
                          if (SubscriptionFeatureFlags
                              .showLegacySubscriptionMethods)
                            _DrawerItem(
                              icon: AppAssets.iconCategory,
                              iconColor: Theme.of(context).colorScheme.primary,
                              title: 'نقاط البيع',
                              onTap: () {
                                context.push(
                                  GRouter.config.applicationRoutes.pointsOfSale,
                                );
                              },
                            ),
                          _DrawerItem(
                            icon: AppAssets.iconCategory,
                            iconColor: Theme.of(context).colorScheme.primary,
                            title: 'تغيير السنة',
                            onTap: () {
                              if (prefsRepository.isGuest) {
                                context.pushPage(
                                  CreateGuestScreen(
                                    forEdit: true,
                                    forYearOnly: true,
                                  ),
                                );
                                return;
                              }
                              context.push(
                                "${GRouter.config.applicationRoutes.changeUniversity}/true",
                              );
                            },
                          ),
                          if (!prefsRepository.isGuest)
                            _DrawerItem(
                              icon: AppAssets.iconCategory,
                              iconColor: Theme.of(context).colorScheme.primary,
                              title: 'تغيير كلمة المرور',
                              onTap: () {
                                context.push(
                                  GRouter
                                      .config
                                      .applicationRoutes
                                      .changePassword,
                                );
                              },
                            ),
                          _DrawerItem(
                            icon: AppAssets.iconCategory,
                            iconColor: Theme.of(context).colorScheme.primary,
                            title: 'تواصل معنا',
                            onTap: () {
                              context.push(
                                GRouter.config.applicationRoutes.contactUs,
                              );
                            },
                          ),
                          _DrawerItem(
                            icon: AppAssets.iconCategory,
                            iconColor: Theme.of(context).colorScheme.primary,
                            title: 'عن التطبيق',
                            onTap: () {
                              context.push(
                                GRouter.config.applicationRoutes.aboutApp,
                              );
                            },
                          ),
                          Column(
                            children: [
                              _ThemeTogglePreview(),
                              25.verticalSpace,
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 40,
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      if (prefsRepository.isGuest) {
                                        context.go(
                                          GRouter
                                              .config
                                              .applicationRoutes
                                              .login,
                                        );
                                        return;
                                      }
                                      _showLogoutConfirm(context);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      side: BorderSide(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        width: 1,
                                      ),
                                      backgroundColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.logout, size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          prefsRepository.isGuest
                                              ? "تسجيل الدخول"
                                              : 'تسجيل خروج',
                                          style: GoogleFonts.cairo(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              15.verticalSpace,
                              if (!prefsRepository.isGuest &&
                                  prefsRepository.isStudent &&
                                  kIsIOS) ...[
                                BlocBuilder<AuthBloc, AuthState>(
                                  buildWhen: (p, c) =>
                                      p.authStatus != c.authStatus,
                                  builder: (context, state) {
                                    return state.authStatus.isLoading
                                        ? CoursatyAppLoader()
                                        : Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                            ),
                                            child: SizedBox(
                                              width: double.infinity,
                                              height: 40,
                                              child: OutlinedButton(
                                                onPressed: () async {
                                                  _showDeleteAccountConfirm(
                                                    context,
                                                  );
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                                  side: BorderSide(
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                    width: 1,
                                                  ),
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.delete_outline,
                                                      size: 18,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      "حذف الحساب",
                                                      style: GoogleFonts.cairo(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        height: 1.4,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                  },
                                ),
                                15.verticalSpace,
                              ],
                              Text(
                                'Version 2.0.0',
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.greyDark,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.iconColor,
  });

  final String icon;
  final String title;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Row(
          children: [
            SvgPicture.asset(icon, height: 25, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.4,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 30,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeTogglePreview extends StatefulWidget {
  @override
  State<_ThemeTogglePreview> createState() => _ThemeTogglePreviewState();
}

class _ThemeTogglePreviewState extends State<_ThemeTogglePreview> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return Container(
          height: 40,
          width: 0.25.sw,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(22),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: GestureDetector(
            onTap: () {
              BlocProvider.of<AppBloc>(context).add(ChangeThemeEvent());
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: state.isThemeLight
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.primary,
                  child: SvgPicture.asset(
                    AppAssets.iconSun,
                    color: !state.isThemeLight
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.primary,
                    height: 15,
                  ),
                ),
                CircleAvatar(
                  radius: 15,
                  backgroundColor: !state.isThemeLight
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.primary,
                  child: SvgPicture.asset(
                    AppAssets.iconMoon,
                    color: state.isThemeLight
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.primary,
                    height: 15,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
