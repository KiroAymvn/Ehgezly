// core/theme/app_theme.dart
//
// Defines the entire MaterialApp theme in one place.
// Import and use AppTheme.light in main.dart.

import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._(); // Prevent instantiation

  static ThemeData get light => ThemeData(
        scaffoldBackgroundColor: const Color(0xffe5eaf6),
        primarySwatch: Colors.indigo,
        fontFamily: 'Poppins',
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xffe5eaf6),
          foregroundColor: Colors.indigo,
          elevation: 3,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.indigo,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      );
}
