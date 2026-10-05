import 'package:cached_network_image/cached_network_image.dart';
import 'package:coursaty_student_and_teacher/app/widgets/chip_widget.dart';
import 'package:coursaty_student_and_teacher/features/home/data/models/home_response_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/common/constant/design/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    this.height = 200,
    this.onTap,
    required this.subject,
  });

  final Program subject;
  final double height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        height: height,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryLightTrack, width: 0.85),
          boxShadow: [AppColors.cardShadow],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: subject.image ?? '',
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: AppColors.primaryLightTrack,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.primaryLightTrack,
                    child: Icon(
                      Icons.image_outlined,
                      color: AppColors.greyNormal,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  subject.name ?? '',
                  style: GoogleFonts.cairo(
                    fontSize: height > 100 ? 18 : 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    spacing: 10.w,
                    children: [
                      // if ((subject.isProgram ?? false) &&
                      //     subject.teacherName != null) ...{
                      //   ChipWidget(
                      //     text: subject.teacherName!,
                      //     iconPath: AppAssets.iconUser,
                      //     iconColor: AppColors.secondary,
                      //   ),
                      // },
                      if (!(subject.isProgram ?? false)) ...{
                        ChipWidget(
                          text: subject.year?.name,
                          iconPath: AppAssets.iconLayers,
                          iconColor: AppColors.secondary,
                        ),
                        ChipWidget(
                          text: subject.season?.name,
                          iconPath: AppAssets.iconDocument,
                          iconColor: AppColors.secondary,
                        ),
                      },
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
