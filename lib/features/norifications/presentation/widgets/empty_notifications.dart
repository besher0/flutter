import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/common/constant/design/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

class EmptyNotificationsState extends StatelessWidget {
  const EmptyNotificationsState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.primaryLightTrack,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                AppAssets.iconBell,
                height: 26,
                color: AppColors.greyNormal,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد إشعارات',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.6),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
