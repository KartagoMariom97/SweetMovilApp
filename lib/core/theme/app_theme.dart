import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final colorScheme = const ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryVariant,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onPrimary,
      error: AppColors.error,
      errorContainer: AppColors.errorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      background: AppColors.background,
      onBackground: AppColors.onBackground,
      surfaceVariant: AppColors.surfaceVariant,
    );

    final textTheme = GoogleFonts.interTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.onSurface,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.onSurface,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.onSurface,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.onSurface,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.onSurface,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.onSurfaceVariant,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onPrimary,
      ),
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface,
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      cardTheme: CardTheme(
        color: AppColors.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.outlineVariant),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
        hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primary.withOpacity(0.2),
        labelStyle: const TextStyle(color: AppColors.onSurface, fontSize: 12),
        side: const BorderSide(color: AppColors.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceVariant,
        contentTextStyle: const TextStyle(color: AppColors.onSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
