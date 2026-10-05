import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Primary action button: teal background, white text, shadow.
class CoursatyPrimaryButton extends StatelessWidget {
  const CoursatyPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.onLongPress,
    this.isLoading = false,
    this.margin,
    this.onTapDown,
    this.onTapUp,
  });

  final String label;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final void Function(TapDownDetails d)? onTapDown;
  final void Function(TapUpDetails u)? onTapUp;
  final bool isLoading;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 50,
      margin: margin,
      decoration: BoxDecoration(
        color: onPressed == null
            ? AppColors.greyNormal
            : Theme.of(context).colorScheme.primary,
        border: Border.all(color: AppColors.secondaryActive),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppColors.buttonShadow],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          onLongPress: onLongPress,
          onTapUp: onTapUp,
          onTapDown: onTapDown,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Secondary action button: grey background, dark text.
class CoursatySecondaryButton extends StatelessWidget {
  const CoursatySecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: color ?? AppColors.greyLight,
        border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: foregroundColor ?? AppColors.greyDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
