import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../utils/image_picker_helper.dart';
import 'app_shimmer.dart';

enum PhotoPickerShape {
  circle,
  rectangle,
  card,
}

/// Widget interaktif untuk memilih / mengunggah foto dari Kamera atau Galeri.
class AppPhotoPickerField extends StatelessWidget {
  final File? selectedFile;
  final String? initialUrl;
  final String label;
  final String? helperText;
  final PhotoPickerShape shape;
  final double height;
  final ValueChanged<File?> onPhotoChanged;

  const AppPhotoPickerField({
    super.key,
    this.selectedFile,
    this.initialUrl,
    this.label = 'Foto',
    this.helperText,
    this.shape = PhotoPickerShape.card,
    this.height = 160,
    required this.onPhotoChanged,
  });

  Future<void> _handlePick(BuildContext context) async {
    final hasPhoto = selectedFile != null || (initialUrl != null && initialUrl!.isNotEmpty);
    final file = await ImagePickerHelper.showImageSourceDialog(
      context,
      title: 'Pilih $label',
      allowRemove: hasPhoto,
    );

    if (file != null) {
      if (file.path.isEmpty) {
        // Penanda hapus foto
        onPhotoChanged(null);
      } else {
        onPhotoChanged(file);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: AppTypography.bodyEmphasis),
          const SizedBox(height: AppSpacing.xs4),
        ],
        if (helperText != null) ...[
          Text(
            helperText!,
            style: AppTypography.caption.copyWith(color: AppColors.ink600),
          ),
          const SizedBox(height: AppSpacing.sm8),
        ],
        if (shape == PhotoPickerShape.circle)
          _buildCirclePicker(context)
        else
          _buildRectanglePicker(context),
      ],
    );
  }

  Widget _buildCirclePicker(BuildContext context) {
    final hasLocal = selectedFile != null;
    final hasUrl = initialUrl != null && initialUrl!.isNotEmpty;

    return Center(
      child: Stack(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryContainer,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasLocal
                ? Image.file(
                    selectedFile!,
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                  )
                : hasUrl
                    ? AppNetworkImage(
                        imageUrl: initialUrl,
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                      )
                    : const Icon(
                        Icons.person_rounded,
                        size: 54,
                        color: AppColors.primary,
                      ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _handlePick(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRectanglePicker(BuildContext context) {
    final hasLocal = selectedFile != null;
    final hasUrl = initialUrl != null && initialUrl!.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handlePick(context),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        child: Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.surface50,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            border: Border.all(
              color: hasLocal || hasUrl ? AppColors.secondary : AppColors.border,
              width: hasLocal || hasUrl ? 1.5 : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              if (hasLocal)
                Positioned.fill(
                  child: Image.file(
                    selectedFile!,
                    fit: BoxFit.cover,
                  ),
                )
              else if (hasUrl)
                Positioned.fill(
                  child: AppNetworkImage(
                    imageUrl: initialUrl,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_a_photo_rounded,
                          color: AppColors.secondary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Pilih Foto (Kamera / Galeri)',
                        style: AppTypography.captionMedium.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Format JPG/PNG maks. 5MB',
                        style: AppTypography.caption.copyWith(
                          fontSize: 11,
                          color: AppColors.ink600,
                        ),
                      ),
                    ],
                  ),
                ),

              // Overlay Badge saat foto sudah terpasang
              if (hasLocal || hasUrl)
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.camera_alt, color: Colors.white, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'Ubah Foto',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
