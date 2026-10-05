import 'package:flutter/material.dart';

/// Centralized app color palette from Coursaty Figma design.
/// Foundation tokens: text, primary, secondary, grey.
abstract final class AppColors {
  AppColors._();

  // --- Text
  /// Primary text (titles, labels)
  static const Color textNormal = Color(0xFF020707);

  /// Body / secondary text
  static const Color textBody = Color(0xFF212121);

  /// White text (on primary buttons)
  static const Color textLight = Color(0xFFFFFFFF);
  static const success = Color(0xFF39AC27);
  static const danger = Color(0xFFC61F1F);

  // --- Primary (teal)
  /// Main brand color: buttons, links, progress fill
  static const Color primary = Color(0xFF1F6366);
  static const primaryLight = Color(0xFFE9EFF0);

  /// Header text, primary darker (Figma Foundation/primary/Darker)
  static const Color primaryDarker = Color(0xFF0B2324);

  /// Chip text, primary dark active (Figma Foundation/primary/Dark :active)
  static const Color primaryDarkActive = Color(0xFF0E2D2E);

  /// Input border, primary hover
  static const Color primaryLightBorder = Color(0xFFDDE8E8);
  static const primaryActive = Color(0xFF194F52);
  static const text = Color(0xFF020707);
  static const grey = Color(0xFFC7C7C7);

  /// Progress bar track, card border (Figma Foundation/primary/Light)
  static const Color primaryLightTrack = Color(0xFFE9EFF0);

  /// Progress bar track border
  static const Color primaryLightTrackBorder = Color(0xFFBACFD0);

  // --- Secondary (warm)
  /// Button border (active state)
  static const Color secondaryActive = Color(0xFFF9E3C4);

  static const Color secondary = Color(0xFFECA541);

  // --- Grey
  /// Placeholder text
  static const Color greyNormal = Color(0xFFC7C7C7);

  /// Secondary button text
  static const Color greyDark = Color(0xFF777777);

  /// Secondary button background
  static const Color greyLight = Color(0xFFEEEEEE);

  /// Chip/tag background (Figma Grey/Light hover)
  static const Color chipBackground = Color(0xFFF7F7F7);

  /// Description text (Figma Foundation/Grey/Dark :active)
  static const Color greyDarkActive = Color(0xFF5A5A5A);

  /// Section title teal (e.g. "عن الأستاذ", "وصف الموقع")
  static const Color sectionTitle = Color(0xFF1F6366);

  // --- Surfaces
  static const Color surface = Color(0xFFFFFFFF);
  static const Color inputBorder = primaryLightBorder;

  // error
  static const Color red = Color(0xffC61F1F);

  // --- Dark Theme
  static const Color darkBackground = Color(0xFF1D2223);
  static const Color darkSurface = Color(0xFF232829);
  static const Color darkSurfaceVariant = Color(0xFF2A3031);

  // Text
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B8B9);
  static const Color darkTextMuted = Color(0xFF7A8384);

  // Borders / outlines
  static const Color darkBorder = Color(0xFF3A4243);

  // Primary (slightly lighter for contrast on dark)
  static const Color darkPrimary = Color(0xFF2A8C90);
  static const Color darkPrimarySoft = Color(0xFF1F6366);

  // Input
  static const Color darkInputFill = Color(0xFF232829);

  // Error (slightly softer for dark)
  static const Color darkRed = Color(0xFFE57373);

  // --- Shadows
  static const BoxShadow inputShadow = BoxShadow(
    color: Color(0x0F000000),
    offset: Offset(0, 2),
    blurRadius: 6,
  );
  static const BoxShadow buttonShadow = BoxShadow(
    color: Color(0x29000000),
    offset: Offset(0, 3),
    blurRadius: 8,
  );

  /// Card shadow (Figma 0px 2.554px 10.216px rgba(0,0,0,0.08))
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x14000000),
    offset: Offset(0, 2.554),
    blurRadius: 10.216,
  );
}
