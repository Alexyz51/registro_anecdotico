import 'package:flutter/material.dart';

class AppTheme {
  // Tema claro
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF8e0b13),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF8e0b13),
      foregroundColor: Colors.white,
    ),
    cardColor: Colors.white,
    iconTheme: const IconThemeData(color: Colors.black87),
    textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black87)),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(),
    ),
  );

  // Tema oscuro
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF8e0b13),
    scaffoldBackgroundColor: const Color(0xFF121212), // negro grisáceo
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF8e0b13),
      foregroundColor: Colors.white,
    ),
    cardColor: const Color(0xFF1E1E1E),
    iconTheme: const IconThemeData(color: Colors.white70),
    textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white70)),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF2C2C2C), // para inputs oscuros
      border: OutlineInputBorder(),
    ),
  );
}
