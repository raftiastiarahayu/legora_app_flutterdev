import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sutura_colors.dart';

class SuturaText {
  static TextStyle title = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: SuturaColors.textPrimary,
  );

  static TextStyle subtitle = GoogleFonts.poppins(
    fontSize: 14,
    color: SuturaColors.textSecondary,
  );

  static TextStyle body = GoogleFonts.poppins(
    fontSize: 14,
    height: 1.6,
    color: SuturaColors.textPrimary,
  );

  static TextStyle money = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: SuturaColors.primary,
  );

  // Caption style for smaller text
  static TextStyle caption = GoogleFonts.poppins(
    fontSize: 12,
    color: SuturaColors.textSecondary,
  );
}
