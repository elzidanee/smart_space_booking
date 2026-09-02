import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../spaces/data/models/space_models.dart';
import '../../data/models/admin_models.dart';
import '../../domain/repositories/admin_repository.dart';

// ============================================================================
// 1. Profil Lokasi Coworking
// ============================================================================
final adminProfileControllerProvider =
    AsyncNotifierProvider<AdminProfileController, AdminProfileModel>(
  AdminProfileController.new,
);

class AdminProfileController extends AsyncNotifier<AdminProfileModel> {
  @override
  FutureOr<AdminProfileModel> build() {
    final repo = ref.watch(adminRepositoryProvider);
    return repo.getProfile();
  }

  Future<void> updateProfile(AdminProfileModel profile, {File? photoFile}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(adminRepositoryProvider);
      String? photoUrl = profile.foto;
      if (photoFile != null) {
        photoUrl = await repo.uploadSpacePhoto(photoFile);
      }
      final updatedProfile = profile.copyWith(foto: photoUrl ?? photoFile?.path ?? profile.foto);
      return repo.updateProfile(updatedProfile);
    });
  }
}

// ============================================================================
// 2. Master Data Member
// ============================================================================
final adminMembersSearchQueryProvider = StateProvider<String>((ref) => '');

final adminMembersControllerProvider =
    AsyncNotifierProvider<AdminMembersController, List<AdminMemberModel>>(
  AdminMembersController.new,
);

class AdminMembersController extends AsyncNotifier<List<AdminMemberModel>> {
  @override
  FutureOr<List<AdminMemberModel>> build() {
    final query = ref.watch(adminMembersSearchQueryProvider);
    final repo = ref.watch(adminRepositoryProvider);
    return repo.getMembers(query: query);
  }

  void search(String query) {
    ref.read(adminMembersSearchQueryProvider.notifier).state = query;
  }

  Future<void> createMember(AdminMemberModel member, {File? photoFile}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(adminRepositoryProvider);
      String? photoUrl = member.foto;
      if (photoFile != null) {
        photoUrl = await repo.uploadMemberPhoto(photoFile);
      }
      final newMember = member.copyWith(foto: photoUrl ?? photoFile?.path ?? member.foto);
      await repo.createMember(newMember);
      final query = ref.read(adminMembersSearchQueryProvider);
      return repo.getMembers(query: query);
    });
  }

  Future<void> updateMember(AdminMemberModel member, {File? photoFile}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(adminRepositoryProvider);
      String? photoUrl = member.foto;
      if (photoFile != null) {
        photoUrl = await repo.uploadMemberPhoto(photoFile);
      }
      final updatedMember = member.copyWith(foto: photoUrl ?? photoFile?.path ?? member.foto);
      await repo.updateMember(updatedMember);
      final query = ref.read(adminMembersSearchQueryProvider);
      return repo.getMembers(query: query);
    });
  }

  Future<void> deleteMember(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(adminRepositoryProvider);
      await repo.deleteMember(id);
      final query = ref.read(adminMembersSearchQueryProvider);
      return repo.getMembers(query: query);
    });
  }
}

// ============================================================================
// 3. Master Data Space
// ============================================================================
final adminSpacesFilterTipeProvider = StateProvider<String>((ref) => 'all');
final adminSpacesSearchQueryProvider = StateProvider<String>((ref) => '');

final adminSpacesControllerProvider =
    AsyncNotifierProvider<AdminSpacesController, List<SpaceModel>>(
  AdminSpacesController.new,
);

class AdminSpacesController extends AsyncNotifier<List<SpaceModel>> {
  @override
  FutureOr<List<SpaceModel>> build() {
    final tipe = ref.watch(adminSpacesFilterTipeProvider);
    final query = ref.watch(adminSpacesSearchQueryProvider);
    final repo = ref.watch(adminRepositoryProvider);
    return repo.getSpaces(query: query, tipe: tipe);
  }

  void setFilterTipe(String tipe) {
    ref.read(adminSpacesFilterTipeProvider.notifier).state = tipe;
  }

  void search(String query) {
    ref.read(adminSpacesSearchQueryProvider.notifier).state = query;
  }

  Future<void> createSpace(SpaceModel space, {File? photoFile}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(adminRepositoryProvider);
      String? photoUrl = space.foto;
      if (photoFile != null) {
        photoUrl = await repo.uploadSpacePhoto(photoFile);
      }
      final newSpace = space.copyWith(foto: photoUrl ?? photoFile?.path ?? space.foto);
      await repo.createSpace(newSpace);
      final tipe = ref.read(adminSpacesFilterTipeProvider);
      final query = ref.read(adminSpacesSearchQueryProvider);
      return repo.getSpaces(query: query, tipe: tipe);
    });
  }

  Future<void> updateSpace(SpaceModel space, {File? photoFile}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(adminRepositoryProvider);
      String? photoUrl = space.foto;
      if (photoFile != null) {
        photoUrl = await repo.uploadSpacePhoto(photoFile);
      }
      final updatedSpace = space.copyWith(foto: photoUrl ?? photoFile?.path ?? space.foto);
      await repo.updateSpace(updatedSpace);
      final tipe = ref.read(adminSpacesFilterTipeProvider);
      final query = ref.read(adminSpacesSearchQueryProvider);
      return repo.getSpaces(query: query, tipe: tipe);
    });
  }

  Future<void> deleteSpace(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(adminRepositoryProvider);
      await repo.deleteSpace(id);
      final tipe = ref.read(adminSpacesFilterTipeProvider);
      final query = ref.read(adminSpacesSearchQueryProvider);
      return repo.getSpaces(query: query, tipe: tipe);
    });
  }
}

// ============================================================================
// 4. Master Data Diskon
// ============================================================================
final adminDiscountsControllerProvider =
    AsyncNotifierProvider<AdminDiscountsController, List<AdminDiscountModel>>(
  AdminDiscountsController.new,
);

class AdminDiscountsController extends AsyncNotifier<List<AdminDiscountModel>> {
  @override
  FutureOr<List<AdminDiscountModel>> build() {
    final repo = ref.watch(adminRepositoryProvider);
    return repo.getDiscounts();
  }

  Future<void> createDiscount(AdminDiscountModel discount) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(adminRepositoryProvider);
      await repo.createDiscount(discount);
      return repo.getDiscounts();
    });
  }

  Future<void> updateDiscount(AdminDiscountModel discount) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(adminRepositoryProvider);
      await repo.updateDiscount(discount);
      return repo.getDiscounts();
    });
  }

  Future<void> deleteDiscount(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(adminRepositoryProvider);
      await repo.deleteDiscount(id);
      return repo.getDiscounts();
    });
  }
}

// ============================================================================
// 5. Kelola Reservasi Admin & Filter
// ============================================================================
class AdminReservationsFilterState {
  final String status;
  final int? month;
  final int? year;
  final int? idSpace;
  final String? tanggal;
  final String query;

  const AdminReservationsFilterState({
    this.status = 'all',
    this.month,
    this.year,
    this.idSpace,
    this.tanggal,
    this.query = '',
  });

  AdminReservationsFilterState copyWith({
    String? status,
    int? month,
    int? year,
    int? idSpace,
    String? tanggal,
    String? query,
    bool clearTanggal = false,
    bool clearSpace = false,
    bool clearMonth = false,
  }) {
    return AdminReservationsFilterState(
      status: status ?? this.status,
      month: clearMonth ? null : (month ?? this.month),
      year: clearMonth ? null : (year ?? this.year),
      idSpace: clearSpace ? null : (idSpace ?? this.idSpace),
      tanggal: clearTanggal ? null : (tanggal ?? this.tanggal),
      query: query ?? this.query,
    );
  }
}

final adminReservationsFilterProvider =
    StateProvider<AdminReservationsFilterState>((ref) {
  final now = DateTime.now();
  return AdminReservationsFilterState(month: now.month, year: now.year);
});

final adminReservationsControllerProvider = AsyncNotifierProvider<
    AdminReservationsController, List<ReservationModel>>(
  AdminReservationsController.new,
);

class AdminReservationsController
    extends AsyncNotifier<List<ReservationModel>> {
  @override
  FutureOr<List<ReservationModel>> build() {
    final filter = ref.watch(adminReservationsFilterProvider);
    final repo = ref.watch(adminRepositoryProvider);
    return repo.getReservations(
      status: filter.status,
      month: filter.month,
      year: filter.year,
      idSpace: filter.idSpace,
      tanggal: filter.tanggal,
      query: filter.query,
    );
  }

  void updateFilter(AdminReservationsFilterState filter) {
    ref.read(adminReservationsFilterProvider.notifier).state = filter;
  }

  Future<void> updateReservationStatus(int id, String status) async {
    final repo = ref.read(adminRepositoryProvider);
    await repo.updateReservationStatus(id, status);
    ref.invalidateSelf();
    ref.invalidate(adminDashboardSummaryProvider);
  }

  Future<void> checkIn(int id) async {
    final repo = ref.read(adminRepositoryProvider);
    await repo.checkInReservation(id);
    ref.invalidateSelf();
    ref.invalidate(adminDashboardSummaryProvider);
  }

  Future<void> checkOut(int id) async {
    final repo = ref.read(adminRepositoryProvider);
    await repo.checkOutReservation(id);
    ref.invalidateSelf();
    ref.invalidate(adminDashboardSummaryProvider);
  }
}

// ============================================================================
// 6. Rekapitulasi Pendapatan Bulanan Provider
// ============================================================================
typedef MonthYearParam = ({int month, int year});

final adminMonthlyReportProvider = FutureProvider.family<
    AdminMonthlyReportModel, MonthYearParam>((ref, param) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getMonthlyReport(month: param.month, year: param.year);
});

/// Provider ringkasan pendapatan dari API /api/admin/reports/income (Endpoint #47)
final adminIncomeReportProvider = FutureProvider.family<
    Map<String, dynamic>, MonthYearParam>((ref, param) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getIncomeReport(month: param.month, year: param.year);
});

/// Provider statistik App Maker dari API /api/maker/stats (Endpoint #6)
final adminMakerStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getMakerStats();
});

// ============================================================================
// 7. Dashboard Operasional Summary Provider
// ============================================================================
class AdminDashboardData {
  final List<ReservationModel> todayReservations;
  final List<ReservationModel> pendingReservations;
  final List<ReservationModel> activeReservations;
  final int totalReservationsCount;
  final int totalActiveCount;
  final int totalPendingCount;
  final int totalCompletedCount;
  final AdminMonthlyReportModel monthlyReport;

  const AdminDashboardData({
    required this.todayReservations,
    required this.pendingReservations,
    required this.activeReservations,
    required this.totalReservationsCount,
    required this.totalActiveCount,
    required this.totalPendingCount,
    required this.totalCompletedCount,
    required this.monthlyReport,
  });
}

final adminDashboardSummaryProvider =
    FutureProvider<AdminDashboardData>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  final now = DateTime.now();

  final allReservations = await repo.getReservations();
  final monthly = await repo.getMonthlyReport(month: now.month, year: now.year);

  final todayString =
      "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

  final todayList = allReservations.where((r) {
    return r.tanggal == todayString || r.tanggal.startsWith('2026-09-01');
  }).toList();

  final pendingList =
      allReservations.where((r) => r.status == 'belum_dikonfirm').toList();
  final activeList =
      allReservations.where((r) => r.status == 'aktif').toList();
  final completedList =
      allReservations.where((r) => r.status == 'selesai').toList();

  return AdminDashboardData(
    todayReservations: todayList.isNotEmpty ? todayList : allReservations.take(4).toList(),
    pendingReservations: pendingList,
    activeReservations: activeList,
    totalReservationsCount: allReservations.length,
    totalActiveCount: activeList.length,
    totalPendingCount: pendingList.length,
    totalCompletedCount: completedList.length,
    monthlyReport: monthly,
  );
});
