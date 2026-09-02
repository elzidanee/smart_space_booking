import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/space_models.dart';

final spacesRemoteDataSourceProvider = Provider<SpacesRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return SpacesRemoteDataSourceImpl(dio);
});

abstract class SpacesRemoteDataSource {
  Future<List<SpaceModel>> getSpaces({String? query, String? tipe});
  Future<List<Map<String, dynamic>>> getSpaceTypes();
  Future<SpaceModel> getSpaceById(int id);
  Future<List<Map<String, dynamic>>> getActiveDiscounts();
  Future<AvailabilityCheckResult> checkAvailability({
    required int spaceId,
    required String tanggal,
    required String jamMulai,
    required int durasi,
  });
  Future<PromoCheckResult> checkPromo(String kodePromo, {int subtotal = 0});
  Future<ReservationModel> createReservation(CreateReservationRequest request);
}

class SpacesRemoteDataSourceImpl implements SpacesRemoteDataSource {
  final Dio _dio;

  SpacesRemoteDataSourceImpl(this._dio);

  /// Helper untuk mengekstrak data dari berbagai kemungkinan format response backend
  dynamic _extractData(dynamic responseData) {
    if (responseData == null) return null;
    dynamic parsed = responseData;
    if (parsed is String) {
      final trimmed = parsed.trim();
      if (trimmed.isEmpty) return null;
      try {
        parsed = jsonDecode(trimmed);
      } catch (_) {
        return parsed;
      }
    }
    if (parsed is Map) {
      if (parsed.containsKey('data') && parsed['data'] != null) {
        return parsed['data'];
      }
      return parsed;
    }
    return parsed;
  }

  @override
  Future<List<SpaceModel>> getSpaces({String? query, String? tipe}) async {
    final queryTipe = (tipe == 'personal_desk' || tipe == 'desk') ? 'desk' : tipe;
    // QA-001/018: Tidak ada silent mock fallback — exception dilempar agar UI menampilkan error state.
    final response = await _dio.get(
      ApiEndpoints.spaces,
      queryParameters: {
        if (query != null && query.trim().isNotEmpty) 'search': query.trim(),
        if (queryTipe != null && queryTipe.trim().isNotEmpty && queryTipe != 'all' && queryTipe != 'semua')
          'tipe': queryTipe.trim(),
      },
    );

    final data = _extractData(response.data);
    if (data is List) {
      return data
          .whereType<Map>()
          .map((json) => SpaceModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> getSpaceTypes() async {
    try {
      final response = await _dio.get(ApiEndpoints.spaceTypes);
      final data = _extractData(response.data);
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return [
        {'id': 1, 'tipe': 'personal_desk', 'nama': 'Personal Desk'},
        {'id': 2, 'tipe': 'meeting_room', 'nama': 'Meeting Room'},
        {'id': 3, 'tipe': 'private_office', 'nama': 'Private Office'},
      ];
    } catch (_) {
      return [
        {'id': 1, 'tipe': 'personal_desk', 'nama': 'Personal Desk'},
        {'id': 2, 'tipe': 'meeting_room', 'nama': 'Meeting Room'},
        {'id': 3, 'tipe': 'private_office', 'nama': 'Private Office'},
      ];
    }
  }

  @override
  Future<SpaceModel> getSpaceById(int id) async {
    final response = await _dio.get('${ApiEndpoints.spaces}/$id');
    final data = _extractData(response.data);
    if (data is Map) {
      return SpaceModel.fromJson(Map<String, dynamic>.from(data));
    } else if (data is List && data.isNotEmpty && data.first is Map) {
      return SpaceModel.fromJson(Map<String, dynamic>.from(data.first as Map));
    }
    throw Exception('Detail ruangan dengan ID $id tidak ditemukan.');
  }

  @override
  Future<List<Map<String, dynamic>>> getActiveDiscounts() async {
    final response = await _dio.get(ApiEndpoints.diskonActive);
    final data = _extractData(response.data);
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
  }

  @override
  Future<AvailabilityCheckResult> checkAvailability({
    required int spaceId,
    required String tanggal,
    required String jamMulai,
    required int durasi,
  }) async {
    try {
      // GET /api/spaces/availability?id_space=X&tanggal=Y&jam_mulai=Z&durasi_jam=N
      final response = await _dio.get(
        ApiEndpoints.spaceAvailability,
        queryParameters: {
          'id_space': spaceId,
          'tanggal': tanggal,
          'jam_mulai': jamMulai,
          'durasi_jam': durasi, // API: durasi_jam
        },
      );

      final data = _extractData(response.data);
      if (data is Map) {
        return AvailabilityCheckResult.fromJson(Map<String, dynamic>.from(data));
      }
      return AvailabilityCheckResult(
        isAvailable: true,
        message: 'Space tersedia untuk jadwal ini',
        tanggal: tanggal,
        jamMulai: jamMulai,
        durasi: durasi,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;
      String message = 'Space tidak tersedia pada jadwal yang dipilih.';
      if (responseData is Map && responseData['message'] != null) {
        message = responseData['message'].toString();
      }
      if (statusCode == 400 ||
          statusCode == 409 ||
          message.toLowerCase().contains('tidak tersedia') ||
          message.toLowerCase().contains('sudah terisi')) {
        return AvailabilityCheckResult(
          isAvailable: false,
          message: message,
          tanggal: tanggal,
          jamMulai: jamMulai,
          durasi: durasi,
        );
      }
      rethrow;
    }
  }

  @override
  Future<PromoCheckResult> checkPromo(String kodePromo, {int subtotal = 0}) async {
    final cleanKode = kodePromo.trim().toUpperCase();

    // POST /api/diskon/check — payload kompatibel dengan semua backend
    final response = await _dio.post(
      ApiEndpoints.checkDiskon,
      data: {
        'nama_diskon': cleanKode,
        'kode_promo': cleanKode,
        'kode': cleanKode,
        'kode_diskon': cleanKode,
      },
    );

    final data = _extractData(response.data);
    if (data is Map) {
      return PromoCheckResult.fromJson(Map<String, dynamic>.from(data), subtotal: subtotal);
    }
    throw Exception('Kode promo tidak valid atau telah kedaluwarsa.');
  }

  @override
  Future<ReservationModel> createReservation(CreateReservationRequest request) async {
    final response = await _dio.post(
      ApiEndpoints.reservasi,
      data: request.toJson(),
    );

    final data = _extractData(response.data);
    if (data is Map) {
      return ReservationModel.fromJson(Map<String, dynamic>.from(data));
    }
    throw Exception('Gagal membuat reservasi: format respon server tidak valid.');
  }
}
