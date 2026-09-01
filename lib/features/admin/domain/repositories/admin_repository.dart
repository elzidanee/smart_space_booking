import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../spaces/data/models/space_models.dart';
import '../../data/datasources/admin_remote_datasource.dart';
import '../../data/models/admin_models.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final dataSource = ref.watch(adminRemoteDataSourceProvider);
  return AdminRepositoryImpl(dataSource);
});

abstract class AdminRepository {
  // Profil
  Future<AdminProfileModel> getProfile();
  Future<AdminProfileModel> updateProfile(AdminProfileModel profile);

  // Members CRUD
  Future<List<AdminMemberModel>> getMembers({String? query});
  Future<AdminMemberModel> createMember(AdminMemberModel member);
  Future<AdminMemberModel> updateMember(AdminMemberModel member);
  Future<bool> deleteMember(int id);

  // Spaces CRUD
  Future<List<SpaceModel>> getSpaces({String? query, String? tipe});
  Future<SpaceModel> createSpace(SpaceModel space);
  Future<SpaceModel> updateSpace(SpaceModel space);
  Future<bool> deleteSpace(int id);

  // Discounts CRUD
  Future<List<AdminDiscountModel>> getDiscounts();
  Future<AdminDiscountModel> createDiscount(AdminDiscountModel discount);
  Future<AdminDiscountModel> updateDiscount(AdminDiscountModel discount);
  Future<bool> deleteDiscount(int id);

  // Reservations
  Future<List<ReservationModel>> getReservations({
    String? status,
    int? month,
    int? year,
    int? idSpace,
    String? tanggal,
    String? query,
  });
  Future<ReservationModel> getReservationById(int id);
  Future<ReservationModel> updateReservationStatus(int id, String status);
  Future<ReservationModel> checkInReservation(int id);
  Future<ReservationModel> checkOutReservation(int id);

  // Monthly Report
  Future<AdminMonthlyReportModel> getMonthlyReport({int? month, int? year});
}

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _dataSource;

  AdminRepositoryImpl(this._dataSource);

  @override
  Future<AdminProfileModel> getProfile() => _dataSource.getProfile();

  @override
  Future<AdminProfileModel> updateProfile(AdminProfileModel profile) =>
      _dataSource.updateProfile(profile);

  @override
  Future<List<AdminMemberModel>> getMembers({String? query}) =>
      _dataSource.getMembers(query: query);

  @override
  Future<AdminMemberModel> createMember(AdminMemberModel member) =>
      _dataSource.createMember(member);

  @override
  Future<AdminMemberModel> updateMember(AdminMemberModel member) =>
      _dataSource.updateMember(member);

  @override
  Future<bool> deleteMember(int id) => _dataSource.deleteMember(id);

  @override
  Future<List<SpaceModel>> getSpaces({String? query, String? tipe}) =>
      _dataSource.getSpaces(query: query, tipe: tipe);

  @override
  Future<SpaceModel> createSpace(SpaceModel space) =>
      _dataSource.createSpace(space);

  @override
  Future<SpaceModel> updateSpace(SpaceModel space) =>
      _dataSource.updateSpace(space);

  @override
  Future<bool> deleteSpace(int id) => _dataSource.deleteSpace(id);

  @override
  Future<List<AdminDiscountModel>> getDiscounts() => _dataSource.getDiscounts();

  @override
  Future<AdminDiscountModel> createDiscount(AdminDiscountModel discount) =>
      _dataSource.createDiscount(discount);

  @override
  Future<AdminDiscountModel> updateDiscount(AdminDiscountModel discount) =>
      _dataSource.updateDiscount(discount);

  @override
  Future<bool> deleteDiscount(int id) => _dataSource.deleteDiscount(id);

  @override
  Future<List<ReservationModel>> getReservations({
    String? status,
    int? month,
    int? year,
    int? idSpace,
    String? tanggal,
    String? query,
  }) =>
      _dataSource.getReservations(
        status: status,
        month: month,
        year: year,
        idSpace: idSpace,
        tanggal: tanggal,
        query: query,
      );

  @override
  Future<ReservationModel> getReservationById(int id) =>
      _dataSource.getReservationById(id);

  @override
  Future<ReservationModel> updateReservationStatus(int id, String status) =>
      _dataSource.updateReservationStatus(id, status);

  @override
  Future<ReservationModel> checkInReservation(int id) =>
      _dataSource.checkInReservation(id);

  @override
  Future<ReservationModel> checkOutReservation(int id) =>
      _dataSource.checkOutReservation(id);

  @override
  Future<AdminMonthlyReportModel> getMonthlyReport({int? month, int? year}) =>
      _dataSource.getMonthlyReport(month: month, year: year);
}
