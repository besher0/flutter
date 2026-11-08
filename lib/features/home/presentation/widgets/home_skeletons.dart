import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/widgets/skeleton/skeleton.dart';
import '../../../courses/presentation/widgets/course_skeletons.dart';
import '../../../sales_points/presentation/widgets/sales_point_skeletons.dart';

/// Skeletons for the home feature. Sizes mirror `HomeContent`,
/// `BannerCarousel`, `TeacherAvatarName`, `SectionCard`, `SubjectCard` and the
/// teacher home metric cards.

/// Bones of one `SectionCard` (220 wide, image + title + chips).
class SectionCardSkeleton extends StatelessWidget {
  const SectionCardSkeleton({super.key, this.height = 200});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SkeletonCard(
      width: 220,
      height: height,
      padding: const EdgeInsets.all(10),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: SkeletonBox(borderRadius: BorderRadius.circular(12))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SkeletonText(fontSize: height > 100 ? 18 : 16, width: 130),
              const SizedBox(height: 10),
              Row(
                spacing: 10.w,
                children: const [
                  SkeletonChip(width: 66),
                  SkeletonChip(width: 80),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bones of one `TeacherAvatarName` (69 circle + name).
class TeacherAvatarSkeleton extends StatelessWidget {
  const TeacherAvatarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SkeletonAvatar(size: 69),
          SizedBox(height: 8),
          SkeletonText(fontSize: 14, width: 56),
        ],
      ),
    );
  }
}

/// Bones of one `SubjectCard` (110 high, 157×83 image, title and chips).
class SubjectCardSkeleton extends StatelessWidget {
  const SubjectCardSkeleton({super.key, this.chipCount = 2});

  final int chipCount;

  @override
  Widget build(BuildContext context) {
    return SkeletonCard(
      height: 110,
      padding: const EdgeInsets.only(right: 10),
      child: Row(
        children: [
          SkeletonBox(
            width: 157,
            height: 83,
            borderRadius: BorderRadius.circular(12),
          ),
          10.horizontalSpace,
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SkeletonText(fontSize: 16, width: 110),
                if (chipCount > 0) ...[
                  const SizedBox(height: 14),
                  // The real chips scroll horizontally; clip the same way.
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    child: Row(
                      spacing: 14,
                      children: [
                        for (var i = 0; i < chipCount; i++)
                          SkeletonChip(width: i.isEven ? 58 : 70),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// First load of a vertical list of `SubjectCard`s.
class SubjectListSkeleton extends StatelessWidget {
  const SubjectListSkeleton({
    super.key,
    this.count = 6,
    this.padding = const EdgeInsets.all(20),
    this.spacing = 15,
    this.chipCount = 2,
  });

  final int count;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final int chipCount;

  @override
  Widget build(BuildContext context) {
    return SkeletonList(
      count: count,
      padding: padding,
      spacing: spacing,
      itemBuilder: (_, _) => SubjectCardSkeleton(chipCount: chipCount),
    );
  }
}

/// Student home first load: banner, teachers row, subjects and programs rows.
class HomeContentSkeleton extends StatelessWidget {
  const HomeContentSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget horizontalCards() => SizedBox(
      height: 200,
      child: ListView.separated(
        primary: false,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(width: 20),
        itemBuilder: (_, _) => const SectionCardSkeleton(),
      ),
    );

    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            10.verticalSpace,
            // BannerCarousel: 16:8.5 page with 8 side padding, then dots.
            AspectRatio(
              aspectRatio: 16 / 8.5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SkeletonBox(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: [
                SkeletonAvatar(size: 7.5),
                SkeletonAvatar(size: 7.5),
                SkeletonAvatar(size: 7.5),
              ],
            ),
            const SizedBox(height: 12),
            const SectionHeaderSkeleton(titleWidth: 70),
            const SizedBox(height: 12),
            SizedBox(
              height: 130,
              child: ListView.separated(
                primary: false,
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, _) => const TeacherAvatarSkeleton(),
              ),
            ),
            const SectionHeaderSkeleton(titleWidth: 60),
            const SizedBox(height: 12),
            horizontalCards(),
            const SizedBox(height: 24),
            const SectionHeaderSkeleton(titleWidth: 70),
            const SizedBox(height: 12),
            horizontalCards(),
          ],
        ),
      ),
    );
  }
}

/// Points of sale row on the home page while it loads (one card, 140 high).
class HomeSalesPointsSkeleton extends StatelessWidget {
  const HomeSalesPointsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SectionHeaderSkeleton(titleWidth: 80),
          20.verticalSpace,
          SizedBox(
            height: 140,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: SalesPointCardSkeleton(width: 1.sw - 40),
            ),
          ),
        ],
      ),
    );
  }
}

/// Subjects page first load: year pills, season pills, a season divider and
/// subject cards.
class SubjectsScreenSkeleton extends StatelessWidget {
  const SubjectsScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    // The real pills are horizontal lists; clip the same way.
    Widget pills({required double height, required double radius}) => SizedBox(
      height: height,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          spacing: 10,
          children: [
            for (final w in const [92.0, 84.0, 96.0])
              SkeletonBox(
                width: w,
                height: height,
                borderRadius: BorderRadius.circular(radius),
              ),
          ],
        ),
      ),
    );

    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            pills(height: 42, radius: 14),
            const SizedBox(height: 22),
            pills(height: 38, radius: 12),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Expanded(child: SkeletonBox(height: 1)),
                      const SizedBox(width: 10),
                      SkeletonBox(
                        width: 80,
                        height: 29,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  for (var i = 0; i < 5; i++)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: SubjectCardSkeleton(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bones of a teacher home metric card (86 high, value + label, small icon).
class MetricCardSkeleton extends StatelessWidget {
  const MetricCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonCard(
      height: 86,
      shadow: false,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              const SkeletonText(
                fontSize: 20,
                lineHeight: kCairoNaturalLineHeight,
                width: 56,
              ),
              const Spacer(),
              SkeletonBox(
                width: 24,
                height: 24,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          ),
          const SkeletonText(
            fontSize: 14,
            lineHeight: kCairoNaturalLineHeight,
            width: 110,
          ),
        ],
      ),
    );
  }
}

/// Teacher home first load: month earnings card, 2×2 metric cards and the
/// pending courses row.
class TeacherHomeSkeleton extends StatelessWidget {
  const TeacherHomeSkeleton({super.key, this.showEarnings = true});

  /// False on an iPhone with paid content hidden (no earnings card).
  final bool showEarnings;

  @override
  Widget build(BuildContext context) {
    Widget metricsRow() => const Row(
      children: [
        Expanded(child: MetricCardSkeleton()),
        SizedBox(width: 10),
        Expanded(child: MetricCardSkeleton()),
      ],
    );
    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showEarnings) ...[
              SkeletonBox(height: 86, borderRadius: BorderRadius.circular(12)),
              const SizedBox(height: 12),
            ],
            metricsRow(),
            const SizedBox(height: 10),
            metricsRow(),
            const SizedBox(height: 14),
            const SectionHeaderSkeleton(titleWidth: 140),
            const SizedBox(height: 8),
            SizedBox(
              height: 200.h,
              child: ListView.separated(
                primary: false,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 15),
                scrollDirection: Axis.horizontal,
                itemCount: 2,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, _) => const CourseCardSkeleton(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bones of one subscription card (220 high: cover 83, title, chips, footer).
class SubscriptionCardSkeleton extends StatelessWidget {
  const SubscriptionCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonCard(
      height: 220,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(
            height: 83,
            width: double.infinity,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 12),
          SkeletonText(fontSize: 20, width: 0.5.sw),
          const SizedBox(height: 10),
          const Row(
            spacing: 10,
            children: [SkeletonChip(width: 70), SkeletonChip(width: 84)],
          ),
          const Spacer(),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonText(fontSize: 10, width: 90),
              SkeletonText(fontSize: 10, width: 60),
            ],
          ),
        ],
      ),
    );
  }
}

/// First load of the active / expired subscriptions lists.
class SubscriptionListSkeleton extends StatelessWidget {
  const SubscriptionListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonList(
      count: 3,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      spacing: 16,
      itemBuilder: (_, _) => const SubscriptionCardSkeleton(),
    );
  }
}

/// First load of the interests tab (cards with a 62 thumbnail and text).
class InterestListSkeleton extends StatelessWidget {
  const InterestListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonList(
      count: 4,
      padding: const EdgeInsets.all(16),
      spacing: 12,
      itemBuilder: (_, _) => SkeletonCard(
        radius: 16,
        shadow: false,
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(
              width: 62,
              height: 62,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonText(
                    fontSize: 16,
                    lineHeight: kCairoNaturalLineHeight,
                    width: 140,
                  ),
                  SizedBox(height: 6),
                  SkeletonText(
                    fontSize: 13,
                    lineHeight: kCairoNaturalLineHeight,
                    width: 100,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
