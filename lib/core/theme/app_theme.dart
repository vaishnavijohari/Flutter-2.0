// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.teal,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 1,
    ),
    cardColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: Colors.teal,
      secondary: Colors.amber,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.teal,
    scaffoldBackgroundColor: Colors.black,
    fontFamily: 'Roboto',
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      elevation: 0,
    ),
    cardColor: Colors.grey[850],
    colorScheme: const ColorScheme.dark(
      primary: Colors.tealAccent,
      secondary: Colors.amber,
      surface: Color(0xFF121212),
    ),
  );
}