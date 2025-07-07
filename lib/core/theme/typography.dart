import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';
import 'constants.dart';

class AppTypography {
  static TextStyle headline = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static TextStyle subtitle = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primary.withOpacity(0.7),
  );

  static TextStyle body = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static TextStyle status = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static TextStyle caption = GoogleFonts.poppins(
    fontSize: 12,
    color: Colors.grey[600],
    fontWeight: FontWeight.w500,
  );

  static TextStyle headerTitle = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle headerSubtitle = GoogleFonts.poppins(
    fontSize: 14,
    color: Colors.white.withOpacity(0.8),
  );

  static TextStyle button = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}