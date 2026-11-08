import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/haptics/app_haptics.dart';
import 'interaction/app_pressable.dart';
import 'loading_indicator/inline_loader.dart';

/// How long a button ignores taps after one, so a double tap cannot send the
/// same request twice before the bloc reports it as loading.
const Duration kButtonTapCooldown = Duration(milliseconds: 600);

/// Blocks repeated taps: taps are ignored while [isLoading] is true and for
/// [kButtonTapCooldown] after each accepted tap. Only an accepted tap plays
/// [haptic] (a disabled, loading or repeated tap stays silent).
mixin _TapGuard<T extends StatefulWidget> on State<T> {
  Timer? _cooldown;

  bool get _coolingDown => _cooldown?.isActive ?? false;

  VoidCallback? guarded(
    VoidCallback? action, {
    required bool isLoading,
    AppHapticType? haptic,
  }) {
    if (action == null || isLoading) return null;
    return () {
      if (_coolingDown) return;
      _cooldown = Timer(kButtonTapCooldown, () {});
      // Queued by AppHaptics: if the action reports an outcome at once
      // (success / error), only the outcome is felt.
      if (haptic != null) AppHaptics.play(haptic);
      action();
    };
  }

  @override
  void dispose() {
    _cooldown?.cancel();
    super.dispose();
  }
}

/// Primary action button: teal background, white text, shadow.
///
/// While [isLoading] is true the button keeps its size, color and label,
/// shows a small spinner before the label and ignores taps; repeated taps are
/// also ignored for a short moment after each tap. An enabled button shrinks
/// slightly while pressed ([AppPressScale]) and plays [haptic] when the tap
/// is accepted (default a light tap; null for none).
class CoursatyPrimaryButton extends StatefulWidget {
  const CoursatyPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.onLongPress,
    this.isLoading = false,
    this.margin,
    this.onTapDown,
    this.onTapUp,
    this.haptic = AppHapticType.lightTap,
  });

  final String label;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final void Function(TapDownDetails d)? onTapDown;
  final void Function(TapUpDetails u)? onTapUp;
  final bool isLoading;
  final EdgeInsets? margin;
  final AppHapticType? haptic;

  @override
  State<CoursatyPrimaryButton> createState() => _CoursatyPrimaryButtonState();
}

class _CoursatyPrimaryButtonState extends State<CoursatyPrimaryButton>
    with _TapGuard {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loading = widget.isLoading;
    final onPrimary = theme.colorScheme.onPrimary;
    final enabled = widget.onPressed != null && !loading;
    final button = Container(
      height: 50,
      decoration: BoxDecoration(
        color: widget.onPressed == null
            ? AppColors.greyNormal
            : theme.colorScheme.primary,
        border: Border.all(color: AppColors.secondaryActive),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppColors.buttonShadow],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: guarded(
            widget.onPressed,
            isLoading: loading,
            haptic: widget.haptic,
          ),
          onLongPress: loading ? null : widget.onLongPress,
          onTapUp: loading ? null : widget.onTapUp,
          onTapDown: loading ? null : widget.onTapDown,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: LoadingLabel(
                label: widget.label,
                isLoading: loading,
                style: theme.textTheme.labelLarge?.copyWith(color: onPrimary),
                color: onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
    return Semantics(
      button: true,
      enabled: enabled,
      child: Padding(
        padding: widget.margin ?? EdgeInsets.zero,
        child: AppPressScale(enabled: enabled, child: button),
      ),
    );
  }
}

/// Secondary action button: grey background, dark text. Same loading and
/// repeated-tap behavior as [CoursatyPrimaryButton].
class CoursatySecondaryButton extends StatefulWidget {
  const CoursatySecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.foregroundColor,
    this.isLoading = false,
    this.haptic = AppHapticType.lightTap,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? foregroundColor;
  final bool isLoading;
  final AppHapticType? haptic;

  @override
  State<CoursatySecondaryButton> createState() =>
      _CoursatySecondaryButtonState();
}

class _CoursatySecondaryButtonState extends State<CoursatySecondaryButton>
    with _TapGuard {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = widget.foregroundColor ?? AppColors.greyDark;
    final enabled = widget.onPressed != null && !widget.isLoading;
    final button = Container(
      height: 50,
      decoration: BoxDecoration(
        color: widget.color ?? AppColors.greyLight,
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
          onTap: guarded(
            widget.onPressed,
            isLoading: widget.isLoading,
            haptic: widget.haptic,
          ),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: LoadingLabel(
                label: widget.label,
                isLoading: widget.isLoading,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
                color: foreground,
              ),
            ),
          ),
        ),
      ),
    );
    return Semantics(
      button: true,
      enabled: enabled,
      child: AppPressScale(enabled: enabled, child: button),
    );
  }
}
