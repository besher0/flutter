import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/common/constant/design/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

class TeacherEmptyCourses extends StatelessWidget {
  const TeacherEmptyCourses({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            50.verticalSpace,
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: AppColors.primaryLightTrack,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                AppAssets.iconVideo,
                height: 28,
                color: AppColors.greyNormal,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "لايوجد كورسات بعد",
              style: GoogleFonts.cairo(
                fontSize: 18,
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
