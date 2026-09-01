import 'package:flutter/material.dart';

/// Skala Spasi & Radius sesuai PRD Bagian III §2.3 dan §2.4.
class AppSpacing {
  AppSpacing._();

  // Skala Grid 4px
  static const double xs4 = 4.0;
  static const double sm8 = 8.0;
  static const double md12 = 12.0;
  static const double lg16 = 16.0;
  static const double xl24 = 24.0;
  static const double xxl32 = 32.0;
  static const double xxxl48 = 48.0;
  static const double huge64 = 64.0;

  // Corner Radius
  static const double radiusButton = 12.0;
  static const double radiusField = 12.0;
  static const double radiusCard = 16.0;
  static const double radiusBottomSheet = 24.0;
  static const double radiusPill = 999.0;

  // Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0F1C1917), // rgba(28, 25, 23, 0.06)
      offset: Offset(0, 2),
      blurRadius: 8,
    ),
  ];

  static const List<BoxShadow> bottomSheetShadow = [
    BoxShadow(
      color: Color(0x1A1C1917), // rgba(28, 25, 23, 0.10)
      offset: Offset(0, -4),
      blurRadius: 16,
    ),
  ];
}
