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
    final response = await _dio.get(
      ApiEndpoints.spaces,
      queryParameters: {
        if (query != null && query.trim().isNotEmpty) 'search': query.trim(),
        if (queryTipe != null && queryTipe.trim().isNotEmpty && queryTipe != 'all' && queryTipe != 'semua')
          'tipe': queryTipe.trim(),
      },
    );

    var data = _extractData(response.data);
    if (data is Map) {
      for (final v in data.values) {
        if (v is List) { data = v; break; }
      }
    }
    if (data is List) {
      return data
          .whereType<Map>()
          .map((json) => SpaceModel.fromJson(Map<String, dynamic>.from(json)))
          .where((s) => s.id > 0)
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
    // 1. Cek dulu apakah jam sewa untuk hari ini sudah terlewat dari jam saat ini
    // Logika sederhana: kalau user milih hari ini tapi jam mulainya udah lewat di jam HP,
    // otomatis kita tolak dengan pesan yang ramah biar gak pesan jam di masa lalu.
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final cleanTanggal = tanggal.contains('T')
        ? tanggal.split('T').first
        : tanggal.split(' ').first;

    final reqStartMin = TimeSlotCollisionHelper.timeToMinutes(jamMulai);
    final reqEndMin = reqStartMin + (durasi * 60);

    if (cleanTanggal == todayStr) {
      final curMin = now.hour * 60 + now.minute;
      if (reqStartMin < curMin) {
        return AvailabilityCheckResult(
          isAvailable: false,
          message: 'Jam sewa ($jamMulai) sudah terlewat dari waktu saat ini. Silakan pilih jam berikutnya.',
          tanggal: tanggal,
          jamMulai: jamMulai,
          durasi: durasi,
        );
      }
    }

    // 2. Cross-check tabrakan jadwal langsung ke daftar reservasi yang tersimpan di sistem:
    // Kenapa kita cek juga ke daftar reservasi?
    // Biar kalau ada user atau member lain yang sudah reservasi di ruangan & jam yang sama,
    // sistem langsung mendeteksi bahwa slot tersebut sudah terisi (mencegah tabrakan jadwal / double booking).
    try {
      List<ReservationModel> existingReservations = [];

      // Coba ambil daftar reservasi (bisa lewat endpoint admin atau riwayat member)
      try {
        final resResponse = await _dio.get(
          ApiEndpoints.adminReservasi,
          queryParameters: {
            'id_space': spaceId,
            'tanggal': cleanTanggal,
          },
        );
        final resData = _extractData(resResponse.data);
        if (resData is List) {
          existingReservations = resData
              .whereType<Map>()
              .map((e) => ReservationModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      } catch (_) {
        // Kalau akun yang login bukan admin (dapat 401/403), fallback cek reservasi member
        try {
          final myResponse = await _dio.get(ApiEndpoints.reservasiMy);
          final myData = _extractData(myResponse.data);
          if (myData is List) {
            existingReservations = myData
                .whereType<Map>()
                .map((e) => ReservationModel.fromJson(Map<String, dynamic>.from(e)))
                .toList();
          }
        } catch (_) {}
      }

      // Periksa satu per satu apakah ada reservasi lain yang jamnya tabrakan
      for (final res in existingReservations) {
        // Reservasi yang dibatalkan tidak memakan slot ruangan
        final st = res.status.toLowerCase();
        if (st == 'dibatalkan' || st == 'cancelled' || st == 'canceled') {
          continue;
        }

        final resDate = res.tanggal.contains('T')
            ? res.tanggal.split('T').first
            : res.tanggal.split(' ').first;

        final isMatchSpace = res.spaceId == spaceId || res.spaceId == 0;
        final isMatchDate = resDate == cleanTanggal;

        if (isMatchSpace && isMatchDate && res.jamMulai.isNotEmpty) {
          final resStartMin = TimeSlotCollisionHelper.timeToMinutes(res.jamMulai);
          int resEndMin = res.jamSelesai.isNotEmpty
              ? TimeSlotCollisionHelper.timeToMinutes(res.jamSelesai)
              : 0;
          if (resEndMin <= resStartMin) {
            resEndMin = resStartMin + ((res.durasi > 0 ? res.durasi : 1) * 60);
          }

          // Cek rumus tabrakan jam: A mulai sebelum B selesai, DAN A selesai setelah B mulai
          if (TimeSlotCollisionHelper.isRangeColliding(
            startMinA: reqStartMin,
            endMinA: reqEndMin,
            startMinB: resStartMin,
            endMinB: resEndMin,
          )) {
            final endStr = res.jamSelesai.isNotEmpty
                ? res.jamSelesai
                : '${(resEndMin ~/ 60).toString().padLeft(2, '0')}:${(resEndMin % 60).toString().padLeft(2, '0')}';

            return AvailabilityCheckResult(
              isAvailable: false,
              message: 'Slot ruangan pukul ${res.jamMulai} - $endStr sudah ter-reservasi (${res.kodeBooking}). Silakan pilih jam lain.',
              tanggal: tanggal,
              jamMulai: jamMulai,
              durasi: durasi,
            );
          }
        }
      }
    } catch (_) {
      // Jika terjadi kendala jaringan lokal saat cross-check, lanjut ke endpoint availability server
    }

    // 3. Panggil API pengecekan ketersediaan space resmi dari server:
    // GET /api/spaces/availability?id_space=X&tanggal=Y&jam_mulai=Z&durasi_jam=N
    try {
      final response = await _dio.get(
        ApiEndpoints.spaceAvailability,
        queryParameters: {
          'id_space': spaceId,
          'tanggal': cleanTanggal,
          'jam_mulai': jamMulai,
          'durasi_jam': durasi, // API: durasi_jam
        },
      );

      final rootMap = response.data is Map ? Map<String, dynamic>.from(response.data as Map) : null;
      final data = _extractData(response.data);

      if (data is Map) {
        final res = AvailabilityCheckResult.fromJson(Map<String, dynamic>.from(data));
        // Jika di response data pesannya kosong atau generik, tapi di root response ada pesan yang lebih spesifik:
        if ((res.message.isEmpty || res.message == 'Space tersedia' || res.message == 'Space sudah terisi') &&
            rootMap != null &&
            rootMap['message'] != null) {
          return AvailabilityCheckResult(
            isAvailable: res.isAvailable,
            message: rootMap['message'].toString(),
            tanggal: res.tanggal ?? tanggal,
            jamMulai: res.jamMulai ?? jamMulai,
            durasi: res.durasi ?? durasi,
          );
        }
        return res;
      }

      final rootStatus = rootMap?['status'];
      final rootMsg = rootMap?['message']?.toString();
      if (rootStatus == false) {
        return AvailabilityCheckResult(
          isAvailable: false,
          message: rootMsg ?? 'Space tidak tersedia pada jadwal yang dipilih.',
          tanggal: tanggal,
          jamMulai: jamMulai,
          durasi: durasi,
        );
      }

      return AvailabilityCheckResult(
        isAvailable: true,
        message: rootMsg ?? 'Space tersedia untuk jadwal ini',
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
          message.toLowerCase().contains('sudah terisi') ||
          message.toLowerCase().contains('ter-reservasi') ||
          message.toLowerCase().contains('dibooking') ||
          message.toLowerCase().contains('bentrok')) {
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
