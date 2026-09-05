import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../spaces/data/models/space_models.dart';
import '../../domain/repositories/admin_repository.dart';
import '../providers/admin_controller.dart';
import '../widgets/confirmation_dialog.dart';

class AdminReservationDetailScreen extends ConsumerStatefulWidget {
  final ReservationModel reservation;

  const AdminReservationDetailScreen({
    super.key,
    required this.reservation,
  });

  @override
  ConsumerState<AdminReservationDetailScreen> createState() =>
      _AdminReservationDetailScreenState();
}

class _AdminReservationDetailScreenState
    extends ConsumerState<AdminReservationDetailScreen> {
  late ReservationModel _current;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _current = widget.reservation;
    _fetchLatestDetail();
  }

  Future<void> _fetchLatestDetail() async {
    try {
      final repo = ref.read(adminRepositoryProvider);
      final latest = await repo.getReservationById(_current.id);
      if (mounted) {
        setState(() => _current = latest);
      }
    } catch (_) {}
  }

  Future<void> _handleCheckIn() async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Konfirmasi Check-in',
      message:
          'Pastikan tamu telah berada di lokasi coworking dan kode booking sesuai.',
      memberName: _current.namaMember ?? 'Tamu',
      bookingCode: _current.kodeBooking,
      spaceName: _current.namaSpace,
      confirmLabel: 'Check-in Sekarang',
      confirmColor: AppColors.info,
      icon: Icons.login_rounded,
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(adminReservationsControllerProvider.notifier)
          .checkIn(_current.id);
      if (mounted) {
        setState(() {
          _current = _current.copyWith(status: 'aktif');
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tamu berhasil Check-in! Status berubah menjadi Aktif.'),
            backgroundColor: AppColors.info,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal melakukan check-in: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _handleCheckOut() async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Konfirmasi Check-out',
      message:
          'Tamu akan menyelesaikan sesi reservasi. Aksi ini tidak dapat dibatalkan.',
      memberName: _current.namaMember ?? 'Tamu',
      bookingCode: _current.kodeBooking,
      spaceName: _current.namaSpace,
      confirmLabel: 'Selesaikan & Check-out',
      confirmColor: AppColors.success,
      icon: Icons.check_circle_outline_rounded,
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(adminReservationsControllerProvider.notifier)
          .checkOut(_current.id);
      if (mounted) {
        setState(() {
          _current = _current.copyWith(status: 'selesai');
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-out berhasil! Status reservasi Selesai.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal melakukan check-out: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _handleChangeStatus(String newStatus) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Ubah Status Reservasi',
      message: 'Apakah Anda yakin ingin mengubah status menjadi "$newStatus"?',
      bookingCode: _current.kodeBooking,
      memberName: _current.namaMember,
      confirmLabel: 'Ubah Status',
      confirmColor: AppColors.secondary,
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(adminReservationsControllerProvider.notifier)
          .updateReservationStatus(_current.id, newStatus);
      if (mounted) {
        setState(() {
          _current = _current.copyWith(status: newStatus);
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status berhasil diubah menjadi $newStatus'),
            backgroundColor: AppColors.secondary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengubah status: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface50,
      appBar: AppBar(
        title: const Text('Detail Reservasi Tamu'),
        backgroundColor: AppColors.surface0,
        elevation: 0,
        centerTitle: false,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _handleChangeStatus,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'disetujui',
                child: Text('Setujui Reservasi'),
              ),
              const PopupMenuItem(
                value: 'dibatalkan',
                child: Text('Batalkan Reservasi'),
              ),
              const PopupMenuItem(
                value: 'belum_dikonfirm',
                child: Text('Kembalikan ke Menunggu'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.secondary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Status Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface0,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(28, 25, 23, 0.04),
                          blurRadius: 10,
                          offset: Offset(0, 4),
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
                              _current.kodeBooking,
                              style: AppTypography.h2.copyWith(
                                color: AppColors.secondary,
                                fontSize: 18,
                              ),
                            ),
                            StatusBadge(status: ReservasiStatus.fromApi(_current.status)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: AppColors.border, height: 1),
                        const SizedBox(height: 12),
                        Text(
                          _current.namaSpace ?? 'Space',
                          style: AppTypography.h2.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kategori: ${_current.tipeSpace?.replaceAll('_', ' ').toUpperCase() ?? "RUANGAN"}',
                          style: AppTypography.caption.copyWith(color: AppColors.ink600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Data Tamu / Pemesan Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface0,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('INFORMASI PEMESAN', style: AppTypography.sectionLabel),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          icon: Icons.person_outline,
                          label: 'Nama Lengkap',
                          value: _current.namaMember ?? 'Ahmad Fauzi',
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          icon: Icons.phone_outlined,
                          label: 'Nomor Kontak',
                          value: _current.teleponMember ?? '081234567890',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Jadwal Reservasi Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface0,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('JADWAL PENGGUNAAN', style: AppTypography.sectionLabel),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Tanggal',
                          value: DateFormatter.formatIndonesian(_current.tanggal),
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          icon: Icons.access_time,
                          label: 'Waktu Sewa',
                          value:
                              '${_current.jamMulai} - ${_current.jamSelesai} (${_current.durasi} Jam)',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Rincian Biaya
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface0,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('RINCIAN PEMBAYARAN', style: AppTypography.sectionLabel),
                        const SizedBox(height: 12),
                        () {
                          final subtotalVal = _current.subtotal > 0
                              ? _current.subtotal
                              : (_current.totalBayar > 0
                                  ? _current.totalBayar + _current.potonganDiskon
                                  : 0);
                          final totalVal = _current.totalBayar > 0
                              ? _current.totalBayar
                              : (subtotalVal > 0
                                  ? (subtotalVal - _current.potonganDiskon > 0
                                      ? subtotalVal - _current.potonganDiskon
                                      : subtotalVal)
                                  : 0);

                          return Column(
                            children: [
                              _buildPriceRow(
                                'Subtotal (${_current.durasi} jam)',
                                CurrencyFormatter.formatRupiah(subtotalVal),
                              ),
                              if (_current.potonganDiskon > 0) ...[
                                const SizedBox(height: 6),
                                _buildPriceRow(
                                  'Potongan Diskon Promo',
                                  '- ${CurrencyFormatter.formatRupiah(_current.potonganDiskon)}',
                                  isDiscount: true,
                                ),
                              ],
                              const SizedBox(height: 10),
                              const Divider(color: AppColors.border),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Total Tagihan', style: AppTypography.h2.copyWith(fontSize: 16)),
                                  Text(
                                    CurrencyFormatter.formatRupiah(totalVal),
                                    style: AppTypography.h2.copyWith(
                                      color: AppColors.secondary,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Operational Action Buttons (A7)
                  if (_current.status == 'belum_dikonfirm') ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _handleChangeStatus('disetujui'),
                        icon: const Icon(Icons.check),
                        label: const Text('Setujui Reservasi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _handleChangeStatus('dibatalkan'),
                        icon: const Icon(Icons.close, color: AppColors.danger),
                        label: const Text('Tolak / Batalkan Reservasi'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(color: AppColors.danger),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ] else if (_current.status == 'disetujui') ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _handleCheckIn,
                        icon: const Icon(Icons.login_rounded),
                        label: const Text('Tamu Hadir — Check-in Sekarang'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.info,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ] else if (_current.status == 'aktif') ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _handleCheckOut,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Selesai Sesi — Check-out Tamu'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface0,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: Text(
                          _current.status == 'selesai'
                              ? 'Reservasi telah selesai diproses.'
                              : 'Reservasi ini telah dibatalkan.',
                          style: AppTypography.captionMedium.copyWith(color: AppColors.ink600),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.secondary),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: AppTypography.caption.copyWith(color: AppColors.ink600),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.captionMedium.copyWith(
              color: AppColors.ink900,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              color: isDiscount ? AppColors.primary : AppColors.ink600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTypography.captionMedium.copyWith(
              color: isDiscount ? AppColors.primary : AppColors.ink900,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
