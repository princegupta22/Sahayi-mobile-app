import 'package:flutter/material.dart';

/// Palette derived from the Sahayi logo (green hand + orange roof).
class AppColors {
  AppColors._();

  static const Color forest = Color(0xFF1B5E20);
  static const Color leaf = Color(0xFF4C9A2A);
  static const Color leafLight = Color(0xFF8BC34A);
  static const Color roof = Color(0xFFF7941D);
  static const Color roofDeep = Color(0xFFE65100);

  static const Color background = Color(0xFFF6FAF5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1B2420);
  static const Color textSecondary = Color(0xFF667066);
  static const Color divider = Color(0xFFE2E9DF);
  static const Color danger = Color(0xFFD64545);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [leaf, forest],
  );

  static const LinearGradient roofGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [roof, roofDeep],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEAF6E9), Color(0xFFF6FAF5)],
  );
}
