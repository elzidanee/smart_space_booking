import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Helper terpusat untuk pemilihan gambar dari Kamera atau Galeri.
class ImagePickerHelper {
  ImagePickerHelper._();

  static final ImagePicker _picker = ImagePicker();

  /// Mengambil gambar dari [ImageSource] (Camera / Gallery) dengan konfigurasi standar.
  static Future<File?> pickImage(
    ImageSource source, {
    double maxWidth = 1024,
    double maxHeight = 1024,
    int imageQuality = 85,
  }) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (picked != null) {
        return File(picked.path);
      }
      return null;
    } catch (e) {
      debugPrint('[ImagePickerHelper] Error picking image: $e');
      return null;
    }
  }

  /// Menampilkan bottom sheet interaktif untuk memilih sumber gambar (Kamera atau Galeri).
  static Future<File?> showImageSourceDialog(
    BuildContext context, {
    String title = 'Pilih Sumber Foto',
    String subtitle = 'Ambil foto langsung dengan kamera atau pilih dari galeri perangkat',
    bool allowRemove = false,
  }) async {
    return await showModalBottomSheet<File?>(
      context: context,
      backgroundColor: AppColors.surface0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusBottomSheet),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg16,
            vertical: AppSpacing.xl24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.ink300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md12),

              Text(title, style: AppTypography.h3),
              const SizedBox(height: AppSpacing.xs4),
              Text(
                subtitle,
                style: AppTypography.caption.copyWith(color: AppColors.ink600),
              ),
              const SizedBox(height: AppSpacing.lg16),

              // Opsi 1: Kamera
              _ImageSourceTile(
                icon: Icons.camera_alt_rounded,
                iconColor: AppColors.primary,
                title: 'Kamera',
                subtitle: 'Ambil foto baru langsung dari kamera',
                onTap: () async {
                  final file = await pickImage(ImageSource.camera);
                  if (ctx.mounted) {
                    Navigator.pop(ctx, file);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.sm8),

              // Opsi 2: Galeri
              _ImageSourceTile(
                icon: Icons.photo_library_rounded,
                iconColor: AppColors.secondary,
                title: 'Galeri Foto',
                subtitle: 'Pilih foto yang tersimpan di memori perangkat',
                onTap: () async {
                  final file = await pickImage(ImageSource.gallery);
                  if (ctx.mounted) {
                    Navigator.pop(ctx, file);
                  }
                },
              ),

              if (allowRemove) ...[
                const SizedBox(height: AppSpacing.sm8),
                _ImageSourceTile(
                  icon: Icons.delete_outline_rounded,
                  iconColor: AppColors.danger,
                  title: 'Hapus Foto',
                  subtitle: 'Gunakan foto placeholder default',
                  onTap: () {
                    Navigator.pop(ctx, File('')); // Sentral penanda hapus
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageSourceTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ImageSourceTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md12,
            vertical: AppSpacing.md12,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface50,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: AppSpacing.md12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.bodyEmphasis),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.caption.copyWith(color: AppColors.ink600),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.ink600,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
