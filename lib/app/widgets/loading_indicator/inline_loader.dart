import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Small spinner for inline use (inside buttons, next to a label, at the end
/// of a list). Not for whole screens: those use a skeleton.
class InlineLoader extends StatelessWidget {
  const InlineLoader({super.key, this.size, this.color, this.strokeWidth = 2});

  final double? size;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final s = size ?? 18.r;
    return SizedBox(
      width: s,
      height: s,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

/// A button label that keeps its text and shows a small [InlineLoader] before
/// it while [isLoading] is true. Use as the child of any button whose
/// action runs asynchronously, together with disabling the button.
class LoadingLabel extends StatelessWidget {
  const LoadingLabel({
    super.key,
    required this.label,
    required this.isLoading,
    this.style,
    this.color,
    this.loaderSize,
  });

  final String label;
  final bool isLoading;
  final TextStyle? style;

  /// Loader color; defaults to the text color.
  final Color? color;
  final double? loaderSize;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      style: style,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    if (!isLoading) return text;
    final effectiveColor =
        color ?? style?.color ?? DefaultTextStyle.of(context).style.color;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InlineLoader(size: loaderSize ?? 16.r, color: effectiveColor),
        SizedBox(width: 8.w),
        Flexible(child: text),
      ],
    );
  }
}

/// Compact loader shown below the loaded items of a paginated list while the
/// next page loads. Keeps a fixed height so the list does not jump.
class ListEndLoader extends StatelessWidget {
  const ListEndLoader({super.key, this.height});

  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 48.h,
      child: const Center(child: InlineLoader()),
    );
  }
}

/// Keeps [child] on screen while background work (a save, a delete) runs:
/// a thin progress bar on top and no touches until [busy] is false.
class BusyOverlay extends StatelessWidget {
  const BusyOverlay({super.key, required this.busy, required this.child});

  final bool busy;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: busy,
      child: Stack(
        children: [
          child,
          if (busy)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(minHeight: 2),
            ),
        ],
      ),
    );
  }
}
