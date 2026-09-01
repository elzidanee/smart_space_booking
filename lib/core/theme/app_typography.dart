import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Sistem tipografi Sora + Inter sesuai PRD Bagian III §2.2.
class AppTypography {
  AppTypography._();

  // Headings (Sora)
  static TextStyle get h1 => GoogleFonts.sora(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.ink900,
        height: 1.3,
      );

  static TextStyle get h2 => GoogleFonts.sora(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.ink900,
        height: 1.35,
      );

  static TextStyle get sectionLabel => GoogleFonts.sora(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
        color: AppColors.ink600,
        height: 1.4,
      );

  // Body & Text (Inter)
  static TextStyle get body => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.ink900,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.ink900,
        height: 1.5,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.ink600,
        height: 1.4,
      );

  static TextStyle get captionMedium => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.ink600,
        height: 1.4,
      );

  // Angka Finansial (Inter SemiBold with tabular-nums)
  static TextStyle get priceLarge => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.ink900,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle get priceMedium => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.ink900,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle get priceSmall => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.ink900,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}
