import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme(double fontScale) {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF1565C0),
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF1565C0),
        secondary: const Color(0xFF42A5F5),
      ),
      textTheme: _textTheme(fontScale),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData darkTheme(double fontScale) {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF1565C0),
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF1565C0),
        secondary: const Color(0xFF42A5F5),
      ),
      textTheme: _textTheme(fontScale),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
    );
  }

  static TextTheme _textTheme(double fontScale) {
    return TextTheme(
      displayLarge: TextStyle(fontSize: 32 * fontScale, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontSize: 20 * fontScale, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 16 * fontScale),
      bodyMedium: TextStyle(fontSize: 14 * fontScale),
      labelLarge: TextStyle(fontSize: 16 * fontScale, fontWeight: FontWeight.w500),
    );
  }
}
