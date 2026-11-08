import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/widgets/skeleton/skeleton.dart';

/// Bones of one `PointOfSaleCard` (image 157 wide, name, two chips).
class SalesPointCardSkeleton extends StatelessWidget {
  const SalesPointCardSkeleton({super.key, this.width});

  final double? width;

  @override
  Widget build(BuildContext context) {
    return SkeletonCard(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Row(
        children: [
          SkeletonBox(
            width: 157,
            height: 83,
            borderRadius: BorderRadius.circular(12),
          ),
          10.horizontalSpace,
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SkeletonText(fontSize: 16, width: 100),
                SizedBox(height: 14),
                SkeletonChip(width: 90),
                SizedBox(height: 10),
                SkeletonChip(width: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
