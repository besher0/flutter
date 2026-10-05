import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/widgets/chip_widget.dart';
import '../../../../core/theme/app_colors.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.title,
    required this.imageUrl,
    this.chips = const [],
    this.onTap,
    this.footer,
    this.height,
  });

  final double? height;
  final String title;
  final String imageUrl;
  final List<CourseChipData> chips;
  final VoidCallback? onTap;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 0.8.sw,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primaryLightTrack, width: 0.85),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 1.sw,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _placeholder(),
                  errorWidget: (_, __, ___) => _placeholder(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.4,
              ),
              textAlign: TextAlign.end,
            ),
            if (chips.isNotEmpty) ...[
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 10,
                  children: chips
                      .map(
                        (c) => ChipWidget(
                          text: c.text,
                          iconPath: c.iconPath,
                          iconColor: c.iconColor,
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
            ?footer,
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    height: 83,
    decoration: BoxDecoration(
      color: AppColors.primaryLightTrack,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(Icons.image_outlined, color: AppColors.greyNormal, size: 40),
  );
}

class CourseChipData {
  const CourseChipData(this.text, this.iconPath, {required this.iconColor});

  final String text;
  final String iconPath;
  final Color iconColor;
}
