import 'package:flutter/material.dart';

class AppColors {
  static const primaryGreen = Color(0xFF1D9E75);
  static const primaryBlue = Color(0xFF378ADD);
  static const primaryRed = Color(0xFFE24B4A);
  static const primaryAmber = Color(0xFFF5A623);
  static const textDark = Color(0xFF111111);
  static const background = Color(0xFFF7F8FA);
  static const border = Color(0xFFE0E0E0);
  static const white = Colors.white;
  static const grey = Colors.grey;
}

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: AppColors.primaryGreen,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
    ),
  );
}
