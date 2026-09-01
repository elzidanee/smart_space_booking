import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../spaces/data/models/space_models.dart';
import '../providers/reservations_controller.dart';

/// Layar E-Ticket Digital sesuai Stitch Screen 09 (a4fe2ef1773c4b56afee8ae1115da513).
class ETicketScreen extends ConsumerWidget {
  final int? reservationId;

  const ETicketScreen({super.key, this.reservationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Jika reservationId diberikan, ambil detail reservasi tersebut.
    // Jika null (misal diakses via Shell Tab 3), ambil latest active ticket.
    final AsyncValue<ReservationModel?> ticketAsync = reservationId != null
        ? ref.watch(eTicketProvider(reservationId!)).whenData((data) => data)
        : ref.watch(latestActiveTicketProvider);

    return Scaffold(
      backgroundColor: AppColors.surface50,
      appBar: AppBar(
        backgroundColor: AppColors.surface0,
        elevation: 0,
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.ink900),
                onPressed: () => context.pop(),
              )
            : null,
        title: Text(
          'E-Ticket Digital',
          style: AppTypography.h3.copyWith(color: AppColors.ink900),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppColors.ink600),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tunjukkan QR Code ini ke resepsionis untuk verifikasi check-in.'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
        ],
      ),
      body: ticketAsync.when(
        data: (ticket) {
          if (ticket == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.confirmation_number_outlined,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md12),
                    Text('Belum Ada E-Ticket Aktif', style: AppTypography.h3),
                    const SizedBox(height: AppSpacing.xs4),
                    Text(
                      'Pemesanan yang telah disetujui akan menampilkan e-ticket QR di sini.',
                      style: AppTypography.caption,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg16),
                    ElevatedButton(
                      onPressed: () => context.go('/member'),
                      child: const Text('Jelajahi Ruangan'),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg16,
              AppSpacing.md12,
              AppSpacing.lg16,
              AppSpacing.xxl32,
            ),
            child: Column(
              children: [
                // ── Card Boarding Pass Perforated Ticket ─────────────────────
                _BoardingPassCard(ticket: ticket),
                const SizedBox(height: AppSpacing.xl24),

                // ── Action Buttons (Unduh & Bagikan) ─────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: ticket.kodeBooking));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Kode booking ${ticket.kodeBooking} disalin ke clipboard!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusField),
                          ),
                        ),
                        icon: const Icon(Icons.copy_rounded, color: AppColors.ink900, size: 18),
                        label: Text(
                          'Salin Kode',
                          style: AppTypography.bodyEmphasis.copyWith(color: AppColors.ink900),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('E-Ticket siap dibagikan.'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusField),
                          ),
                        ),
                        icon: const Icon(Icons.share_rounded, size: 18),
                        label: Text(
                          'Bagikan',
                          style: AppTypography.bodyEmphasis.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg16),

                // ── Check-in Instruction Footer ─────────────────────────────
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusField),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                      const SizedBox(width: AppSpacing.sm8),
                      Expanded(
                        child: Text(
                          'Tunjukkan QR Code ini ke petugas saat tiba di lokasi untuk proses check-in.',
                          style: AppTypography.captionMedium.copyWith(color: AppColors.ink900),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xl24),
            child: AppShimmer(height: 480),
          ),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl24),
            child: Text('Gagal memuat tiket: $err'),
          ),
        ),
      ),
    );
  }
}

/// Kartu Tiket Boarding-Pass dengan lubang perforasi di samping & dashed line di tengah
class _BoardingPassCard extends StatelessWidget {
  final ReservationModel ticket;

  const _BoardingPassCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    DateTime? parsedDate;
    try {
      parsedDate = DateTime.parse(ticket.tanggal);
    } catch (_) {}

    final dateDisplay = parsedDate != null
        ? DateFormatter.formatFullDate(parsedDate)
        : ticket.tanggal;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface0,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        boxShadow: AppSpacing.cardShadow,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // ── Bagian Atas: Status & QR Code ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl24,
              AppSpacing.xl24,
              AppSpacing.xl24,
              AppSpacing.md12,
            ),
            child: Column(
              children: [
                // Status Badge
                _buildStatusPill(ticket.status),
                const SizedBox(height: AppSpacing.lg16),

                // QR Code Container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: ticket.kodeBooking,
                    version: QrVersions.auto,
                    size: 190.0,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AppColors.ink900,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: AppColors.ink900,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md12),

                // Booking Code Label & Value
                Text(
                  'BOOKING CODE',
                  style: AppTypography.caption.copyWith(
                    letterSpacing: 1.2,
                    color: AppColors.ink600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ticket.kodeBooking,
                  style: AppTypography.h2.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // ── Bagian Perforasi (Cutout Lingkaran + Garis Putus-putus) ────────
          SizedBox(
            height: 32,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Dashed separator line
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomPaint(
                    size: const Size(double.infinity, 1),
                    painter: _DashedLinePainter(),
                  ),
                ),
                // Left Cutout Circle
                Positioned(
                  left: -12,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.surface50,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                  ),
                ),
                // Right Cutout Circle
                Positioned(
                  right: -12,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.surface50,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bagian Bawah: Rincian Reservasi ───────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl24,
              AppSpacing.sm8,
              AppSpacing.xl24,
              AppSpacing.xl24,
            ),
            child: Column(
              children: [
                _buildDetailRow('Ruangan / Space', ticket.namaSpace ?? 'Coworking Space'),
                const SizedBox(height: AppSpacing.sm8),
                _buildDetailRow('Tanggal', dateDisplay),
                const SizedBox(height: AppSpacing.sm8),
                _buildDetailRow('Jam Mulai - Selesai', '${ticket.jamMulai} - ${ticket.jamSelesai} WIB'),
                const SizedBox(height: AppSpacing.sm8),
                _buildDetailRow('Durasi', '${ticket.durasi} Jam'),
                if (ticket.namaMember != null && ticket.namaMember!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm8),
                  _buildDetailRow('Atas Nama', ticket.namaMember!),
                ],
                const SizedBox(height: AppSpacing.md12),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: AppSpacing.md12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.ink600),
                    ),
                    Text(
                      CurrencyFormatter.format(ticket.totalBayar),
                      style: AppTypography.h2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.ink600),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            style: AppTypography.bodyEmphasis.copyWith(color: AppColors.ink900),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPill(String status) {
    Color bg;
    Color text;
    String label;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'aktif':
        bg = AppColors.primaryContainer;
        text = AppColors.primary;
        icon = Icons.pin_drop_rounded;
        label = 'Sedang Aktif Digunakan';
        break;
      case 'disetujui':
        bg = const Color(0xFFE0F4F2);
        text = const Color(0xFF0E5C56);
        icon = Icons.check_circle_rounded;
        label = 'Disetujui - Siap Digunakan';
        break;
      case 'selesai':
        bg = const Color(0xFFD4E9DB);
        text = const Color(0xFF1E5631);
        icon = Icons.done_all_rounded;
        label = 'Selesai';
        break;
      case 'dibatalkan':
        bg = const Color(0xFFFFDAD6);
        text = AppColors.danger;
        icon = Icons.cancel_rounded;
        label = 'Dibatalkan';
        break;
      default:
        bg = const Color(0xFFFFF4E5);
        text = const Color(0xFFB26B00);
        icon = Icons.hourglass_empty_rounded;
        label = 'Menunggu Konfirmasi';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: text),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: text,
            ),
          ),
        ],
      ),
    );
  }
}

/// CustomPainter untuk membuat garis putus-putus (dashed line)
class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1.5;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
