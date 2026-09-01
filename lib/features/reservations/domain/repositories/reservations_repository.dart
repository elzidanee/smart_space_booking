import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exception_mapper.dart';
import '../../../spaces/data/models/space_models.dart';
import '../../data/datasources/reservations_remote_datasource.dart';

final reservationsRepositoryProvider = Provider<ReservationsRepository>((ref) {
  final remoteDataSource = ref.watch(reservationsRemoteDataSourceProvider);
  return ReservationsRepositoryImpl(remoteDataSource);
});

abstract class ReservationsRepository {
  Future<List<ReservationModel>> getMyReservations({String? status});
  Future<ReservationHistorySummary> getMyHistory({int? bulan, int? tahun});
  Future<ReservationModel> getReservationById(int id);
  Future<bool> cancelReservation(int id);
  Future<ReservationModel> getETicket(int id);
}

class ReservationsRepositoryImpl implements ReservationsRepository {
  final ReservationsRemoteDataSource _remoteDataSource;

  ReservationsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ReservationModel>> getMyReservations({String? status}) async {
    try {
      return await _remoteDataSource.getMyReservations(status: status);
    } catch (e) {
      throw ExceptionMapper.map(e);
    }
  }

  @override
  Future<ReservationHistorySummary> getMyHistory({int? bulan, int? tahun}) async {
    try {
      return await _remoteDataSource.getMyHistory(bulan: bulan, tahun: tahun);
    } catch (e) {
      throw ExceptionMapper.map(e);
    }
  }

  @override
  Future<ReservationModel> getReservationById(int id) async {
    try {
      return await _remoteDataSource.getReservationById(id);
    } catch (e) {
      throw ExceptionMapper.map(e);
    }
  }

  @override
  Future<bool> cancelReservation(int id) async {
    try {
      return await _remoteDataSource.cancelReservation(id);
    } catch (e) {
      throw ExceptionMapper.map(e);
    }
  }

  @override
  Future<ReservationModel> getETicket(int id) async {
    try {
      return await _remoteDataSource.getETicket(id);
    } catch (e) {
      throw ExceptionMapper.map(e);
    }
  }
}
