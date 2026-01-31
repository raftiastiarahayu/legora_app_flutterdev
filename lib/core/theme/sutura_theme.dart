import 'package:flutter/material.dart';
import 'sutura_colors.dart';

class SuturaTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: SuturaColors.background,
      primaryColor: SuturaColors.primary,

      colorScheme: ColorScheme.fromSeed(
        seedColor: SuturaColors.primary,
        primary: SuturaColors.primary,
        secondary: SuturaColors.secondary,
        surface: SuturaColors.background,
        onSurface: SuturaColors.textPrimary,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: SuturaColors.textPrimary,
      ),

      cardTheme: CardThemeData(
        color: SuturaColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      dividerTheme: const DividerThemeData(
        color: SuturaColors.border,
        thickness: 1,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SuturaColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SuturaColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
