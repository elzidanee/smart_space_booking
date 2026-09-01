import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exception_mapper.dart';
import '../../data/datasources/spaces_remote_datasource.dart';
import '../../data/models/space_models.dart';

final spacesRepositoryProvider = Provider<SpacesRepository>((ref) {
  final remoteDataSource = ref.watch(spacesRemoteDataSourceProvider);
  return SpacesRepositoryImpl(remoteDataSource);
});

abstract class SpacesRepository {
  Future<List<SpaceModel>> getSpaces({String? query, String? tipe});
  Future<SpaceModel> getSpaceById(int id);
  Future<AvailabilityCheckResult> checkAvailability({
    required int spaceId,
    required String tanggal,
    required String jamMulai,
    required int durasi,
  });
  Future<PromoCheckResult> checkPromo(String kodePromo, {int subtotal = 0});
  Future<ReservationModel> createReservation(CreateReservationRequest request);
}

class SpacesRepositoryImpl implements SpacesRepository {
  final SpacesRemoteDataSource _remoteDataSource;

  SpacesRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<SpaceModel>> getSpaces({String? query, String? tipe}) async {
    try {
      return await _remoteDataSource.getSpaces(query: query, tipe: tipe);
    } catch (e) {
      throw ExceptionMapper.map(e);
    }
  }

  @override
  Future<SpaceModel> getSpaceById(int id) async {
    try {
      return await _remoteDataSource.getSpaceById(id);
    } catch (e) {
      throw ExceptionMapper.map(e);
    }
  }

  @override
  Future<AvailabilityCheckResult> checkAvailability({
    required int spaceId,
    required String tanggal,
    required String jamMulai,
    required int durasi,
  }) async {
    try {
      return await _remoteDataSource.checkAvailability(
        spaceId: spaceId,
        tanggal: tanggal,
        jamMulai: jamMulai,
        durasi: durasi,
      );
    } catch (e) {
      throw ExceptionMapper.map(e);
    }
  }

  @override
  Future<PromoCheckResult> checkPromo(String kodePromo, {int subtotal = 0}) async {
    try {
      return await _remoteDataSource.checkPromo(kodePromo, subtotal: subtotal);
    } catch (e) {
      throw ExceptionMapper.map(e);
    }
  }

  @override
  Future<ReservationModel> createReservation(CreateReservationRequest request) async {
    try {
      return await _remoteDataSource.createReservation(request);
    } catch (e) {
      throw ExceptionMapper.map(e);
    }
  }
}
