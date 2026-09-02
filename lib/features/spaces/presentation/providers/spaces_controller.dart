import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/repositories/spaces_repository.dart';
import '../../data/models/space_models.dart';

/// Provider filter kategori terpilih: 'all' | 'personal_desk' | 'meeting_room' | 'private_office'
final selectedSpaceCategoryProvider = StateProvider<String>((ref) => 'all');

/// Provider keyword pencarian
final spaceSearchQueryProvider = StateProvider<String>((ref) => '');

/// Provider daftar space (dengan filter kategori & pencarian)
final spacesListProvider = FutureProvider.autoDispose<List<SpaceModel>>((ref) async {
  final repository = ref.watch(spacesRepositoryProvider);
  final category = ref.watch(selectedSpaceCategoryProvider);
  final query = ref.watch(spaceSearchQueryProvider);

  return await repository.getSpaces(
    query: query.isEmpty ? null : query,
    tipe: category == 'all' ? null : category,
  );
});

/// Provider tipe/kategori space dari API /api/spaces/types (FR-06 / Endpoint #12)
final spaceTypesProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(spacesRepositoryProvider);
  return await repository.getSpaceTypes();
});

/// Provider promo/diskon aktif dari API /api/diskon/active (Endpoint #16)
final activeDiscountsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
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

  int calculateSubtotal(int hargaPerJam) => hargaPerJam * durationHours;

  int calculateDiscount(int subtotal) {
    if (appliedPromo == null) return 0;
    if (appliedPromo!.potongan > 0) return appliedPromo!.potongan;
    if (appliedPromo!.persentase > 0) {
      return (subtotal * appliedPromo!.persentase / 100).round();
    }
    return 0;
  }

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

/// Notifier Controller untuk manajemen form reservasi space
class BookingController extends StateNotifier<BookingFormState> {
  final SpacesRepository _repository;

  BookingController(this._repository)
      : super(BookingFormState(
          selectedDate: DateTime.now(),
          selectedTime: const TimeOfDay(hour: 9, minute: 0),
          durationHours: 3,
        ));

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

  Future<void> checkAvailability(int spaceId) async {
    state = state.copyWith(isCheckingAvailability: true, clearError: true);
    try {
      final result = await _repository.checkAvailability(
        spaceId: spaceId,
        tanggal: state.formattedDate,
        jamMulai: state.formattedTime,
        durasi: state.durationHours,
      );
      state = state.copyWith(
        isCheckingAvailability: false,
        availabilityResult: result,
      );
    } catch (e) {
      state = state.copyWith(
        isCheckingAvailability: false,
        errorMessage: 'Gagal mengecek ketersediaan: ${e.toString()}',
      );
    }
  }

  Future<bool> applyPromo(String code, int subtotal) async {
    if (code.trim().isEmpty) return false;
    state = state.copyWith(isCheckingPromo: true, clearPromoError: true);
    try {
      final promo = await _repository.checkPromo(code, subtotal: subtotal);
      state = state.copyWith(
        isCheckingPromo: false,
        appliedPromo: promo,
        clearPromoError: true,
      );
      return true;
    } catch (e) {
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

  Future<ReservationModel?> submitBooking(int spaceId) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final request = CreateReservationRequest(
        spaceId: spaceId,
        tanggal: state.formattedDate,
        jamMulai: state.formattedTime,
        durasi: state.durationHours,
        kodePromo: state.appliedPromo?.kode,
      );

      final reservation = await _repository.createReservation(request);
      state = state.copyWith(
        isSubmitting: false,
        createdReservation: reservation,
      );
      return reservation;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Gagal membuat reservasi: ${e.toString()}',
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
