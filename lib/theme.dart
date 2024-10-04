import 'package:flutter/material.dart';

class AppTheme {
  // Define primary, secondary, accent, and background colors
  static const Color primaryColor = Color(0xFFACE1AF);
  static const Color secondaryColor = Color(0xFFB0EBB4);
  static const Color accentColor = Color(0xFFBFF6C3);
  static const Color backgroundColor = Color(0xFFE0FBE2);

  // Define the theme data
  static ThemeData get theme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor, // Corrected parameter
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor, // Corrected parameter
          foregroundColor: Colors.black, // Corrected parameter
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: secondaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor),
        ),
        labelStyle: const TextStyle(color: primaryColor),
        prefixIconColor: primaryColor,
      ),
    );
  }
}