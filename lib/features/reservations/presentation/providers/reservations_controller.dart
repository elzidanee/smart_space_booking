import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../spaces/data/models/space_models.dart';
import '../../data/datasources/reservations_remote_datasource.dart';
import '../../domain/repositories/reservations_repository.dart';
import '../../../spaces/domain/repositories/spaces_repository.dart';

/// Provider filter status reservasi: 'all' | 'menunggu' | 'disetujui' | 'aktif' | 'selesai' | 'dibatalkan'
final selectedReservationStatusFilterProvider =
    StateProvider<String>((ref) => 'all');

/// Provider filter bulan histori
final selectedHistoryMonthProvider =
    StateProvider<int>((ref) => DateTime.now().month);

/// Provider filter tahun histori
final selectedHistoryYearProvider =
    StateProvider<int>((ref) => DateTime.now().year);

/// Provider daftar reservasi member
final myReservationsProvider =
    FutureProvider.autoDispose<List<ReservationModel>>((ref) async {
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 2), () => link.close());
  ref.onDispose(() => timer.cancel());

  final repository = ref.watch(reservationsRepositoryProvider);
  final status = ref.watch(selectedReservationStatusFilterProvider);
  final list = await repository.getMyReservations(status: status);

  // Trik Penyelamat Data (Defensive Data Enrichment):
  // Kadang respon backend UKK untuk daftar tiket cuma ngasih data mentah (totalBayar 0 atau nama/foto ruangan null).
  // Biar tampilan kartu tiket di HP member gak kosong melompong:
  // Kita ambil katalog ruangan dari SpacesRepository, lalu kita jodohkan (mapping) berdasarkan spaceId atau nama ruangannya.
  if (list.any((r) => r.totalBayar <= 0)) {
    try {
      final spacesRepo = ref.watch(spacesRepositoryProvider);
      final spaces = await spacesRepo.getSpaces();
      final spaceMap = {for (final s in spaces) s.id: s};
      final spaceNameMap = {
        for (final s in spaces) s.nama.toLowerCase().trim(): s
      };

      return list.map((r) {
        if (r.totalBayar > 0) return r;
        final matched = spaceMap[r.spaceId] ??
            spaceNameMap[r.namaSpace?.toLowerCase().trim() ?? ''];
        if (matched != null && matched.hargaPerJam > 0) {
          final durasi = r.durasi > 0 ? r.durasi : 1;
          final calcSubtotal = matched.hargaPerJam * durasi;
          // Hitung ulang total bayar: subtotal - diskon
          final calcTotal = (calcSubtotal - r.potonganDiskon) > 0
              ? (calcSubtotal - r.potonganDiskon)
              : calcSubtotal;
          return r.copyWith(
            subtotal: r.subtotal > 0 ? r.subtotal : calcSubtotal,
            totalBayar: calcTotal,
            namaSpace: r.namaSpace ?? matched.nama,
            tipeSpace: r.tipeSpace ?? matched.tipe,
            fotoSpace: r.fotoSpace ?? matched.foto,
          );
        }
        return r;
      }).toList();
    } catch (_) {}
  }

  return list;
});

/// Provider histori & rekapitulasi pengeluaran bulanan
final myHistoryReservationsProvider =
    FutureProvider.autoDispose<ReservationHistorySummary>((ref) async {
  final repository = ref.watch(reservationsRepositoryProvider);
  final bulan = ref.watch(selectedHistoryMonthProvider);
  final tahun = ref.watch(selectedHistoryYearProvider);
  return await repository.getMyHistory(bulan: bulan, tahun: tahun);
});

/// Provider detail reservasi spesifik
final reservationDetailProvider =
    FutureProvider.autoDispose.family<ReservationModel, int>((ref, id) async {
  final repository = ref.watch(reservationsRepositoryProvider);
  return await repository.getReservationById(id);
});

/// Provider e-ticket digital
final eTicketProvider =
    FutureProvider.autoDispose.family<ReservationModel, int>((ref, id) async {
  final repository = ref.watch(reservationsRepositoryProvider);
  ReservationModel ticket = await repository.getETicket(id);

  // Enrichment: jika totalBayar masih 0 setelah parsing (backend kadang tidak mengirim field harga),
  // hitung ulang dari katalog ruangan berdasarkan spaceId atau nama space.
  if (ticket.totalBayar <= 0) {
    try {
      final spacesRepo = ref.watch(spacesRepositoryProvider);
      final spaces = await spacesRepo.getSpaces();
      final spaceMap = {for (final s in spaces) s.id: s};
      final spaceNameMap = {
        for (final s in spaces) s.nama.toLowerCase().trim(): s
      };

      final matched = spaceMap[ticket.spaceId] ??
          spaceNameMap[ticket.namaSpace?.toLowerCase().trim() ?? ''];
      if (matched != null && matched.hargaPerJam > 0) {
        final durasi = ticket.durasi > 0 ? ticket.durasi : 1;
        final calcSubtotal = matched.hargaPerJam * durasi;
        final calcTotal = (calcSubtotal - ticket.potonganDiskon) > 0
            ? (calcSubtotal - ticket.potonganDiskon)
            : calcSubtotal;
        ticket = ticket.copyWith(
          subtotal: ticket.subtotal > 0 ? ticket.subtotal : calcSubtotal,
          totalBayar: calcTotal,
          namaSpace: ticket.namaSpace ?? matched.nama,
          tipeSpace: ticket.tipeSpace ?? matched.tipe,
          fotoSpace: ticket.fotoSpace ?? matched.foto,
        );
      }
    } catch (_) {}
  }

  return ticket;
});

/// Provider tiket aktif paling baru (untuk Tab 3 Tiket pada Shell)
final latestActiveTicketProvider =
    FutureProvider.autoDispose<ReservationModel?>((ref) async {
  final repository = ref.watch(reservationsRepositoryProvider);
  final all = await repository.getMyReservations();
  // Cari tiket yang disetujui atau aktif
  final activeList = all.where((r) => r.status == 'aktif' || r.status == 'disetujui').toList();
  if (activeList.isNotEmpty) {
    return activeList.first;
  }
  return all.isNotEmpty ? all.first : null;
});

/// Controller untuk aksi pembatalan reservasi
class CancelReservationController extends StateNotifier<AsyncValue<bool>> {
  final ReservationsRepository _repository;
  final Ref _ref;

  CancelReservationController(this._repository, this._ref)
      : super(const AsyncValue.data(false));

  Future<bool> cancel(int id) async {
    if (!mounted) return false;
    state = const AsyncValue.loading();
    try {
      final success = await _repository.cancelReservation(id);
      if (!mounted) return success;
      state = AsyncValue.data(success);
      if (success) {
        _ref.invalidate(myReservationsProvider);
        _ref.invalidate(myHistoryReservationsProvider);
        _ref.invalidate(latestActiveTicketProvider);
      }
      return success;
    } catch (e, stack) {
      if (!mounted) return false;
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}

// Tidak pakai autoDispose agar tidak ter-dispose di tengah operasi async cancel
final cancelReservationControllerProvider =
    StateNotifierProvider<CancelReservationController, AsyncValue<bool>>((ref) {
  final repository = ref.watch(reservationsRepositoryProvider);
  return CancelReservationController(repository, ref);
});

// Provider agregasi statistik pemakaian untuk ditampilkan di layar Profil Member:
// Menghitung: Total Booking, Total Jam Pemakaian, dan Total Biaya yang sudah dikeluarkan.
final memberUsageStatsProvider = FutureProvider.autoDispose<
    ({int totalBooking, int totalJam, int totalPengeluaran})>((ref) async {
  final repo = ref.watch(reservationsRepositoryProvider);

  List<ReservationModel> allReservations = [];
  try {
    allReservations = await repo.getMyReservations(status: 'all');
  } catch (e) {
    dev.log('[MEMBER STATS] Gagal load all reservations: $e', name: 'MEMBER');
  }

  // 1. Ambil transaksi yang valid (buang yang dibatalkan biar statistiknya gak palsu)
  final validRes = allReservations
      .where((r) => r.status.toLowerCase() != 'dibatalkan')
      .toList();
  final resBooking = validRes.length;

  // 2. Akumulasi jam sewa pake .fold() (mirip rumus reduce di JavaScript):
  // Kita jumlahkan durasi dari setiap tiket (0 + tiket1 + tiket2 + ...)
  final resJam =
      validRes.fold<int>(0, (sum, r) => sum + (r.durasi > 0 ? r.durasi : 1));

  // 3. Akumulasi total rupiah yang dibayar
  final resPengeluaran =
      validRes.fold<int>(0, (sum, r) => sum + r.totalBayar);

  // 4. Bandingkan dengan riwayat bulanan dari server backend:
  int histBooking = 0;
  int histJam = 0;
  int histPengeluaran = 0;
  try {
    final bulan = ref.watch(selectedHistoryMonthProvider);
    final tahun = ref.watch(selectedHistoryYearProvider);
    final history = await repo.getMyHistory(bulan: bulan, tahun: tahun);
    histBooking = history.totalTransaksi;
    histJam = history.totalJam;
    histPengeluaran = history.totalPengeluaran;
  } catch (_) {}

  // Pilih angka yang paling tinggi / lengkap antara hitungan lokal vs data history backend
  // Biar tampilan statistik di profil user selalu terisi akurat dan gak 0
  return (
    totalBooking: resBooking > histBooking ? resBooking : histBooking,
    totalJam: resJam > histJam ? resJam : histJam,
    totalPengeluaran:
        resPengeluaran > histPengeluaran ? resPengeluaran : histPengeluaran,
  );
});
