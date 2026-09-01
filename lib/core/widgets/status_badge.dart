import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Enum 5 status reservasi resmi sesuai PRD Bagian II §7 & Bagian III §2.5a.
enum ReservasiStatus {
  belumDikonfirm,
  disetujui,
  aktif,
  selesai,
  dibatalkan;

  static ReservasiStatus fromApi(String? value) => switch (value?.toLowerCase()) {
        'belum_dikonfirm' => ReservasiStatus.belumDikonfirm,
        'disetujui' => ReservasiStatus.disetujui,
        'aktif' => ReservasiStatus.aktif,
        'selesai' => ReservasiStatus.selesai,
        'dibatalkan' => ReservasiStatus.dibatalkan,
        _ => ReservasiStatus.belumDikonfirm,
      };

  String toApi() => switch (this) {
        ReservasiStatus.belumDikonfirm => 'belum_dikonfirm',
        ReservasiStatus.disetujui => 'disetujui',
        ReservasiStatus.aktif => 'aktif',
        ReservasiStatus.selesai => 'selesai',
        ReservasiStatus.dibatalkan => 'dibatalkan',
      };
}

/// Widget Status Badge sesuai PRD Bagian III §2.5a (Pill: Ikon + Warna + Teks).
class StatusBadge extends StatelessWidget {
  final ReservasiStatus status;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final (label, backgroundColor, textColor, icon) = _getBadgeProperties();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.sm8 : AppSpacing.md12,
        vertical: compact ? AppSpacing.xs4 : 6.0,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: compact ? 12.0 : 14.0,
            color: textColor,
          ),
          SizedBox(width: compact ? AppSpacing.xs4 : 6.0),
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 11.0 : 12.0,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  (String, Color, Color, IconData) _getBadgeProperties() {
    return switch (status) {
      ReservasiStatus.belumDikonfirm => (
          'Menunggu Konfirmasi',
          AppColors.warning.withValues(alpha: 0.12),
          AppColors.warning,
          Icons.hourglass_empty_rounded,
        ),
      ReservasiStatus.disetujui => (
          'Disetujui',
          AppColors.secondaryContainer,
          AppColors.secondary,
          Icons.check_circle_outline_rounded,
        ),
      ReservasiStatus.aktif => (
          'Sedang Digunakan',
          AppColors.info.withValues(alpha: 0.12),
          AppColors.info,
          Icons.location_on_outlined,
        ),
      ReservasiStatus.selesai => (
          'Selesai',
          AppColors.success.withValues(alpha: 0.12),
          AppColors.success,
          Icons.done_all_rounded,
        ),
      ReservasiStatus.dibatalkan => (
          'Dibatalkan',
          AppColors.danger.withValues(alpha: 0.10),
          AppColors.danger,
          Icons.cancel_outlined,
        ),
    };
  }
}
