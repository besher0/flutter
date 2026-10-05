import 'package:cached_network_image/cached_network_image.dart';
import 'package:coursaty_student_and_teacher/core/common/constant/design/constant_design.dart';
import 'package:coursaty_student_and_teacher/core/routes/router.dart';
import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:coursaty_student_and_teacher/features/teachers/presentation/screens/revenue_screen.dart';
import 'package:coursaty_student_and_teacher/features/teachers/presentation/screens/withdrawals_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/widgets/logout_confirmation_dialog.dart';
import '../../../../core/common/constant/design/app_assets.dart';
import '../../../../core/common/constant/configuration/feature_flags.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import 'teacher_affiliations_screen.dart';

class TeacherProfile extends StatefulWidget {
  const TeacherProfile({super.key});

  @override
  State<TeacherProfile> createState() => _TeacherProfileState();
}

class _TeacherProfileState extends State<TeacherProfile> {
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();

  Future<void> _showLogoutConfirm(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => LogoutConfirmationDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: HWEdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                30.verticalSpace,
                BlocBuilder<AuthBloc, AuthState>(
                  buildWhen: (p, c) =>
                      p.updateProfileStatus != c.updateProfileStatus ||
                      p.profileStatus != c.profileStatus,
                  builder: (context, state) {
                    return Container(
                      height: 86,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        spacing: 5,
                        children: [
                          state.profileModel?.teacher?.image != null
                              ? ClipRRect(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    180,
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        state.profileModel!.teacher!.image!,
                                    width: 60.r,
                                    height: 60.r,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) {
                                      return Icon(Icons.error);
                                    },
                                  ),
                                )
                              : CircleAvatar(
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
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,

                              children: [
                                Padding(
                                  padding: HWEdgeInsets.symmetric(
                                    vertical: 10.0,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${_prefsRepository.name}',
                                        style: GoogleFonts.cairo(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        '${_prefsRepository.phone}',
                                        style: GoogleFonts.cairo(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    context.push(
                                      "${GRouter.config.applicationRoutes.editProfile}/true",
                                    );
                                  },
                                  child: SvgPicture.asset(
                                    AppAssets.iconEdit,
                                    width: 24,
                                    height: 24,
                                    colorFilter: const ColorFilter.mode(
                                      Color(0xFFF9E3C4),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                15.verticalSpace,
                Row(
                  children: [
                    if (SubscriptionFeatureFlags.showLegacySubscriptionMethods)
                      Expanded(
                        child: _ButtonItem(
                          onTap: () {
                            context.push(
                              GRouter.config.applicationRoutes.pointsOfSale,
                            );
                          },
                          title: "نقاط البيع",
                        ),
                      ),
                    if (SubscriptionFeatureFlags.showLegacySubscriptionMethods)
                      SizedBox(width: 10),
                    Expanded(
                      child: _ButtonItem(
                        onTap: () {
                          context.push(
                            GRouter.config.applicationRoutes.contactUs,
                          );
                        },
                        title: "تواصل معنا",
                      ),
                    ),
                  ],
                ),
                15.verticalSpace,
                Row(
                  children: [
                    Expanded(
                      child: _ButtonItem(
                        onTap: () {
                          context.pushPage(TeacherRevenueScreen());
                        },
                        title: "إيراداتي",
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _ButtonItem(
                        onTap: () {
                          context.pushPage(TeacherWithdrawalsScreen());
                        },
                        title: "سحوباتي",
                      ),
                    ),
                  ],
                ),
                15.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _ButtonItem(
                        onTap: () {
                          context.pushPage(TeacherAffiliationsScreen());
                        },
                        title: "جامعاتي",
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _ButtonItem(
                        onTap: () {
                          context.push(
                            GRouter.config.applicationRoutes.changePassword,
                          );
                        },
                        title: "تغيير كلمة المرور",
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: OutlinedButton(
                  onPressed: () async {
                    _showLogoutConfirm(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1,
                    ),
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'تسجيل خروج',
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
          ],
        ),
      ),
    );
  }
}

class _ButtonItem extends StatelessWidget {
  const _ButtonItem({super.key, required this.title, required this.onTap});

  final String title;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: HWEdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.textLight,
          borderRadius: BorderRadius.circular(kr12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              offset: Offset(0, 2.55),
              blurRadius: 10.22,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: Color(0xff129879).withValues(alpha: 0.2),
                radius: 30,
                child: Center(
                  child: SvgPicture.asset(
                    AppAssets.iconDownload2,
                    color: Color(0xff1F6366),
                  ),
                ),
              ),
              15.verticalSpace,
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
