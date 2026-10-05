import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/common/constant/design/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

import 'package:coursaty_student_and_teacher/core/utils/responsive_padding.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
    this.onBellTap,
    this.onBackTap,
    this.onMenuTap,
    this.onSearch,
  });

  final VoidCallback? onMenuTap;
  final VoidCallback? onBellTap;
  final VoidCallback? onBackTap;
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (p, c) => p.updateProfileStatus != c.updateProfileStatus,
      builder: (context, state) {
        return AppBar(
          leadingWidth: 40.w,
          foregroundColor: AppColors.primary,
          actions: [
            if (onSearch != null) ...{
              InkWell(
                onTap: onSearch,
                child: SvgPicture.asset(
                  AppAssets.iconSearch,
                  height: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              10.horizontalSpace,
            },
            if (onBellTap != null) ...{
              InkWell(
                onTap: onBellTap,
                child: SvgPicture.asset(
                  AppAssets.iconBell,
                  height: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              10.horizontalSpace,
            },
          ],
          leading: onBackTap == null
              ? null
              : Padding(
                  padding: HWEdgeInsetsDirectional.only(start: 10),
                  child: InkWell(
                    onTap: onBackTap ?? () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.arrow_back_outlined,
                      size: 30,
                      color: AppColors.primary,
                    ),
                  ),
                ),
          title: Text(
            'مرحبا ${GetIt.I<PrefsRepository>().name}',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
              height: 1.4,
            ),
          ),
          centerTitle: true,
        );
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
