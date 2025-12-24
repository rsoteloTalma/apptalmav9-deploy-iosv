import 'package:apptalma_v9/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TalmaTheme {
  static ThemeData defaultTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.indigo,
    splashFactory: InkSplash.splashFactory,
    highlightColor: Colors.white.withAlpha(51),
    scaffoldBackgroundColor: Colors.grey.shade50,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
    useMaterial3: true,
    textTheme: GoogleFonts.robotoTextTheme().copyWith(
      headlineLarge: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor),
      bodyLarge: const TextStyle(fontSize: 16, color: Colors.black87),
      bodySmall: const TextStyle(fontSize: 16, color: AppColors.primaryColor),
      titleMedium: const TextStyle(fontSize: 20, color: AppColors.talmaCyan),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
  );
}
