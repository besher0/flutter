import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Horizontal step progress bar: filled portion in primary, rest in light track.
class StepProgressIndicator extends StatelessWidget {
  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.height = 14,
  }) : assert(currentStep >= 0 && currentStep <= totalSteps),
       assert(totalSteps > 0);

  final int currentStep;
  final int totalSteps;
  final double height;

  @override
  Widget build(BuildContext context) {
    final progress = totalSteps > 0
        ? (currentStep / totalSteps).clamp(0.0, 1.0)
        : 0.0;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(33),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primaryLightTrack,
                  border: Border.all(
                    color: AppColors.primaryLightTrackBorder,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(33),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(33),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A SizedBox that takes a fraction of the parent's width.
class FractionallySizedBox extends StatelessWidget {
  const FractionallySizedBox({
    super.key,
    required this.widthFactor,
    required this.child,
  }) : assert(widthFactor >= 0 && widthFactor <= 1);

  final double widthFactor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth * widthFactor;
        return SizedBox(width: width, child: child);
      },
    );
  }
}
