import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF2B547A);
  static const Color secondaryBlue = Color(0xFF436286);
  static const Color darkAccent = Color(0xFF002C4B);
  static const Color gradientStart = Color(0xFF436286);
  static const Color gradientMid = Color(0xFF375B80);
  static const Color gradientEnd = Color(0xFF002C4B);

  // Neutral
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color lightBackground = Color(0xFFD7DADD);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color neutralGrey = Color(0xFFB6B6B7);

  // Semantic
  static const Color highPriority = Color(0xFFFB3434);
  static const Color mediumPriority = Color(0xFFC56100);
  static const Color lowPriority = Color(0xFF0E9D25);
  static const Color success = Color(0xFF49B65F);
  static const Color online = Color(0xFF00C950);

  // Accent
  static const Color accentBlue = Color(0xFF299ADF);
  static const Color lightBlue = Color(0xFF3FB1EA);
  static const Color chatBubble = Color(0xFFE3F2FD);
  static const Color tipBackground = Color(0xFFE5F0FA);
  static const Color tipBorder = Color(0xFFB6CEE5);

  // Text
  static const Color textDark = Color(0xFF372A4C);
  static const Color textSubtitle = Color(0xFF436286);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
        secondary: AppColors.secondaryBlue,
        surface: AppColors.pureWhite,
      ),
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.pureWhite,
        foregroundColor: AppColors.darkAccent,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.pureWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }
}
