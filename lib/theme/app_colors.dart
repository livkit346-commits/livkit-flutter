import 'package:flutter/material.dart';

class AppColors {
  // 🌘 Backgrounds - From sign-in.html gradient
  static const List<Color> bgGradient = [
    Color(0xFF0F2027),
    Color(0xFF203A43),
    Color(0xFF2C5364),
  ];
  
  static const Color background = Color(0xFF0F2027);

  // 🎨 Accents - From sign-in.html and admin portal
  static const Color primary = Color(0xFF7C4DFF); // Purple
  static const Color secondary = Color(0xFF4568DC); // Blue
  static const Color surface = Color(0xFF1A1A1A);
  
  // ⚪ Text
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textDisabled = Colors.white38;

  // 🛑 Status
  static const Color error = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF00C853);
}
