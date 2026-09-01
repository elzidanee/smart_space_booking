import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Ilustrasi coworking space — digambar penuh dengan CustomPainter.
/// Menampilkan ruangan dengan jendela, meja kerja berderet, kursi, dan lampu gantung.
class CoworkingIllustration extends StatelessWidget {
  final double width;
  final double height;
  final bool isAdmin; // Jika true, warna aksen pakai Deep Teal (admin)

  const CoworkingIllustration({
    super.key,
    this.width = 280,
    this.height = 180,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _CoworkingPainter(isAdmin: isAdmin),
      ),
    );
  }
}

class _CoworkingPainter extends CustomPainter {
  final bool isAdmin;
  _CoworkingPainter({required this.isAdmin});

  Color get accent => isAdmin ? AppColors.secondary : AppColors.primary;
  Color get accentLight =>
      isAdmin ? const Color(0xFFDCEEEC) : const Color(0xFFFBE7D8);
  Color get accentMid =>
      isAdmin ? const Color(0xFF1A7A72) : const Color(0xFFD96A22);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Background dinding ──────────────────────────────────────────────────
    final wallPaint = Paint()..color = const Color(0xFFF5F0EB);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.72), wallPaint);

    // ── Lantai ──────────────────────────────────────────────────────────────
    final floorPaint = Paint()..color = const Color(0xFFEAE3D8);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.72, w, h * 0.28), floorPaint);

    // Garis-garis parket lantai
    final parketPaint = Paint()
      ..color = const Color(0xFFD9CFC2)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 5; i++) {
      final y = h * 0.72 + i * (h * 0.28 / 5);
      canvas.drawLine(Offset(0, y), Offset(w, y), parketPaint);
    }
    for (int i = 0; i < 8; i++) {
      final x = i * (w / 7);
      canvas.drawLine(Offset(x, h * 0.72), Offset(x, h), parketPaint);
    }

    // ── Jendela kiri (besar, ada curtain) ──────────────────────────────────
    _drawWindow(canvas, Offset(w * 0.05, h * 0.06), w * 0.22, h * 0.45);

    // ── Jendela kanan ──────────────────────────────────────────────────────
    _drawWindow(canvas, Offset(w * 0.73, h * 0.06), w * 0.22, h * 0.45);

    // ── Lampu gantung kiri ─────────────────────────────────────────────────
    _drawPendantLight(canvas, Offset(w * 0.28, 0), h, accent);

    // ── Lampu gantung kanan ────────────────────────────────────────────────
    _drawPendantLight(canvas, Offset(w * 0.67, 0), h, accentMid);

    // ── Meja kiri (personal desk) ──────────────────────────────────────────
    _drawDesk(canvas, Offset(w * 0.08, h * 0.60), w * 0.32, h, accent, accentLight);

    // ── Meja kanan ─────────────────────────────────────────────────────────
    _drawDesk(canvas, Offset(w * 0.58, h * 0.60), w * 0.32, h, accent, accentLight);

    // ── Meja tengah kecil (standing desk / divider) ────────────────────────
    _drawSmallDividerDesk(canvas, Offset(w * 0.42, h * 0.65), w, h, accent);

    // ── Tanaman pojok kiri bawah ────────────────────────────────────────────
    _drawPlant(canvas, Offset(w * 0.00, h * 0.58), h, accentLight, accent);

    // ── Label brand kecil (dekoratif, bukan teks penting) ──────────────────
    _drawLogo(canvas, Offset(w * 0.38, h * 0.08), w, accent);
  }

  // ── Jendela dengan bingkai & tirai ─────────────────────────────────────
  void _drawWindow(Canvas canvas, Offset tl, double ww, double wh) {
    // langit di luar jendela
    final skyPaint = Paint()..color = const Color(0xFFD6EAF8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tl.dx, tl.dy, ww, wh),
        const Radius.circular(4),
      ),
      skyPaint,
    );
    // Awan kecil
    _drawCloud(canvas, tl + Offset(ww * 0.15, wh * 0.2), ww * 0.55);

    // Bingkai jendela
    final framePaint = Paint()
      ..color = const Color(0xFFBFAA96)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tl.dx, tl.dy, ww, wh),
        const Radius.circular(4),
      ),
      framePaint,
    );
    // Garis tengah jendela (pembagi)
    canvas.drawLine(
      tl + Offset(ww / 2, 0),
      tl + Offset(ww / 2, wh),
      framePaint,
    );
    canvas.drawLine(
      tl + Offset(0, wh * 0.45),
      tl + Offset(ww, wh * 0.45),
      framePaint,
    );

    // Tirai kiri
    _drawCurtain(canvas, tl, ww * 0.22, wh, const Color(0xFFD4A87A), isLeft: true);
    // Tirai kanan
    _drawCurtain(
      canvas,
      tl + Offset(ww - ww * 0.22, 0),
      ww * 0.22,
      wh,
      const Color(0xFFD4A87A),
      isLeft: false,
    );
  }

  void _drawCloud(Canvas canvas, Offset center, double cloudW) {
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    final r = cloudW * 0.2;
    canvas.drawCircle(center + Offset(cloudW * 0.12, r * 0.5), r * 0.85, cloudPaint);
    canvas.drawCircle(center + Offset(cloudW * 0.38, 0), r, cloudPaint);
    canvas.drawCircle(center + Offset(cloudW * 0.62, r * 0.3), r * 0.75, cloudPaint);
    canvas.drawRect(
      Rect.fromLTWH(center.dx + cloudW * 0.07, center.dy + r * 0.35, cloudW * 0.6, r * 0.7),
      cloudPaint,
    );
  }

  void _drawCurtain(Canvas canvas, Offset tl, double cw, double ch, Color color,
      {required bool isLeft}) {
    final path = Path();
    if (isLeft) {
      path.moveTo(tl.dx, tl.dy);
      path.quadraticBezierTo(
        tl.dx + cw * 0.8, tl.dy + ch * 0.3,
        tl.dx + cw, tl.dy + ch,
      );
      path.lineTo(tl.dx, tl.dy + ch);
    } else {
      path.moveTo(tl.dx + cw, tl.dy);
      path.quadraticBezierTo(
        tl.dx + cw * 0.2, tl.dy + ch * 0.3,
        tl.dx, tl.dy + ch,
      );
      path.lineTo(tl.dx + cw, tl.dy + ch);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.75));

    // Garis lipatan tirai
    final foldPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (int i = 1; i <= 3; i++) {
      final t = i / 4.0;
      if (isLeft) {
        canvas.drawLine(
          tl + Offset(cw * t * 0.4, ch * t * 0.5),
          tl + Offset(cw * (0.6 + t * 0.1), ch * (0.5 + t * 0.4)),
          foldPaint,
        );
      } else {
        canvas.drawLine(
          tl + Offset(cw * (1 - t * 0.4), ch * t * 0.5),
          tl + Offset(cw * (0.4 - t * 0.1), ch * (0.5 + t * 0.4)),
          foldPaint,
        );
      }
    }
  }

  // ── Lampu gantung (pendant light) ──────────────────────────────────────
  void _drawPendantLight(Canvas canvas, Offset topCenter, double h, Color accent) {
    final cordPaint = Paint()
      ..color = const Color(0xFF8C7B6E)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    // Kabel
    canvas.drawLine(topCenter, topCenter + Offset(0, h * 0.28), cordPaint);

    final shadeTip = topCenter + Offset(0, h * 0.28);
    // Kap lampu (trapesium terbalik → ellipse atas kecil, bawah lebih lebar)
    final shadePaint = Paint()..color = const Color(0xFFD4A055);
    final shadePath = Path()
      ..moveTo(shadeTip.dx - 10, shadeTip.dy)
      ..lineTo(shadeTip.dx + 10, shadeTip.dy)
      ..lineTo(shadeTip.dx + 18, shadeTip.dy + 22)
      ..lineTo(shadeTip.dx - 18, shadeTip.dy + 22)
      ..close();
    canvas.drawPath(shadePath, shadePaint);

    // Highlight kap
    canvas.drawPath(
      shadePath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Cahaya (radial gradient halo di lantai)
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [accent.withValues(alpha: 0.12), Colors.transparent],
      ).createShader(Rect.fromCircle(
        center: Offset(shadeTip.dx, h * 0.82),
        radius: 45,
      ));
    canvas.drawCircle(Offset(shadeTip.dx, h * 0.82), 45, glowPaint);
  }

  // ── Meja kerja dengan monitor & keyboard ───────────────────────────────
  void _drawDesk(Canvas canvas, Offset tl, double dw, double totalH,
      Color accent, Color accentLight) {
    final floorY = totalH * 0.72;

    // Kaki meja (2 kaki)
    final legPaint = Paint()..color = const Color(0xFF8C7B6E);
    canvas.drawRect(Rect.fromLTWH(tl.dx + dw * 0.12, floorY - 2, 5, totalH - floorY + 2), legPaint);
    canvas.drawRect(Rect.fromLTWH(tl.dx + dw * 0.82, floorY - 2, 5, totalH - floorY + 2), legPaint);

    // Permukaan meja
    final topPaint = Paint()..color = const Color(0xFFBEA98A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tl.dx, tl.dy, dw, 8),
        const Radius.circular(3),
      ),
      topPaint,
    );
    // Tepi bawah meja (ketebalan)
    canvas.drawRect(
      Rect.fromLTWH(tl.dx + 2, tl.dy + 7, dw - 4, 4),
      Paint()..color = const Color(0xFFA08A6E),
    );

    // Monitor (layar)
    final monitorX = tl.dx + dw * 0.25;
    final monitorY = tl.dy - 42;
    final monitorW = dw * 0.5;
    // badan monitor
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(monitorX, monitorY, monitorW, 32),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF3D3530),
    );
    // layar monitor
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(monitorX + 3, monitorY + 3, monitorW - 6, 26),
        const Radius.circular(2),
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accentLight, accentLight.withValues(alpha: 0.5)],
        ).createShader(Rect.fromLTWH(monitorX, monitorY, monitorW, 32)),
    );
    // konten mock layar (garis-garis UI)
    final uiLinePaint = Paint()
      ..color = accent.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(monitorX + 6, monitorY + 9),
      Offset(monitorX + monitorW - 6, monitorY + 9),
      uiLinePaint,
    );
    canvas.drawLine(
      Offset(monitorX + 6, monitorY + 16),
      Offset(monitorX + monitorW * 0.65, monitorY + 16),
      Paint()
        ..color = accent.withValues(alpha: 0.35)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );

    // Kaki monitor (tiang & base)
    canvas.drawRect(
      Rect.fromLTWH(monitorX + monitorW * 0.45, monitorY + 32, monitorW * 0.1, 8),
      Paint()..color = const Color(0xFF3D3530),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(monitorX + monitorW * 0.3, tl.dy - 2, monitorW * 0.4, 3),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF3D3530),
    );

    // Keyboard
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tl.dx + dw * 0.15, tl.dy - 5, dw * 0.7, 5),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF4A403A),
    );

    // Cangkir kopi di pojok
    _drawCoffeeCup(canvas, Offset(tl.dx + dw * 0.82, tl.dy - 14), accent);

    // Kursi (depan meja)
    _drawChair(canvas, Offset(tl.dx + dw * 0.3, floorY + 4), dw * 0.4, totalH, accent);
  }

  void _drawCoffeeCup(Canvas canvas, Offset base, Color accent) {
    // Badan cangkir
    final cupPaint = Paint()..color = Colors.white;
    final cupPath = Path()
      ..moveTo(base.dx, base.dy)
      ..lineTo(base.dx + 2, base.dy + 12)
      ..lineTo(base.dx + 12, base.dy + 12)
      ..lineTo(base.dx + 14, base.dy)
      ..close();
    canvas.drawPath(cupPath, cupPaint);
    canvas.drawPath(
      cupPath,
      Paint()
        ..color = const Color(0xFFCCC0B0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    // Uap kopi (kurva kecil)
    final steamPaint = Paint()
      ..color = const Color(0xFFCCC0B0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawArc(
      Rect.fromLTWH(base.dx + 3, base.dy - 8, 4, 7),
      math.pi, math.pi, false, steamPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(base.dx + 7, base.dy - 8, 4, 7),
      math.pi, math.pi, false, steamPaint,
    );
    // Handle cangkir
    canvas.drawArc(
      Rect.fromLTWH(base.dx + 12, base.dy + 2, 6, 6),
      -math.pi / 2, math.pi, false,
      Paint()
        ..color = const Color(0xFFCCC0B0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    // Isi kopi
    canvas.drawRect(
      Rect.fromLTWH(base.dx + 2, base.dy + 1, 10, 3),
      Paint()..color = const Color(0xFF6B3D1E),
    );
  }

  void _drawChair(Canvas canvas, Offset tl, double cw, double totalH, Color accent) {
    final floorY = totalH * 0.72;
    // Sandaran
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tl.dx, tl.dy + 2, cw, 16),
        const Radius.circular(4),
      ),
      Paint()..color = accent.withValues(alpha: 0.18),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tl.dx, tl.dy + 2, cw, 16),
        const Radius.circular(4),
      ),
      Paint()
        ..color = accent.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    // Dudukan
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tl.dx + 1, tl.dy + 18, cw - 2, 8),
        const Radius.circular(3),
      ),
      Paint()..color = accent.withValues(alpha: 0.25),
    );
    // Kaki kursi (4 kaki)
    final legPaint = Paint()
      ..color = const Color(0xFF8C7B6E)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(tl.dx + 4, tl.dy + 26),
      Offset(tl.dx + 2, floorY + totalH * 0.08),
      legPaint,
    );
    canvas.drawLine(
      Offset(tl.dx + cw - 4, tl.dy + 26),
      Offset(tl.dx + cw - 2, floorY + totalH * 0.08),
      legPaint,
    );
  }

  // ── Meja divider di tengah (narrow) ────────────────────────────────────
  void _drawSmallDividerDesk(Canvas canvas, Offset tl, double totalW, double totalH, Color accent) {
    final floorY = totalH * 0.72;
    // Tiang/kaki
    canvas.drawRect(
      Rect.fromLTWH(tl.dx + 2, floorY - 2, 4, totalH - floorY + 2),
      Paint()..color = const Color(0xFF8C7B6E),
    );
    // Permukaan
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tl.dx - 8, tl.dy, 24, 5),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFBEA98A),
    );
    // Tanaman mini di atas meja
    _drawMiniPlant(canvas, Offset(tl.dx - 2, tl.dy - 14), accent);
  }

  // ── Tanaman pojok ────────────────────────────────────────────────────────
  void _drawPlant(Canvas canvas, Offset base, double totalH, Color lightColor, Color darkColor) {
    final floorY = totalH * 0.72;
    // Pot
    final potPath = Path()
      ..moveTo(base.dx + 2, floorY - 18)
      ..lineTo(base.dx, floorY)
      ..lineTo(base.dx + 20, floorY)
      ..lineTo(base.dx + 18, floorY - 18)
      ..close();
    canvas.drawPath(potPath, Paint()..color = const Color(0xFFB07A45));
    canvas.drawPath(
      potPath,
      Paint()
        ..color = const Color(0xFF8C5E30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    // Tanah
    canvas.drawOval(
      Rect.fromLTWH(base.dx, floorY - 22, 20, 8),
      Paint()..color = const Color(0xFF6B4423),
    );
    // Daun-daun (cabang)
    final leafPaint = Paint()..color = const Color(0xFF4A7C59);
    final leafLightPaint = Paint()..color = const Color(0xFF6AAF78);
    // Batang
    canvas.drawLine(
      Offset(base.dx + 10, floorY - 22),
      Offset(base.dx + 10, floorY - 50),
      Paint()
        ..color = const Color(0xFF5A7A3A)
        ..strokeWidth = 2,
    );
    // Daun kiri bawah
    canvas.drawOval(
      Rect.fromLTWH(base.dx - 6, floorY - 48, 18, 12),
      leafPaint,
    );
    // Daun kanan bawah
    canvas.drawOval(
      Rect.fromLTWH(base.dx + 4, floorY - 52, 18, 12),
      leafLightPaint,
    );
    // Daun atas kiri
    canvas.drawOval(
      Rect.fromLTWH(base.dx - 8, floorY - 65, 16, 10),
      leafLightPaint,
    );
    // Daun atas tengah
    canvas.drawOval(
      Rect.fromLTWH(base.dx + 2, floorY - 70, 16, 10),
      leafPaint,
    );
  }

  void _drawMiniPlant(Canvas canvas, Offset base, Color accent) {
    // Pot kecil
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(base.dx + 1, base.dy + 8, 10, 7),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFB07A45),
    );
    // Daun
    canvas.drawOval(
      Rect.fromLTWH(base.dx - 1, base.dy, 7, 10),
      Paint()..color = const Color(0xFF4A7C59),
    );
    canvas.drawOval(
      Rect.fromLTWH(base.dx + 5, base.dy + 2, 7, 8),
      Paint()..color = const Color(0xFF6AAF78),
    );
  }

  // ── Logo/wordmark dekoratif kecil di dinding ───────────────────────────
  void _drawLogo(Canvas canvas, Offset center, double w, Color accent) {
    // Kotak kecil dekoratif (seperti signage di dinding coworking)
    final bgRect = Rect.fromCenter(center: center, width: 72, height: 22);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(6)),
      Paint()..color = accent.withValues(alpha: 0.12),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(6)),
      Paint()
        ..color = accent.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    // Titik dekoratif (3 dot seperti logo brand sederhana)
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(center.dx - 12 + i * 12.0, center.dy),
        3,
        Paint()..color = accent.withValues(alpha: 0.6),
      );
    }
  }

  @override
  bool shouldRepaint(_CoworkingPainter oldDelegate) =>
      oldDelegate.isAdmin != isAdmin;
}

// ─── Ilustrasi khusus layar Register Admin (gedung dari luar) ─────────────

/// Ilustrasi gedung coworking dari luar, untuk layar daftar pengelola space.
class BuildingIllustration extends StatelessWidget {
  final double width;
  final double height;

  const BuildingIllustration({
    super.key,
    this.width = 280,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _BuildingPainter()),
    );
  }
}

class _BuildingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Langit gradien
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFFBFD9F0), const Color(0xFFE8F4F8)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.65), skyPaint);

    // Trotoar / jalan
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.82, w, h * 0.18),
      Paint()..color = const Color(0xFFD4CCC4),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.65, w, h * 0.17),
      Paint()..color = const Color(0xFFBEB6AE),
    );
    // Garis trotoar
    for (int i = 0; i < 8; i++) {
      canvas.drawRect(
        Rect.fromLTWH(i * (w / 7) - 3, h * 0.65, w / 14, h * 0.17),
        Paint()..color = const Color(0xFFCCC4BC),
      );
    }

    // Gedung utama (tengah)
    _drawMainBuilding(canvas, w, h);

    // Gedung kecil kiri
    _drawSideBuilding(canvas, Offset(0, h * 0.32), w * 0.18, h * 0.33, w, h,
        const Color(0xFFD4CCC4));

    // Gedung kecil kanan
    _drawSideBuilding(canvas, Offset(w * 0.80, h * 0.38), w * 0.2, h * 0.27, w, h,
        const Color(0xFFCAC2BA));

    // Pohon kiri
    _drawTree(canvas, Offset(w * 0.07, h * 0.55), h);
    // Pohon kanan
    _drawTree(canvas, Offset(w * 0.87, h * 0.58), h);

    // Awan
    _drawCloudShape(canvas, Offset(w * 0.1, h * 0.06), w * 0.28);
    _drawCloudShape(canvas, Offset(w * 0.60, h * 0.03), w * 0.22);
  }

  void _drawMainBuilding(Canvas canvas, double w, double h) {
    // Badan gedung
    final buildPaint = Paint()..color = const Color(0xFFE8E0D4);
    canvas.drawRect(
      Rect.fromLTWH(w * 0.22, h * 0.12, w * 0.56, h * 0.53),
      buildPaint,
    );

    // Atap / entablature
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.19, h * 0.08, w * 0.62, h * 0.07),
        const Radius.circular(3),
      ),
      Paint()..color = AppColors.secondary,
    );

    // Nama space (signage)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.31, h * 0.16, w * 0.38, h * 0.09),
        const Radius.circular(4),
      ),
      Paint()..color = AppColors.secondaryContainer,
    );
    // Garis-garis mock teks signage
    final signPaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(w * 0.35, h * 0.195),
      Offset(w * 0.65, h * 0.195),
      signPaint,
    );
    canvas.drawLine(
      Offset(w * 0.39, h * 0.225),
      Offset(w * 0.61, h * 0.225),
      Paint()
        ..color = AppColors.secondary.withValues(alpha: 0.4)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );

    // Pintu utama
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.42, h * 0.46, w * 0.16, h * 0.19),
        const Radius.circular(3),
      ),
      Paint()..color = AppColors.secondary,
    );
    // Handle pintu
    canvas.drawCircle(
      Offset(w * 0.545, h * 0.555),
      3,
      Paint()..color = const Color(0xFFD4A055),
    );

    // Jendela baris pertama
    for (int i = 0; i < 4; i++) {
      if (i == 1 || i == 2) continue; // skip posisi pintu
      final wx = w * 0.25 + i * w * 0.14;
      _drawBuildingWindow(canvas, Offset(wx, h * 0.29), w * 0.09, h * 0.1);
    }
    // Jendela baris kedua
    for (int i = 0; i < 4; i++) {
      final wx = w * 0.25 + i * w * 0.14;
      _drawBuildingWindow(canvas, Offset(wx, h * 0.43), w * 0.09, h * 0.09);
    }
  }

  void _drawBuildingWindow(Canvas canvas, Offset tl, double ww, double wh) {
    // Frame jendela
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tl.dx, tl.dy, ww, wh),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFD6EAF8),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tl.dx, tl.dy, ww, wh),
        const Radius.circular(2),
      ),
      Paint()
        ..color = const Color(0xFFBFAA96)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    // Silang jendela
    canvas.drawLine(
      tl + Offset(ww / 2, 0),
      tl + Offset(ww / 2, wh),
      Paint()
        ..color = const Color(0xFFBFAA96)
        ..strokeWidth = 1,
    );
    canvas.drawLine(
      tl + Offset(0, wh * 0.5),
      tl + Offset(ww, wh * 0.5),
      Paint()
        ..color = const Color(0xFFBFAA96)
        ..strokeWidth = 1,
    );
  }

  void _drawSideBuilding(Canvas canvas, Offset tl, double bw, double bh,
      double totalW, double totalH, Color color) {
    canvas.drawRect(Rect.fromLTWH(tl.dx, tl.dy, bw, bh), Paint()..color = color);
    // Jendela kecil
    for (int row = 0; row < 2; row++) {
      for (int col = 0; col < 2; col++) {
        final wx = tl.dx + col * bw * 0.48 + bw * 0.1;
        final wy = tl.dy + row * bh * 0.4 + bh * 0.08;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(wx, wy, bw * 0.3, bh * 0.22),
            const Radius.circular(2),
          ),
          Paint()..color = const Color(0xFFD6EAF8),
        );
      }
    }
  }

  void _drawTree(Canvas canvas, Offset base, double h) {
    // Batang
    canvas.drawRect(
      Rect.fromLTWH(base.dx - 4, base.dy - 4, 8, h * 0.15),
      Paint()..color = const Color(0xFF8B6343),
    );
    // Mahkota (3 lingkaran bertumpuk)
    canvas.drawCircle(
      base + Offset(0, -h * 0.08),
      h * 0.09,
      Paint()..color = const Color(0xFF3D6B45),
    );
    canvas.drawCircle(
      base + Offset(-h * 0.04, -h * 0.14),
      h * 0.08,
      Paint()..color = const Color(0xFF4E8A58),
    );
    canvas.drawCircle(
      base + Offset(h * 0.04, -h * 0.16),
      h * 0.075,
      Paint()..color = const Color(0xFF3D6B45),
    );
  }

  void _drawCloudShape(Canvas canvas, Offset tl, double cw) {
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    final r = cw * 0.22;
    canvas.drawCircle(tl + Offset(cw * 0.18, r * 0.6), r * 0.8, cloudPaint);
    canvas.drawCircle(tl + Offset(cw * 0.42, 0), r, cloudPaint);
    canvas.drawCircle(tl + Offset(cw * 0.68, r * 0.4), r * 0.75, cloudPaint);
    canvas.drawRect(
      Rect.fromLTWH(tl.dx + cw * 0.12, tl.dy + r * 0.4, cw * 0.62, r * 0.65),
      cloudPaint,
    );
  }

  @override
  bool shouldRepaint(_BuildingPainter oldDelegate) => false;
}
