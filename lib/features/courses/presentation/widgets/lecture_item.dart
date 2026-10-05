import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_padding.dart';

class LectureItem extends StatelessWidget {
  const LectureItem({
    super.key,
    this.onEdit,
    this.onDelete,
    required this.lectureName,
    required this.index,
  });

  final Function()? onEdit, onDelete;
  final String lectureName;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            spreadRadius: 0,
            blurRadius: 10.22,
            offset: Offset(0, 2.5),
          ),
        ],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryLightTrack),
      ),
      child: Row(
        children: [
          IntrinsicWidth(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadiusDirectional.only(
                  topStart: Radius.circular(12),
                  bottomStart: Radius.circular(12),
                ),
                color: [
                  Theme.of(context).colorScheme.primary,
                  AppColors.secondary,
                ][index % 2],
              ),
              child: Center(
                child: Padding(
                  padding: HWEdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              lectureName,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          if (onEdit != null) ...{
            IconButton(onPressed: onEdit, icon: Icon(Icons.edit)),
          },
          if (onDelete != null) ...{
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete, color: Colors.red),
            ),
          },
          10.horizontalSpace,
        ],
      ),
    );
  }
}
