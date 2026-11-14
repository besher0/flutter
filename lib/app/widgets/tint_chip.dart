import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/common/constant/design/app_assets.dart';
import '../../core/theme/app_colors.dart';

/// Colour of a [TintChip]: a light tint background, icon and text in the
/// darker shade of the same colour.
enum ChipTone { teal, amber }

/// Small pill with an icon and a short text, e.g. «4 فيديو» or «45 د» on the
/// lesson and video cards.
class TintChip extends StatelessWidget {
  const TintChip({
    super.key,
    required this.iconPath,
    required this.text,
    this.tone = ChipTone.teal,
  });

  final String iconPath;
  final String text;
  final ChipTone tone;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final base = switch (tone) {
      ChipTone.teal => dark ? AppColors.darkPrimary : AppColors.primary,
      ChipTone.amber => AppColors.secondary,
    };
    final foreground = dark
        ? base
        : switch (tone) {
            ChipTone.teal => AppColors.primary,
            ChipTone.amber => const Color(0xFF9A6418),
          };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: base.withValues(alpha: dark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconPath,
            height: 14,
            colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            maxLines: 1,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: foreground,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// «45 د», «1 ساعة», «1 ساعة و30 د», «14 ساعة و4 د». Under a minute shows
/// «1 د». Null for no duration (unknown or zero).
String? formatStudyDuration(int? seconds) {
  if (seconds == null || seconds <= 0) return null;
  final minutes = seconds < 60 ? 1 : (seconds / 60).round();
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  if (hours == 0) return '$rest د';
  if (rest == 0) return '$hours ساعة';
  return '$hours ساعة و$rest د';
}

/// The chips under a lesson's or a video's title: video count (lessons only)
/// and total length. Nothing when there is nothing to show.
class StudyStatsChips extends StatelessWidget {
  const StudyStatsChips({super.key, this.videosCount, this.durationSeconds});

  final int? videosCount;
  final int? durationSeconds;

  @override
  Widget build(BuildContext context) {
    final duration = formatStudyDuration(durationSeconds);
    final count = videosCount;
    if ((count == null || count <= 0) && duration == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          if (count != null && count > 0)
            TintChip(iconPath: AppAssets.iconPlayCircle, text: '$count فيديو'),
          if (duration != null)
            TintChip(
              iconPath: AppAssets.iconTimer,
              text: duration,
              tone: ChipTone.amber,
            ),
        ],
      ),
    );
  }
}
