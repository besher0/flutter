import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../core/theme/app_colors.dart';

/// Colors of skeleton bones for the current theme.
@immutable
class SkeletonColors {
  const SkeletonColors({required this.base, required this.highlight});

  /// Bone color (and the static color when animations are off).
  final Color base;

  /// Color of the moving shimmer band.
  final Color highlight;

  static const SkeletonColors light = SkeletonColors(
    base: AppColors.primaryLightTrack,
    highlight: Color(0xFFF7FAFA),
  );

  static const SkeletonColors dark = SkeletonColors(
    base: AppColors.darkSurfaceVariant,
    highlight: AppColors.darkBorder,
  );

  static SkeletonColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

/// One shimmer animation for a whole skeleton layout.
///
/// Every [SkeletonBox] (and the shapes built on it) below this widget paints
/// itself with the same moving gradient, positioned in this widget's
/// coordinate space, so all bones shimmer as one surface while card chrome
/// (backgrounds, borders, shadows) around them stays untouched. Only the bones
/// repaint on each tick; nothing rebuilds.
///
/// The band moves in the reading direction (right to left in Arabic). When the
/// platform asks for reduced motion ([MediaQuery.disableAnimations]) the bones
/// are drawn static. The subtree is hidden from screen readers and replaced by
/// a single "loading" label, and it ignores touches.
class AppShimmer extends StatefulWidget {
  const AppShimmer({
    super.key,
    required this.child,
    this.semanticLabel = 'جاري التحميل',
    this.period = const Duration(milliseconds: 1500),
  });

  final Widget child;
  final String semanticLabel;
  final Duration period;

  /// Whether [context] is already under an [AppShimmer] (so a nested
  /// skeleton can join its animation instead of starting its own).
  static bool isActive(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_ShimmerScope>() != null;

  /// Wraps [child] in an [AppShimmer] unless one is already above [context].
  static Widget ensure(BuildContext context, Widget child) =>
      isActive(context) ? child : AppShimmer(child: child);

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.period,
  );
  final GlobalKey _areaKey = GlobalKey();
  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (_reduceMotion) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel,
      container: true,
      child: ExcludeSemantics(
        child: IgnorePointer(
          child: RepaintBoundary(
            key: _areaKey,
            child: _ShimmerScope(
              animation: _reduceMotion ? null : _controller,
              areaKey: _areaKey,
              colors: SkeletonColors.of(context),
              rtl: Directionality.of(context) == TextDirection.rtl,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class _ShimmerScope extends InheritedWidget {
  const _ShimmerScope({
    required this.animation,
    required this.areaKey,
    required this.colors,
    required this.rtl,
    required super.child,
  });

  final Animation<double>? animation;
  final GlobalKey areaKey;
  final SkeletonColors colors;
  final bool rtl;

  static _ShimmerScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ShimmerScope>();

  @override
  bool updateShouldNotify(_ShimmerScope old) =>
      animation != old.animation ||
      areaKey != old.areaKey ||
      colors != old.colors ||
      rtl != old.rtl;
}

/// The basic skeleton bone: a rounded rectangle (or circle) that shimmers with
/// the nearest [AppShimmer]. Outside an [AppShimmer] it is drawn static.
///
/// Without [width]/[height] it fills the constraints it is given (falling back
/// to the minimum on an unbounded axis).
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  /// A circle of [size] diameter.
  const SkeletonBox.circle({super.key, required double size})
    : width = size,
      height = size,
      borderRadius = null,
      shape = BoxShape.circle;

  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    final scope = _ShimmerScope.maybeOf(context);
    final direction = Directionality.maybeOf(context) ?? TextDirection.rtl;
    final bone = _SkeletonBone(
      animation: scope?.animation,
      areaKey: scope?.areaKey,
      colors: scope?.colors ?? SkeletonColors.of(context),
      rtl: scope?.rtl ?? direction == TextDirection.rtl,
      borderRadius: (borderRadius ?? BorderRadius.circular(6)).resolve(
        direction,
      ),
      shape: shape,
    );
    if (width == null && height == null) return bone;
    return SizedBox(width: width, height: height, child: bone);
  }
}

class _SkeletonBone extends LeafRenderObjectWidget {
  const _SkeletonBone({
    required this.animation,
    required this.areaKey,
    required this.colors,
    required this.rtl,
    required this.borderRadius,
    required this.shape,
  });

  final Animation<double>? animation;
  final GlobalKey? areaKey;
  final SkeletonColors colors;
  final bool rtl;
  final BorderRadius borderRadius;
  final BoxShape shape;

  @override
  RenderSkeletonBone createRenderObject(BuildContext context) =>
      RenderSkeletonBone(
        animation: animation,
        areaKey: areaKey,
        colors: colors,
        rtl: rtl,
        borderRadius: borderRadius,
        shape: shape,
      );

  @override
  void updateRenderObject(BuildContext context, RenderSkeletonBone r) {
    r
      ..animation = animation
      ..areaKey = areaKey
      ..colors = colors
      ..rtl = rtl
      ..borderRadius = borderRadius
      ..shape = shape;
  }
}

/// Paints one bone. Public only so tests can find it.
class RenderSkeletonBone extends RenderBox {
  RenderSkeletonBone({
    required Animation<double>? animation,
    required this.areaKey,
    required SkeletonColors colors,
    required bool rtl,
    required BorderRadius borderRadius,
    required BoxShape shape,
  }) : _animation = animation,
       _colors = colors,
       _rtl = rtl,
       _borderRadius = borderRadius,
       _shape = shape;

  Animation<double>? _animation;
  Animation<double>? get animation => _animation;
  set animation(Animation<double>? value) {
    if (value == _animation) return;
    if (attached) _animation?.removeListener(markNeedsPaint);
    _animation = value;
    if (attached) _animation?.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  GlobalKey? areaKey;

  SkeletonColors _colors;
  set colors(SkeletonColors value) {
    if (value == _colors) return;
    _colors = value;
    markNeedsPaint();
  }

  bool _rtl;
  set rtl(bool value) {
    if (value == _rtl) return;
    _rtl = value;
    markNeedsPaint();
  }

  BorderRadius _borderRadius;
  set borderRadius(BorderRadius value) {
    if (value == _borderRadius) return;
    _borderRadius = value;
    markNeedsPaint();
  }

  BoxShape _shape;
  set shape(BoxShape value) {
    if (value == _shape) return;
    _shape = value;
    markNeedsPaint();
  }

  /// Whether this bone is currently animated (false when motion is reduced).
  bool get isAnimated => _animation != null;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _animation?.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _animation?.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => Size(
    constraints.hasBoundedWidth ? constraints.maxWidth : constraints.minWidth,
    constraints.hasBoundedHeight
        ? constraints.maxHeight
        : constraints.minHeight,
  );

  @override
  bool hitTestSelf(Offset position) => false;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (size.isEmpty) return;
    final rect = offset & size;
    final paint = Paint()..color = _colors.base;
    final anim = _animation;
    if (anim != null) {
      // Position the band in the AppShimmer's coordinate space so every bone
      // shows the same band at the same moment.
      var areaLeft = offset.dx;
      var areaWidth = size.width;
      final area = areaKey?.currentContext?.findRenderObject();
      if (area is RenderBox && area.attached && area.hasSize) {
        final origin = localToGlobal(Offset.zero, ancestor: area);
        areaLeft = offset.dx - origin.dx;
        areaWidth = area.size.width;
      }
      final band = math.max(areaWidth * 0.5, 80.0);
      final t = _rtl ? 1 - anim.value : anim.value;
      final start = areaLeft - band + t * (areaWidth + band);
      paint.shader = ui.Gradient.linear(
        Offset(start, 0),
        Offset(start + band, 0),
        [_colors.base, _colors.highlight, _colors.base],
        const [0.0, 0.5, 1.0],
      );
    }
    final canvas = context.canvas;
    if (_shape == BoxShape.circle) {
      canvas.drawOval(rect, paint);
    } else {
      canvas.drawRRect(_borderRadius.toRRect(rect), paint);
    }
  }
}
