import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_illustrations.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../providers/spaces_controller.dart';
import '../../data/models/space_models.dart';

/// Layar Detail & Pemesanan Space sesuai Stitch Screen 06 (522764a8941d41a1b90eb3e285424c15).
class SpaceDetailBookingScreen extends ConsumerStatefulWidget {
  final int spaceId;

  const SpaceDetailBookingScreen({
    super.key,
    required this.spaceId,
  });

  @override
  ConsumerState<SpaceDetailBookingScreen> createState() =>
      _SpaceDetailBookingScreenState();
}

class _SpaceDetailBookingScreenState
    extends ConsumerState<SpaceDetailBookingScreen> {
  final _promoController = TextEditingController();
  bool _isFavorite = false;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final bookingState = ref.read(bookingControllerProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: bookingState.selectedDate.isBefore(today) ? today : bookingState.selectedDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.ink900,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref.read(bookingControllerProvider.notifier).setDate(picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final bookingState = ref.read(bookingControllerProvider);
    final picked = await showTimePicker(
      context: context,
      initialTime: bookingState.selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.ink900,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref.read(bookingControllerProvider.notifier).setTime(picked);
    }
  }

  void _showBookingConfirmationDialog(SpaceModel space) {
    final bookingState = ref.read(bookingControllerProvider);
    final subtotal = bookingState.calculateSubtotal(space.hargaPerJam);
    final diskon = bookingState.calculateDiscount(subtotal);
    final total = bookingState.calculateTotal(space.hargaPerJam);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusBottomSheet),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl24,
            vertical: AppSpacing.xl24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle pill
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

              Text('Konfirmasi Pemesanan', style: AppTypography.h2),
              const SizedBox(height: AppSpacing.xs4),
              Text(
                'Periksa kembali rincian reservasi workstation Anda sebelum melanjutkan.',
                style: AppTypography.caption,
              ),
              const SizedBox(height: AppSpacing.lg16),

              // Rincian Box
              Container(
                padding: const EdgeInsets.all(AppSpacing.md12),
                decoration: BoxDecoration(
                  color: AppColors.surface50,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildConfirmRow('Ruangan/Space', space.nama),
                    const SizedBox(height: 8),
                    _buildConfirmRow('Tanggal', bookingState.displayDate),
                    const SizedBox(height: 8),
                    _buildConfirmRow('Waktu', '${bookingState.formattedTime} WIB (${bookingState.durationHours} Jam)'),
                    const SizedBox(height: 8),
                    _buildConfirmRow('Subtotal', CurrencyFormatter.format(subtotal)),
                    if (diskon > 0 && bookingState.appliedPromo != null) ...[
                      const SizedBox(height: 8),
                      _buildConfirmRow(
                        'Diskon (${bookingState.appliedPromo!.kode})',
                        '-${CurrencyFormatter.format(diskon)}',
                        isPromo: true,
                      ),
                    ],
                    const Divider(height: 16),
                    _buildConfirmRow(
                      'Total Pembayaran',
                      CurrencyFormatter.format(total),
                      isTotal: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl24),

              // Tombol Konfirmasi
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final res = await ref
                        .read(bookingControllerProvider.notifier)
                        .submitBooking(space.id);

                    if (!mounted) return;

                    if (res != null) {
                      _showSuccessBookingDialog(res);
                    } else {
                      final err = ref.read(bookingControllerProvider).errorMessage;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(err ?? 'Gagal membuat reservasi.'),
                          backgroundColor: AppColors.danger,
                        ),
                      );
                    }
                  },
                  child: const Text('Konfirmasi & Buat Reservasi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessBookingDialog(ReservationModel reservation) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        ),
        title: Center(
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 36,
                ),
              ),
              const SizedBox(height: AppSpacing.md12),
              Text(
                'Reservasi Berhasil Dibuat!',
                style: AppTypography.h2,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Kode booking reservasi Anda:',
              style: AppTypography.caption,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                reservation.kodeBooking,
                style: AppTypography.h2.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md12),
            Text(
              'Status saat ini: Belum Dikonfirmasi. Menunggu persetujuan dari pengelola space.',
              style: AppTypography.caption.copyWith(color: AppColors.ink600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.pop(); // Kembali ke katalog
              },
              child: const Text('Selesai & Kembali ke Beranda'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmRow(String label, String value,
      {bool isTotal = false, bool isPromo = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTypography.bodyEmphasis
              : AppTypography.caption.copyWith(color: AppColors.ink600),
        ),
        Text(
          value,
          style: isTotal
              ? AppTypography.h3.copyWith(color: AppColors.primary)
              : isPromo
                  ? AppTypography.captionMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)
                  : AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final spaceAsync = ref.watch(spaceDetailProvider(widget.spaceId));
    final bookingState = ref.watch(bookingControllerProvider);

    return spaceAsync.when(
      data: (space) {
        final subtotal = bookingState.calculateSubtotal(space.hargaPerJam);
        final diskon = bookingState.calculateDiscount(subtotal);
        final total = bookingState.calculateTotal(space.hargaPerJam);

        final validName = space.nama.isNotEmpty ? space.nama : 'Detail Ruangan';

        return Scaffold(
          backgroundColor: AppColors.surface50,
          appBar: AppBar(
            backgroundColor: AppColors.surface0,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.ink900),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/member');
                }
              },
            ),
            title: Text(
              'Detail Ruangan',
              style: AppTypography.h3.copyWith(color: AppColors.ink900),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? AppColors.danger : AppColors.ink900,
                ),
                onPressed: () {
                  setState(() => _isFavorite = !_isFavorite);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isFavorite
                          ? 'Disimpan ke daftar favorit'
                          : 'Dihapus dari favorit'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero Image Banner ──────────────────────────────────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  child: AppNetworkImage(
                    imageUrl: space.foto,
                    fit: BoxFit.cover,
                    height: 220,
                    width: double.infinity,
                  ),
                ),
                const SizedBox(height: AppSpacing.md12),

                // Category & Capacity Pill
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                      ),
                      child: Text(
                        space.tipeLabel,
                        style: AppTypography.captionMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm8),
                    Row(
                      children: [
                        const Icon(Icons.group_outlined, size: 18, color: AppColors.ink600),
                        const SizedBox(width: 4),
                        Text(
                          '${space.kapasitas > 0 ? space.kapasitas : 1} orang',
                          style: AppTypography.caption.copyWith(color: AppColors.ink600),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm8),

                // Nama Space
                Text(validName, style: AppTypography.h1),
                const SizedBox(height: 2),

                // Harga
                RichText(
                  text: TextSpan(
                    text: CurrencyFormatter.format(space.hargaPerJam),
                    style: AppTypography.h2.copyWith(color: AppColors.primary),
                    children: [
                      TextSpan(
                        text: ' / jam',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.ink600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg16),

                // ── Fasilitas Termasuk ─────────────────────────────────
                if (space.fasilitas.isNotEmpty) ...[
                  Text('Fasilitas Termasuk', style: AppTypography.bodyEmphasis),
                  const SizedBox(height: AppSpacing.sm8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: space.fasilitas.map((f) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surface0,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_getFacilityIcon(f), size: 16, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(f, style: AppTypography.captionMedium),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg16),
                ],

                // ── Deskripsi Ruangan ──────────────────────────────────
                if (space.deskripsi != null && space.deskripsi!.trim().isNotEmpty) ...[
                  Text('Deskripsi Ruangan', style: AppTypography.bodyEmphasis),
                  const SizedBox(height: AppSpacing.xs4),
                  Text(
                    space.deskripsi!,
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.ink600, height: 1.5),
                  ),
                  const SizedBox(height: AppSpacing.xl24),
                ],

                // ── Booking Widget Card (Stitch Screen 06) ───────────────
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl24),
                  decoration: BoxDecoration(
                    color: AppColors.surface0,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppSpacing.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Atur Jadwal Reservasi',
                        style: AppTypography.h2.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: AppSpacing.md12),

                      // Tanggal Picker
                      Text('Tanggal Sewa', style: AppTypography.bodyMedium),
                      const SizedBox(height: AppSpacing.xs4),
                      InkWell(
                        onTap: () => _selectDate(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surface50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 20, color: AppColors.ink600),
                              const SizedBox(width: 10),
                              Text(bookingState.displayDate, style: AppTypography.bodyMedium),
                              const Spacer(),
                              const Icon(Icons.arrow_drop_down, color: AppColors.ink600),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md12),

                      // Grid Waktu Mulai & Durasi
                      Row(
                        children: [
                          // Waktu Mulai
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Waktu Mulai', style: AppTypography.bodyMedium),
                                const SizedBox(height: AppSpacing.xs4),
                                InkWell(
                                  onTap: () => _selectTime(context),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.schedule_outlined, size: 18, color: AppColors.ink600),
                                        const SizedBox(width: 8),
                                        Text(bookingState.formattedTime, style: AppTypography.bodyMedium),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md12),

                          // Durasi Stepper
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Durasi Sewa', style: AppTypography.bodyMedium),
                                const SizedBox(height: AppSpacing.xs4),
                                Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.surface50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove, size: 18),
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          ref.read(bookingControllerProvider.notifier).decrementDuration();
                                        },
                                      ),
                                      Text(
                                        '${bookingState.durationHours} Jam',
                                        style: AppTypography.bodyEmphasis,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add, size: 18),
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          ref.read(bookingControllerProvider.notifier).incrementDuration();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md12),

                      // Tombol Cek Ketersediaan Real-Time
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton.icon(
                          onPressed: bookingState.isCheckingAvailability
                              ? null
                              : () {
                                  ref
                                      .read(bookingControllerProvider.notifier)
                                      .checkAvailability(space.id);
                                },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.secondary, width: 1.5),
                            foregroundColor: AppColors.secondary,
                          ),
                          icon: bookingState.isCheckingAvailability
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.search_rounded, size: 18),
                          label: const Text('Cek Ketersediaan Slot'),
                        ),
                      ),

                      // Availability Status Badge
                      if (bookingState.availabilityResult != null) ...[
                        const SizedBox(height: AppSpacing.sm8),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: bookingState.availabilityResult!.isAvailable
                                  ? const Color(0xFFD4E9DB)
                                  : const Color(0xFFFFDAD6),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  bookingState.availabilityResult!.isAvailable
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  size: 16,
                                  color: bookingState.availabilityResult!.isAvailable
                                      ? const Color(0xFF2D6A4F)
                                      : AppColors.danger,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  bookingState.availabilityResult!.message,
                                  style: AppTypography.captionMedium.copyWith(
                                    color: bookingState.availabilityResult!.isAvailable
                                        ? const Color(0xFF2D6A4F)
                                        : AppColors.danger,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const Divider(height: 28),

                      // ── Input Kode Promo ──────────────────────────────
                      Text('Kode Promo (Opsional)', style: AppTypography.bodyMedium),
                      const SizedBox(height: AppSpacing.xs4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _promoController,
                              textCapitalization: TextCapitalization.characters,
                              decoration: const InputDecoration(
                                hintText: 'Cth: DISKONHEMAT20',
                                prefixIcon: Icon(Icons.local_offer_outlined, size: 20),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm8),
                          ElevatedButton(
                            onPressed: bookingState.isCheckingPromo
                                ? null
                                : () {
                                    ref.read(bookingControllerProvider.notifier).applyPromo(
                                          _promoController.text,
                                          subtotal,
                                        );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.surface50,
                              foregroundColor: AppColors.ink900,
                              elevation: 0,
                              side: const BorderSide(color: AppColors.border),
                              minimumSize: const Size(88, 48),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            child: bookingState.isCheckingPromo
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Terapkan'),
                          ),
                        ],
                      ),

                      // Active Promo Chip
                      if (bookingState.appliedPromo != null) ...[
                        const SizedBox(height: AppSpacing.sm8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_outline, size: 16, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(
                                '${bookingState.appliedPromo!.kode} (-${bookingState.appliedPromo!.persentase}%)',
                                style: AppTypography.captionMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  ref.read(bookingControllerProvider.notifier).removePromo();
                                  _promoController.clear();
                                },
                                child: const Icon(Icons.close, size: 16, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Promo Error Message
                      if (bookingState.promoError != null) ...[
                        const SizedBox(height: AppSpacing.xs4),
                        Text(
                          bookingState.promoError!,
                          style: AppTypography.caption.copyWith(color: AppColors.danger),
                        ),
                      ],

                      const Divider(height: 28),

                      // ── Rincian Biaya ─────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtotal (${bookingState.durationHours} Jam)',
                            style: AppTypography.caption.copyWith(color: AppColors.ink600),
                          ),
                          Text(
                            CurrencyFormatter.format(subtotal),
                            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      if (diskon > 0) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Potongan Diskon',
                              style: AppTypography.caption.copyWith(color: AppColors.primary),
                            ),
                            Text(
                              '-${CurrencyFormatter.format(diskon)}',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 10),
                      const Divider(height: 1, color: AppColors.border),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Pembayaran', style: AppTypography.bodyEmphasis),
                          Text(
                            CurrencyFormatter.format(total),
                            style: AppTypography.h2.copyWith(color: AppColors.ink900),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 90), // Space for sticky bottom bar
              ],
            ),
          ),

          // ── Sticky Bottom Bar CTA ──────────────────────────────────────────
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface0,
              border: const Border(top: BorderSide(color: AppColors.border)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Bayar',
                        style: AppTypography.caption.copyWith(color: AppColors.ink600),
                      ),
                      Text(
                        CurrencyFormatter.format(total),
                        style: AppTypography.h3.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.lg16),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: bookingState.isSubmitting
                            ? null
                            : () => _showBookingConfirmationDialog(space),
                        child: bookingState.isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Lanjutkan Reservasi'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Detail Space'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/member');
              }
            },
          ),
        ),
        body: AppEmptyState(
          illustration: const NetworkErrorIllustration(size: 160),
          title: 'Gagal Memuat Detail Space',
          message: err.toString().replaceAll('Exception: ', '').replaceAll('ServerFailure: ', ''),
          actionLabel: 'Coba Lagi',
          onAction: () => ref.invalidate(spaceDetailProvider(widget.spaceId)),
        ),
      ),
    );
  }

  IconData _getFacilityIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('wifi') || lower.contains('lan')) return Icons.wifi;
    if (lower.contains('tv') || lower.contains('proyektor') || lower.contains('screen')) {
      return Icons.tv;
    }
    if (lower.contains('ac') || lower.contains('air')) return Icons.ac_unit;
    if (lower.contains('whiteboard') || lower.contains('board')) return Icons.aspect_ratio;
    if (lower.contains('sound') || lower.contains('audio') || lower.contains('speaker')) {
      return Icons.speaker;
    }
    if (lower.contains('coffee') || lower.contains('kopi') || lower.contains('bar')) {
      return Icons.local_cafe_outlined;
    }
    if (lower.contains('lock') || lower.contains('key')) return Icons.lock_outline;
    return Icons.check_circle_outline;
  }
}
