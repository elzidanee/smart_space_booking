import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

// =============================================================================
// REUSABLE EMPTY STATE WIDGET (PRD Bagian III §6)
// =============================================================================

class AppEmptyState extends StatelessWidget {
  final Widget illustration;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color actionColor;

  const AppEmptyState({
    super.key,
    required this.illustration,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.actionColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            illustration,
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTypography.h2.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                message,
                style: AppTypography.caption.copyWith(
                  color: AppColors.ink600,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: actionColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  actionLabel!,
                  style: AppTypography.bodyEmphasis.copyWith(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 1. EMPTY RESERVATIONS ILLUSTRATION
//    Desk notebook + coffee mug + potted plant with terracotta & teal accents
// =============================================================================

class EmptyReservationsIllustration extends StatelessWidget {
  final double size;

  const EmptyReservationsIllustration({super.key, this.size = 180});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.85,
      child: CustomPaint(
        painter: _EmptyReservationsPainter(),
      ),
    );
  }
}

class _EmptyReservationsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background circle aura
    final auraPaint = Paint()..color = AppColors.primaryContainer.withValues(alpha: 0.5);
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.38, auraPaint);

    // Desk surface / base line
    final deskPaint = Paint()
      ..color = const Color(0xFFE2DDD7)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.1, h * 0.78), Offset(w * 0.9, h * 0.78), deskPaint);

    // Notebook (Agenda)
    final bookShadow = Paint()..color = const Color(0xFFD6CFC7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.28, h * 0.38, w * 0.44, h * 0.40),
        const Radius.circular(8),
      ),
      bookShadow,
    );

    final bookPaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.26, h * 0.36, w * 0.44, h * 0.40),
        const Radius.circular(8),
      ),
      bookPaint,
    );

    // Notebook bookmark ribbon (Terracotta)
    final ribbonPaint = Paint()..color = AppColors.primary;
    final ribbonPath = Path()
      ..moveTo(w * 0.34, h * 0.36)
      ..lineTo(w * 0.34, h * 0.72)
      ..lineTo(w * 0.38, h * 0.68)
      ..lineTo(w * 0.42, h * 0.72)
      ..lineTo(w * 0.42, h * 0.36)
      ..close();
    canvas.drawPath(ribbonPath, ribbonPaint);

    // Notebook lines
    final linePaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.46, h * 0.44), Offset(w * 0.63, h * 0.44), linePaint);
    canvas.drawLine(Offset(w * 0.46, h * 0.52), Offset(w * 0.63, h * 0.52), linePaint);
    canvas.drawLine(Offset(w * 0.46, h * 0.60), Offset(w * 0.58, h * 0.60), linePaint);

    // Coffee Mug (Teal)
    final mugPaint = Paint()..color = AppColors.secondary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.16, h * 0.56, w * 0.11, h * 0.22),
        const Radius.circular(4),
      ),
      mugPaint,
    );

    // Mug handle
    final handlePaint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawArc(
      Rect.fromLTWH(w * 0.12, h * 0.60, w * 0.08, h * 0.12),
      math.pi / 2,
      math.pi,
      false,
      handlePaint,
    );

    // Coffee steam
    final steamPaint = Paint()
      ..color = AppColors.ink300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final steamPath = Path()
      ..moveTo(w * 0.20, h * 0.52)
      ..quadraticBezierTo(w * 0.18, h * 0.47, w * 0.21, h * 0.43);
    canvas.drawPath(steamPath, steamPaint);

    // Potted plant on right
    final potPaint = Paint()..color = const Color(0xFF8C7A6B);
    final potPath = Path()
      ..moveTo(w * 0.74, h * 0.62)
      ..lineTo(w * 0.84, h * 0.62)
      ..lineTo(w * 0.81, h * 0.78)
      ..lineTo(w * 0.77, h * 0.78)
      ..close();
    canvas.drawPath(potPath, potPaint);

    // Plant leaves (Green)
    final leafPaint = Paint()..color = AppColors.success;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.76, h * 0.55), width: w * 0.08, height: h * 0.12),
      leafPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.82, h * 0.54), width: w * 0.07, height: h * 0.14),
      leafPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.79, h * 0.48), width: w * 0.06, height: h * 0.13),
      Paint()..color = const Color(0xFF439A65),
    );

    // Floating sparkles
    final sparklePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    _drawSparkle(canvas, Offset(w * 0.70, h * 0.28), 6, sparklePaint);
    _drawSparkle(canvas, Offset(w * 0.22, h * 0.32), 4, Paint()..color = AppColors.secondary);
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius, Paint paint) {
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// 2. EMPTY SPACES ILLUSTRATION
//    Modern workstation, desk lamp, and ergonomic chair
// =============================================================================

class EmptySpacesIllustration extends StatelessWidget {
  final double size;

  const EmptySpacesIllustration({super.key, this.size = 180});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.85,
      child: CustomPaint(
        painter: _EmptySpacesPainter(),
      ),
    );
  }
}

class _EmptySpacesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background soft circle
    final bgPaint = Paint()..color = AppColors.secondaryContainer.withValues(alpha: 0.55);
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.38, bgPaint);

    // Desk baseline
    final linePaint = Paint()
      ..color = const Color(0xFFDCD6CF)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.12, h * 0.80), Offset(w * 0.88, h * 0.80), linePaint);

    // Work desk
    final deskPaint = Paint()..color = const Color(0xFFC7B299);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.24, h * 0.56, w * 0.52, h * 0.05),
        const Radius.circular(3),
      ),
      deskPaint,
    );

    // Desk legs
    final legPaint = Paint()
      ..color = AppColors.ink900
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.28, h * 0.61), Offset(w * 0.28, h * 0.80), legPaint);
    canvas.drawLine(Offset(w * 0.72, h * 0.61), Offset(w * 0.72, h * 0.80), legPaint);

    // Laptop on desk
    final laptopBase = Paint()..color = const Color(0xFF78716C);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.42, h * 0.54, w * 0.16, h * 0.02),
        const Radius.circular(2),
      ),
      laptopBase,
    );

    final laptopScreen = Paint()..color = AppColors.secondary;
    final screenPath = Path()
      ..moveTo(w * 0.44, h * 0.54)
      ..lineTo(w * 0.46, h * 0.42)
      ..lineTo(w * 0.56, h * 0.42)
      ..lineTo(w * 0.56, h * 0.54)
      ..close();
    canvas.drawPath(screenPath, laptopScreen);

    // Desk Lamp (Terracotta)
    final lampPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final lampPath = Path()
      ..moveTo(w * 0.32, h * 0.56)
      ..lineTo(w * 0.32, h * 0.42)
      ..lineTo(w * 0.38, h * 0.36);
    canvas.drawPath(lampPath, lampPaint);

    // Lamp shade
    final shadePaint = Paint()..color = AppColors.primary;
    final shadePath = Path()
      ..moveTo(w * 0.35, h * 0.36)
      ..lineTo(w * 0.42, h * 0.34)
      ..lineTo(w * 0.40, h * 0.40)
      ..close();
    canvas.drawPath(shadePath, shadePaint);

    // Lamp light glow cone
    final glowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primaryContainer.withValues(alpha: 0.6),
          AppColors.primaryContainer.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(w * 0.34, h * 0.38, w * 0.20, h * 0.20));
    final glowPath = Path()
      ..moveTo(w * 0.38, h * 0.38)
      ..lineTo(w * 0.48, h * 0.56)
      ..lineTo(w * 0.34, h * 0.56)
      ..close();
    canvas.drawPath(glowPath, glowPaint);

    // Ergonomic Chair outline behind/around desk
    final chairPaint = Paint()
      ..color = AppColors.ink600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.62, h * 0.44, w * 0.12, h * 0.16),
        const Radius.circular(6),
      ),
      chairPaint,
    );
    canvas.drawLine(Offset(w * 0.68, h * 0.60), Offset(w * 0.68, h * 0.72), chairPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// 3. EMPTY PROMO / DISCOUNT ILLUSTRATION
//    Voucher coupon with starbursts and terracotta badge
// =============================================================================

class EmptyPromoIllustration extends StatelessWidget {
  final double size;

  const EmptyPromoIllustration({super.key, this.size = 180});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.85,
      child: CustomPaint(
        painter: _EmptyPromoPainter(),
      ),
    );
  }
}

class _EmptyPromoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background circle
    final bgPaint = Paint()..color = AppColors.primaryContainer.withValues(alpha: 0.5);
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.38, bgPaint);

    // Ticket Background (Rotated slightly)
    canvas.save();
    canvas.translate(w * 0.5, h * 0.5);
    canvas.rotate(-0.06);
    canvas.translate(-w * 0.5, -h * 0.5);

    final ticketShadow = Paint()..color = const Color(0xFFD5CDC5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.22, h * 0.33, w * 0.56, h * 0.36),
        const Radius.circular(12),
      ),
      ticketShadow,
    );

    final ticketPaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.20, h * 0.31, w * 0.56, h * 0.36),
        const Radius.circular(12),
      ),
      ticketPaint,
    );

    // Dashed divider inside ticket
    final dashPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    for (double y = h * 0.35; y < h * 0.63; y += 8) {
      canvas.drawLine(Offset(w * 0.40, y), Offset(w * 0.40, y + 4), dashPaint);
    }

    // Percentage circle badge
    final pctBadge = Paint()..color = AppColors.primary;
    canvas.drawCircle(Offset(w * 0.30, h * 0.49), w * 0.07, pctBadge);

    // Percent symbol
    final pctTextPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.27, h * 0.52), Offset(w * 0.33, h * 0.46), pctTextPaint);
    canvas.drawCircle(Offset(w * 0.28, h * 0.46), 2, pctTextPaint);
    canvas.drawCircle(Offset(w * 0.32, h * 0.52), 2, pctTextPaint);

    // Text bar placeholders on the right
    final textBar1 = Paint()..color = AppColors.ink900;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.44, h * 0.42, w * 0.26, h * 0.04),
        const Radius.circular(2),
      ),
      textBar1,
    );

    final textBar2 = Paint()..color = AppColors.ink300;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.44, h * 0.50, w * 0.18, h * 0.03),
        const Radius.circular(2),
      ),
      textBar2,
    );

    canvas.restore();

    // Floating celebration stars
    final starPaint = Paint()
      ..color = AppColors.warning
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    _drawSparkle(canvas, Offset(w * 0.22, h * 0.24), 7, starPaint);
    _drawSparkle(canvas, Offset(w * 0.78, h * 0.28), 6, Paint()..color = AppColors.secondary);
    _drawSparkle(canvas, Offset(w * 0.80, h * 0.68), 5, Paint()..color = AppColors.primary);
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius, Paint paint) {
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// 4. EMPTY MEMBERS / COMMUNITY ILLUSTRATION
//    Collaborative workspace member avatars and ID badge
// =============================================================================

class EmptyMembersIllustration extends StatelessWidget {
  final double size;

  const EmptyMembersIllustration({super.key, this.size = 180});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.85,
      child: CustomPaint(
        painter: _EmptyMembersPainter(),
      ),
    );
  }
}

class _EmptyMembersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background circle
    final bgPaint = Paint()..color = AppColors.secondaryContainer.withValues(alpha: 0.5);
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.38, bgPaint);

    // ID Badge card
    final cardShadow = Paint()..color = const Color(0xFFD6CFC7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.32, h * 0.28, w * 0.36, h * 0.48),
        const Radius.circular(10),
      ),
      cardShadow,
    );

    final cardPaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.30, h * 0.26, w * 0.36, h * 0.48),
        const Radius.circular(10),
      ),
      cardPaint,
    );

    // Badge lanyard hole
    final holePaint = Paint()..color = AppColors.ink300;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.44, h * 0.29, w * 0.08, h * 0.02),
        const Radius.circular(2),
      ),
      holePaint,
    );

    // Member avatar circle inside badge
    final avatarPaint = Paint()..color = AppColors.secondary;
    canvas.drawCircle(Offset(w * 0.48, h * 0.42), w * 0.08, avatarPaint);

    final facePaint = Paint()..color = AppColors.secondaryContainer;
    canvas.drawCircle(Offset(w * 0.48, h * 0.40), w * 0.045, facePaint);

    // Member name & ID lines
    final nameLine = Paint()..color = AppColors.ink900;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.37, h * 0.54, w * 0.22, h * 0.03),
        const Radius.circular(2),
      ),
      nameLine,
    );

    final subLine = Paint()..color = AppColors.ink300;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.40, h * 0.60, w * 0.16, h * 0.025),
        const Radius.circular(2),
      ),
      subLine,
    );

    // Side avatar bubbles (collaborators)
    final bubble1 = Paint()..color = AppColors.primaryContainer;
    canvas.drawCircle(Offset(w * 0.22, h * 0.52), w * 0.07, bubble1);
    canvas.drawCircle(Offset(w * 0.22, h * 0.50), w * 0.035, Paint()..color = AppColors.primary);

    final bubble2 = Paint()..color = AppColors.secondaryContainer;
    canvas.drawCircle(Offset(w * 0.76, h * 0.48), w * 0.07, bubble2);
    canvas.drawCircle(Offset(w * 0.76, h * 0.46), w * 0.035, Paint()..color = AppColors.secondary);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// 5. NETWORK ERROR / OFFLINE ILLUSTRATION
//    Cloud & reconnect plug with warm alert styling
// =============================================================================

class NetworkErrorIllustration extends StatelessWidget {
  final double size;

  const NetworkErrorIllustration({super.key, this.size = 180});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.85,
      child: CustomPaint(
        painter: _NetworkErrorPainter(),
      ),
    );
  }
}

class _NetworkErrorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background circle
    final bgPaint = Paint()..color = const Color(0xFFFDE8E8);
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.38, bgPaint);

    // Disconnected cloud
    final cloudPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.42, h * 0.42), w * 0.12, cloudPaint);
    canvas.drawCircle(Offset(w * 0.56, h * 0.40), w * 0.14, cloudPaint);
    canvas.drawCircle(Offset(w * 0.66, h * 0.46), w * 0.10, cloudPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.36, h * 0.44, w * 0.38, h * 0.14),
        const Radius.circular(8),
      ),
      cloudPaint,
    );

    // Warning exclamation badge
    final alertBg = Paint()..color = AppColors.danger;
    canvas.drawCircle(Offset(w * 0.52, h * 0.46), w * 0.07, alertBg);

    final alertText = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.52, h * 0.42), Offset(w * 0.52, h * 0.47), alertText);
    canvas.drawCircle(Offset(w * 0.52, h * 0.50), 1.5, alertText);

    // Broken wifi signal waves below
    final wavePaint = Paint()
      ..color = AppColors.ink300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.52, h * 0.68), width: w * 0.24, height: h * 0.20),
      math.pi * 1.2,
      math.pi * 0.6,
      false,
      wavePaint,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.52, h * 0.70), width: w * 0.14, height: h * 0.12),
      math.pi * 1.2,
      math.pi * 0.6,
      false,
      wavePaint,
    );
    canvas.drawCircle(Offset(w * 0.52, h * 0.72), 2.5, Paint()..color = AppColors.ink600);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
