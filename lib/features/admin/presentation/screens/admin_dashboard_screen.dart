import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../spaces/data/models/space_models.dart';
import '../providers/admin_controller.dart';
import '../widgets/admin_stat_card.dart';
import 'admin_monthly_report_screen.dart';
import 'admin_reservation_detail_screen.dart';

class AdminDashboardScreen extends ConsumerWidget {
  final VoidCallback? onNavigateToReservations;
  final VoidCallback? onNavigateToMasterData;

  const AdminDashboardScreen({
    super.key,
    this.onNavigateToReservations,
    this.onNavigateToMasterData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.value?.user;
    final dashboardAsync = ref.watch(adminDashboardSummaryProvider);

    final todayFormatted = DateFormatter.formatIndonesian(
      DateTime.now().toIso8601String().substring(0, 10),
    );

    return Scaffold(
      backgroundColor: AppColors.surface50,
      body: RefreshIndicator(
        color: AppColors.secondary,
        onRefresh: () async {
          ref.invalidate(adminDashboardSummaryProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting & Space Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todayFormatted.toUpperCase(),
                          style: AppTypography.sectionLabel.copyWith(
                            color: AppColors.secondary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.namaSpace ?? 'Smart Space Hub',
                          style: AppTypography.h1.copyWith(fontSize: 22),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.store, color: AppColors.secondary, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // KPI Stat Cards Grid
              dashboardAsync.when(
                loading: () => const Row(
                  children: [
                    Expanded(child: AppShimmer(child: ShimmerPlaceholder(height: 100, borderRadius: 16))),
                    SizedBox(width: 12),
                    Expanded(child: AppShimmer(child: ShimmerPlaceholder(height: 100, borderRadius: 16))),
                  ],
                ),
                error: (err, _) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface0,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text('Gagal memuat ringkasan: $err', style: AppTypography.caption),
                ),
                data: (data) => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AdminStatCard(
                            title: 'Menunggu Konfirmasi',
                            value: '${data.totalPendingCount}',
                            subtitle: 'Perlu ditinjau',
                            icon: Icons.hourglass_top_rounded,
                            iconColor: AppColors.warning,
                            onTap: onNavigateToReservations,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AdminStatCard(
                            title: 'Sedang Aktif',
                            value: '${data.totalActiveCount}',
                            subtitle: 'Tamu di lokasi',
                            icon: Icons.people_outline_rounded,
                            iconColor: AppColors.info,
                            onTap: onNavigateToReservations,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Monthly Revenue Snapshot Card
                    AdminStatCard(
                      title: 'Estimasi Pendapatan Bulan Ini',
                      value: CurrencyFormatter.formatRupiah(data.monthlyReport.pendapatanBersih),
                      subtitle:
                          '${data.monthlyReport.totalTransaksi} transaksi • Tap untuk lihat laporan lengkap',
                      icon: Icons.trending_up_rounded,
                      iconColor: AppColors.success,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AdminMonthlyReportScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions Bar
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AdminMonthlyReportScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.analytics_outlined, size: 18, color: AppColors.secondary),
                      label: const Text('Laporan Finansial', style: TextStyle(color: AppColors.secondary, fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onNavigateToMasterData,
                      icon: const Icon(Icons.add_business_outlined, size: 18, color: AppColors.secondary),
                      label: const Text('Kelola Master Data', style: TextStyle(color: AppColors.secondary, fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section: Reservasi Butuh Tindakan / Hari Ini
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('RESERVASI HARI INI', style: AppTypography.sectionLabel),
                  if (onNavigateToReservations != null)
                    TextButton(
                      onPressed: onNavigateToReservations,
                      child: const Text('Lihat Semua', style: TextStyle(color: AppColors.secondary, fontSize: 13)),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              dashboardAsync.when(
                loading: () => const AppShimmer(
                  child: ShimmerPlaceholder(height: 140, borderRadius: 16),
                ),
                error: (err, _) => const SizedBox.shrink(),
                data: (data) {
                  final list = data.todayReservations;
                  if (list.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface0,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.event_available, size: 48, color: AppColors.ink300),
                            const SizedBox(height: 8),
                            Text('Tidak ada reservasi untuk hari ini', style: AppTypography.h2.copyWith(fontSize: 15)),
                            const SizedBox(height: 4),
                            Text('Jadwal pemesanan berikutnya akan tampil di sini.', style: AppTypography.caption),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: list.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildTodayReservationCard(context, item),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayReservationCard(BuildContext context, ReservationModel item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AdminReservationDetailScreen(reservation: item),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface0,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(28, 25, 23, 0.04),
                blurRadius: 8,
                offset: Offset(0, 3),
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
                    item.kodeBooking,
                    style: AppTypography.h2.copyWith(color: AppColors.secondary, fontSize: 14),
                  ),
                  StatusBadge(status: item.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.namaSpace, style: AppTypography.h2.copyWith(fontSize: 15)),
                        const SizedBox(height: 2),
                        Text('Tamu: ${item.namaMember ?? "Ahmad Fauzi"}', style: AppTypography.caption),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surface50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, size: 12, color: AppColors.secondary),
                        const SizedBox(width: 4),
                        Text(
                          '${item.jamMulai} - ${item.jamSelesai}',
                          style: AppTypography.captionMedium.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
