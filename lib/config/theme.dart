import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF1A73E8);
  static const Color secondary = Color(0xFF34A853);
  static const Color warning = Color(0xFFFBBC04);
  static const Color danger = Color(0xFFEA4335);
  static const Color bgLight = Color(0xFFF5F7FA);
  static const Color cardBg = Colors.white;
  static const Color textPrimary = Color(0xFF202124);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color divider = Color(0xFFE8EAED);

  static const Color excellent = Color(0xFF34A853);
  static const Color proficient = Color(0xFF1A73E8);
  static const Color weak = Color(0xFFFBBC04);
  static const Color gap = Color(0xFFEA4335);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: primary,
        scaffoldBackgroundColor: bgLight,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: textPrimary,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: cardBg,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
}
