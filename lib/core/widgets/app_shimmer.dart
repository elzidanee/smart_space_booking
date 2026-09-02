import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Reusable Skeleton Shimmer Loading sesuai PRD NFR §6 & Desain §6.
class AppShimmer extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;
  final Widget? child;

  const AppShimmer({
    super.key,
    this.width,
    this.height,
    this.borderRadius = AppSpacing.radiusButton,
    this.margin,
    this.child,
  });

  /// Factory skeleton untuk card katalog space
  static Widget spaceCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg16),
      decoration: BoxDecoration(
        color: AppColors.surface0,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppShimmer(
            height: 160,
            borderRadius: AppSpacing.radiusCard,
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                AppShimmer(width: 140, height: 18),
                SizedBox(height: AppSpacing.sm8),
                AppShimmer(width: 80, height: 14),
                SizedBox(height: AppSpacing.md12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppShimmer(width: 100, height: 14),
                    AppShimmer(width: 110, height: 20),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Factory skeleton untuk card reservasi
  static Widget reservationCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md12),
      padding: const EdgeInsets.all(AppSpacing.lg16),
      decoration: BoxDecoration(
        color: AppColors.surface0,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppShimmer(width: 120, height: 14),
              AppShimmer(width: 90, height: 22, borderRadius: AppSpacing.radiusPill),
            ],
          ),
          SizedBox(height: AppSpacing.md12),
          AppShimmer(width: 180, height: 18),
          SizedBox(height: AppSpacing.sm8),
          AppShimmer(width: 130, height: 14),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Shimmer.fromColors(
        baseColor: AppColors.border.withValues(alpha: 0.6),
        highlightColor: Colors.white,
        child: child ??
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
      ),
    );
  }
}

/// Placeholder container inside an AppShimmer
class ShimmerPlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const ShimmerPlaceholder({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Widget gambar jaringan yang aman untuk semua platform (Desktop Windows, Web, Mobile)
/// Mencegah crash sqflite/platform channel pada Windows Desktop dengan fallback cerdas.
class AppNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? errorWidget;
  final IconData placeholderIcon;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorWidget,
    this.placeholderIcon = Icons.meeting_room_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final rawUrl = imageUrl?.trim();

    if (rawUrl != null && rawUrl.isNotEmpty) {
      // 1. Cek apakah ini path file lokal (hasil jepretan kamera / galeri lokal)
      try {
        final localFile = File(rawUrl);
        if (localFile.existsSync()) {
          final img = Image.file(
            localFile,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => _buildFallback(),
          );
          if (borderRadius != null) {
            return ClipRRect(borderRadius: borderRadius!, child: img);
          }
          return img;
        }
      } catch (_) {}
    }

    String? fullUrl;
    if (rawUrl != null && rawUrl.isNotEmpty) {
      if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
        fullUrl = rawUrl;
      } else {
        const base = 'https://learn.smktelkom-mlg.sch.id/coworking';
        final cleanPath = rawUrl.startsWith('/') ? rawUrl : '/$rawUrl';
        if (!cleanPath.startsWith('/uploads/') && cleanPath.contains('.')) {
          fullUrl = '$base/uploads/spaces$cleanPath';
        } else {
          fullUrl = '$base$cleanPath';
        }
      }
    }

    Widget imageContent;

    if (fullUrl == null || fullUrl.isEmpty) {
      imageContent = _buildFallback();
    } else {
      imageContent = Image.network(
        fullUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _buildFallback();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: AppColors.surface50,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary.withValues(alpha: 0.7),
                ),
              ),
            ),
          );
        },
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageContent,
      );
    }

    return imageContent;
  }

  Widget _buildFallback() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          color: AppColors.primaryContainer,
          child: Center(
            child: Icon(
              placeholderIcon,
              size: (height != null && height! < 60) ? 24 : 48,
              color: AppColors.primary,
            ),
          ),
        );
  }
}

