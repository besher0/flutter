import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_platform.dart';

/// Layout rules shared by the phone and desktop versions.
///
/// The screens are designed for a phone. On a desktop window they keep that
/// design but at their real size (ScreenUtil scales 1:1 there, see
/// `CoursatyApp`), inside a content area of at most [maxContentWidth], and
/// pages with more room ([isWide]) can lay out side by side.
abstract final class AppLayout {
  /// Widest the app's content grows; wider windows centre it.
  static const double maxContentWidth = 1280;

  /// From this width a desktop window gets the desktop layouts (side
  /// navigation, two columns).
  static const double wideBreakpoint = 900;

  /// Smallest window the desktop app allows (also set in the Windows runner).
  static const Size minWindowSize = Size(1024, 680);

  /// The area the app is drawn in inside a desktop window of [window] size.
  static Size contentSize(Size window) => Size(
    window.width > maxContentWidth ? maxContentWidth : window.width,
    window.height,
  );

  /// Course cards: 80% of the phone's width; a fixed width on desktop, where
  /// 80% of the window made one card fill the row.
  static double get courseCardWidth => AppPlatform.isDesktop ? 340 : 0.8.sw;

  /// Cards shown in a horizontal list (notifications, points of sale).
  static double listCardWidth(double phoneWidth) =>
      AppPlatform.isDesktop ? 420 : phoneWidth;

  static bool isWide(BuildContext context) =>
      AppPlatform.isDesktop &&
      MediaQuery.sizeOf(context).width >= wideBreakpoint;
}

/// App-wide scrolling: Flutter's default (on desktop the mouse wheel scrolls,
/// the mouse does not drag).
///
/// ⚠️ Mouse drag used to be on for every list. Inside a scrolling page the
/// list's drag handling then swallowed clicks on the desktop video controls
/// (play/pause did nothing on the "add video" page). Only horizontal rows
/// get mouse drag ([HorizontalDragScrollBehavior]), since a plain wheel does
/// not scroll them (it needs Shift): wrap them in [HorizontalMouseDrag].
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();
}

/// Mouse drag for one horizontal list on desktop (see [HorizontalMouseDrag]).
class HorizontalDragScrollBehavior extends MaterialScrollBehavior {
  const HorizontalDragScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    ...super.dragDevices,
    if (AppPlatform.isDesktop) PointerDeviceKind.mouse,
  };
}

/// Wrap a horizontal list so the mouse can drag it on desktop. Phones are
/// unchanged.
class HorizontalMouseDrag extends StatelessWidget {
  const HorizontalMouseDrag({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!AppPlatform.isDesktop) return child;
    return ScrollConfiguration(
      behavior: const HorizontalDragScrollBehavior(),
      child: child,
    );
  }
}

/// Forms (add course, lecture, video, file, question, notification, profile)
/// keep a readable width on desktop instead of stretching across the window.
/// Phones get the child unchanged.
class DesktopFormWidth extends StatelessWidget {
  const DesktopFormWidth({super.key, required this.child});

  static const double maxWidth = 760;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!AppPlatform.isDesktop) return child;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Centres the whole app inside [AppLayout.maxContentWidth] on desktop.
/// Phones get the child unchanged.
class DesktopFrame extends StatelessWidget {
  const DesktopFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!AppPlatform.isDesktop) return child;
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppLayout.maxContentWidth,
          ),
          child: child,
        ),
      ),
    );
  }
}
