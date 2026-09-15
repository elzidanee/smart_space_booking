import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/repositories/spaces_repository.dart';
import '../../data/models/space_models.dart';

/// Provider filter kategori terpilih: 'all' | 'personal_desk' | 'meeting_room' | 'private_office'
final selectedSpaceCategoryProvider = StateProvider<String>((ref) => 'all');

/// Provider keyword pencarian
final spaceSearchQueryProvider = StateProvider<String>((ref) => '');

// Provider daftar space (dengan filter kategori & pencarian):
// Trik Caching Memori 5 Menit:
// Pake autoDispose biar hemat RAM HP, tapi kita kasih napas 5 menit pake ref.keepAlive().
// Jadi kalau user bolak-balik buka tab katalog dalam kurun 5 menit, datanya langsung muncul instan
// tanpa perlu request ulang ke internet. Lewat dari 5 menit, cache baru dibersihkan.
final spacesListProvider = FutureProvider.autoDispose<List<SpaceModel>>((ref) async {
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 5), () => link.close());
  ref.onDispose(() => timer.cancel());

  final repository = ref.watch(spacesRepositoryProvider);
  final category = ref.watch(selectedSpaceCategoryProvider);
  final query = ref.watch(spaceSearchQueryProvider);

  final spaces = await repository.getSpaces(
    query: query.isEmpty ? null : query,
    tipe: category == 'all' ? null : category,
  );

  // Client-side fallback filter: menjamin akurasi jika server API mengabaikan query param
  return spaces.where((space) {
    if (category != 'all' && category != 'semua' && category.isNotEmpty) {
      final s = space.tipe.toLowerCase().replaceAll(' ', '_').trim();
      final f = category.toLowerCase().replaceAll(' ', '_').trim();
      final isDeskMatch = (s == 'desk' || s == 'personal_desk') && (f == 'desk' || f == 'personal_desk');
      final isMeetingMatch = (s == 'meeting_room' || s == 'meeting') && (f == 'meeting_room' || f == 'meeting');
      final isOfficeMatch = (s == 'private_office' || s == 'office') && (f == 'private_office' || f == 'office');
      if (!(isDeskMatch || isMeetingMatch || isOfficeMatch || s == f || s.contains(f) || f.contains(s))) {
        return false;
      }
    }
    if (query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      final matchNama = space.nama.toLowerCase().contains(q);
      final matchTipe = space.tipeLabel.toLowerCase().contains(q) || space.tipe.toLowerCase().contains(q);
      final matchFasilitas = space.fasilitas.any((fas) => fas.toLowerCase().contains(q));
      final matchDesc = space.deskripsi?.toLowerCase().contains(q) ?? false;
      if (!matchNama && !matchTipe && !matchFasilitas && !matchDesc) return false;
    }
    return true;
  }).toList();
});

/// Provider tipe/kategori space dari API /api/spaces/types (FR-06 / Endpoint #12)
final spaceTypesProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 10), () => link.close());
  ref.onDispose(() => timer.cancel());

  final repository = ref.watch(spacesRepositoryProvider);
  return await repository.getSpaceTypes();
});

/// Provider promo/diskon aktif dari API /api/diskon/active (Endpoint #16)
final activeDiscountsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 5), () => link.close());
  ref.onDispose(() => timer.cancel());

  final repository = ref.watch(spacesRepositoryProvider);
  return await repository.getActiveDiscounts();
});

/// Provider detail space berdasarkan ID
final spaceDetailProvider =
    FutureProvider.autoDispose.family<SpaceModel, int>((ref, spaceId) async {
  final repository = ref.watch(spacesRepositoryProvider);
  return await repository.getSpaceById(spaceId);
});

/// State untuk formulir booking di Layar M4
class BookingFormState {
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final int durationHours;
  final bool isCheckingAvailability;
  final AvailabilityCheckResult? availabilityResult;
  final bool isCheckingPromo;
  final PromoCheckResult? appliedPromo;
  final String? promoError;
  final bool isSubmitting;
  final ReservationModel? createdReservation;
  final String? errorMessage;

  const BookingFormState({
    required this.selectedDate,
    required this.selectedTime,
    this.durationHours = 3,
    this.isCheckingAvailability = false,
    this.availabilityResult,
    this.isCheckingPromo = false,
    this.appliedPromo,
    this.promoError,
    this.isSubmitting = false,
    this.createdReservation,
    this.errorMessage,
  });

  String get formattedDate => DateFormatter.toApiDate(selectedDate);
  String get displayDate => DateFormatter.formatFullDate(selectedDate);

  String get formattedTime {
    final h = selectedTime.hour.toString().padLeft(2, '0');
    final m = selectedTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // --- Rumus Perhitungan Biaya Booking ---
  // 1. Subtotal = harga ruangan per jam dikalikan berapa jam durasi booking yang dipilih
  int calculateSubtotal(int hargaPerJam) => hargaPerJam * durationHours;

  // 2. Diskon = kalau ada voucher persentase (misal 20%), hitung (subtotal * 20 / 100).
  // Dibulatkan pake .round() biar gak ada angka pecahan/perak desimal.
  int calculateDiscount(int subtotal) {
    if (appliedPromo == null) return 0;
    if (appliedPromo!.persentase > 0 && subtotal > 0) {
      return (subtotal * appliedPromo!.persentase / 100).round();
    }
    if (appliedPromo!.potongan > 0) return appliedPromo!.potongan;
    return 0;
  }

  // 3. Total Bayar = Subtotal dikurangi potongan diskon.
  // Dijaga minimal 0 (total < 0 ? 0 : total) biar gak minus kalau dapet voucher gratis/100%.
  int calculateTotal(int hargaPerJam) {
    final subtotal = calculateSubtotal(hargaPerJam);
    final discount = calculateDiscount(subtotal);
    final total = subtotal - discount;
    return total < 0 ? 0 : total;
  }

  BookingFormState copyWith({
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    int? durationHours,
    bool? isCheckingAvailability,
    AvailabilityCheckResult? availabilityResult,
    bool clearAvailability = false,
    bool? isCheckingPromo,
    PromoCheckResult? appliedPromo,
    bool clearPromo = false,
    String? promoError,
    bool clearPromoError = false,
    bool? isSubmitting,
    ReservationModel? createdReservation,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BookingFormState(
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      durationHours: durationHours ?? this.durationHours,
      isCheckingAvailability: isCheckingAvailability ?? this.isCheckingAvailability,
      availabilityResult:
          clearAvailability ? null : (availabilityResult ?? this.availabilityResult),
      isCheckingPromo: isCheckingPromo ?? this.isCheckingPromo,
      appliedPromo: clearPromo ? null : (appliedPromo ?? this.appliedPromo),
      promoError: clearPromoError ? null : (promoError ?? this.promoError),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      createdReservation: createdReservation ?? this.createdReservation,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// Controller untuk mengelola seluruh formulir pemesanan ruangan (Layar Booking).
class BookingController extends StateNotifier<BookingFormState> {
  final SpacesRepository _repository;

  BookingController(this._repository)
      : super(BookingFormState(
          selectedDate: DateTime.now(),
          selectedTime: const TimeOfDay(hour: 9, minute: 0),
          durationHours: 3,
        ));

  // Catatan: Di setiap perubahan tanggal/jam/durasi di bawah, kita pasang 'clearAvailability: true'.
  // Kenapa? Karena kalau jadwal diubah, hasil pengecekan slot yang lama udah gak valid.
  // Jadi hasil ketersediaan direset biar user wajib ngecek slot baru ke server.
  void setDate(DateTime date) {
    state = state.copyWith(
      selectedDate: date,
      clearAvailability: true,
    );
  }

  void setTime(TimeOfDay time) {
    state = state.copyWith(
      selectedTime: time,
      clearAvailability: true,
    );
  }

  void incrementDuration() {
    if (state.durationHours < 12) {
      state = state.copyWith(
        durationHours: state.durationHours + 1,
        clearAvailability: true,
      );
    }
  }

  void decrementDuration() {
    if (state.durationHours > 1) {
      state = state.copyWith(
        durationHours: state.durationHours - 1,
        clearAvailability: true,
      );
    }
  }

  // Cek ketersediaan slot ke server & database:
  // Fungsi ini memastikan apakah jadwal yang dipilih user (tanggal, jam mulai, dan durasi)
  // masih kosong atau sudah pernah di-reservasi oleh orang lain.
  // Mengembalikan hasil ketersediaan agar tombol "Lanjutkan Reservasi" bisa langsung tahu hasilnya.
  Future<AvailabilityCheckResult?> checkAvailability(int spaceId) async {
    state = state.copyWith(isCheckingAvailability: true, clearError: true);
    try {
      final result = await _repository.checkAvailability(
        spaceId: spaceId,
        tanggal: state.formattedDate,
        jamMulai: state.formattedTime,
        durasi: state.durationHours,
      );
      if (!mounted) return result;
      state = state.copyWith(
        isCheckingAvailability: false,
        availabilityResult: result,
      );
      return result;
    } catch (e) {
      if (!mounted) return null;
      final errMsg = 'Gagal mengecek ketersediaan: ${e.toString()}';
      state = state.copyWith(
        isCheckingAvailability: false,
        errorMessage: errMsg,
      );
      return null;
    }
  }

  // Terapkan kupon promo / diskon:
  Future<bool> applyPromo(String code, int subtotal) async {
    if (code.trim().isEmpty) return false;
    state = state.copyWith(isCheckingPromo: true, clearPromoError: true);
    try {
      final promo = await _repository.checkPromo(code, subtotal: subtotal);
      if (!mounted) return true;
      state = state.copyWith(
        isCheckingPromo: false,
        appliedPromo: promo,
        clearPromoError: true,
      );
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(
        isCheckingPromo: false,
        promoError: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  void removePromo() {
    state = state.copyWith(clearPromo: true, clearPromoError: true);
  }

  // Proses pengiriman booking ke server:
  Future<ReservationModel?> submitBooking(int spaceId, {int? hargaPerJam}) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      // Trik Pengaman (Double Check):
      // Sebelum kirim data booking, kita cek ulang ketersediaan slot real-time tepat detik ini.
      // Tujuannya mencegah 'race condition': siapa tahu pas user lagi asyik isi form,
      // ada orang lain yang kebetulan baru aja ngebayar slot jam tersebut.
      final avail = await _repository.checkAvailability(
        spaceId: spaceId,
        tanggal: state.formattedDate,
        jamMulai: state.formattedTime,
        durasi: state.durationHours,
      );

      if (!avail.isAvailable) {
        if (!mounted) return null;
        state = state.copyWith(
          isSubmitting: false,
          availabilityResult: avail,
          errorMessage: avail.message.isNotEmpty
              ? avail.message
              : 'Slot ruangan pada jadwal ini sudah terisi oleh pemesan lain.',
        );
        return null;
      }

      int? subtotalVal;
      int? discountVal;
      int? totalVal;
      if (hargaPerJam != null && hargaPerJam > 0) {
        subtotalVal = state.calculateSubtotal(hargaPerJam);
        discountVal = state.calculateDiscount(subtotalVal);
        totalVal = state.calculateTotal(hargaPerJam);
      }

      // 2. Submit Pemesanan ke POST /api/reservasi
      final request = CreateReservationRequest(
        spaceId: spaceId,
        tanggal: state.formattedDate,
        jamMulai: state.formattedTime,
        durasi: state.durationHours,
        kodePromo: state.appliedPromo?.kode,
        idDiskon: (state.appliedPromo?.id != null && state.appliedPromo!.id > 0)
            ? state.appliedPromo!.id
            : null,
        hargaPerJam: hargaPerJam,
        subtotal: subtotalVal,
        potonganDiskon: discountVal,
        totalBayar: totalVal,
      );

      final reservation = await _repository.createReservation(request);
      if (!mounted) return reservation;
      state = state.copyWith(
        isSubmitting: false,
        createdReservation: reservation,
      );
      return reservation;
    } catch (e) {
      if (!mounted) return null;
      final msg = e.toString().replaceAll('Exception: ', '').replaceAll('ServerFailure: ', '');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: msg.isNotEmpty ? msg : 'Gagal membuat reservasi.',
      );
      return null;
    }
  }

  void reset() {
    state = BookingFormState(
      selectedDate: DateTime.now(),
      selectedTime: const TimeOfDay(hour: 9, minute: 0),
      durationHours: 3,
    );
  }
}

final bookingControllerProvider =
    StateNotifierProvider.autoDispose<BookingController, BookingFormState>((ref) {
  final repository = ref.watch(spacesRepositoryProvider);
  return BookingController(repository);
});
