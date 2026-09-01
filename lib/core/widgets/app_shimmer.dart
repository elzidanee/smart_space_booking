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

  const AppShimmer({
    super.key,
    this.width,
    this.height,
    this.borderRadius = AppSpacing.radiusButton,
    this.margin,
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
              children: [
                const AppShimmer(width: 140, height: 18),
                const SizedBox(height: AppSpacing.sm8),
                const AppShimmer(width: 80, height: 14),
                const SizedBox(height: AppSpacing.md12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              AppShimmer(width: 120, height: 14),
              AppShimmer(width: 90, height: 22, borderRadius: AppSpacing.radiusPill),
            ],
          ),
          const SizedBox(height: AppSpacing.md12),
          const AppShimmer(width: 180, height: 18),
          const SizedBox(height: AppSpacing.sm8),
          const AppShimmer(width: 130, height: 14),
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
        child: Container(
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
