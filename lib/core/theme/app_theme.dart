import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// App-wide theme using Cairo font and Coursaty colors.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final cairo = GoogleFonts.cairo();
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.textLight,
        surface: AppColors.surface,
        onSurface: AppColors.textNormal,
        outline: AppColors.inputBorder,
        secondary: AppColors.secondary,
      ),
      scaffoldBackgroundColor: AppColors.surface,
      textTheme: TextTheme(
        headlineMedium: cairo.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textNormal,
          height: 1.4,
        ),
        titleMedium: cairo.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textNormal,
          height: 1.4,
        ),
        bodyMedium: cairo.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textBody,
          height: 1.4,
        ),
        labelLarge: cairo.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textLight,
          height: 1.4,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: cairo.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.greyNormal,
        ),
        labelStyle: cairo.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textNormal,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textNormal,
          side: const BorderSide(color: AppColors.inputBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  static ThemeData get dark {
    final cairo = GoogleFonts.cairo();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        onPrimary: Colors.white,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        outline: AppColors.darkBorder,
      ),

      scaffoldBackgroundColor: AppColors.darkBackground,

      textTheme: TextTheme(
        headlineMedium: cairo.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.darkTextPrimary,
          height: 1.4,
        ),
        titleMedium: cairo.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.darkTextPrimary,
          height: 1.4,
        ),
        bodyMedium: cairo.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.darkTextSecondary,
          height: 1.4,
        ),
        labelLarge: cairo.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1.4,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkInputFill,

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.darkPrimary,
            width: 1.5,
          ),
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),

        hintStyle: cairo.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.darkTextMuted,
        ),

        labelStyle: cairo.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.darkTextSecondary,
        ),
      ),

      // ✅ Buttons (important for consistency)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkTextPrimary,
          side: const BorderSide(color: AppColors.darkBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
