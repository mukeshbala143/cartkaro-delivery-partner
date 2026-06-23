import 'package:flutter/material.dart';

/// Centralized color palette for the Cartkaro Delivery Partner app.
/// A premium black theme accented with a luxury gold tone.
class AppColors {
  AppColors._();

  // Base surfaces
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF121212);
  static const Color surfaceVariant = Color(0xFF1E1E1E);
  static const Color cardBackground = Color(0xFF1A1A1A);

  // Accent (premium gold)
  static const Color primary = Color(0xFFD4AF37);
  static const Color primaryDark = Color(0xFFB8932E);
  static const Color primaryLight = Color(0xFFE9D08E);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textHint = Color(0xFF6E6E6E);

  // Status
  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);

  // Borders / dividers
  static const Color border = Color(0xFF2A2A2A);
  static const Color divider = Color(0xFF272727);

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF000000), Color(0xFF101010), Color(0xFF000000)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFD4AF37), Color(0xFFF1D58A)],
  );

  static Color? get kLightText => null;

  static Color? get kDarkText => null;

  static Color? get kBackground => null;

  static Color? get kPrimary => null;
}