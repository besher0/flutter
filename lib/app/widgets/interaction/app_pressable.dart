import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../services/haptics/app_haptics.dart';

/// Press scales used across the app (made deeper on 2026-11-08: the first
/// values, 0.97 / 0.95 / 0.98, were hardly visible on a phone).
abstract final class PressScale {
  /// Full-width buttons.
  static const double button = 0.94;

  /// Small icon buttons and pills.
  static const double icon = 0.90;

  /// Selectable cards, answers and list rows.
  static const double card = 0.96;
}

/// Shrinks [child] slightly while a finger is on it and springs it back on
/// release.
///
/// It only *listens* to pointers (a [Listener]): it never joins the gesture
/// arena, so the wrapped control keeps its own tap handling, semantics, focus
/// and keyboard behavior, and its action still runs exactly once from its own
/// `onTap` (never on a cancelled touch). The scale is released on pointer
/// up / cancel and as soon as the finger moves like a scroll.
///
/// Disabled ([enabled] false) or with reduced motion
/// ([MediaQuery.disableAnimations]) it does nothing.
class AppPressScale extends StatefulWidget {
  const AppPressScale({
    super.key,
    required this.child,
    this.enabled = true,
    this.scale = PressScale.button,
  });

  final Widget child;
  final bool enabled;
  final double scale;

  static const Duration pressDuration = Duration(milliseconds: 100);
  static const Duration releaseDuration = Duration(milliseconds: 160);

  @override
  State<AppPressScale> createState() => _AppPressScaleState();
}

class _AppPressScaleState extends State<AppPressScale> {
  int? _pointer;
  Offset? _downAt;
  bool _pressed = false;

  void _set(bool pressed) {
    if (_pressed == pressed || !mounted) return;
    setState(() => _pressed = pressed);
  }

  void _release() {
    _pointer = null;
    _downAt = null;
    _set(false);
  }

  @override
  void didUpdateWidget(AppPressScale oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Became disabled or loading while pressed (e.g. the tap started a
    // request): spring back.
    if (!widget.enabled && _pressed) _release();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion) return widget.child;
    return Listener(
      behavior: HitTestBehavior.deferToChild,
      onPointerDown: (event) {
        if (!widget.enabled || _pointer != null) return;
        if (event.kind == PointerDeviceKind.mouse &&
            event.buttons != kPrimaryMouseButton) {
          return;
        }
        _pointer = event.pointer;
        _downAt = event.position;
        _set(true);
      },
      onPointerMove: (event) {
        if (event.pointer != _pointer || _downAt == null) return;
        if ((event.position - _downAt!).distance > kTouchSlop) _release();
      },
      onPointerUp: (event) {
        if (event.pointer == _pointer) _release();
      },
      onPointerCancel: (event) {
        if (event.pointer == _pointer) _release();
      },
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1,
        duration: _pressed
            ? AppPressScale.pressDuration
            : AppPressScale.releaseDuration,
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

/// A custom tappable (card, pill, chip, row) with the app's press scale and
/// haptic: an [InkWell] (ripple optional) so semantics, focus and keyboard
/// activation keep working, wrapped in [AppPressScale].
///
/// [haptic] plays when the tap is accepted (not on touch down, so cancelled
/// touches stay silent); pass null when the action reports its own outcome.
class AppPressable extends StatelessWidget {
  const AppPressable({
    super.key,
    required this.child,
    required this.onTap,
    this.haptic = AppHapticType.lightTap,
    this.scale = PressScale.card,
    this.borderRadius,
    this.showRipple = true,
    this.semanticLabel,
    this.selected,
    this.toggled,
  });

  final Widget child;
  final VoidCallback? onTap;
  final AppHapticType? haptic;
  final double scale;
  final BorderRadius? borderRadius;
  final bool showRipple;
  final String? semanticLabel;
  final bool? selected;
  final bool? toggled;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Semantics(
      label: semanticLabel,
      selected: selected,
      toggled: toggled,
      button: true,
      child: AppPressScale(
        enabled: enabled,
        scale: scale,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: !enabled
                ? null
                : () {
                    final type = haptic;
                    if (type != null) AppHaptics.play(type);
                    onTap!();
                  },
            borderRadius: borderRadius,
            splashFactory: showRipple ? null : NoSplash.splashFactory,
            highlightColor: showRipple ? null : Colors.transparent,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// For `TabBar.onTap`: a selection haptic when the tap changes the tab (not
/// when the current tab is tapped again, nor for swipes, which do not call
/// `onTap`). [controller] defaults to the surrounding [DefaultTabController].
void tabTapHaptic(BuildContext context, {TabController? controller}) {
  final tabs = controller ?? DefaultTabController.maybeOf(context);
  // TabBar calls onTap right after animateTo: a real change is animating.
  if (tabs == null || tabs.indexIsChanging) AppHaptics.selection();
}
