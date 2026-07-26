import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryTeal = Color(0xFF00897B);
  static const Color primaryRed = Color(0xFFE24B4A);
  static const Color primaryAmber = Color(0xFFF5A623);
  static const Color primaryBlue = Color(0xFF378ADD);
  static const Color textDark = Color(0xFF111111);
  static const Color background = Color(0xFFF7F8FA);
  static const Color border = Color(0xFFE0E0E0);
  static const Color white = Colors.white;
  static const Color grey = Colors.grey;
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryTeal,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryTeal,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
