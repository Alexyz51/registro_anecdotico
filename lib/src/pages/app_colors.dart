import 'package:flutter/material.dart';

/// Colores principales (independientes del tema)
class AppColors {
  // Colores base (puedes ajustarlos a tu estilo)
  static const primary = Color(0xFF1565C0); // azul fuerte
  static const secondary = Color(0xFF42A5F5); // azul más claro
  static const accent = Color(0xFFFFC107); // ámbar
  static const error = Color(0xFFE53935); // rojo

  // Fondos y textos modo CLARO
  static const lightBackground = Color(0xFFF5F5F5); // gris muy clarito
  static const lightCard = Colors.white;
  static const lightText = Colors.black87;

  // Fondos y textos modo OSCURO
  static const darkBackground = Color(0xFF121212); // gris muy oscuro
  static const darkCard = Color(0xFF1E1E1E);
  static const darkText = Colors.white70;
}
