import 'dart:developer' as dev;
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

    List<ReservationModel> list = [];
    try {
      final response = await _dio.get(
        ApiEndpoints.reservasiMy,
        queryParameters: {
          'status': ?apiStatus,
        },
      );

      final data = _extractData(response.data);
      if (data is List) {
        list = data
            .whereType<Map>()
            .map((json) => ReservationModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      }
    } on DioException catch (_) {
      // Fallback: fetch without status param and filter locally
      if (apiStatus != null) {
        try {
          final fallbackResponse = await _dio.get(ApiEndpoints.reservasiMy);
          final fallbackData = _extractData(fallbackResponse.data);
          if (fallbackData is List) {
            list = fallbackData
                .whereType<Map>()
                .map((json) => ReservationModel.fromJson(Map<String, dynamic>.from(json)))
                .toList();
          }
        } catch (_) {
          rethrow;
        }
      } else {
        rethrow;
      }
    }

    // Client-side filtering
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
        if (filterLower == 'aktif') return s == 'aktif' || s == 'active';
        if (filterLower == 'selesai') return s == 'selesai' || s == 'completed';
        if (filterLower == 'dibatalkan') {
          return s == 'dibatalkan' || s == 'cancelled' || s == 'canceled';
        }
        return s == filterLower;
      }).toList();
    }

    // GET /api/reservasi/my hanya mengembalikan total_bayar tanpa harga_per_jam.
    // Untuk item yang total_bayar=0, fetch detail individual yang punya data pricing lengkap.
    if (list.any((r) => r.totalBayar <= 0)) {
      final enriched = await Future.wait(list.map((r) async {
        if (r.totalBayar > 0) return r;
        dev.log('[ENRICH] id=${r.id} totalBayar=${r.totalBayar} subtotal=${r.subtotal} → fetching detail...', name: 'API');
        try {
          final detail = await getReservationById(r.id);
          dev.log('[ENRICH] id=${r.id} detail.totalBayar=${detail.totalBayar} detail.subtotal=${detail.subtotal}', name: 'API');
          // Pertahankan field yang ada di list tapi tidak di detail (nama_member dsb.)
          final totalBayar = detail.totalBayar > 0 ? detail.totalBayar : r.totalBayar;
          final subtotal   = detail.subtotal   > 0 ? detail.subtotal   : r.subtotal;
          final potongan   = detail.potonganDiskon > 0 ? detail.potonganDiskon : r.potonganDiskon;
          return r.copyWith(
            totalBayar:    totalBayar,
            subtotal:      subtotal,
            potonganDiskon: potongan,
            namaSpace:  r.namaSpace  ?? detail.namaSpace,
            tipeSpace:  r.tipeSpace  ?? detail.tipeSpace,
            fotoSpace:  r.fotoSpace  ?? detail.fotoSpace,
            jamMulai:   r.jamMulai.isEmpty  ? detail.jamMulai  : r.jamMulai,
            jamSelesai: r.jamSelesai.isEmpty ? detail.jamSelesai : r.jamSelesai,
            durasi:     r.durasi > 0 ? r.durasi : detail.durasi,
          );
        } catch (e) {
          dev.log('[ENRICH] id=${r.id} GAGAL enrich: $e', name: 'API');
          return r;
        }
      }));
      return enriched;
    }

    return list;
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
    dev.log('[HISTORY] raw keys: ${data is Map ? data.keys.toList() : "not a map"}', name: 'API');
    dev.log('[HISTORY] raw data: $data', name: 'API');

    if (data is Map<String, dynamic>) {
      // API mengembalikan: { month, year, total_reservasi, total_pengeluaran, items/reservasi: [...] }
      final listData = data['items'] ?? data['reservasi'] ?? data['data'] ?? [];
      dev.log('[HISTORY] listData type=${listData.runtimeType} length=${listData is List ? listData.length : "?"}', name: 'API');

      List<ReservationModel> items = [];
      if (listData is List) {
        for (final json in listData) {
          if (json is Map) {
            final map = Map<String, dynamic>.from(json);
            dev.log('[HISTORY ITEM] keys=${map.keys.toList()} detail_reservasi=${map["detail_reservasi"]} total_bayar=${map["total_bayar"]}', name: 'API');
            items.add(ReservationModel.fromJson(map));
          }
        }
      }

      // Enrichment: jika item dari history tidak punya harga, fetch detail
      if (items.any((r) => r.totalBayar <= 0)) {
        items = await Future.wait(items.map((r) async {
          if (r.totalBayar > 0) return r;
          dev.log('[HISTORY ENRICH] id=${r.id} totalBayar=0 → fetching detail...', name: 'API');
          try {
            final detail = await getReservationById(r.id);
            dev.log('[HISTORY ENRICH] id=${r.id} detail.totalBayar=${detail.totalBayar}', name: 'API');
            return r.copyWith(
              totalBayar:     detail.totalBayar     > 0 ? detail.totalBayar     : r.totalBayar,
              subtotal:       detail.subtotal        > 0 ? detail.subtotal        : r.subtotal,
              potonganDiskon: detail.potonganDiskon  > 0 ? detail.potonganDiskon  : r.potonganDiskon,
              namaSpace:  r.namaSpace  ?? detail.namaSpace,
              tipeSpace:  r.tipeSpace  ?? detail.tipeSpace,
              fotoSpace:  r.fotoSpace  ?? detail.fotoSpace,
              jamMulai:   r.jamMulai.isEmpty   ? detail.jamMulai   : r.jamMulai,
              jamSelesai: r.jamSelesai.isEmpty  ? detail.jamSelesai  : r.jamSelesai,
              durasi:     r.durasi > 0 ? r.durasi : detail.durasi,
            );
          } catch (e) {
            dev.log('[HISTORY ENRICH] id=${r.id} GAGAL: $e', name: 'API');
            return r;
          }
        }));
      }

      int totalBayar = data['total_pengeluaran'] is int
          ? data['total_pengeluaran'] as int
          : int.tryParse(data['total_pengeluaran']?.toString() ?? '0') ?? 0;
      int totalJam = data['total_jam'] is int
          ? data['total_jam'] as int
          : int.tryParse(data['total_jam']?.toString() ?? '0') ?? 0;
      int totalTx = data['total_reservasi'] is int
          ? data['total_reservasi'] as int
          : items.length;

      // Fallback: hitung dari items jika dari API 0 tapi items ada
      if (totalBayar == 0 && items.isNotEmpty) {
        totalBayar = items
            .where((r) => r.status.toLowerCase() != 'dibatalkan')
            .fold(0, (sum, r) => sum + r.totalBayar);
      }
      if (totalJam == 0 && items.isNotEmpty) {
        totalJam = items
            .where((r) => r.status.toLowerCase() != 'dibatalkan')
            .fold(0, (sum, r) => sum + (r.durasi > 0 ? r.durasi : 1));
      }

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
    dev.log('[RESERVASI DETAIL #$id] raw: $data', name: 'API');
    if (data is Map<String, dynamic>) {
      final model = ReservationModel.fromJson(data);
      dev.log('[RESERVASI DETAIL #$id] totalBayar=${model.totalBayar} subtotal=${model.subtotal} durasi=${model.durasi}', name: 'API');
      return model;
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
    // Strategi dual-source:
    // 1. Ambil data dari endpoint e-ticket → dapat kode_booking, status, member info
    // 2. Ambil data dari endpoint detail reservasi → dapat harga, jadwal, durasi yang akurat
    // Gabungkan keduanya: prioritaskan harga dari detail reservasi (lebih lengkap),
    // sedangkan kode_booking dan status dari e-ticket.

    // ── Langkah 1: Fetch e-ticket endpoint ───────────────────────────────────
    String? eTicketKodeBooking;
    String? eTicketStatus;
    String? eTicketNamaSpace;
    String? eTicketFotoSpace;
    String? eTicketTipeSpace;
    String? eTicketNamaMember;
    String? eTicketTelponMember;

    try {
      final response = await _dio.get(ApiEndpoints.eTicket(id));
      final dynamic raw = response.data['data'] ?? response.data;
      if (raw is Map<String, dynamic>) {
        final space  = raw['space']  as Map<String, dynamic>? ?? {};
        final member = raw['member'] as Map<String, dynamic>? ?? {};

        eTicketKodeBooking  = raw['kode_booking']?.toString();
        eTicketStatus       = raw['status_reservasi']?.toString();
        eTicketNamaSpace    = space['nama_space']?.toString() ?? space['nama']?.toString();
        eTicketFotoSpace    = space['foto_url']?.toString()   ?? space['foto']?.toString();
        eTicketTipeSpace    = space['tipe']?.toString();
        eTicketNamaMember   = member['nama_member']?.toString();
        eTicketTelponMember = member['telp']?.toString();

        dev.log('[E-TICKET #$id] kode=$eTicketKodeBooking status=$eTicketStatus', name: 'API');
      }
    } catch (e) {
      dev.log('[E-TICKET #$id] e-ticket endpoint error: $e — akan fallback ke detail', name: 'API');
    }

    // ── Langkah 2: Fetch detail reservasi (sumber data harga & jadwal terpercaya) ─
    ReservationModel detail;
    try {
      detail = await getReservationById(id);
    } catch (e) {
      // Jika keduanya gagal, lempar error
      throw Exception('Gagal memuat data tiket reservasi #$id: $e');
    }

    // ── Langkah 3: Gabungkan — prioritas e-ticket untuk identitas, detail untuk harga ─
    final merged = detail.copyWith(
      kodeBooking:   (eTicketKodeBooking  != null && eTicketKodeBooking.trim().isNotEmpty)
                         ? eTicketKodeBooking.trim()
                         : (detail.kodeBooking.isNotEmpty ? detail.kodeBooking : null),
      status:        eTicketStatus ?? detail.status,
      namaSpace:     eTicketNamaSpace  ?? detail.namaSpace,
      fotoSpace:     eTicketFotoSpace  ?? detail.fotoSpace,
      tipeSpace:     eTicketTipeSpace  ?? detail.tipeSpace,
      namaMember:    eTicketNamaMember  ?? detail.namaMember,
      teleponMember: eTicketTelponMember ?? detail.teleponMember,
    );

    dev.log(
      '[E-TICKET #$id] MERGED totalBayar=${merged.totalBayar} subtotal=${merged.subtotal} '
      'tanggal=${merged.tanggal} jamMulai=${merged.jamMulai} durasi=${merged.durasi}',
      name: 'API',
    );

    return merged;
  }
}
