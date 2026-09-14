import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

// =============================================================================
// ONBOARDING ILLUSTRATION 1: DISCOVER WORKSPACES
// Modern co-working building with windows, plants, and welcome vibe
// =============================================================================

class DiscoverWorkspacesIllustration extends StatelessWidget {
  final double size;

  const DiscoverWorkspacesIllustration({super.key, this.size = 280});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DiscoverWorkspacesPainter(),
      ),
    );
  }
}

class _DiscoverWorkspacesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Large soft background circle
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.5,
        colors: [
          AppColors.primaryContainer.withValues(alpha: 0.6),
          AppColors.primaryContainer.withValues(alpha: 0.1),
        ],
      ).createShader(Rect.fromCircle(center: Offset(w * 0.5, h * 0.48), radius: w * 0.42));
    canvas.drawCircle(Offset(w * 0.5, h * 0.48), w * 0.42, bgPaint);

    // Ground / floor line
    final groundPaint = Paint()
      ..color = const Color(0xFFE2DDD7)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.08, h * 0.82), Offset(w * 0.92, h * 0.82), groundPaint);

    // === MAIN BUILDING ===
    // Building body
    final buildingPaint = Paint()..color = Colors.white;
    final buildingShadow = Paint()..color = const Color(0xFFE8E4DF);
    // Shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.22, h * 0.22, w * 0.52, h * 0.62),
        const Radius.circular(12),
      ),
      buildingShadow,
    );
    // Main body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.20, h * 0.20, w * 0.52, h * 0.62),
        const Radius.circular(12),
      ),
      buildingPaint,
    );

    // Building roof accent bar (Terracotta)
    final roofPaint = Paint()..color = AppColors.primary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.20, h * 0.20, w * 0.52, h * 0.045),
        const Radius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      roofPaint,
    );

    // === WINDOWS (3x3 grid) ===
    final windowPaint = Paint()..color = AppColors.secondary;
    final windowGlow = Paint()..color = AppColors.secondaryContainer;
    const windowW = 0.11;
    const windowH = 0.10;
    final cols = [0.26, 0.40, 0.54];
    final rows = [0.30, 0.46, 0.62];

    for (int r = 0; r < rows.length; r++) {
      for (int c = 0; c < cols.length; c++) {
        // Determine if window is "lit"
        final isLit = (r + c) % 2 == 0;
        final paint = isLit ? windowPaint : windowGlow;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * cols[c], h * rows[r], w * windowW, h * windowH),
            const Radius.circular(4),
          ),
          paint,
        );
        // Window cross bars
        final barPaint = Paint()
          ..color = Colors.white.withValues(alpha: isLit ? 0.3 : 0.5)
          ..strokeWidth = 1.2;
        final cx = w * cols[c] + w * windowW / 2;
        final cy = h * rows[r] + h * windowH / 2;
        canvas.drawLine(
          Offset(cx, h * rows[r]),
          Offset(cx, h * rows[r] + h * windowH),
          barPaint,
        );
        canvas.drawLine(
          Offset(w * cols[c], cy),
          Offset(w * cols[c] + w * windowW, cy),
          barPaint,
        );
      }
    }

    // === ENTRANCE DOOR ===
    final doorPaint = Paint()..color = AppColors.primary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.40, h * 0.68, w * 0.12, h * 0.14),
        const Radius.only(
          topLeft: Radius.circular(6),
          topRight: Radius.circular(6),
        ),
      ),
      doorPaint,
    );
    // Door handle
    final handlePaint = Paint()..color = AppColors.primaryContainer;
    canvas.drawCircle(Offset(w * 0.49, h * 0.76), 2.5, handlePaint);

    // === LEFT PLANT / TREE ===
    final trunkPaint = Paint()
      ..color = const Color(0xFF8C7A6B)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.12, h * 0.82), Offset(w * 0.12, h * 0.62), trunkPaint);

    final leafPaint1 = Paint()..color = AppColors.success;
    final leafPaint2 = Paint()..color = const Color(0xFF439A65);
    canvas.drawCircle(Offset(w * 0.12, h * 0.58), w * 0.06, leafPaint1);
    canvas.drawCircle(Offset(w * 0.08, h * 0.62), w * 0.045, leafPaint2);
    canvas.drawCircle(Offset(w * 0.16, h * 0.63), w * 0.04, leafPaint1);
    canvas.drawCircle(Offset(w * 0.12, h * 0.52), w * 0.04, leafPaint2);

    // === RIGHT PLANT ===
    canvas.drawLine(Offset(w * 0.86, h * 0.82), Offset(w * 0.86, h * 0.66), trunkPaint);
    canvas.drawCircle(Offset(w * 0.86, h * 0.62), w * 0.05, leafPaint2);
    canvas.drawCircle(Offset(w * 0.82, h * 0.65), w * 0.035, leafPaint1);
    canvas.drawCircle(Offset(w * 0.90, h * 0.64), w * 0.04, leafPaint1);

    // === FLOATING LOCATION PIN (Terracotta) ===
    final pinPaint = Paint()..color = AppColors.primary;
    final pinPath = Path()
      ..moveTo(w * 0.78, h * 0.22)
      ..quadraticBezierTo(w * 0.72, h * 0.22, w * 0.72, h * 0.16)
      ..quadraticBezierTo(w * 0.72, h * 0.09, w * 0.78, h * 0.09)
      ..quadraticBezierTo(w * 0.84, h * 0.09, w * 0.84, h * 0.16)
      ..quadraticBezierTo(w * 0.84, h * 0.22, w * 0.78, h * 0.22)
      ..close();
    canvas.drawPath(pinPath, pinPaint);
    // Pin tip
    final tipPath = Path()
      ..moveTo(w * 0.755, h * 0.21)
      ..lineTo(w * 0.78, h * 0.27)
      ..lineTo(w * 0.805, h * 0.21);
    canvas.drawPath(tipPath, pinPaint);
    // Pin inner dot
    canvas.drawCircle(Offset(w * 0.78, h * 0.155), w * 0.025, Paint()..color = Colors.white);

    // === SPARKLES ===
    final sparklePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    _drawStar4(canvas, Offset(w * 0.88, h * 0.18), 6, sparklePaint);
    _drawStar4(canvas, Offset(w * 0.15, h * 0.28), 5,
        Paint()..color = AppColors.secondary..strokeWidth = 2.0..strokeCap = StrokeCap.round);
    _drawStar4(canvas, Offset(w * 0.90, h * 0.40), 4,
        Paint()..color = AppColors.warning..strokeWidth = 1.8..strokeCap = StrokeCap.round);

    // Small decorative dots
    canvas.drawCircle(Offset(w * 0.08, h * 0.38), 3, Paint()..color = AppColors.primaryContainer);
    canvas.drawCircle(Offset(w * 0.94, h * 0.52), 2.5, Paint()..color = AppColors.secondaryContainer);
    canvas.drawCircle(Offset(w * 0.70, h * 0.08), 2.5, Paint()..color = AppColors.primaryContainer);
  }

  void _drawStar4(Canvas canvas, Offset center, double radius, Paint paint) {
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - radius * 0.6, center.dy - radius * 0.6),
      Offset(center.dx + radius * 0.6, center.dy + radius * 0.6),
      paint..strokeWidth = 1.5,
    );
    canvas.drawLine(
      Offset(center.dx + radius * 0.6, center.dy - radius * 0.6),
      Offset(center.dx - radius * 0.6, center.dy + radius * 0.6),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// ONBOARDING ILLUSTRATION 2: EASY BOOKING
// Calendar with clock, check marks, and reservation card
// =============================================================================

class EasyBookingIllustration extends StatelessWidget {
  final double size;

  const EasyBookingIllustration({super.key, this.size = 280});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _EasyBookingPainter(),
      ),
    );
  }
}

class _EasyBookingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background circle gradient
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.5,
        colors: [
          AppColors.secondaryContainer.withValues(alpha: 0.6),
          AppColors.secondaryContainer.withValues(alpha: 0.1),
        ],
      ).createShader(Rect.fromCircle(center: Offset(w * 0.5, h * 0.48), radius: w * 0.42));
    canvas.drawCircle(Offset(w * 0.5, h * 0.48), w * 0.42, bgPaint);

    // === MAIN CALENDAR CARD ===
    final cardShadow = Paint()..color = const Color(0xFFE0DBD5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.17, h * 0.20, w * 0.60, h * 0.58),
        const Radius.circular(16),
      ),
      cardShadow,
    );

    final cardPaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.15, h * 0.18, w * 0.60, h * 0.58),
        const Radius.circular(16),
      ),
      cardPaint,
    );

    // Calendar header bar (Teal)
    final headerPaint = Paint()..color = AppColors.secondary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.15, h * 0.18, w * 0.60, h * 0.09),
        const Radius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      headerPaint,
    );

    // Calendar header dots (month nav)
    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.24, h * 0.225), 3, dotPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.36, h * 0.215, w * 0.18, h * 0.02),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.7),
    );
    canvas.drawCircle(Offset(w * 0.66, h * 0.225), 3, dotPaint);

    // Calendar day headers (S M T W T F S)
    final dayHeaderPaint = Paint()..color = AppColors.ink300;
    const days = 7;
    for (int i = 0; i < days; i++) {
      final cx = w * (0.20 + i * 0.075);
      canvas.drawCircle(Offset(cx, h * 0.32), 2, dayHeaderPaint);
    }

    // Calendar date grid (5 x 7 simplified)
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 7; col++) {
        final cx = w * (0.20 + col * 0.075);
        final cy = h * (0.38 + row * 0.07);

        // Highlight the selected date
        if (row == 1 && col == 3) {
          canvas.drawCircle(Offset(cx, cy), w * 0.025, Paint()..color = AppColors.primary);
          canvas.drawCircle(Offset(cx, cy), 2, Paint()..color = Colors.white);
        } else if (row == 1 && (col == 2 || col == 4)) {
          // Range highlight
          canvas.drawCircle(
            Offset(cx, cy),
            w * 0.02,
            Paint()..color = AppColors.primaryContainer,
          );
          canvas.drawCircle(Offset(cx, cy), 1.5, Paint()..color = AppColors.ink600);
        } else {
          canvas.drawCircle(Offset(cx, cy), 1.5, Paint()..color = AppColors.ink300);
        }
      }
    }

    // === BOOKING CONFIRMATION CARD (floating top-right) ===
    canvas.save();
    canvas.translate(w * 0.65, h * 0.08);
    canvas.rotate(0.12);

    final miniCardShadow = Paint()..color = const Color(0xFFE0DBD5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 2, w * 0.28, h * 0.16),
        const Radius.circular(10),
      ),
      miniCardShadow,
    );
    final miniCard = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w * 0.28, h * 0.16),
        const Radius.circular(10),
      ),
      miniCard,
    );

    // Mini card check icon
    final checkBg = Paint()..color = AppColors.success;
    canvas.drawCircle(Offset(w * 0.06, h * 0.08), w * 0.032, checkBg);
    final checkPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final checkPath = Path()
      ..moveTo(w * 0.045, h * 0.08)
      ..lineTo(w * 0.058, h * 0.09)
      ..lineTo(w * 0.077, h * 0.07);
    canvas.drawPath(checkPath, checkPaint);

    // Mini card text lines
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.11, h * 0.055, w * 0.14, h * 0.02),
        const Radius.circular(2),
      ),
      Paint()..color = AppColors.ink900,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.11, h * 0.09, w * 0.10, h * 0.015),
        const Radius.circular(2),
      ),
      Paint()..color = AppColors.ink300,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.11, h * 0.115, w * 0.12, h * 0.015),
        const Radius.circular(2),
      ),
      Paint()..color = AppColors.primaryContainer,
    );

    canvas.restore();

    // === CLOCK ICON (floating left) ===
    final clockBg = Paint()..color = AppColors.primaryContainer;
    canvas.drawCircle(Offset(w * 0.10, h * 0.45), w * 0.07, clockBg);

    final clockFace = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawCircle(Offset(w * 0.10, h * 0.45), w * 0.045, clockFace);

    // Clock hands
    final handPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.10, h * 0.45), Offset(w * 0.10, h * 0.42), handPaint);
    canvas.drawLine(Offset(w * 0.10, h * 0.45), Offset(w * 0.12, h * 0.46), handPaint);

    // === SPARKLES & DECORATIONS ===
    _drawStar4(canvas, Offset(w * 0.08, h * 0.22), 5,
        Paint()..color = AppColors.primary..strokeWidth = 2.0..strokeCap = StrokeCap.round);
    _drawStar4(canvas, Offset(w * 0.88, h * 0.55), 6,
        Paint()..color = AppColors.secondary..strokeWidth = 2.0..strokeCap = StrokeCap.round);
    _drawStar4(canvas, Offset(w * 0.50, h * 0.88), 4,
        Paint()..color = AppColors.warning..strokeWidth = 1.8..strokeCap = StrokeCap.round);

    // Decorative dots
    canvas.drawCircle(Offset(w * 0.92, h * 0.30), 3, Paint()..color = AppColors.primaryContainer);
    canvas.drawCircle(Offset(w * 0.05, h * 0.60), 2.5, Paint()..color = AppColors.secondaryContainer);
    canvas.drawCircle(Offset(w * 0.82, h * 0.82), 2.5, Paint()..color = AppColors.primaryContainer);
  }

  void _drawStar4(Canvas canvas, Offset center, double radius, Paint paint) {
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - radius * 0.6, center.dy - radius * 0.6),
      Offset(center.dx + radius * 0.6, center.dy + radius * 0.6),
      paint..strokeWidth = 1.5,
    );
    canvas.drawLine(
      Offset(center.dx + radius * 0.6, center.dy - radius * 0.6),
      Offset(center.dx - radius * 0.6, center.dy + radius * 0.6),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// ONBOARDING ILLUSTRATION 3: SMART MANAGEMENT
// Dashboard with chart, notifications bell, and QR ticket
// =============================================================================

class SmartManagementIllustration extends StatelessWidget {
  final double size;

  const SmartManagementIllustration({super.key, this.size = 280});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SmartManagementPainter(),
      ),
    );
  }
}

class _SmartManagementPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background circle gradient
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.5,
        colors: [
          AppColors.primaryContainer.withValues(alpha: 0.5),
          AppColors.primaryContainer.withValues(alpha: 0.08),
        ],
      ).createShader(Rect.fromCircle(center: Offset(w * 0.5, h * 0.48), radius: w * 0.42));
    canvas.drawCircle(Offset(w * 0.5, h * 0.48), w * 0.42, bgPaint);

    // === MAIN DASHBOARD CARD ===
    final cardShadow = Paint()..color = const Color(0xFFE0DBD5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.14, h * 0.22, w * 0.62, h * 0.55),
        const Radius.circular(16),
      ),
      cardShadow,
    );
    final cardPaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.12, h * 0.20, w * 0.62, h * 0.55),
        const Radius.circular(16),
      ),
      cardPaint,
    );

    // Dashboard top bar
    final topBarPaint = Paint()..color = AppColors.surface50;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.12, h * 0.20, w * 0.62, h * 0.07),
        const Radius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      topBarPaint,
    );

    // Hamburger menu icon
    final menuPaint = Paint()
      ..color = AppColors.ink600
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 3; i++) {
      final y = h * (0.225 + i * 0.012);
      canvas.drawLine(Offset(w * 0.17, y), Offset(w * 0.22, y), menuPaint);
    }

    // Dashboard title bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.35, h * 0.225, w * 0.16, h * 0.016),
        const Radius.circular(2),
      ),
      Paint()..color = AppColors.ink900,
    );

    // User avatar
    canvas.drawCircle(Offset(w * 0.68, h * 0.235), w * 0.02, Paint()..color = AppColors.secondary);

    // === STATS ROW ===
    final statColors = [AppColors.primary, AppColors.secondary, AppColors.success];
    for (int i = 0; i < 3; i++) {
      final x = w * (0.16 + i * 0.19);
      // Stat card
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, h * 0.31, w * 0.16, h * 0.10),
          const Radius.circular(8),
        ),
        Paint()..color = statColors[i].withValues(alpha: 0.12),
      );
      // Stat value dot
      canvas.drawCircle(Offset(x + w * 0.04, h * 0.345), w * 0.015, Paint()..color = statColors[i]);
      // Stat text lines
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + w * 0.065, h * 0.34, w * 0.07, h * 0.012),
          const Radius.circular(1),
        ),
        Paint()..color = AppColors.ink900,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + w * 0.065, h * 0.36, w * 0.05, h * 0.01),
          const Radius.circular(1),
        ),
        Paint()..color = AppColors.ink300,
      );
    }

    // === CHART AREA ===
    // Chart background
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.16, h * 0.45, w * 0.54, h * 0.22),
        const Radius.circular(8),
      ),
      Paint()..color = AppColors.surface50,
    );

    // Grid lines
    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.5)
      ..strokeWidth = 0.8;
    for (int i = 0; i < 4; i++) {
      final y = h * (0.48 + i * 0.05);
      canvas.drawLine(Offset(w * 0.18, y), Offset(w * 0.68, y), gridPaint);
    }

    // Bar chart
    final barData = [0.6, 0.8, 0.45, 0.9, 0.5, 0.75, 0.65];
    for (int i = 0; i < barData.length; i++) {
      final barX = w * (0.21 + i * 0.07);
      final barH = h * 0.16 * barData[i];
      final barY = h * 0.64 - barH;
      final color = i == 3 ? AppColors.primary : AppColors.secondary.withValues(alpha: 0.6);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(barX, barY, w * 0.035, barH),
          const Radius.only(
            topLeft: Radius.circular(3),
            topRight: Radius.circular(3),
          ),
        ),
        Paint()..color = color,
      );
    }

    // === FLOATING QR TICKET (bottom-right) ===
    canvas.save();
    canvas.translate(w * 0.72, h * 0.52);
    canvas.rotate(-0.08);

    final qrCardShadow = Paint()..color = const Color(0xFFE0DBD5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 2, w * 0.22, h * 0.28),
        const Radius.circular(10),
      ),
      qrCardShadow,
    );
    final qrCard = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w * 0.22, h * 0.28),
        const Radius.circular(10),
      ),
      qrCard,
    );

    // QR code simplified
    final qrPaint = Paint()..color = AppColors.ink900;
    final qrSize = w * 0.12;
    final qrX = w * 0.05;
    final qrY = h * 0.04;
    // Border
    canvas.drawRect(
      Rect.fromLTWH(qrX, qrY, qrSize, qrSize),
      Paint()
        ..color = AppColors.ink900
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
    // QR squares pattern
    final cellSize = qrSize / 5;
    final qrPattern = [
      [1, 1, 0, 1, 1],
      [1, 0, 1, 0, 1],
      [0, 1, 1, 1, 0],
      [1, 0, 1, 0, 1],
      [1, 1, 0, 1, 1],
    ];
    for (int r = 0; r < 5; r++) {
      for (int c = 0; c < 5; c++) {
        if (qrPattern[r][c] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(
              qrX + c * cellSize,
              qrY + r * cellSize,
              cellSize,
              cellSize,
            ),
            qrPaint,
          );
        }
      }
    }

    // Ticket text below QR
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.03, h * 0.18, w * 0.16, h * 0.015),
        const Radius.circular(1),
      ),
      Paint()..color = AppColors.ink900,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.05, h * 0.21, w * 0.12, h * 0.012),
        const Radius.circular(1),
      ),
      Paint()..color = AppColors.ink300,
    );
    // Ticket accent bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.03, h * 0.24, w * 0.16, h * 0.018),
        const Radius.circular(3),
      ),
      Paint()..color = AppColors.primaryContainer,
    );

    canvas.restore();

    // === FLOATING BELL NOTIFICATION (top-left) ===
    final bellBg = Paint()..color = AppColors.primaryContainer;
    canvas.drawCircle(Offset(w * 0.10, h * 0.18), w * 0.055, bellBg);

    // Bell icon
    final bellPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    final bellPath = Path()
      ..moveTo(w * 0.08, h * 0.19)
      ..quadraticBezierTo(w * 0.08, h * 0.15, w * 0.10, h * 0.15)
      ..quadraticBezierTo(w * 0.12, h * 0.15, w * 0.12, h * 0.19)
      ..lineTo(w * 0.07, h * 0.19);
    canvas.drawPath(bellPath, bellPaint);
    // Bell dot
    canvas.drawCircle(Offset(w * 0.12, h * 0.155), 3, Paint()..color = AppColors.danger);

    // === SPARKLES ===
    _drawStar4(canvas, Offset(w * 0.92, h * 0.20), 5,
        Paint()..color = AppColors.secondary..strokeWidth = 2.0..strokeCap = StrokeCap.round);
    _drawStar4(canvas, Offset(w * 0.06, h * 0.70), 4,
        Paint()..color = AppColors.primary..strokeWidth = 2.0..strokeCap = StrokeCap.round);
    _drawStar4(canvas, Offset(w * 0.55, h * 0.90), 5,
        Paint()..color = AppColors.warning..strokeWidth = 1.8..strokeCap = StrokeCap.round);

    canvas.drawCircle(Offset(w * 0.90, h * 0.75), 3, Paint()..color = AppColors.secondaryContainer);
    canvas.drawCircle(Offset(w * 0.04, h * 0.40), 2, Paint()..color = AppColors.primaryContainer);
  }

  void _drawStar4(Canvas canvas, Offset center, double radius, Paint paint) {
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - radius * 0.6, center.dy - radius * 0.6),
      Offset(center.dx + radius * 0.6, center.dy + radius * 0.6),
      paint..strokeWidth = 1.5,
    );
    canvas.drawLine(
      Offset(center.dx + radius * 0.6, center.dy - radius * 0.6),
      Offset(center.dx - radius * 0.6, center.dy + radius * 0.6),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// SPLASH LOGO ILLUSTRATION
// App logo with animated ring and building silhouette
// =============================================================================

class SplashLogoIllustration extends StatelessWidget {
  final double size;

  const SplashLogoIllustration({super.key, this.size = 160});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SplashLogoPainter(),
      ),
    );
  }
}

class _SplashLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Outer ring glow
    final ringGlow = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.42, ringGlow);

    // Outer ring
    final ringPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.38, ringPaint);

    // Inner circle fill
    final innerBg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primary,
          AppColors.primary.withValues(alpha: 0.85),
        ],
      ).createShader(Rect.fromCircle(center: Offset(w * 0.5, h * 0.5), radius: w * 0.30));
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.30, innerBg);

    // Building silhouette (white on terracotta)
    final buildPaint = Paint()..color = Colors.white;

    // Left building
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.30, h * 0.32, w * 0.14, h * 0.30),
        const Radius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
      ),
      buildPaint,
    );
    // Right building (taller)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.48, h * 0.26, w * 0.16, h * 0.36),
        const Radius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
      ),
      buildPaint,
    );

    // Windows on left building
    final windowPaint = Paint()..color = AppColors.primary;
    canvas.drawRect(Rect.fromLTWH(w * 0.33, h * 0.36, w * 0.035, h * 0.04), windowPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.38, h * 0.36, w * 0.035, h * 0.04), windowPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.33, h * 0.44, w * 0.035, h * 0.04), windowPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.38, h * 0.44, w * 0.035, h * 0.04), windowPaint);

    // Windows on right building
    canvas.drawRect(Rect.fromLTWH(w * 0.52, h * 0.30, w * 0.04, h * 0.04), windowPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.58, h * 0.30, w * 0.04, h * 0.04), windowPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.52, h * 0.38, w * 0.04, h * 0.04), windowPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.58, h * 0.38, w * 0.04, h * 0.04), windowPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.52, h * 0.46, w * 0.04, h * 0.04), windowPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.58, h * 0.46, w * 0.04, h * 0.04), windowPaint);

    // Location pin on top
    final pinPath = Path()
      ..addOval(Rect.fromCircle(center: Offset(w * 0.56, h * 0.20), radius: w * 0.04));
    canvas.drawPath(pinPath, Paint()..color = Colors.white);
    final pinTip = Path()
      ..moveTo(w * 0.535, h * 0.235)
      ..lineTo(w * 0.56, h * 0.28)
      ..lineTo(w * 0.585, h * 0.235);
    canvas.drawPath(pinTip, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(w * 0.56, h * 0.20), w * 0.018, Paint()..color = AppColors.primary);

    // Decorative arc at bottom
    final arcPaint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.5, h * 0.5), radius: w * 0.34),
      math.pi * 0.55,
      math.pi * 0.35,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
