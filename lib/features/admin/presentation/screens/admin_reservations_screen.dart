import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../spaces/data/models/space_models.dart';
import '../providers/admin_controller.dart';
import 'admin_reservation_detail_screen.dart';

class AdminReservationsScreen extends ConsumerStatefulWidget {
  const AdminReservationsScreen({super.key});

  @override
  ConsumerState<AdminReservationsScreen> createState() =>
      _AdminReservationsScreenState();
}

class _AdminReservationsScreenState
    extends ConsumerState<AdminReservationsScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<({String label, String value})> _statusOptions = const [
    (label: 'Semua', value: 'all'),
    (label: 'Menunggu', value: 'belum_dikonfirm'),
    (label: 'Disetujui', value: 'disetujui'),
    (label: 'Aktif', value: 'aktif'),
    (label: 'Selesai', value: 'selesai'),
    (label: 'Dibatalkan', value: 'dibatalkan'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    final currentFilter = ref.read(adminReservationsFilterProvider);
    ref
        .read(adminReservationsControllerProvider.notifier)
        .updateFilter(currentFilter.copyWith(query: query));
  }

  void _onStatusSelected(String status) {
    final currentFilter = ref.read(adminReservationsFilterProvider);
    ref
        .read(adminReservationsControllerProvider.notifier)
        .updateFilter(currentFilter.copyWith(status: status));
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.secondary,
              onPrimary: Colors.white,
              onSurface: AppColors.ink900,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      final currentFilter = ref.read(adminReservationsFilterProvider);
      ref
          .read(adminReservationsControllerProvider.notifier)
          .updateFilter(currentFilter.copyWith(tanggal: formatted));
    }
  }

  void _clearDateFilter() {
    final currentFilter = ref.read(adminReservationsFilterProvider);
    ref
        .read(adminReservationsControllerProvider.notifier)
        .updateFilter(currentFilter.copyWith(clearTanggal: true));
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(adminReservationsFilterProvider);
    final reservationsAsync = ref.watch(adminReservationsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.surface50,
      appBar: AppBar(
        title: const Text('Kelola Semua Reservasi'),
        backgroundColor: AppColors.surface0,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              filter.tanggal != null
                  ? Icons.event_available_rounded
                  : Icons.calendar_month_outlined,
              color: filter.tanggal != null
                  ? AppColors.secondary
                  : AppColors.ink600,
            ),
            tooltip: 'Filter Tanggal',
            onPressed: () => _selectDate(context),
          ),
          if (filter.tanggal != null)
            IconButton(
              icon: const Icon(Icons.clear, color: AppColors.danger),
              tooltip: 'Hapus Filter Tanggal',
              onPressed: _clearDateFilter,
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar & Filters Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: AppColors.surface0,
            child: Column(
              children: [
                // Search Input
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Cari kode booking, nama tamu, atau space...',
                    hintStyle: AppTypography.caption.copyWith(color: AppColors.ink300),
                    prefixIcon: const Icon(Icons.search, color: AppColors.ink600, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surface50,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Active Date Filter Badge if Selected
                if (filter.tanggal != null) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.event, size: 14, color: AppColors.secondary),
                            const SizedBox(width: 6),
                            Text(
                              'Tanggal: ${filter.tanggal}',
                              style: AppTypography.captionMedium.copyWith(
                                color: AppColors.secondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // Status Filter Chips Scrollable
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _statusOptions.map((opt) {
                      final isSelected = filter.status == opt.value;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(opt.label),
                          selected: isSelected,
                          selectedColor: AppColors.secondary,
                          labelStyle: AppTypography.captionMedium.copyWith(
                            color: isSelected ? Colors.white : AppColors.ink600,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          backgroundColor: AppColors.surface50,
                          side: BorderSide(
                            color: isSelected ? AppColors.secondary : AppColors.border,
                          ),
                          onSelected: (_) => _onStatusSelected(opt.value),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          // Reservation List
          Expanded(
            child: reservationsAsync.when(
              loading: () => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, __) => const AppShimmer(
                  child: ShimmerPlaceholder(height: 140, borderRadius: 16),
                ),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
                      const SizedBox(height: 12),
                      Text('Gagal memuat data reservasi', style: AppTypography.h2),
                      const SizedBox(height: 6),
                      Text('$err', style: AppTypography.caption, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(adminReservationsControllerProvider),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (reservations) {
                if (reservations.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.event_busy_outlined, size: 64, color: AppColors.ink300),
                          const SizedBox(height: 16),
                          Text(
                            filter.query.isNotEmpty
                                ? 'Tidak ditemukan reservasi untuk "${filter.query}"'
                                : 'Belum ada data reservasi',
                            style: AppTypography.h2,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Reservasi tamu akan muncul di daftar ini sesuai filter yang dipilih.',
                            style: AppTypography.caption,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.secondary,
                  onRefresh: () async {
                    ref.invalidate(adminReservationsControllerProvider);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: reservations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = reservations[index];
                      return _buildReservationCard(context, item);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationCard(BuildContext context, ReservationModel item) {
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
              // Header: Booking code + Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.kodeBooking,
                    style: AppTypography.h2.copyWith(
                      color: AppColors.secondary,
                      fontSize: 15,
                    ),
                  ),
                  StatusBadge(status: item.status),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 10),

              // Space & Member Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.namaSpace,
                          style: AppTypography.h2.copyWith(fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.person, size: 14, color: AppColors.ink600),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.namaMember ?? 'Tamu Coworking',
                                style: AppTypography.captionMedium.copyWith(
                                  color: AppColors.ink600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatRupiah(item.totalBayar),
                    style: AppTypography.h2.copyWith(
                      color: AppColors.ink900,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Date & Time Footer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 13, color: AppColors.secondary),
                        const SizedBox(width: 6),
                        Text(
                          DateFormatter.formatIndonesian(item.tanggal),
                          style: AppTypography.caption.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 13, color: AppColors.secondary),
                        const SizedBox(width: 4),
                        Text(
                          '${item.jamMulai} - ${item.jamSelesai}',
                          style: AppTypography.captionMedium.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
