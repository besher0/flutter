import 'package:flutter/material.dart';

import '../../core/platform/app_layout.dart';

/// A row of cards: a horizontal list on the phone (as before), and on a wide
/// desktop window a grid that wraps onto new lines, so every card is visible
/// without sideways scrolling.
class AdaptiveCardRow extends StatelessWidget {
  const AdaptiveCardRow({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.height,
    this.spacing = 12,
    this.padding = const EdgeInsets.symmetric(vertical: 15),
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  /// Height of the phone's list (cards fill it less the vertical padding).
  final double height;
  final double spacing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    if (AppLayout.isWide(context)) {
      return Padding(
        padding: padding,
        child: Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            // The same card height as inside the phone's list.
            for (var i = 0; i < itemCount; i++)
              SizedBox(
                height: height - padding.vertical,
                child: itemBuilder(context, i),
              ),
          ],
        ),
      );
    }
    return SizedBox(
      height: height,
      child: HorizontalMouseDrag(
        child: ListView.separated(
          padding: padding,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: itemCount,
          separatorBuilder: (_, _) => SizedBox(width: spacing),
          itemBuilder: itemBuilder,
        ),
      ),
    );
  }
}
