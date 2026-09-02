import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_illustrations.dart';
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

  final List<String> _monthNames = const [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
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

  void _showFilterModal(BuildContext context) {
    final currentFilter = ref.read(adminReservationsFilterProvider);
    final spacesAsync = ref.read(adminSpacesControllerProvider);

    int? selectedMonth = currentFilter.month;
    int? selectedYear = currentFilter.year ?? DateTime.now().year;
    int? selectedSpaceId = currentFilter.idSpace;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filter Reservasi Lengkap', style: AppTypography.h2),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Filter Ruangan / Space
                  Text('Filter Berdasarkan Ruangan:', style: AppTypography.captionMedium),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int?>(
                    initialValue: selectedSpaceId,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Semua Ruangan (All Spaces)')),
                      if (spacesAsync.value != null)
                        ...spacesAsync.value!.map(
                          (s) => DropdownMenuItem(
                            value: s.id,
                            child: Text('${s.nama} (${s.tipe})'),
                          ),
                        ),
                    ],
                    onChanged: (val) => setModalState(() => selectedSpaceId = val),
                  ),
                  const SizedBox(height: 16),

                  // Filter Periode Bulan & Tahun
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Bulan:', style: AppTypography.captionMedium),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int?>(
                              initialValue: selectedMonth,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('Semua Bulan')),
                                ...List.generate(
                                  12,
                                  (i) => DropdownMenuItem(
                                    value: i + 1,
                                    child: Text(_monthNames[i]),
                                  ),
                                ),
                              ],
                              onChanged: (val) => setModalState(() => selectedMonth = val),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tahun:', style: AppTypography.captionMedium),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              initialValue: selectedYear,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              items: [2025, 2026, 2027, 2028, 2029, 2030].map(
                                (y) => DropdownMenuItem(value: y, child: Text('$y')),
                              ).toList(),
                              onChanged: (val) {
                                if (val != null) setModalState(() => selectedYear = val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            ref.read(adminReservationsControllerProvider.notifier).updateFilter(
                              AdminReservationsFilterState(
                                status: currentFilter.status,
                                query: currentFilter.query,
                              ),
                            );
                            Navigator.of(ctx).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Reset Filter'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ref.read(adminReservationsControllerProvider.notifier).updateFilter(
                              currentFilter.copyWith(
                                idSpace: selectedSpaceId,
                                clearSpace: selectedSpaceId == null,
                                month: selectedMonth,
                                clearMonth: selectedMonth == null,
                                year: selectedYear,
                              ),
                            );
                            Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Terapkan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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

  void _clearSpaceFilter() {
    final currentFilter = ref.read(adminReservationsFilterProvider);
    ref
        .read(adminReservationsControllerProvider.notifier)
        .updateFilter(currentFilter.copyWith(clearSpace: true));
  }

  void _clearMonthFilter() {
    final currentFilter = ref.read(adminReservationsFilterProvider);
    ref
        .read(adminReservationsControllerProvider.notifier)
        .updateFilter(currentFilter.copyWith(clearMonth: true));
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(adminReservationsFilterProvider);
    final reservationsAsync = ref.watch(adminReservationsControllerProvider);
    final spacesAsync = ref.watch(adminSpacesControllerProvider);

    String? selectedSpaceName;
    if (filter.idSpace != null && spacesAsync.value != null) {
      final found = spacesAsync.value!.where((s) => s.id == filter.idSpace).firstOrNull;
      selectedSpaceName = found?.nama;
    }

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
              (filter.idSpace != null || filter.month != null)
                  ? Icons.filter_alt
                  : Icons.filter_alt_outlined,
              color: (filter.idSpace != null || filter.month != null)
                  ? AppColors.secondary
                  : AppColors.ink600,
            ),
            tooltip: 'Filter Ruangan & Periode',
            onPressed: () => _showFilterModal(context),
          ),
          IconButton(
            icon: Icon(
              filter.tanggal != null
                  ? Icons.event_available_rounded
                  : Icons.calendar_month_outlined,
              color: filter.tanggal != null
                  ? AppColors.secondary
                  : AppColors.ink600,
            ),
            tooltip: 'Filter Tanggal Spesifik',
            onPressed: () => _selectDate(context),
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
                const SizedBox(height: 10),

                // Active Filter Badges (Space, Bulan/Tahun, Tanggal)
                if (filter.tanggal != null || filter.idSpace != null || filter.month != null) ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (filter.tanggal != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Chip(
                              backgroundColor: AppColors.secondaryContainer,
                              avatar: const Icon(Icons.event, size: 14, color: AppColors.secondary),
                              label: Text('Tgl: ${filter.tanggal}', style: const TextStyle(fontSize: 12, color: AppColors.secondary)),
                              deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.secondary),
                              onDeleted: _clearDateFilter,
                            ),
                          ),
                        if (selectedSpaceName != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Chip(
                              backgroundColor: AppColors.surface50,
                              avatar: const Icon(Icons.meeting_room_outlined, size: 14, color: AppColors.ink900),
                              label: Text('Space: $selectedSpaceName', style: const TextStyle(fontSize: 12, color: AppColors.ink900)),
                              deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.ink900),
                              onDeleted: _clearSpaceFilter,
                            ),
                          ),
                        if (filter.month != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Chip(
                              backgroundColor: AppColors.surface50,
                              avatar: const Icon(Icons.calendar_view_month, size: 14, color: AppColors.ink900),
                              label: Text('Bulan: ${_monthNames[filter.month! - 1]} ${filter.year ?? ''}', style: const TextStyle(fontSize: 12, color: AppColors.ink900)),
                              deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.ink900),
                              onDeleted: _clearMonthFilter,
                            ),
                          ),
                      ],
                    ),
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
                separatorBuilder: (context, _) => const SizedBox(height: 12),
                itemBuilder: (context, _) => const AppShimmer(
                  child: ShimmerPlaceholder(height: 140, borderRadius: 16),
                ),
              ),
              error: (err, _) => AppEmptyState(
                illustration: const NetworkErrorIllustration(size: 160),
                title: 'Gagal Memuat Reservasi',
                message: '$err',
                actionLabel: 'Coba Lagi',
                actionColor: AppColors.secondary,
                onAction: () => ref.invalidate(adminReservationsControllerProvider),
              ),
              data: (reservations) {
                if (reservations.isEmpty) {
                  return AppEmptyState(
                    illustration: const EmptyReservationsIllustration(size: 160),
                    title: filter.query.isNotEmpty
                        ? 'Tidak Ditemukan'
                        : 'Belum Ada Reservasi',
                    message: filter.query.isNotEmpty
                        ? 'Tidak ada reservasi yang cocok dengan kata kunci "${filter.query}"'
                        : 'Belum ada reservasi masuk pada kategori status yang dipilih.',
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
                    separatorBuilder: (context, _) => const SizedBox(height: 12),
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
                  StatusBadge(status: ReservasiStatus.fromApi(item.status)),
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
                          item.namaSpace ?? 'Space',
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
                    CurrencyFormatter.formatRupiah(item.totalBayar > 0
                        ? item.totalBayar
                        : (item.subtotal > 0
                            ? (item.subtotal - item.potonganDiskon > 0
                                ? item.subtotal - item.potonganDiskon
                                : item.subtotal)
                            : 0)),
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
