import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

import '../../../../core/widgets/app_alert.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? memberName;
  final String? bookingCode;
  final String? spaceName;
  final String confirmLabel;
  final String cancelLabel;
  final Color confirmColor;
  final IconData icon;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.memberName,
    this.bookingCode,
    this.spaceName,
    this.confirmLabel = 'Ya, Lanjutkan',
    this.cancelLabel = 'Batal',
    this.confirmColor = AppColors.secondary,
    this.icon = Icons.warning_amber_rounded,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String? memberName,
    String? bookingCode,
    String? spaceName,
    String confirmLabel = 'Ya, Lanjutkan',
    String cancelLabel = 'Batal',
    Color confirmColor = AppColors.secondary,
    IconData icon = Icons.warning_amber_rounded,
  }) {
    Map<String, String>? details;
    if (bookingCode != null || memberName != null || spaceName != null) {
      details = {};
      if (bookingCode != null) details['Kode Booking'] = bookingCode;
      if (memberName != null) details['Nama Tamu'] = memberName;
      if (spaceName != null) details['Ruangan'] = spaceName;
    }

    AppAlertType alertType = AppAlertType.info;
    if (confirmColor == AppColors.danger) {
      alertType = AppAlertType.danger;
    } else if (confirmColor == AppColors.warning) {
      alertType = AppAlertType.warning;
    } else if (confirmColor == AppColors.success) {
      alertType = AppAlertType.success;
    }

    return AppAlert.showDialog(
      context: context,
      title: title,
      message: message,
      type: alertType,
      customColor: confirmColor,
      customIcon: icon,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      details: details,
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.surface0,
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Icon + Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: confirmColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: confirmColor, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.h2.copyWith(fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Message description
            Text(
              message,
              style: AppTypography.caption.copyWith(color: AppColors.ink600),
            ),
            const SizedBox(height: 16),

            // Info Card (Kode Booking + Member Name)
            if (memberName != null || bookingCode != null || spaceName != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (bookingCode != null)
                      _buildInfoRow('Kode Booking', bookingCode!, isBold: true),
                    if (memberName != null) ...[
                      const SizedBox(height: 6),
                      _buildInfoRow('Nama Tamu', memberName!),
                    ],
                    if (spaceName != null) ...[
                      const SizedBox(height: 6),
                      _buildInfoRow('Ruangan', spaceName!),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      cancelLabel,
                      style: AppTypography.bodyEmphasis.copyWith(color: AppColors.ink900),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      confirmLabel,
                      style: AppTypography.bodyEmphasis.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(color: AppColors.ink600),
        ),
        Text(
          value,
          style: isBold
              ? AppTypography.captionMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink900,
                )
              : AppTypography.captionMedium.copyWith(color: AppColors.ink900),
        ),
      ],
    );
  }
}
