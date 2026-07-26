import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryOrange = Color(0xFFFF6F00);
  static const Color primaryBlue = Color(0xFF378ADD);
  static const Color primaryRed = Color(0xFFE24B4A);
  static const Color primaryGreen = Color(0xFF1D9E75);
  static const Color primaryAmber = Color(0xFFF5A623);
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
        seedColor: AppColors.primaryOrange,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryOrange,
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
