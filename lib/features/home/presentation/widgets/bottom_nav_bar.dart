import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/common/constant/design/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

class CoursatyBottomNavBar extends StatelessWidget {
  const CoursatyBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.isStudent,
  });

  final bool isStudent;
  final int currentIndex;
  final ValueChanged<int> onTap;

  BottomNavigationBarItem _buildItem({
    required String label,
    required String iconPath,
    required BuildContext context,
  }) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        iconPath,
        height: 25,
        colorFilter: const ColorFilter.mode(
          AppColors.greyNormal,
          BlendMode.srcIn,
        ),
      ),
      activeIcon: SvgPicture.asset(
        iconPath,
        height: 25,
        colorFilter: ColorFilter.mode(
          Theme.of(context).colorScheme.primary,
          BlendMode.srcIn,
        ),
      ),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = isStudent
        ? [
            _buildItem(
              label: 'الرئيسية',
              iconPath: AppAssets.iconHome,
              context: context,
            ),
            _buildItem(
              label: 'الكورسات',
              iconPath: AppAssets.iconLayers,
              context: context,
            ),
            _buildItem(
              label: 'اشتراكاتي',
              iconPath: AppAssets.iconDocument,
              context: context,
            ),
            _buildItem(
              label: 'التنزيلات',
              iconPath: AppAssets.iconDownload,
              context: context,
            ),
          ]
        : [
            _buildItem(
              label: 'الرئيسية',
              iconPath: AppAssets.iconHome,
              context: context,
            ),
            _buildItem(
              label: 'كورساتي',
              iconPath: AppAssets.iconLayers,
              context: context,
            ),
            _buildItem(
              label: 'ملفي',
              iconPath: AppAssets.iconUser,
              context: context,
            ),
          ];

    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: InkRipple.splashFactory,
        textTheme: Theme.of(context).textTheme.copyWith(
          labelSmall: GoogleFonts.cairo(fontSize: 10, height: 1.4),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        items: items,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 10,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: AppColors.greyNormal,
        selectedLabelStyle: GoogleFonts.cairo(
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: GoogleFonts.cairo(
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
        showUnselectedLabels: true,
      ),
    );
  }
}
