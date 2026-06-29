import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryGreen = Color(0xFF00694C);
  static const Color primaryBlue = Color(0xFF378ADD);
  static const Color primaryRed = Color(0xFFE24B4A);
  static const Color primaryAmber = Color(0xFFF5A623);
  static const Color textDark = Color(0xFF111111);
  static const Color background = Color(0xFFFCF9F8);
  static const Color surface = Color(0xFFF0EDEC);
  static const Color border = Color(0xFFE0E0E0);
  static const Color white = Colors.white;
  static const Color grey = Colors.grey;
  static const Color successGreen = Color(0xFF1D9E75);
  static const Color cardShadow = Color(0x0A000000);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
