import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryColor = Color(0xFFFACC15);
  static const Color primaryColorDark = Color(0xFFEAB308);

  static const Color accentColor = Color(0xFF42A5F5);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFF44336);

  static const Color backgroundColor = Color(0xFFF8F5EE);
  static const Color surfaceColor = Colors.white;

  static const Color textPrimaryColor = Color(0xFF1F2937);
  static const Color textSecondaryColor = Color(0xFF6B7280);
  static const Color textLightColor = Colors.white;
  static final TextStyle h1 = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
    height: 1.2,
  );

  static final TextStyle h2 = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static final TextStyle h3 = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static final TextStyle subtitle1 = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );

  static final TextStyle subtitle2 = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );

  static final TextStyle body1 = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimaryColor,
    height: 1.5,
  );

  static final TextStyle body2 = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textSecondaryColor,
    height: 1.5,
  );

  static final TextStyle button = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static final TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondaryColor,
  );
}
