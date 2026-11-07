import 'package:flutter/material.dart';

import '../../../../app/widgets/skeleton/skeleton.dart';
import '../../../../core/theme/app_colors.dart';

/// Bones of one `NotificationTile` (48 circle, title + date, two lines).
class NotificationTileSkeleton extends StatelessWidget {
  const NotificationTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonAvatar(size: 48),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonText(fontSize: 16, width: 120),
                    SkeletonText(fontSize: 14, width: 64),
                  ],
                ),
                SizedBox(height: 6),
                SkeletonText(fontSize: 16, lines: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// First load of a notifications list (16 side padding, dividers).
class NotificationListSkeleton extends StatelessWidget {
  const NotificationListSkeleton({super.key, this.count = 7});

  final int count;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        primary: false,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: count,
        separatorBuilder: (_, _) =>
            Divider(height: 1, color: AppColors.primaryLightTrack),
        itemBuilder: (_, _) => const NotificationTileSkeleton(),
      ),
    );
  }
}
