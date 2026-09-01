import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_illustrations.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../spaces/data/models/space_models.dart';
import '../providers/reservations_controller.dart';

/// Layar Histori & Pengeluaran Member sesuai Stitch Screen 08 (d223e5f0fdb347d6b1d2b714beef430e).
class ReservationsHistoryScreen extends ConsumerStatefulWidget {
  const ReservationsHistoryScreen({super.key});

  @override
  ConsumerState<ReservationsHistoryScreen> createState() =>
      _ReservationsHistoryScreenState();
}

class _ReservationsHistoryScreenState
    extends ConsumerState<ReservationsHistoryScreen> {
  final List<String> _bulanList = const [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  final List<int> _tahunList = [2025, 2026, 2027];

  @override
  Widget build(BuildContext context) {
    final selectedMonth = ref.watch(selectedHistoryMonthProvider);
    final selectedYear = ref.watch(selectedHistoryYearProvider);
    final historyAsync = ref.watch(myHistoryReservationsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface50,
      appBar: AppBar(
        backgroundColor: AppColors.surface0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.ink900),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Histori & Pengeluaran',
          style: AppTypography.h3.copyWith(color: AppColors.ink900),
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(myHistoryReservationsProvider);
        },
        child: CustomScrollView(
          slivers: [
            // ── Month & Year Filter Bar ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                color: AppColors.surface0,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg16,
                  0,
                  AppSpacing.lg16,
                  AppSpacing.md12,
                ),
                child: Row(
                  children: [
                    // Month Dropdown
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface50,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusField),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: selectedMonth,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.ink600),
                            items: List.generate(12, (index) {
                              return DropdownMenuItem(
                                value: index + 1,
                                child: Text(
                                  _bulanList[index],
                                  style: AppTypography.bodyMedium,
                                ),
                              );
                            }),
                            onChanged: (val) {
                              if (val != null) {
                                ref.read(selectedHistoryMonthProvider.notifier).state = val;
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm8),

                    // Year Dropdown
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface50,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusField),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: selectedYear,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.ink600),
                            items: _tahunList.map((yr) {
                              return DropdownMenuItem(
                                value: yr,
                                child: Text(
                                  '$yr',
                                  style: AppTypography.bodyMedium,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                ref.read(selectedHistoryYearProvider.notifier).state = val;
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Summary Cards (Total Pengeluaran & Jam) ──────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg16),
                child: historyAsync.when(
                  data: (summary) => Container(
                    padding: const EdgeInsets.all(AppSpacing.lg16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Pengeluaran Bulan Ini',
                              style: AppTypography.captionMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                              ),
                              child: Text(
                                '${summary.totalTransaksi} Transaksi',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          CurrencyFormatter.format(summary.totalPengeluaran),
                          style: AppTypography.h1.copyWith(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md12),
                        const Divider(color: Colors.white24, height: 1),
                        const SizedBox(height: AppSpacing.sm8),
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined, color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Akumulasi Waktu Kerja: ${summary.totalJam} Jam',
                              style: AppTypography.captionMedium.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  loading: () => const AppShimmer(height: 120),
                  error: (error, stack) => const SizedBox.shrink(),
                ),
              ),
            ),

            // ── Section Title ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg16,
                  vertical: AppSpacing.xs4,
                ),
                child: Text(
                  'Riwayat Pemesanan',
                  style: AppTypography.h3.copyWith(color: AppColors.ink900),
                ),
              ),
            ),

            // ── History Items List (Stitch Screen 08) ───────────────────────
            historyAsync.when(
              data: (summary) {
                if (summary.items.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppEmptyState(
                      illustration: const EmptyReservationsIllustration(size: 160),
                      title: 'Tidak Ada Riwayat Transaksi',
                      message: 'Belum ada catatan reservasi atau transaksi selesai di bulan ${_bulanList[selectedMonth - 1]} $selectedYear.',
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg16,
                    AppSpacing.sm8,
                    AppSpacing.lg16,
                    AppSpacing.xxl32,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = summary.items[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm8),
                          child: _HistoryItemCard(reservation: item),
                        );
                      },
                      childCount: summary.items.length,
                    ),
                  ),
                );
              },
              loading: () => SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.lg16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: AppShimmer(height: 72),
                    ),
                    childCount: 4,
                  ),
                ),
              ),
              error: (err, _) => SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl24),
                    child: Text('Gagal memuat histori: $err'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Item riwayat pada Stitch Screen 08
class _HistoryItemCard extends StatelessWidget {
  final ReservationModel reservation;

  const _HistoryItemCard({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final isCancelled = reservation.status == 'dibatalkan';

    DateTime? parsedDate;
    try {
      parsedDate = DateTime.parse(reservation.tanggal);
    } catch (_) {}

    final dateStr = parsedDate != null
        ? DateFormatter.formatShortDate(parsedDate)
        : reservation.tanggal;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md12),
      decoration: BoxDecoration(
        color: AppColors.surface0,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Thumbnail Space
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusField),
            child: SizedBox(
              width: 56,
              height: 56,
              child: reservation.fotoSpace != null && reservation.fotoSpace!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: reservation.fotoSpace!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const AppShimmer(width: 56, height: 56),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.primaryContainer,
                        child: const Icon(Icons.meeting_room, color: AppColors.primary),
                      ),
                    )
                  : Container(
                      color: AppColors.primaryContainer,
                      child: const Icon(Icons.meeting_room, color: AppColors.primary),
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.md12),

          // Detail Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: AppTypography.bodyEmphasis.copyWith(
                    decoration: isCancelled ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${reservation.namaSpace ?? "Space"} • ${reservation.durasi} Jam',
                  style: AppTypography.caption.copyWith(color: AppColors.ink600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Price & Status Badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(reservation.totalBayar),
                style: AppTypography.bodyEmphasis.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isCancelled ? AppColors.ink600 : AppColors.ink900,
                  decoration: isCancelled ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 4),
              _buildSmallBadge(reservation.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallBadge(String status) {
    Color bg;
    Color text;
    String label;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'selesai':
        bg = const Color(0xFFD4E9DB);
        text = const Color(0xFF1E5631);
        icon = Icons.check_circle_rounded;
        label = 'Selesai';
        break;
      case 'dibatalkan':
        bg = const Color(0xFFFFDAD6);
        text = AppColors.danger;
        icon = Icons.cancel_rounded;
        label = 'Dibatalkan';
        break;
      case 'disetujui':
        bg = const Color(0xFFE0F4F2);
        text = const Color(0xFF0E5C56);
        icon = Icons.event_available_rounded;
        label = 'Disetujui';
        break;
      case 'aktif':
        bg = AppColors.primaryContainer;
        text = AppColors.primary;
        icon = Icons.pin_drop_rounded;
        label = 'Aktif';
        break;
      default:
        bg = const Color(0xFFFFF4E5);
        text = const Color(0xFFB26B00);
        icon = Icons.hourglass_empty_rounded;
        label = 'Menunggu';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: text),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: text,
            ),
          ),
        ],
      ),
    );
  }
}
