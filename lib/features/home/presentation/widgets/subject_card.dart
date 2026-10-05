import 'package:cached_network_image/cached_network_image.dart';
import 'package:coursaty_student_and_teacher/app/widgets/chip_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/common/constant/design/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

class SubjectCard extends StatelessWidget {
  const SubjectCard({
    super.key,
    required this.title,
    required this.imageUrl,
    this.semester,
    this.year,
    this.teacher,
    this.onTap,
  });

  final String title;
  final String imageUrl;
  final String? semester;
  final String? year;
  final String? teacher;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        padding: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryLightTrack, width: 0.85),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 157,
                height: 83,
                fit: BoxFit.cover,
                placeholder: (_, __) => _placeholder(157, 83),
                errorWidget: (_, __, ___) => _placeholder(157, 83),
              ),
            ),
            10.horizontalSpace,
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (semester != null) ...{
                          ChipWidget(
                            text: semester,
                            iconPath: AppAssets.iconDocument,
                            iconColor: AppColors.secondary,
                          ),
                          const SizedBox(width: 14),
                        },
                        if (year != null) ...{
                          ChipWidget(
                            text: year,
                            iconPath: AppAssets.iconLayers,
                            iconColor: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 14),
                        },
                        if (teacher != null)
                          ChipWidget(
                            text: teacher,
                            iconPath: AppAssets.iconUser,
                            iconColor: Theme.of(context).colorScheme.primary,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(double w, double h) => Container(
    width: w,
    height: h,
    color: AppColors.primaryLightTrack,
    child: Icon(Icons.image_outlined, color: AppColors.greyNormal, size: 32),
  );
}
