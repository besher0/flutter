import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'app_shimmer.dart';

/// Natural line height of Cairo (ascent + descent) when a `TextStyle` sets no
/// `height`. Use it for text whose real style has no explicit height.
const double kCairoNaturalLineHeight = 1.875;

/// Placeholder for one or more lines of text.
///
/// Each line takes exactly the height the real text line takes
/// (`fontSize * lineHeight`), with a rounded bar centered in it, so swapping
/// the skeleton for the real text does not move anything below it.
class SkeletonText extends StatelessWidget {
  const SkeletonText({
    super.key,
    required this.fontSize,
    this.width,
    this.lineHeight = 1.4,
    this.lines = 1,
    this.lastLineWidthFactor = 0.6,
  });

  final double fontSize;

  /// Width of the bar (or of the full lines). Null fills the available width.
  final double? width;

  /// The real text's `TextStyle.height`.
  final double lineHeight;
  final int lines;

  /// Width of the last line relative to the others when [lines] > 1.
  final double lastLineWidthFactor;

  @override
  Widget build(BuildContext context) {
    final barHeight = fontSize * 0.72;
    final radius = BorderRadius.circular(barHeight / 2.5);
    Widget line(double factor) => SizedBox(
      height: fontSize * lineHeight,
      width: width,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: FractionallySizedBox(
          widthFactor: factor,
          child: SkeletonBox(height: barHeight, borderRadius: radius),
        ),
      ),
    );
    if (lines <= 1) return line(1);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < lines; i++)
          line(i == lines - 1 ? lastLineWidthFactor : 1),
      ],
    );
  }
}

/// Circular placeholder for an avatar or round icon.
class SkeletonAvatar extends StatelessWidget {
  const SkeletonAvatar({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => SkeletonBox.circle(size: size);
}

/// Placeholder with the exact box of `ChipWidget` (padding 8, text 10 × 1.4,
/// radius 11).
class SkeletonChip extends StatelessWidget {
  const SkeletonChip({super.key, this.width = 72});

  static const double height = 30;

  final double width;

  @override
  Widget build(BuildContext context) => SkeletonBox(
    width: width,
    height: height,
    borderRadius: BorderRadius.circular(11),
  );
}

/// The card chrome the app's cards use (surface, light border, card shadow),
/// for skeletons of those cards. The bones go in [child].
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.radius = 12,
    this.shadow = true,
  });

  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: dark ? AppColors.darkBorder : AppColors.primaryLightTrack,
          width: 0.85,
        ),
        boxShadow: shadow ? const [AppColors.cardShadow] : null,
      ),
      child: child,
    );
  }
}

/// An image-shaped shimmer placeholder of a fixed size, for
/// `CachedNetworkImage.placeholder` and other image slots. Keep the real
/// image's width, height and radius so the layout does not jump.
class ImageSkeleton extends StatelessWidget {
  const ImageSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) => AppShimmer.ensure(
    context,
    SkeletonBox(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      borderRadius: borderRadius ?? BorderRadius.zero,
      shape: shape,
    ),
  );
}

/// Placeholder with the box of a labelled `CoursatyTextField` /
/// `CoursatyDropdown` (label 16 × 1.4, 10 gap, 48 high field, radius 8), for
/// a field whose options are still loading.
class FormFieldSkeleton extends StatelessWidget {
  const FormFieldSkeleton({
    super.key,
    this.showLabel = true,
    this.labelWidth = 90,
    this.fieldHeight = 48,
  });

  final bool showLabel;
  final double labelWidth;
  final double fieldHeight;

  @override
  Widget build(BuildContext context) => AppShimmer.ensure(
    context,
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel) ...[
          SkeletonText(fontSize: 16, width: labelWidth),
          const SizedBox(height: 10),
        ],
        SkeletonBox(
          height: fieldHeight,
          width: double.infinity,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    ),
  );
}

/// A non-scrollable, clipped list of [count] skeleton items, all shimmering
/// together. Use it as the whole body while a list loads for the first time.
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    required this.itemBuilder,
    this.count = 6,
    this.padding,
    this.spacing = 0,
    this.scrollDirection = Axis.vertical,
  });

  final IndexedWidgetBuilder itemBuilder;
  final int count;
  final EdgeInsetsGeometry? padding;
  final double spacing;
  final Axis scrollDirection;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        primary: false,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: scrollDirection,
        padding: padding,
        itemCount: count,
        separatorBuilder: (_, _) => scrollDirection == Axis.vertical
            ? SizedBox(height: spacing)
            : SizedBox(width: spacing),
        itemBuilder: itemBuilder,
      ),
    );
  }
}
