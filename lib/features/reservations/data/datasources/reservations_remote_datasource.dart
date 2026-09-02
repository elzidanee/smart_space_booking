import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../spaces/data/models/space_models.dart';

final reservationsRemoteDataSourceProvider =
    Provider<ReservationsRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return ReservationsRemoteDataSourceImpl(dio);
});

class ReservationHistorySummary {
  final List<ReservationModel> items;
  final int totalPengeluaran;
  final int totalJam;
  final int totalTransaksi;

  const ReservationHistorySummary({
    required this.items,
    required this.totalPengeluaran,
    required this.totalJam,
    required this.totalTransaksi,
  });
}

abstract class ReservationsRemoteDataSource {
  Future<List<ReservationModel>> getMyReservations({String? status});
  Future<ReservationHistorySummary> getMyHistory({int? bulan, int? tahun});
  Future<ReservationModel> getReservationById(int id);
  Future<bool> cancelReservation(int id);
  Future<ReservationModel> getETicket(int id);
}

class ReservationsRemoteDataSourceImpl implements ReservationsRemoteDataSource {
  final Dio _dio;

  ReservationsRemoteDataSourceImpl(this._dio);

  dynamic _extractData(dynamic responseData) {
    if (responseData == null) return null;
    if (responseData is Map && responseData.containsKey('data') && responseData['data'] != null) {
      return responseData['data'];
    }
    return responseData;
  }

  @override
  Future<List<ReservationModel>> getMyReservations({String? status}) async {
    String? apiStatus;
    if (status != null && status.isNotEmpty && status != 'all') {
      if (status == 'menunggu' || status == 'pending') {
        apiStatus = 'belum_dikonfirm';
      } else {
        apiStatus = status;
      }
    }

    try {
      final response = await _dio.get(
        ApiEndpoints.reservasiMy,
        queryParameters: {
          'status': ?apiStatus,
        },
      );

      final data = _extractData(response.data);
      List<ReservationModel> list = [];
      if (data is List) {
        list = data
            .whereType<Map>()
            .map((json) => ReservationModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      }

      // Client-side filtering ensures exact match regardless of backend filtering support
      if (status != null && status.isNotEmpty && status != 'all') {
        final filterLower = status.toLowerCase();
        list = list.where((r) {
          final s = r.status.toLowerCase();
          if (filterLower == 'menunggu' || filterLower == 'belum_dikonfirm') {
            return s == 'belum_dikonfirm' || s == 'menunggu' || s == 'pending';
          }
          if (filterLower == 'disetujui') {
            return s == 'disetujui' || s == 'approved' || s == 'confirmed';
          }
          if (filterLower == 'aktif') {
            return s == 'aktif' || s == 'active';
          }
          if (filterLower == 'selesai') {
            return s == 'selesai' || s == 'completed';
          }
          if (filterLower == 'dibatalkan') {
            return s == 'dibatalkan' || s == 'cancelled' || s == 'canceled';
          }
          return s == filterLower;
        }).toList();
      }

      return list;
    } on DioException catch (_) {
      // Fallback: fetch without status param and filter locally
      if (apiStatus != null) {
        final fallbackResponse = await _dio.get(ApiEndpoints.reservasiMy);
        final fallbackData = _extractData(fallbackResponse.data);
        if (fallbackData is List) {
          final allList = fallbackData
              .whereType<Map>()
              .map((json) => ReservationModel.fromJson(Map<String, dynamic>.from(json)))
              .toList();
          final filterLower = status!.toLowerCase();
          return allList.where((r) {
            final s = r.status.toLowerCase();
            if (filterLower == 'menunggu' || filterLower == 'belum_dikonfirm') {
              return s == 'belum_dikonfirm' || s == 'menunggu' || s == 'pending';
            }
            if (filterLower == 'disetujui') {
              return s == 'disetujui' || s == 'approved' || s == 'confirmed';
            }
            if (filterLower == 'aktif') {
              return s == 'aktif' || s == 'active';
            }
            if (filterLower == 'selesai') {
              return s == 'selesai' || s == 'completed';
            }
            if (filterLower == 'dibatalkan') {
              return s == 'dibatalkan' || s == 'cancelled' || s == 'canceled';
            }
            return s == filterLower;
          }).toList();
        }
      }
      rethrow;
    }
  }

  @override
  Future<ReservationHistorySummary> getMyHistory({int? bulan, int? tahun}) async {
    final response = await _dio.get(
      ApiEndpoints.reservasiMyHistory,
      queryParameters: {
        // API panitia memakai 'month' dan 'year' (bukan bulan/tahun)
        'month': ?bulan,
        'year': ?tahun,
      },
    );

    final dynamic data = response.data['data'] ?? response.data;
    if (data is Map<String, dynamic>) {
      // API mengembalikan: { month, year, total_reservasi, total_pengeluaran, items: [...] }
      final listData = data['items'] ?? data['reservasi'] ?? [];
      final items = (listData as List)
          .map((json) => ReservationModel.fromJson(json as Map<String, dynamic>))
          .toList();

      final totalBayar = data['total_pengeluaran'] is int
          ? data['total_pengeluaran']
          : int.tryParse(data['total_pengeluaran']?.toString() ?? '0') ?? 0;
      final totalJam = data['total_jam'] is int
          ? data['total_jam']
          : int.tryParse(data['total_jam']?.toString() ?? '0') ?? 0;
      final totalTx = data['total_reservasi'] is int
          ? data['total_reservasi']
          : items.length;

      return ReservationHistorySummary(
        items: items,
        totalPengeluaran: totalBayar,
        totalJam: totalJam,
        totalTransaksi: totalTx,
      );
    }
    return const ReservationHistorySummary(
      items: [],
      totalPengeluaran: 0,
      totalJam: 0,
      totalTransaksi: 0,
    );
  }

  @override
  Future<ReservationModel> getReservationById(int id) async {
    final response = await _dio.get(ApiEndpoints.reservasiDetail(id));
    final dynamic data = response.data['data'] ?? response.data;
    if (data is Map<String, dynamic>) {
      return ReservationModel.fromJson(data);
    }
    throw Exception('Data reservasi #$id tidak ditemukan.');
  }

  @override
  Future<bool> cancelReservation(int id) async {
    await _dio.patch(ApiEndpoints.cancelReservasi(id));
    return true;
  }

  @override
  Future<ReservationModel> getETicket(int id) async {
    final response = await _dio.get(ApiEndpoints.eTicket(id));
    final dynamic raw = response.data['data'] ?? response.data;
    if (raw is Map<String, dynamic>) {
      // API e-ticket mengembalikan struktur:
      // { e_ticket_number, kode_booking, coworking_space, member, space, jadwal, rincian_pembayaran, status_reservasi, qr_code_payload }
      final jadwal = raw['jadwal'] as Map<String, dynamic>? ?? {};
      final space = raw['space'] as Map<String, dynamic>? ?? {};
      final rincian = raw['rincian_pembayaran'] as Map<String, dynamic>? ?? {};
      final member = raw['member'] as Map<String, dynamic>? ?? {};

      return ReservationModel(
        id: id,
        kodeBooking: raw['kode_booking']?.toString() ?? '',
        spaceId: space['id'] is int ? space['id'] : int.tryParse(space['id']?.toString() ?? '$id') ?? id,
        namaSpace: space['nama_space']?.toString() ?? space['nama']?.toString(),
        tipeSpace: space['tipe']?.toString(),
        fotoSpace: space['foto_url']?.toString() ?? space['foto']?.toString(),
        tanggal: jadwal['tanggal_reservasi']?.toString() ?? '',
        jamMulai: jadwal['jam_mulai']?.toString() ?? '',
        jamSelesai: jadwal['jam_selesai']?.toString() ?? '',
        durasi: jadwal['durasi_jam'] is int ? jadwal['durasi_jam'] : int.tryParse(jadwal['durasi_jam']?.toString() ?? '1') ?? 1,
        subtotal: rincian['total_harga_awal'] is int ? rincian['total_harga_awal'] : int.tryParse(rincian['total_harga_awal']?.toString() ?? '0') ?? 0,
        potonganDiskon: rincian['potongan_diskon'] is int ? rincian['potongan_diskon'] : int.tryParse(rincian['potongan_diskon']?.toString() ?? '0') ?? 0,
        totalBayar: rincian['total_bayar'] is int ? rincian['total_bayar'] : int.tryParse(rincian['total_bayar']?.toString() ?? '0') ?? 0,
        status: raw['status_reservasi']?.toString() ?? 'disetujui',
        namaMember: member['nama_member']?.toString(),
        teleponMember: member['telp']?.toString(),
      );
    }
    return getReservationById(id);
  }
}
