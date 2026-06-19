import 'package:flutter/material.dart';

class AppColors {
  // Base Colors
  static const Color background = Color(0xFF050505);
  static const Color surface = Color(0xFF121212);
  static const Color card = Color(0xFF1E1E1E);

  // Accent Colors (Neon/Premium)
  static const Color primaryNeon = Color(0xFF00D1FF); // Neon Blue
  static const Color secondaryNeon = Color(0xFF9D00FF); // Neon Purple
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryNeon, secondaryNeon],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF121212), Color(0xFF050505)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textGrey = Color(0xFF6E6E6E);

  // Status Colors
  static const Color success = Color(0xFF00FFA3);
  static const Color error = Color(0xFFFF3B3B);
  static const Color warning = Color(0xFFFFD600);
}
