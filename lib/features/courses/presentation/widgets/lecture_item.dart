import 'package:coursaty_student_and_teacher/app/widgets/tint_chip.dart';
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
    this.trailing,
    this.videosCount,
    this.videosDurationSeconds,
  });

  /// Shown under the name as «4 فيديو» and the total length («1 ساعة و30 د»).
  final int? videosCount;
  final int? videosDurationSeconds;

  final Function()? onEdit, onDelete;

  /// Shown after the name, e.g. the downloads' "studied" badge.
  final Widget? trailing;
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
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // The card has a fixed height (lesson grid): the name takes
                  // what the chips leave, up to two lines, never overflowing.
                  Flexible(
                    child: Text(
                      lectureName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  StudyStatsChips(
                    videosCount: videosCount,
                    durationSeconds: videosDurationSeconds,
                  ),
                ],
              ),
            ),
          ),
          if (trailing != null) ...[trailing!, 6.horizontalSpace],
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
