import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Varian tipe alert dengan palet warna dan ikon harmonis.
enum AppAlertType {
  success,
  danger,
  warning,
  info,
}

extension AppAlertTypeX on AppAlertType {
  Color get color {
    switch (this) {
      case AppAlertType.success:
        return AppColors.success;
      case AppAlertType.danger:
        return AppColors.danger;
      case AppAlertType.warning:
        return AppColors.warning;
      case AppAlertType.info:
        return AppColors.secondary;
    }
  }

  Color get containerColor {
    switch (this) {
      case AppAlertType.success:
        return const Color(0xFFEAF5EE);
      case AppAlertType.danger:
        return const Color(0xFFFDF0EF);
      case AppAlertType.warning:
        return const Color(0xFFFEF8E7);
      case AppAlertType.info:
        return AppColors.secondaryContainer;
    }
  }

  IconData get icon {
    switch (this) {
      case AppAlertType.success:
        return Icons.check_circle_outline_rounded;
      case AppAlertType.danger:
        return Icons.error_outline_rounded;
      case AppAlertType.warning:
        return Icons.warning_amber_rounded;
      case AppAlertType.info:
        return Icons.info_outline_rounded;
    }
  }

  String get defaultTag {
    switch (this) {
      case AppAlertType.success:
        return 'BERHASIL';
      case AppAlertType.danger:
        return 'PERHATIAN';
      case AppAlertType.warning:
        return 'PERINGATAN';
      case AppAlertType.info:
        return 'INFORMASI';
    }
  }
}

/// Helper utama untuk memunculkan Alert Dialog, Toast, dan Banner elegan.
class AppAlert {
  AppAlert._();

  /// Menampilkan dialog modal konfirmasi/peringatan berdesain elegan.
  static Future<bool?> showDialog({
    required BuildContext context,
    required String title,
    required String message,
    AppAlertType type = AppAlertType.info,
    String? tag,
    String confirmLabel = 'Lanjutkan',
    String? cancelLabel = 'Batal',
    Map<String, String>? details,
    Widget? customContent,
    IconData? customIcon,
    Color? customColor,
    bool barrierDismissible = true,
  }) {
    final alertColor = customColor ?? type.color;
    final alertIcon = customIcon ?? type.icon;
    final alertTag = tag ?? type.defaultTag;

    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, _, child) {
        final curvedVal = Curves.easeOutCubic.transform(anim.value);
        return Transform.scale(
          scale: 0.92 + (0.08 * curvedVal),
          child: Opacity(
            opacity: anim.value.clamp(0.0, 1.0),
            child: _AppAlertModal(
              title: title,
              message: message,
              type: type,
              tag: alertTag,
              color: alertColor,
              icon: alertIcon,
              confirmLabel: confirmLabel,
              cancelLabel: cancelLabel,
              details: details,
              customContent: customContent,
            ),
          ),
        );
      },
    );
  }

  /// Shortcut untuk dialog konfirmasi tindakan penting/destruktif (danger/warning).
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Ya, Lanjutkan',
    String cancelLabel = 'Batal',
    AppAlertType type = AppAlertType.warning,
    Map<String, String>? details,
    IconData? icon,
    Color? color,
  }) {
    return showDialog(
      context: context,
      title: title,
      message: message,
      type: type,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      details: details,
      customIcon: icon,
      customColor: color,
    );
  }

  /// Shortcut untuk dialog sukses.
  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String buttonLabel = 'Selesai',
    Map<String, String>? details,
  }) {
    return showDialog(
      context: context,
      title: title,
      message: message,
      type: AppAlertType.success,
      confirmLabel: buttonLabel,
      cancelLabel: null,
      details: details,
    );
  }

  /// Shortcut untuk dialog error.
  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String message,
    String buttonLabel = 'Mengerti',
  }) {
    return showDialog(
      context: context,
      title: title,
      message: message,
      type: AppAlertType.danger,
      confirmLabel: buttonLabel,
      cancelLabel: null,
    );
  }

  /// Menampilkan floating toast / floating alert banner di layar.
  static void showToast({
    required BuildContext context,
    required String message,
    String? title,
    AppAlertType type = AppAlertType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: EdgeInsets.zero,
        duration: duration,
        content: Container(
          decoration: BoxDecoration(
            color: AppColors.surface0,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: type.color.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Tinted Icon Circle
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: type.containerColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(type.icon, color: type.color, size: 20),
                ),
              ),
              const SizedBox(width: 14),

              // Title + Message
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null && title.isNotEmpty) ...[
                      Text(
                        title,
                        style: AppTypography.bodyEmphasis.copyWith(
                          fontSize: 14,
                          color: AppColors.ink900,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      message,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.ink600,
                        height: 1.35,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Optional Action
              if (onAction != null && actionLabel != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    messenger.hideCurrentSnackBar();
                    onAction();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    visualDensity: VisualDensity.compact,
                    foregroundColor: type.color,
                  ),
                  child: Text(
                    actionLabel,
                    style: AppTypography.bodyEmphasis.copyWith(
                      color: type.color,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget dialog modal internal dengan estetika premium.
class _AppAlertModal extends StatelessWidget {
  final String title;
  final String message;
  final AppAlertType type;
  final String tag;
  final Color color;
  final IconData icon;
  final String confirmLabel;
  final String? cancelLabel;
  final Map<String, String>? details;
  final Widget? customContent;

  const _AppAlertModal({
    required this.title,
    required this.message,
    required this.type,
    required this.tag,
    required this.color,
    required this.icon,
    required this.confirmLabel,
    this.cancelLabel,
    this.details,
    this.customContent,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.surface0,
      surfaceTintColor: Colors.transparent,
      elevation: 12,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: AppColors.surface0,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Top Row: Concentric Icon Ring + Tag Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Concentric Icon Badge
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withValues(alpha: 0.08),
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withValues(alpha: 0.16),
                      ),
                      child: Center(
                        child: Icon(icon, color: color, size: 22),
                      ),
                    ),
                  ],
                ),

                // Subtle Tag Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: type.containerColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
                  ),
                  child: Text(
                    tag,
                    style: AppTypography.sectionLabel.copyWith(
                      color: color,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Title
            Text(
              title,
              style: AppTypography.h2.copyWith(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.ink900,
              ),
            ),
            const SizedBox(height: 8),

            // Message description
            Text(
              message,
              style: AppTypography.body.copyWith(
                fontSize: 14,
                color: AppColors.ink600,
                height: 1.45,
              ),
            ),

            // Optional Details Card
            if (details != null && details!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: details!.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.ink600,
                              fontSize: 12.5,
                            ),
                          ),
                          Text(
                            entry.value,
                            style: AppTypography.bodyEmphasis.copyWith(
                              color: AppColors.ink900,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            // Custom Content
            if (customContent != null) ...[
              const SizedBox(height: 14),
              customContent!,
            ],

            const SizedBox(height: 24),

            // Actions (Batal / Lanjutkan)
            Row(
              children: [
                if (cancelLabel != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        foregroundColor: AppColors.ink900,
                      ),
                      child: Text(
                        cancelLabel!,
                        style: AppTypography.bodyEmphasis.copyWith(
                          color: AppColors.ink900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: 0,
                      shadowColor: color.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      confirmLabel,
                      style: AppTypography.bodyEmphasis.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                      ),
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
}

/// Widget banner informasi inline yang dapat disematkan di dalam layar atau form.
class AppAlertBanner extends StatelessWidget {
  final String message;
  final String? title;
  final AppAlertType type;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onClose;

  const AppAlertBanner({
    super.key,
    required this.message,
    this.title,
    this.type = AppAlertType.info,
    this.actionLabel,
    this.onAction,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: type.containerColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: type.color.withValues(alpha: 0.22), width: 1),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: type.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(type.icon, color: type.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null && title!.isNotEmpty) ...[
                  Text(
                    title!,
                    style: AppTypography.bodyEmphasis.copyWith(
                      color: AppColors.ink900,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  message,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.ink600,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: onAction,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        actionLabel!,
                        style: AppTypography.bodyEmphasis.copyWith(
                          color: type.color,
                          fontSize: 12.5,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onClose != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onClose,
              child: Icon(
                Icons.close_rounded,
                size: 18,
                color: AppColors.ink600.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
