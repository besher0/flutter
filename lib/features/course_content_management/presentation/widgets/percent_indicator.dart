import 'package:flutter/material.dart';
import '../../../../core/utils/extensions/build_context.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  const ProgressIndicatorWidget({
    super.key,
    required this.percent,
    required this.textColor,
    this.backGroundColor,
    this.fractionDigits = 0,
  });

  /// null while the real progress is not known yet (e.g. resuming): shows a
  /// spinning indicator instead of a misleading 0%.
  final double? percent;

  /// Digits after the decimal point in the label (1 for uploads: "37.4%").
  final int fractionDigits;
  final Color textColor;
  final Color? backGroundColor;

  @override
  Widget build(BuildContext context) {
    final percent = this.percent;
    if (percent == null || percent < 0) {
      return CircularProgressIndicator(
        backgroundColor: backGroundColor ?? Colors.grey.shade300,
        valueColor: AlwaysStoppedAnimation<Color>(context.colorScheme.primary),
      );
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        CircularProgressIndicator(
          value: percent / 100,
          backgroundColor: backGroundColor ?? Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(
            context.colorScheme.primary,
          ),
        ),
        Text(
          '${percent.clamp(0, 100).toStringAsFixed(fractionDigits)}%',
          style: TextStyle(
            fontSize: 12,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
