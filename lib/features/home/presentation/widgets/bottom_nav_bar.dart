import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/common/constant/configuration/paid_content_policy.dart';
import '../../../../core/common/constant/design/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:coursaty_student_and_teacher/services/haptics/app_haptics.dart';

/// The student's bottom tabs, in order. The bar and the pages are both built
/// from [studentTabs], so a hidden tab never shifts one against the other.
enum StudentTab { home, courses, subscriptions, downloads }

/// «اشتراكاتي» is hidden with the rest of the paid content (iPhone, while the
/// admin hides it).
List<StudentTab> studentTabs({bool? hidePaid}) => [
  StudentTab.home,
  StudentTab.courses,
  if (!(hidePaid ?? PaidContentPolicy.hidePaid)) StudentTab.subscriptions,
  StudentTab.downloads,
];

typedef HomeNavItem = ({String label, String iconPath});

/// The home tabs for this role, in order: the phone's bottom bar and the
/// desktop's side rail show the same ones.
List<HomeNavItem> homeNavItems({required bool isStudent}) => isStudent
    ? [
        for (final tab in studentTabs())
          switch (tab) {
            StudentTab.home => (
              label: 'الرئيسية',
              iconPath: AppAssets.iconHome,
            ),
            StudentTab.courses => (
              label: 'الكورسات',
              iconPath: AppAssets.iconLayers,
            ),
            StudentTab.subscriptions => (
              label: 'اشتراكاتي',
              iconPath: AppAssets.iconDocument,
            ),
            StudentTab.downloads => (
              label: 'التنزيلات',
              iconPath: AppAssets.iconDownload,
            ),
          },
      ]
    : const [
        (label: 'الرئيسية', iconPath: AppAssets.iconHome),
        (label: 'كورساتي', iconPath: AppAssets.iconLayers),
        (label: 'ملفي', iconPath: AppAssets.iconUser),
      ];

Widget _navIcon(
  BuildContext context,
  String iconPath, {
  required bool active,
}) => SvgPicture.asset(
  iconPath,
  height: 25,
  colorFilter: ColorFilter.mode(
    active ? Theme.of(context).colorScheme.primary : AppColors.greyNormal,
    BlendMode.srcIn,
  ),
);

/// Desktop: the home tabs as a side rail (on the right in RTL).
class CoursatyNavigationRail extends StatelessWidget {
  const CoursatyNavigationRail({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.isStudent,
  });

  final bool isStudent;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final items = homeNavItems(isStudent: isStudent);
    final primary = Theme.of(context).colorScheme.primary;
    return NavigationRail(
      selectedIndex: currentIndex.clamp(0, items.length - 1),
      onDestinationSelected: onTap,
      extended: MediaQuery.sizeOf(context).width >= 1200,
      minExtendedWidth: 200,
      backgroundColor: Theme.of(context).colorScheme.surface,
      indicatorColor: primary.withValues(alpha: 0.12),
      labelType: MediaQuery.sizeOf(context).width >= 1200
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.all,
      selectedLabelTextStyle: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      unselectedLabelTextStyle: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.greyNormal,
      ),
      destinations: [
        for (final item in items)
          NavigationRailDestination(
            icon: _navIcon(context, item.iconPath, active: false),
            selectedIcon: _navIcon(context, item.iconPath, active: true),
            label: Text(item.label),
          ),
      ],
    );
  }
}

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
    final items = [
      for (final item in homeNavItems(isStudent: isStudent))
        _buildItem(
          label: item.label,
          iconPath: item.iconPath,
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
        onTap: (index) {
          if (index != currentIndex) AppHaptics.selection();
          onTap(index);
        },
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
