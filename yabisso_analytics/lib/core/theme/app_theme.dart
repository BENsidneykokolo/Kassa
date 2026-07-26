import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF6A1B9A);
  static const Color primaryLight = Color(0xFF9C4DCC);
  static const Color primaryDark = Color(0xFF38006B);
  static const Color accent = Color(0xFF00BCD4);
  static const Color textDark = Color(0xFF111111);
  static const Color textLight = Color(0xFF757575);
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE0E0E0);
  static const Color white = Colors.white;
  static const Color grey = Colors.grey;
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE24B4A);
  static const Color chartLine1 = Color(0xFF6A1B9A);
  static const Color chartLine2 = Color(0xFF00BCD4);
  static const Color chartBar1 = Color(0xFF6A1B9A);
  static const Color chartBar2 = Color(0xFF9C4DCC);
  static const Color chartPie1 = Color(0xFF6A1B9A);
  static const Color chartPie2 = Color(0xFF00BCD4);
  static const Color chartPie3 = Color(0xFFFF9800);
  static const Color chartPie4 = Color(0xFF4CAF50);
  static const Color chartPie5 = Color(0xFFE24B4A);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
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
      textTheme: GoogleFonts.poppinsTextTheme(),
    );
  }
}
