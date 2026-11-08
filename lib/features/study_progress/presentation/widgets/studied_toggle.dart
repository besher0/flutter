import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/study_progress_store.dart';
import '../../../../app/widgets/interaction/app_pressable.dart';
import '../../../../services/haptics/app_haptics.dart';

/// [StudiedToggle] for [videoId], read from and saved to the local
/// [StudyProgressStore].
class VideoStudiedToggle extends StatelessWidget {
  const VideoStudiedToggle({super.key, required this.videoId, this.size = 30});

  final String videoId;
  final double size;

  @override
  Widget build(BuildContext context) {
    final store = StudyProgressStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => StudiedToggle(
        size: size,
        studied: store.isVideoStudied(videoId),
        onChanged: (studied) {
          final before = store.isVideoStudied(videoId);
          store.setVideoStudied(videoId, studied);
          final after = store.isVideoStudied(videoId);
          // Feedback for the confirmed change only (not for a no-op, and
          // never while the page builds or restores the saved marks):
          // marked → success, unmarked → error.
          if (after == before) return;
          after ? AppHaptics.success() : AppHaptics.error();
        },
      ),
    );
  }
}

/// The lecture's «مدروسة» badge, from the local [StudyProgressStore].
class LectureStudiedBadge extends StatelessWidget {
  const LectureStudiedBadge({super.key, required this.lectureId});

  final String lectureId;

  @override
  Widget build(BuildContext context) {
    final store = StudyProgressStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) =>
          StudiedLectureBadge(studied: store.isLectureStudied(lectureId)),
    );
  }
}

/// Under a lecture's title: «مدروسة» once every video is studied, otherwise
/// how many of all its videos (downloaded or not) are.
class LectureStudyProgress extends StatelessWidget {
  const LectureStudyProgress({super.key, required this.lectureId});

  final String lectureId;

  @override
  Widget build(BuildContext context) {
    final store = StudyProgressStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final total = store.totalVideoCountOf(lectureId);
        if (total == 0) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 6),
          child: store.isLectureStudied(lectureId)
              ? const StudiedLectureBadge(studied: true)
              : Text(
                  'درست ${store.studiedVideoCountOf(lectureId)} من $total فيديو',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.greyNormal,
                  ),
                ),
        );
      },
    );
  }
}

/// "Studied" mark for a video: a wavy-edged seal.
///
/// Not studied, it is a dashed outline with a faint check. Marking it makes
/// the seal pop in with a spring and a small turn, fill with amber, draw a
/// white check, and throw off a ring of sparkles. Clearing it shrinks the
/// seal back quickly, without sparkles.
class StudiedToggle extends StatefulWidget {
  const StudiedToggle({
    super.key,
    required this.studied,
    required this.onChanged,
    this.size = 30,
  });

  final bool studied;
  final ValueChanged<bool> onChanged;
  final double size;

  @override
  State<StudiedToggle> createState() => _StudiedToggleState();
}

class _StudiedToggleState extends State<StudiedToggle>
    with SingleTickerProviderStateMixin {
  static const _markDuration = Duration(milliseconds: 750);
  static const _clearDuration = Duration(milliseconds: 260);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _markDuration,
    reverseDuration: _clearDuration,
    value: widget.studied ? 1 : 0,
  );

  /// Sparkles only follow a mark the student just made, not a page that
  /// opens already studied or a mark being cleared.
  bool _burst = false;

  @override
  void didUpdateWidget(StudiedToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.studied == widget.studied) return;
    if (widget.studied) {
      _burst = true;
      _controller.forward(from: 0);
    } else {
      _burst = false;
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // The haptic comes from the owner once the change is confirmed
  // (VideoStudiedToggle: success when marked, error when cleared).
  void _toggle() => widget.onChanged(!widget.studied);

  @override
  Widget build(BuildContext context) {
    final label = widget.studied ? 'مدروس، اضغط لإلغاء العلامة' : 'وضع كمدروس';
    // Room for the sparkles around the seal.
    final box = widget.size * 1.7;
    return Semantics(
      button: true,
      toggled: widget.studied,
      label: label,
      child: Tooltip(
        message: label,
        child: AppPressScale(
          scale: PressScale.icon,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggle,
            child: SizedBox.square(
              dimension: box,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  painter: StudiedSealPainter(
                    progress: _controller.value,
                    marking: _controller.status != AnimationStatus.reverse,
                    burst: _burst,
                    sealSize: widget.size,
                    idleColor: AppColors.greyNormal,
                    fillColor: AppColors.secondary,
                    sparkleColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The lecture's "studied" badge: the filled seal with a label. It pops in
/// when the lecture's last video is marked.
class StudiedLectureBadge extends StatelessWidget {
  const StudiedLectureBadge({super.key, required this.studied, this.size = 20});

  final bool studied;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      switchInCurve: Curves.elasticOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) =>
          ScaleTransition(scale: animation, child: child),
      child: !studied
          ? const SizedBox.shrink(key: ValueKey('not-studied'))
          : Container(
              key: const ValueKey('studied'),
              padding: const EdgeInsetsDirectional.fromSTEB(4, 2, 10, 2),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox.square(
                    dimension: size,
                    child: CustomPaint(
                      painter: StudiedSealPainter(
                        progress: 1,
                        marking: true,
                        burst: false,
                        sealSize: size,
                        idleColor: AppColors.greyNormal,
                        fillColor: AppColors.secondary,
                        sparkleColor: AppColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'مدروسة',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Paints the seal at [progress] (0 = not studied, 1 = studied), centred in
/// the canvas, with an optional sparkle burst while [marking].
class StudiedSealPainter extends CustomPainter {
  StudiedSealPainter({
    required this.progress,
    required this.marking,
    required this.burst,
    required this.sealSize,
    required this.idleColor,
    required this.fillColor,
    required this.sparkleColor,
  });

  final double progress;
  final bool marking;
  final bool burst;
  final double sealSize;
  final Color idleColor;
  final Color fillColor;
  final Color sparkleColor;

  static const int _waves = 10;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = sealSize / 2;
    final t = progress.clamp(0.0, 1.0);

    // Marking: spring scale and a quarter-turn settle. Clearing: plain shrink
    // of the fill back to the outline.
    final fill = marking ? _interval(t, 0, 0.45, Curves.easeOut) : t;
    final check = marking ? _interval(t, 0.35, 0.85, Curves.easeInOut) : t;
    final scale = marking && t < 1
        ? 0.75 + 0.25 * Curves.elasticOut.transform(_interval(t, 0, 0.9, null))
        : 1.0;
    final turn = marking && t < 1
        ? (1 - _interval(t, 0, 0.7, Curves.easeOut)) * -0.5
        : 0.0;

    if (burst && marking && t > 0.15 && t < 1)
      _paintSparkles(canvas, center, radius, t);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(turn);
    canvas.scale(scale);

    final seal = _sealPath(radius);

    // Idle outline: dashed, fading out as the seal fills.
    if (fill < 1) {
      final outline = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.4, radius * 0.11)
        ..strokeCap = StrokeCap.round
        ..color = idleColor.withValues(alpha: 0.9 * (1 - fill));
      _drawDashed(canvas, seal, outline, radius * 0.32, radius * 0.22);
    }

    if (fill > 0) {
      canvas.drawShadow(
        seal,
        fillColor.withValues(alpha: 0.6 * fill),
        2.5 * fill,
        false,
      );
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            Color.lerp(fillColor, Colors.white, 0.25)!.withValues(alpha: fill),
            fillColor.withValues(alpha: fill),
          ],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius));
      canvas.save();
      canvas.scale(0.55 + 0.45 * fill);
      canvas.drawPath(seal, paint);
      canvas.restore();
    }

    // Ghost check while idle, white check drawn stroke by stroke when marked.
    final checkPath = _checkPath(radius);
    if (check < 1) {
      canvas.drawPath(
        checkPath,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.4, radius * 0.16)
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = idleColor.withValues(alpha: 0.35 * (1 - fill)),
      );
    }
    if (check > 0) {
      canvas.drawPath(
        _partialPath(checkPath, check),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.8, radius * 0.2)
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = Colors.white,
      );
    }
    canvas.restore();
  }

  void _paintSparkles(Canvas canvas, Offset center, double radius, double t) {
    final p = _interval(t, 0.15, 1, Curves.easeOutCubic);
    final fade = 1 - _interval(t, 0.55, 1, Curves.easeIn);
    const count = 8;
    for (var i = 0; i < count; i++) {
      final angle = -math.pi / 2 + i * 2 * math.pi / count;
      final distance = radius * (1.0 + 0.65 * p);
      final at = center + Offset(math.cos(angle), math.sin(angle)) * distance;
      final color = (i.isEven ? sparkleColor : fillColor).withValues(
        alpha: fade,
      );
      if (i.isEven) {
        _drawStar(canvas, at, radius * 0.22 * (1 - 0.4 * p), color);
      } else {
        canvas.drawCircle(
          at,
          radius * 0.09 * (1 - 0.3 * p),
          Paint()..color = color,
        );
      }
    }
  }

  /// A four-pointed sparkle.
  void _drawStar(Canvas canvas, Offset at, double r, Color color) {
    final inner = r * 0.32;
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final angle = -math.pi / 2 + i * math.pi / 4;
      final len = i.isEven ? r : inner;
      final point = at + Offset(math.cos(angle), math.sin(angle)) * len;
      i == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path..close(), Paint()..color = color);
  }

  /// Circle with [_waves] soft bumps: a rosette / seal outline.
  Path _sealPath(double radius) {
    final path = Path();
    const steps = 120;
    for (var i = 0; i <= steps; i++) {
      final a = i * 2 * math.pi / steps;
      final r = radius * (0.9 + 0.1 * math.cos(_waves * a));
      final point = Offset(math.cos(a), math.sin(a)) * r;
      i == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    return path..close();
  }

  Path _checkPath(double radius) => Path()
    ..moveTo(-radius * 0.38, radius * 0.02)
    ..lineTo(-radius * 0.1, radius * 0.3)
    ..lineTo(radius * 0.42, -radius * 0.28);

  Path _partialPath(Path source, double fraction) {
    final result = Path();
    final metrics = source.computeMetrics().toList();
    final total = metrics.fold<double>(0, (sum, m) => sum + m.length);
    var remaining = total * fraction;
    for (final metric in metrics) {
      if (remaining <= 0) break;
      final length = math.min(remaining, metric.length);
      result.addPath(metric.extractPath(0, length), Offset.zero);
      remaining -= length;
    }
    return result;
  }

  void _drawDashed(
    Canvas canvas,
    Path path,
    Paint paint,
    double dash,
    double gap,
  ) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + dash, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + gap;
      }
    }
  }

  static double _interval(double t, double begin, double end, Curve? curve) {
    final v = ((t - begin) / (end - begin)).clamp(0.0, 1.0);
    return curve == null ? v : curve.transform(v);
  }

  @override
  bool shouldRepaint(StudiedSealPainter old) =>
      old.progress != progress ||
      old.marking != marking ||
      old.burst != burst ||
      old.sealSize != sealSize ||
      old.idleColor != idleColor ||
      old.fillColor != fillColor ||
      old.sparkleColor != sparkleColor;
}
