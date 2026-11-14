import 'package:flutter/material.dart';

/// LokaNusantara palette, drawn from traditional Indonesian materials:
/// terracotta brick, prada gold leaf, sogan batik brown and ivory.
abstract final class AppColors {
  static const terakota = Color(0xFFA9432A);
  static const terakotaDark = Color(0xFF7E2F1C);
  static const prada = Color(0xFFD9A84A);
  static const pradaLight = Color(0xFFF6D98A);
  static const sogan = Color(0xFF4A1F14);
  static const soganInk = Color(0xFF2E1A12);
  static const gading = Color(0xFFFAF3E6);
  static const gadingDeep = Color(0xFFF1E4CC);
  static const nila = Color(0xFF2B5C8A);

  static const textPrimary = Color(0xFF2E1A12);
  static const textSecondary = Color(0xFF7A6253);
  static const textMuted = Color(0xFFA8957F);
  static const border = Color(0xFFE6D8C0);
  static const surfaceMuted = Color(0xFFFBF7EF);

  static ThemeData theme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: terakota,
      primary: terakota,
      secondary: prada,
      surface: Colors.white,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: gading,
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: terakota),
      dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
    );
  }
}
