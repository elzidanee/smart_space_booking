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
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../spaces/data/models/space_models.dart';
import '../providers/reservations_controller.dart';

/// Layar Status Pemesanan Member sesuai Stitch Screen 07 (1cee3116adcb4f329a5d9785266527e5).
class ReservationsStatusScreen extends ConsumerStatefulWidget {
  const ReservationsStatusScreen({super.key});

  @override
  ConsumerState<ReservationsStatusScreen> createState() =>
      _ReservationsStatusScreenState();
}

class _ReservationsStatusScreenState
    extends ConsumerState<ReservationsStatusScreen> {
  final List<Map<String, String>> _statusFilters = const [
    {'id': 'all', 'label': 'Semua'},
    {'id': 'menunggu', 'label': 'Menunggu'},
    {'id': 'disetujui', 'label': 'Disetujui'},
    {'id': 'aktif', 'label': 'Aktif'},
    {'id': 'selesai', 'label': 'Selesai'},
    {'id': 'dibatalkan', 'label': 'Dibatalkan'},
  ];

  void _showCancelDialog(ReservationModel reservation) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 28),
            const SizedBox(width: 8),
            Text('Batalkan Pemesanan?', style: AppTypography.h3),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apakah Anda yakin ingin membatalkan reservasi untuk ${reservation.namaSpace ?? "Space"} (${reservation.kodeBooking})?',
              style: AppTypography.body,
            ),
            const SizedBox(height: 8),
            Text(
              'Tindakan ini tidak dapat dibatalkan setelah dikonfirmasi.',
              style: AppTypography.caption.copyWith(color: AppColors.danger),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref
                  .read(cancelReservationControllerProvider.notifier)
                  .cancel(reservation.id);

              if (!mounted) return;

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reservasi berhasil dibatalkan.'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gagal membatalkan reservasi.'),
                    backgroundColor: AppColors.danger,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authSession = ref.watch(authControllerProvider).valueOrNull;
    final userName = authSession?.user?.nama ?? 'Member';
    final userAvatar = authSession?.user?.foto;

    final selectedFilter = ref.watch(selectedReservationStatusFilterProvider);
    final reservationsAsync = ref.watch(myReservationsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface50,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(myReservationsProvider);
          },
          child: CustomScrollView(
            slivers: [
              // ── Top Header / App Bar ───────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg16,
                    AppSpacing.md12,
                    AppSpacing.lg16,
                    AppSpacing.md12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primaryContainer,
                            backgroundImage: (userAvatar != null && userAvatar.isNotEmpty)
                                ? NetworkImage(userAvatar) as ImageProvider
                                : null,
                            child: (userAvatar == null || userAvatar.isEmpty)
                                ? Text(
                                    userName.isNotEmpty ? userName[0].toUpperCase() : 'M',
                                    style: AppTypography.captionMedium.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: AppSpacing.sm8),
                          Text(
                            'Status Pemesanan',
                            style: AppTypography.h2.copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                      // Shortcut ke Histori Bulanan
                      IconButton(
                        icon: const Icon(Icons.history_rounded),
                        color: AppColors.ink900,
                        tooltip: 'Histori & Pengeluaran',
                        onPressed: () {
                          context.push('/reservations/history');
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // ── Filter Horizontal Tabs (Stitch Screen 07) ─────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs4),
                  child: SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg16),
                      itemCount: _statusFilters.length,
                      separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm8),
                      itemBuilder: (context, index) {
                        final filter = _statusFilters[index];
                        final isSelected = selectedFilter == filter['id'];

                        return GestureDetector(
                          onTap: () {
                            ref
                                .read(selectedReservationStatusFilterProvider.notifier)
                                .state = filter['id']!;
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.surface0,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.border,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.25),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              filter['label']!,
                              style: AppTypography.captionMedium.copyWith(
                                color: isSelected ? Colors.white : AppColors.ink600,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md12)),

              // ── Reservation Cards List ─────────────────────────────────────
              reservationsAsync.when(
                data: (reservations) {
                  if (reservations.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: AppEmptyState(
                        illustration: const EmptyReservationsIllustration(size: 160),
                        title: 'Belum Ada Pemesanan',
                        message: 'Anda belum memiliki reservasi dengan status ini. Jelajahi katalog dan pesan space nyaman Anda sekarang.',
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg16,
                      0,
                      AppSpacing.lg16,
                      AppSpacing.xxl32,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = reservations[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md12),
                            child: _ReservationCard(
                              reservation: item,
                              onCancel: () => _showCancelDialog(item),
                              onOpenTicket: () {
                                context.push('/reservations/ticket/${item.id}');
                              },
                            ),
                          );
                        },
                        childCount: reservations.length,
                      ),
                    ),
                  );
                },
                loading: () => SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => AppShimmer.reservationCard(),
                      childCount: 3,
                    ),
                  ),
                ),
                error: (error, stack) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppEmptyState(
                    illustration: const NetworkErrorIllustration(size: 160),
                    title: 'Gagal Memuat Reservasi',
                    message: '$error',
                    actionLabel: 'Coba Lagi',
                    onAction: () => ref.invalidate(myReservationsProvider),
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

/// Card item reservasi dengan status badge sesuai Stitch Screen 07
class _ReservationCard extends StatelessWidget {
  final ReservationModel reservation;
  final VoidCallback onCancel;
  final VoidCallback onOpenTicket;

  const _ReservationCard({
    required this.reservation,
    required this.onCancel,
    required this.onOpenTicket,
  });

  @override
  Widget build(BuildContext context) {
    final status = reservation.status.toLowerCase();
    final isCancelled = status == 'dibatalkan';
    final isActive = status == 'aktif';
    final isApproved = status == 'disetujui';
    final isPending = status == 'belum_dikonfirm' || status == 'menunggu';

    DateTime? parsedDate;
    try {
      parsedDate = DateTime.parse(reservation.tanggal);
    } catch (_) {}

    final dateDisplay = parsedDate != null
        ? DateFormatter.formatFullDate(parsedDate)
        : reservation.tanggal;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface0,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.border,
        ),
        boxShadow: AppSpacing.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        child: Container(
          decoration: BoxDecoration(
            border: isActive
                ? const Border(left: BorderSide(color: AppColors.primary, width: 4))
                : null,
          ),
          padding: const EdgeInsets.all(AppSpacing.lg16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card: Booking Code & Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservation.kodeBooking,
                        style: AppTypography.captionMedium.copyWith(
                          color: AppColors.ink600,
                          fontSize: 11.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        reservation.namaSpace ?? 'Workstation Space',
                        style: AppTypography.h3.copyWith(
                          decoration: isCancelled ? TextDecoration.lineThrough : null,
                          color: isCancelled ? AppColors.ink600 : AppColors.ink900,
                        ),
                      ),
                    ],
                  ),
                  _buildStatusBadge(status),
                ],
              ),
              const SizedBox(height: AppSpacing.md12),

              // Date & Time
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppColors.ink600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$dateDisplay • ${reservation.jamMulai} - ${reservation.jamSelesai} (${reservation.durasi} Jam)',
                    style: AppTypography.bodyMedium.copyWith(
                      fontSize: 13.5,
                      color: isCancelled ? AppColors.ink600 : AppColors.ink900,
                      decoration: isCancelled ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Biaya:',
                    style: AppTypography.caption.copyWith(color: AppColors.ink600),
                  ),
                  Text(
                    CurrencyFormatter.format(reservation.totalBayar),
                    style: AppTypography.bodyEmphasis.copyWith(
                      color: isCancelled ? AppColors.ink600 : AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Footer Actions
              if (isPending || isApproved || isActive) ...[
                const SizedBox(height: AppSpacing.md12),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: AppSpacing.sm8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isPending || isApproved)
                      OutlinedButton(
                        onPressed: onCancel,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.danger),
                          foregroundColor: AppColors.danger,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Batalkan', style: TextStyle(fontSize: 12)),
                      ),
                    if (isApproved || isActive) ...[
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: onOpenTicket,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.qr_code_rounded, size: 16),
                        label: const Text('E-Ticket', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    IconData icon;
    String label;

    switch (status) {
      case 'belum_dikonfirm':
      case 'menunggu':
        bg = const Color(0xFFFFF4E5);
        text = const Color(0xFFB26B00);
        icon = Icons.hourglass_empty;
        label = 'Menunggu Konfirmasi';
        break;
      case 'disetujui':
        bg = const Color(0xFFE0F4F2);
        text = const Color(0xFF0E5C56);
        icon = Icons.check_circle_outline;
        label = 'Disetujui';
        break;
      case 'aktif':
        bg = AppColors.primaryContainer;
        text = AppColors.primary;
        icon = Icons.pin_drop_outlined;
        label = 'Aktif Digunakan';
        break;
      case 'selesai':
        bg = const Color(0xFFD4E9DB);
        text = const Color(0xFF1E5631);
        icon = Icons.done_all;
        label = 'Selesai';
        break;
      case 'dibatalkan':
      default:
        bg = const Color(0xFFFFDAD6);
        text = AppColors.danger;
        icon = Icons.cancel_outlined;
        label = 'Dibatalkan';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: text),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: text,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
