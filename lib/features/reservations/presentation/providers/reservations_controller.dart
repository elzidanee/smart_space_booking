import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../spaces/data/models/space_models.dart';
import '../../data/datasources/reservations_remote_datasource.dart';
import '../../domain/repositories/reservations_repository.dart';

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
  final repository = ref.watch(reservationsRepositoryProvider);
  final status = ref.watch(selectedReservationStatusFilterProvider);
  return await repository.getMyReservations(status: status);
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
  return await repository.getETicket(id);
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
    state = const AsyncValue.loading();
    try {
      final success = await _repository.cancelReservation(id);
      state = AsyncValue.data(success);
      if (success) {
        _ref.invalidate(myReservationsProvider);
        _ref.invalidate(myHistoryReservationsProvider);
        _ref.invalidate(latestActiveTicketProvider);
      }
      return success;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}

final cancelReservationControllerProvider =
    StateNotifierProvider.autoDispose<CancelReservationController, AsyncValue<bool>>((ref) {
  final repository = ref.watch(reservationsRepositoryProvider);
  return CancelReservationController(repository, ref);
});
