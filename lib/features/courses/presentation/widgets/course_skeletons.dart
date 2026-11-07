import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/widgets/skeleton/skeleton.dart';

/// Skeletons for the courses feature. Sizes mirror the real widgets
/// (`CourseCard`, `LectureItem`, `ContentItem`, `ImageHeader`, the course and
/// lecture details pages) so the switch to content does not move anything.

/// Bones of one `CourseCard` (no shimmer of its own: put it under an
/// [AppShimmer]). [height] must be bounded, as for the real card's image.
class CourseCardSkeleton extends StatelessWidget {
  const CourseCardSkeleton({super.key, this.height, this.chipCount = 3});

  final double? height;
  final int chipCount;

  @override
  Widget build(BuildContext context) {
    return SkeletonCard(
      width: 0.8.sw,
      height: height,
      radius: 10,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SkeletonBox(
              width: double.infinity,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 10),
          SkeletonText(fontSize: 20, width: 0.5.sw),
          const SizedBox(height: 10),
          // The real chips scroll horizontally; clip the same way.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              spacing: 10,
              children: [
                for (var i = 0; i < chipCount; i++)
                  SkeletonChip(width: i.isEven ? 64 : 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// First load of a vertical list of `CourseCard(height: 230)`.
class CourseListSkeleton extends StatelessWidget {
  const CourseListSkeleton({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    this.spacing = 32,
    this.count = 4,
  });

  final EdgeInsetsGeometry padding;
  final double spacing;
  final int count;

  @override
  Widget build(BuildContext context) {
    return SkeletonList(
      count: count,
      padding: padding,
      spacing: spacing,
      itemBuilder: (_, _) => const Align(
        alignment: AlignmentDirectional.centerStart,
        child: CourseCardSkeleton(height: 230),
      ),
    );
  }
}

/// Bones of a section header row ("title ........ المزيد").
class SectionHeaderSkeleton extends StatelessWidget {
  const SectionHeaderSkeleton({super.key, this.titleWidth = 90});

  final double titleWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SkeletonText(fontSize: 18, width: titleWidth),
        const SkeletonText(fontSize: 14, width: 40),
      ],
    );
  }
}

/// First load of a courses-by-year page: year sections, each a header and a
/// horizontal row of course cards ([rowHeight] high including 15 vertical
/// padding, cards [cardHeight] high or filling the row).
class CoursesByYearSectionsSkeleton extends StatelessWidget {
  const CoursesByYearSectionsSkeleton({
    super.key,
    this.sections = 2,
    this.rowHeight = 230,
    this.cardHeight,
  });

  final int sections;
  final double rowHeight;
  final double? cardHeight;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var s = 0; s < sections; s++)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SectionHeaderSkeleton(),
                  SizedBox(
                    height: rowHeight,
                    child: ListView.separated(
                      primary: false,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      scrollDirection: Axis.horizontal,
                      itemCount: 2,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (_, _) =>
                          CourseCardSkeleton(height: cardHeight),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Bones of `ImageHeader` (180 high image, 16 side padding).
class ImageHeaderSkeleton extends StatelessWidget {
  const ImageHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SkeletonBox(
        height: 180,
        width: double.infinity,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

/// Course details header while loading: image, then title and price row.
class CourseDetailsHeaderSkeleton extends StatelessWidget {
  const CourseDetailsHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ImageHeaderSkeleton(),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonText(
                  fontSize: 20,
                  lineHeight: kCairoNaturalLineHeight,
                  width: 0.45.sw,
                ),
                const SkeletonText(
                  fontSize: 16,
                  lineHeight: kCairoNaturalLineHeight,
                  width: 70,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Course details "تفاصيل" tab while loading: teacher row, chips, about text.
class CourseDetailsTabSkeleton extends StatelessWidget {
  const CourseDetailsTabSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonAvatar(size: 40.r),
                10.horizontalSpace,
                const SkeletonText(
                  fontSize: 16,
                  lineHeight: kCairoNaturalLineHeight,
                  width: 120,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.transparent),
            const SizedBox(height: 12),
            const Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SkeletonChip(width: 70),
                SkeletonChip(width: 86),
                SkeletonChip(width: 64),
                SkeletonChip(width: 78),
                SkeletonChip(width: 92),
                SkeletonChip(width: 60),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.transparent),
            const SizedBox(height: 12),
            const SkeletonText(
              fontSize: 20,
              lineHeight: kCairoNaturalLineHeight,
              width: 90,
            ),
            const SizedBox(height: 8),
            const SkeletonText(fontSize: 14, lineHeight: 1.8, lines: 4),
          ],
        ),
      ),
    );
  }
}

/// Bones of one `LectureItem` (numbered strip + title), filling its slot.
class LectureItemSkeleton extends StatelessWidget {
  const LectureItemSkeleton({super.key, this.height});

  final double? height;

  @override
  Widget build(BuildContext context) {
    return SkeletonCard(
      height: height,
      shadow: false,
      child: Row(
        children: [
          SkeletonBox(
            width: 24.w + 10,
            height: double.infinity,
            borderRadius: const BorderRadiusDirectional.only(
              topStart: Radius.circular(12),
              bottomStart: Radius.circular(12),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: 0.6,
              child: const SkeletonText(
                fontSize: 16,
                lineHeight: kCairoNaturalLineHeight,
              ),
            ),
          ),
          10.horizontalSpace,
        ],
      ),
    );
  }
}

/// First load of a lecture list laid out like the course pages' lectures tab
/// (one-column grid with the same aspect ratio and spacing).
class LectureListSkeleton extends StatelessWidget {
  const LectureListSkeleton({
    super.key,
    required this.childAspectRatio,
    this.count = 6,
    this.padding = const EdgeInsets.all(16),
  });

  final double childAspectRatio;
  final int count;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: GridView.count(
        primary: false,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 1,
        childAspectRatio: childAspectRatio,
        mainAxisSpacing: 15.h,
        padding: padding,
        children: List.generate(count, (_) => const LectureItemSkeleton()),
      ),
    );
  }
}

/// Bones of one `ContentItem` (file / video / question row, min 80 high).
class ContentItemSkeleton extends StatelessWidget {
  const ContentItemSkeleton({super.key, this.showAction = true});

  final bool showAction;

  @override
  Widget build(BuildContext context) {
    return SkeletonCard(
      height: 80,
      shadow: false,
      child: Row(
        children: [
          SkeletonBox(
            width: 24.w + 10,
            height: double.infinity,
            borderRadius: const BorderRadiusDirectional.only(
              topStart: Radius.circular(12),
              bottomStart: Radius.circular(12),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: 0.7,
              child: const SkeletonText(
                fontSize: 16,
                lineHeight: kCairoNaturalLineHeight,
              ),
            ),
          ),
          if (showAction)
            Padding(
              padding: EdgeInsets.only(left: 10.w, right: 6.w),
              child: const SkeletonBox(width: 25, height: 25),
            ),
        ],
      ),
    );
  }
}

/// First load of a list of `ContentItem`s (padding 16, gap 10).
class ContentListSkeleton extends StatelessWidget {
  const ContentListSkeleton({
    super.key,
    this.count = 5,
    this.padding = const EdgeInsets.all(16),
  });

  final int count;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SkeletonList(
      count: count,
      padding: padding,
      spacing: 10,
      itemBuilder: (_, _) => const ContentItemSkeleton(),
    );
  }
}

/// Lecture details header while loading: image, lecture title, about text.
class LectureDetailsHeaderSkeleton extends StatelessWidget {
  const LectureDetailsHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ImageHeaderSkeleton(),
          15.verticalSpace,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonText(
                  fontSize: 20,
                  lineHeight: kCairoNaturalLineHeight,
                  width: 0.55.sw,
                ),
                15.verticalSpace,
                const SkeletonText(
                  fontSize: 18,
                  lineHeight: kCairoNaturalLineHeight,
                  width: 100,
                ),
                const SizedBox(height: 8),
                const SkeletonText(fontSize: 14, lineHeight: 1.8, lines: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The lecture page's MCQ tab while loading: quiz icon, count line, buttons.
class McqTabSkeleton extends StatelessWidget {
  const McqTabSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SkeletonBox(width: 100, height: 100),
            15.verticalSpace,
            const SkeletonText(
              fontSize: 16,
              lineHeight: kCairoNaturalLineHeight,
              width: 140,
            ),
            15.verticalSpace,
            SkeletonBox(
              height: 50,
              width: double.infinity,
              borderRadius: BorderRadius.circular(12),
            ),
            15.verticalSpace,
            SkeletonBox(
              height: 50,
              width: double.infinity,
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
      ),
    );
  }
}

/// Teacher course "تفاصيل" tab (the course form) while the course loads.
class CourseFormSkeleton extends StatelessWidget {
  const CourseFormSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        primary: false,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          const FormFieldSkeleton(labelWidth: 70),
          const SizedBox(height: 15),
          SkeletonBox(height: 120, width: 1.sw),
          const FormFieldSkeleton(labelWidth: 80),
          10.verticalSpace,
          const FormFieldSkeleton(labelWidth: 70, fieldHeight: 110),
          10.verticalSpace,
          const FormFieldSkeleton(labelWidth: 80),
          10.verticalSpace,
          const FormFieldSkeleton(labelWidth: 140),
        ],
      ),
    );
  }
}

/// Teacher lectures tab (full-width 100-high lecture tiles, gap 10).
class TeacherLectureListSkeleton extends StatelessWidget {
  const TeacherLectureListSkeleton({super.key, this.count = 5});

  final int count;

  @override
  Widget build(BuildContext context) {
    return SkeletonList(
      count: count,
      padding: const EdgeInsets.all(16),
      spacing: 10,
      itemBuilder: (_, _) => const LectureItemSkeleton(height: 100),
    );
  }
}
