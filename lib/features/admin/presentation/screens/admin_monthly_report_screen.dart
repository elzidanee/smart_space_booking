import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../data/models/admin_models.dart';
import '../providers/admin_controller.dart';

class AdminMonthlyReportScreen extends ConsumerStatefulWidget {
  final int? initialMonth;
  final int? initialYear;

  const AdminMonthlyReportScreen({
    super.key,
    this.initialMonth,
    this.initialYear,
  });

  @override
  ConsumerState<AdminMonthlyReportScreen> createState() =>
      _AdminMonthlyReportScreenState();
}

class _AdminMonthlyReportScreenState
    extends ConsumerState<AdminMonthlyReportScreen> {
  late int _selectedMonth;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = widget.initialMonth ?? now.month;
    _selectedYear = widget.initialYear ?? now.year;
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth += delta;
      if (_selectedMonth > 12) {
        _selectedMonth = 1;
        _selectedYear++;
      } else if (_selectedMonth < 1) {
        _selectedMonth = 12;
        _selectedYear--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(
      adminMonthlyReportProvider(
        (month: _selectedMonth, year: _selectedYear),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.surface50,
      appBar: AppBar(
        title: const Text('Laporan Finansial Bulanan'),
        backgroundColor: AppColors.surface0,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Selector Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface0,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: AppColors.secondary),
                    onPressed: () => _changeMonth(-1),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, size: 18, color: AppColors.secondary),
                      const SizedBox(width: 8),
                      Text(
                        '${DateFormatter.getMonthName(_selectedMonth)} $_selectedYear',
                        style: AppTypography.h2.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: AppColors.secondary),
                    onPressed: () => _changeMonth(1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            reportAsync.when(
              loading: () => const Column(
                children: [
                  AppShimmer(
                    child: ShimmerPlaceholder(height: 180, borderRadius: 20),
                  ),
                  SizedBox(height: 16),
                  AppShimmer(
                    child: ShimmerPlaceholder(height: 240, borderRadius: 20),
                  ),
                ],
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
                      const SizedBox(height: 12),
                      Text('Gagal memuat rekapitulasi', style: AppTypography.h2),
                      const SizedBox(height: 6),
                      Text('$err', style: AppTypography.caption),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(
                          adminMonthlyReportProvider(
                            (month: _selectedMonth, year: _selectedYear),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (report) => _buildReportContent(report),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportContent(AdminMonthlyReportModel report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Big Hero Card: Pendapatan Bersih
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.secondary,
                Color(0xFF0A443F),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(14, 92, 86, 0.25),
                blurRadius: 16,
                offset: Offset(0, 8),
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
                    'PENDAPATAN BERSIH BULAN INI',
                    style: AppTypography.sectionLabel.copyWith(
                      color: AppColors.secondaryContainer,
                      letterSpacing: 1,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${report.totalTransaksi} Transaksi',
                      style: AppTypography.captionMedium.copyWith(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                CurrencyFormatter.formatRupiah(report.pendapatanBersih),
                style: AppTypography.h1.copyWith(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pendapatan Kotor',
                          style: AppTypography.caption.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyFormatter.formatRupiah(report.pendapatanKotor),
                          style: AppTypography.captionMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 32, color: Colors.white24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Potongan Diskon',
                          style: AppTypography.caption.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyFormatter.formatRupiah(report.potonganDiskon),
                          style: AppTypography.captionMedium.copyWith(
                            color: const Color(0xFFFFB4A9),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Quick Metrics Row
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                icon: Icons.access_time_filled,
                iconColor: AppColors.info,
                label: 'Total Jam Terpakai',
                value: '${report.totalJamTerpakai} Jam',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                icon: Icons.receipt_long_rounded,
                iconColor: AppColors.primary,
                label: 'Total Booking',
                value: '${report.totalTransaksi} Sesi',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Section: Distribusi Pendapatan per Tipe Space
        Text('DISTRIBUSI PER TIPE RUANGAN', style: AppTypography.sectionLabel),
        const SizedBox(height: 12),

        // Stacked Progress Bar Representation
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface0,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Segmented Visual Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 16,
                  child: Row(
                    children: report.perTipeSpace.map((item) {
                      final color = _getColorForSpaceType(item.tipe);
                      final flex = (item.persentase * 10).round().clamp(1, 1000);
                      return Expanded(
                        flex: flex,
                        child: Container(
                          color: color,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Detail List per Space Type
              ...report.perTipeSpace.map((item) {
                final color = _getColorForSpaceType(item.tipe);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.namaTipe, style: AppTypography.captionMedium),
                            Text(
                              '${item.totalBooking} Booking • ${item.totalJam} Jam',
                              style: AppTypography.caption.copyWith(color: AppColors.ink600, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyFormatter.formatRupiah(item.totalPendapatan),
                            style: AppTypography.captionMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${item.persentase.toStringAsFixed(1)}%',
                            style: AppTypography.caption.copyWith(color: color, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface0,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(label, style: AppTypography.caption.copyWith(color: AppColors.ink600)),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.h2.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Color _getColorForSpaceType(String tipe) {
    switch (tipe) {
      case 'personal_desk':
        return AppColors.primary;
      case 'meeting_room':
        return AppColors.secondary;
      case 'private_office':
      default:
        return AppColors.info;
    }
  }
}
