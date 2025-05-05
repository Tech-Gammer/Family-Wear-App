import 'package:flutter/material.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.primaryColor,
    hintColor: AppColors.accentColor,
    scaffoldBackgroundColor: AppColors.lightBackgroundColor,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.darkTextColor),
      bodyMedium: TextStyle(color: AppColors.darkTextColor),
    ),
    brightness: Brightness.light,
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: AppColors.primaryColor,
    hintColor: AppColors.accentColor,
    scaffoldBackgroundColor: AppColors.darkBackgroundColor,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.lightTextColor),
      bodyMedium: TextStyle(color: AppColors.lightTextColor),
    ),
    brightness: Brightness.dark,
  );
}

class AppColors {
  // Common Colors
  // static const Color primaryColor = Color(0xFFFF4747); // Soft Red-Orange
  static const Color primaryColor = Color(0xFF00B14F)
  ; // Soft Red-Orange
  static const Color accentColor = Color(0xFF242424);  // Dark Gray

  // Light Theme Colors
  static const Color lightBackgroundColor = Color(0xFFF2F2F2); // Light Gray
  static const Color darkTextColor = Color(0xFF242424); // Dark Gray Text

  // Dark Theme Colors
  static const Color darkBackgroundColor = Color(0xFF121212); // Dark Background
  static const Color lightTextColor = Color(0xFFF6F6F6); // Light Gray Text

  static const Color background = Color(0xFFE8E8E8); // Light Gray Text


}
