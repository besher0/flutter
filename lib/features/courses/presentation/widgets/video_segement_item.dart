import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/lecture_details_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions/int.dart';
import '../../../../core/utils/responsive_padding.dart';

class VideoSegementItem extends StatelessWidget {
  const VideoSegementItem({
    super.key,
    required this.index,
    required this.segment,
    this.onEdit,
    this.onDelete,
  });

  final int index;
  final Segment segment;
  final void Function()? onEdit, onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: 0.9.sw,
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
                  padding: HWEdgeInsets.symmetric(horizontal: 25.0),
                  child: Icon(
                    Icons.play_arrow_outlined,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10.h,
              children: [
                Text(
                  segment.segmentName!,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  (segment.startSeconds ?? 0).formatDurationFromSeconds(),
                  // ${(segment.endSeconds == null || segment.endSeconds == 0) ? '' : " - ${(segment.endSeconds ?? 0).formatDurationFromSeconds()}"}
                  style: GoogleFonts.cairo(
                    color: context.colorScheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (onEdit != null) ...{
            InkWell(onTap: onEdit, child: Icon(Icons.edit)),
            10.horizontalSpace,
          },
          if (onDelete != null) ...{
            InkWell(
              onTap: onDelete,
              child: Icon(Icons.delete, color: Colors.red),
            ),
            10.horizontalSpace,
          },
        ],
      ),
    );
  }
}
