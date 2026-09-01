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

  // In-memory mock list untuk testing & fallback offline
  static final List<ReservationModel> _mockReservations = [
    const ReservationModel(
      id: 101,
      kodeBooking: '#BOOK-20260830-0012',
      spaceId: 1,
      namaSpace: 'Flexi Desk 01 (Sora Med)',
      tipeSpace: 'personal_desk',
      fotoSpace: 'https://images.unsplash.com/photo-1527192491265-7e15c55b1ed2?w=800&q=80',
      tanggal: '2026-08-30',
      jamMulai: '09:00',
      jamSelesai: '12:00',
      durasi: 3,
      subtotal: 60000,
      potonganDiskon: 0,
      totalBayar: 60000,
      status: 'belum_dikonfirm',
      namaMember: 'Ahmad Fauzi',
      teleponMember: '081234567890',
      createdAt: '2026-08-29T10:00:00.000Z',
    ),
    const ReservationModel(
      id: 102,
      kodeBooking: '#BOOK-20260825-0045',
      spaceId: 2,
      namaSpace: 'Meeting Room Alpha',
      tipeSpace: 'meeting_room',
      fotoSpace: 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800&q=80',
      tanggal: '2026-08-25',
      jamMulai: '13:00',
      jamSelesai: '15:00',
      durasi: 2,
      subtotal: 200000,
      potonganDiskon: 40000,
      totalBayar: 160000,
      status: 'disetujui',
      namaMember: 'Ahmad Fauzi',
      teleponMember: '081234567890',
      createdAt: '2026-08-24T08:30:00.000Z',
    ),
    const ReservationModel(
      id: 103,
      kodeBooking: '#BOOK-20260824-0010',
      spaceId: 3,
      namaSpace: 'Private Office Suite B',
      tipeSpace: 'private_office',
      fotoSpace: 'https://images.unsplash.com/photo-1497215728101-856f4ea42174?w=800&q=80',
      tanggal: '2026-08-24',
      jamMulai: '14:00',
      jamSelesai: '17:00',
      durasi: 3,
      subtotal: 450000,
      potonganDiskon: 90000,
      totalBayar: 360000,
      status: 'aktif',
      namaMember: 'Ahmad Fauzi',
      teleponMember: '081234567890',
      createdAt: '2026-08-23T14:15:00.000Z',
    ),
    const ReservationModel(
      id: 104,
      kodeBooking: '#BOOK-20260515-0088',
      spaceId: 2,
      namaSpace: 'Ruang Rapat Utama Alpha',
      tipeSpace: 'meeting_room',
      fotoSpace: 'https://images.unsplash.com/photo-1517502884422-41eaead166d4?w=800&q=80',
      tanggal: '2026-05-15',
      jamMulai: '09:00',
      jamSelesai: '14:00',
      durasi: 5,
      subtotal: 500000,
      potonganDiskon: 0,
      totalBayar: 500000,
      status: 'selesai',
      namaMember: 'Ahmad Fauzi',
      teleponMember: '081234567890',
      createdAt: '2026-05-14T09:00:00.000Z',
    ),
    const ReservationModel(
      id: 105,
      kodeBooking: '#BOOK-20260510-0033',
      spaceId: 4,
      namaSpace: 'Private Pod B',
      tipeSpace: 'personal_desk',
      fotoSpace: 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=800&q=80',
      tanggal: '2026-05-10',
      jamMulai: '10:00',
      jamSelesai: '14:00',
      durasi: 4,
      subtotal: 100000,
      potonganDiskon: 0,
      totalBayar: 100000,
      status: 'dibatalkan',
      namaMember: 'Ahmad Fauzi',
      teleponMember: '081234567890',
      createdAt: '2026-05-09T11:00:00.000Z',
    ),
  ];

  @override
  Future<List<ReservationModel>> getMyReservations({String? status}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.reservasiMy,
        queryParameters: {
          if (status != null && status.isNotEmpty && status != 'all') 'status': status,
        },
      );

      final dynamic data = response.data['data'] ?? response.data;
      if (data is List) {
        return data.map((json) => ReservationModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      return _filterMockReservations(status);
    } catch (_) {
      return _filterMockReservations(status);
    }
  }

  List<ReservationModel> _filterMockReservations(String? status) {
    if (status == null || status.isEmpty || status == 'all') {
      return List.from(_mockReservations);
    }
    return _mockReservations.where((r) {
      if (status == 'menunggu') return r.status == 'belum_dikonfirm';
      return r.status.toLowerCase() == status.toLowerCase();
    }).toList();
  }

  @override
  Future<ReservationHistorySummary> getMyHistory({int? bulan, int? tahun}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.reservasiMyHistory,
        queryParameters: {
          if (bulan != null) 'bulan': bulan,
          if (tahun != null) 'tahun': tahun,
        },
      );

      final dynamic data = response.data['data'] ?? response.data;
      if (data is Map<String, dynamic>) {
        final listData = data['reservasi'] ?? data['items'] ?? [];
        final items = (listData as List)
            .map((json) => ReservationModel.fromJson(json as Map<String, dynamic>))
            .toList();

        final totalBayar = data['total_pengeluaran'] is int
            ? data['total_pengeluaran']
            : int.tryParse(data['total_pengeluaran']?.toString() ?? '0') ?? 0;
        final totalJam = data['total_jam'] is int
            ? data['total_jam']
            : int.tryParse(data['total_jam']?.toString() ?? '0') ?? 0;

        return ReservationHistorySummary(
          items: items,
          totalPengeluaran: totalBayar,
          totalJam: totalJam,
          totalTransaksi: items.length,
        );
      }
      return _filterMockHistory(bulan, tahun);
    } catch (_) {
      return _filterMockHistory(bulan, tahun);
    }
  }

  ReservationHistorySummary _filterMockHistory(int? bulan, int? tahun) {
    final filtered = _mockReservations.where((r) {
      if (bulan != null) {
        try {
          final dt = DateTime.parse(r.tanggal);
          if (dt.month != bulan) return false;
          if (tahun != null && dt.year != tahun) return false;
        } catch (_) {}
      }
      return true;
    }).toList();

    int totalPengeluaran = 0;
    int totalJam = 0;

    for (final item in filtered) {
      if (item.status != 'dibatalkan') {
        totalPengeluaran += item.totalBayar;
        totalJam += item.durasi;
      }
    }

    return ReservationHistorySummary(
      items: filtered,
      totalPengeluaran: totalPengeluaran,
      totalJam: totalJam,
      totalTransaksi: filtered.length,
    );
  }

  @override
  Future<ReservationModel> getReservationById(int id) async {
    try {
      final response = await _dio.get(ApiEndpoints.reservasiDetail(id));
      final dynamic data = response.data['data'] ?? response.data;
      if (data is Map<String, dynamic>) {
        return ReservationModel.fromJson(data);
      }
      return _mockReservations.firstWhere((r) => r.id == id,
          orElse: () => _mockReservations.first);
    } catch (_) {
      return _mockReservations.firstWhere((r) => r.id == id,
          orElse: () => _mockReservations.first);
    }
  }

  @override
  Future<bool> cancelReservation(int id) async {
    try {
      await _dio.put(ApiEndpoints.cancelReservasi(id));
      // Update mock in-memory
      final index = _mockReservations.indexWhere((r) => r.id == id);
      if (index != -1) {
        final current = _mockReservations[index];
        _mockReservations[index] = ReservationModel(
          id: current.id,
          kodeBooking: current.kodeBooking,
          spaceId: current.spaceId,
          namaSpace: current.namaSpace,
          tipeSpace: current.tipeSpace,
          fotoSpace: current.fotoSpace,
          tanggal: current.tanggal,
          jamMulai: current.jamMulai,
          jamSelesai: current.jamSelesai,
          durasi: current.durasi,
          subtotal: current.subtotal,
          potonganDiskon: current.potonganDiskon,
          totalBayar: current.totalBayar,
          status: 'dibatalkan',
          namaMember: current.namaMember,
          teleponMember: current.teleponMember,
          createdAt: current.createdAt,
        );
      }
      return true;
    } catch (_) {
      // Mock cancel fallback
      final index = _mockReservations.indexWhere((r) => r.id == id);
      if (index != -1) {
        final current = _mockReservations[index];
        _mockReservations[index] = ReservationModel(
          id: current.id,
          kodeBooking: current.kodeBooking,
          spaceId: current.spaceId,
          namaSpace: current.namaSpace,
          tipeSpace: current.tipeSpace,
          fotoSpace: current.fotoSpace,
          tanggal: current.tanggal,
          jamMulai: current.jamMulai,
          jamSelesai: current.jamSelesai,
          durasi: current.durasi,
          subtotal: current.subtotal,
          potonganDiskon: current.potonganDiskon,
          totalBayar: current.totalBayar,
          status: 'dibatalkan',
          namaMember: current.namaMember,
          teleponMember: current.teleponMember,
          createdAt: current.createdAt,
        );
      }
      return true;
    }
  }

  @override
  Future<ReservationModel> getETicket(int id) async {
    try {
      final response = await _dio.get(ApiEndpoints.eTicket(id));
      final dynamic data = response.data['data'] ?? response.data;
      if (data is Map<String, dynamic>) {
        return ReservationModel.fromJson(data);
      }
      return getReservationById(id);
    } catch (_) {
      return getReservationById(id);
    }
  }
}
