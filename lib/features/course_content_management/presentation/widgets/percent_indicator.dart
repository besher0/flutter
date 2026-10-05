import 'package:flutter/material.dart';
import '../../../../core/utils/extensions/build_context.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  const ProgressIndicatorWidget({
    super.key,
    required this.percent,
    required this.textColor,
    this.backGroundColor,
  });

  final double percent;
  final Color textColor;
  final Color? backGroundColor;

  @override
  Widget build(BuildContext context) {
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
          '${percent.toStringAsFixed(0)}%',
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
