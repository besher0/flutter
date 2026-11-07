import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/widgets/skeleton/skeleton.dart';
import '../../../courses/presentation/widgets/course_skeletons.dart';

/// Skeletons for the teachers feature. Sizes mirror `TeacherCard` /
/// `TeachersGrid`, the teacher detail page, the revenue report and the
/// withdrawals list.

/// Bones of one `TeacherCard` (100 avatar, name, two small chips).
class TeacherCardSkeleton extends StatelessWidget {
  const TeacherCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          const SkeletonAvatar(size: 100),
          const SizedBox(height: 10),
          const SkeletonText(fontSize: 16, width: 90),
          const Spacer(flex: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SkeletonBox(
                width: 40,
                height: 22,
                borderRadius: BorderRadius.circular(11),
              ),
              const SizedBox(width: 14),
              SkeletonBox(
                width: 40,
                height: 22,
                borderRadius: BorderRadius.circular(11),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

/// First load of `TeachersGrid` (2 columns, same aspect ratio and spacing).
class TeachersGridSkeleton extends StatelessWidget {
  const TeachersGridSkeleton({super.key, this.paddingValue, this.count = 6});

  final double? paddingValue;
  final int count;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: GridView.builder(
        primary: false,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: paddingValue ?? 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: (173 / 225).r,
        ),
        itemCount: count,
        itemBuilder: (_, _) => const TeacherCardSkeleton(),
      ),
    );
  }
}

/// Teacher detail first load: profile row, about, section title, courses.
class TeacherDetailSkeleton extends StatelessWidget {
  const TeacherDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                SkeletonAvatar(size: 85),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonText(fontSize: 16, width: 120),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        SkeletonChip(width: 74),
                        SizedBox(width: 14),
                        SkeletonChip(width: 48),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            15.verticalSpace,
            const SkeletonBox(height: 1, width: double.infinity),
            15.verticalSpace,
            const SkeletonText(
              fontSize: 18,
              lineHeight: kCairoNaturalLineHeight,
              width: 90,
            ),
            const SizedBox(height: 8),
            const SkeletonText(fontSize: 14, lineHeight: 1.8, lines: 3),
            15.verticalSpace,
            const SkeletonBox(height: 1, width: double.infinity),
            15.verticalSpace,
            SkeletonText(fontSize: 20, width: 0.6.sw),
            15.verticalSpace,
            for (var i = 0; i < 2; i++)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: CourseCardSkeleton(height: 230),
              ),
          ],
        ),
      ),
    );
  }
}

/// Revenue report first load: hero card, balance card, 2×2 stats, a section.
class RevenueReportSkeleton extends StatelessWidget {
  const RevenueReportSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tileWidth = (constraints.maxWidth - 32 - 12) / 2;
          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SkeletonBox(
                  height: 164,
                  borderRadius: BorderRadius.circular(20),
                ),
                const SizedBox(height: 12),
                SkeletonCard(
                  radius: 18,
                  padding: const EdgeInsets.all(18),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonText(
                        fontSize: 16,
                        lineHeight: kCairoNaturalLineHeight,
                        width: 110,
                      ),
                      SizedBox(height: 10),
                      SkeletonText(
                        fontSize: 22,
                        lineHeight: kCairoNaturalLineHeight,
                        width: 150,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (var i = 0; i < 4; i++)
                      SkeletonCard(
                        width: tileWidth,
                        radius: 16,
                        shadow: false,
                        padding: const EdgeInsets.all(14),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SkeletonBox(width: 18, height: 18),
                                SizedBox(width: 6),
                                Expanded(
                                  child: SkeletonText(
                                    fontSize: 13,
                                    lineHeight: kCairoNaturalLineHeight,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            SkeletonText(
                              fontSize: 18,
                              lineHeight: kCairoNaturalLineHeight,
                              width: 80,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SkeletonCard(
                  radius: 18,
                  shadow: false,
                  padding: const EdgeInsets.all(16),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonText(
                        fontSize: 17,
                        lineHeight: kCairoNaturalLineHeight,
                        width: 120,
                      ),
                      SizedBox(height: 12),
                      SkeletonText(
                        fontSize: 14,
                        lineHeight: kCairoNaturalLineHeight,
                        lines: 4,
                        lastLineWidthFactor: 0.8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Bones of one withdrawal card (title, two info lines, details row).
class WithdrawalCardSkeleton extends StatelessWidget {
  const WithdrawalCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonCard(
      radius: 18,
      padding: const EdgeInsets.all(18),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonText(
            fontSize: 18,
            lineHeight: kCairoNaturalLineHeight,
            width: 130,
          ),
          SizedBox(height: 10),
          SkeletonText(
            fontSize: 14,
            lineHeight: kCairoNaturalLineHeight,
            width: 190,
          ),
          SizedBox(height: 10),
          SkeletonText(
            fontSize: 14,
            lineHeight: kCairoNaturalLineHeight,
            width: 160,
          ),
          SizedBox(height: 18),
          SkeletonText(
            fontSize: 16,
            lineHeight: kCairoNaturalLineHeight,
            width: 100,
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SkeletonText(
                  fontSize: 14,
                  lineHeight: kCairoNaturalLineHeight,
                  lines: 2,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: SkeletonText(
                  fontSize: 14,
                  lineHeight: kCairoNaturalLineHeight,
                  lines: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Affiliations first load (cards with a title and three info lines).
class AffiliationListSkeleton extends StatelessWidget {
  const AffiliationListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonList(
      count: 4,
      padding: const EdgeInsets.all(16),
      spacing: 14,
      itemBuilder: (_, _) => SkeletonCard(
        radius: 18,
        padding: const EdgeInsets.all(18),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonText(
              fontSize: 18,
              lineHeight: kCairoNaturalLineHeight,
              width: 140,
            ),
            SizedBox(height: 10),
            SkeletonText(
              fontSize: 14,
              lineHeight: kCairoNaturalLineHeight,
              width: 200,
            ),
            SizedBox(height: 10),
            SkeletonText(
              fontSize: 14,
              lineHeight: kCairoNaturalLineHeight,
              width: 170,
            ),
            SizedBox(height: 10),
            SkeletonText(
              fontSize: 14,
              lineHeight: kCairoNaturalLineHeight,
              width: 150,
            ),
          ],
        ),
      ),
    );
  }
}

/// Withdrawals first load: summary card then withdrawal cards.
class WithdrawalsSkeleton extends StatelessWidget {
  const WithdrawalsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonList(
      count: 4,
      padding: const EdgeInsets.all(16),
      spacing: 14,
      itemBuilder: (_, i) => i == 0
          ? Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: SkeletonBox(
                height: 168,
                width: double.infinity,
                borderRadius: BorderRadius.circular(18),
              ),
            )
          : const WithdrawalCardSkeleton(),
    );
  }
}
