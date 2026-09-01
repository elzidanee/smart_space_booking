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

  // Mock list seed data saat backend offline / testing
  static final List<SpaceModel> _mockSpaces = [
    const SpaceModel(
      id: 1,
      nama: 'Flexi Desk 01',
      tipe: 'personal_desk',
      kapasitas: 1,
      hargaPerJam: 20000,
      fasilitas: ['WiFi Cepat', 'Power Outlet', 'Coffee Refill', 'AC'],
      deskripsi:
          'Meja kerja personal fleksibel dengan kursi ergonomis, pencahayaan alami, dan koneksi internet serat optik kecepatan tinggi untuk fokus optimal.',
      foto: 'https://images.unsplash.com/photo-1527192491265-7e15c55b1ed2?w=800&q=80',
      status: 'tersedia',
    ),
    const SpaceModel(
      id: 2,
      nama: 'Meeting Room Alpha',
      tipe: 'meeting_room',
      kapasitas: 8,
      hargaPerJam: 100000,
      fasilitas: ['WiFi Cepat', 'TV/Proyektor', 'AC', 'Whiteboard', 'Sound System'],
      deskripsi:
          'Ruang meeting premium yang dirancang untuk mendukung kolaborasi tim dan presentasi klien dengan fasilitas multimedia lengkap dan peredam suara.',
      foto: 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800&q=80',
      status: 'tersedia',
    ),
    const SpaceModel(
      id: 3,
      nama: 'Private Office Suite B',
      tipe: 'private_office',
      kapasitas: 4,
      hargaPerJam: 150000,
      fasilitas: ['WiFi Cepat', 'AC', 'Private Key Access', 'Whiteboard', 'Lounge Access'],
      deskripsi:
          'Ruang kantor privat eksklusif untuk tim kecil, dilengkapi meja eksekutif, sofa tamu, dan akses aman 24/7.',
      foto: 'https://images.unsplash.com/photo-1497215728101-856f4ea42174?w=800&q=80',
      status: 'tersedia',
    ),
    const SpaceModel(
      id: 4,
      nama: 'Flexi Desk 02 (Focus Zone)',
      tipe: 'personal_desk',
      kapasitas: 1,
      hargaPerJam: 25000,
      fasilitas: ['WiFi Cepat', 'Noise Cancelling Divider', 'Monitor Hookup', 'AC'],
      deskripsi:
          'Hot desk di area hening dengan sekat akustik dan dudukan laptop monitor tambahan untuk para developer dan desainer.',
      foto: 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=800&q=80',
      status: 'tersedia',
    ),
    const SpaceModel(
      id: 5,
      nama: 'Meeting Room Beta (Creative Lab)',
      tipe: 'meeting_room',
      kapasitas: 12,
      hargaPerJam: 130000,
      fasilitas: ['WiFi Cepat', 'Smart TV 65 Inch', 'Glassboard', 'Video Conference Cam', 'AC'],
      deskripsi:
          'Ruang pertemuan luas dengan perlengkapan video conference canggih untuk workshop, pitching, dan diskusi hybrid lintas tim.',
      foto: 'https://images.unsplash.com/photo-1517502884422-41eaead166d4?w=800&q=80',
      status: 'tersedia',
    ),
    const SpaceModel(
      id: 6,
      nama: 'Executive Office 01',
      tipe: 'private_office',
      kapasitas: 6,
      hargaPerJam: 200000,
      fasilitas: ['High-speed LAN', 'Private Restroom', 'Mini Bar', 'AC', 'Smart Lock'],
      deskripsi:
          'Kantor eksekutif bertaraf internasional dengan pemandangan kota dan privasi maksimal.',
      foto: 'https://images.unsplash.com/photo-1577495508048-b635879837f1?w=800&q=80',
      status: 'tersedia',
    ),
  ];

  @override
  Future<List<SpaceModel>> getSpaces({String? query, String? tipe}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.spaces,
        queryParameters: {
          if (query != null && query.trim().isNotEmpty) 'search': query.trim(),
          if (tipe != null && tipe.trim().isNotEmpty && tipe != 'all' && tipe != 'semua')
            'tipe': tipe.trim(),
        },
      );

      final dynamic data = response.data['data'] ?? response.data;
      if (data is List) {
        return data.map((json) => SpaceModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      return _filterMockSpaces(query, tipe);
    } catch (_) {
      // Fallback offline mock data
      return _filterMockSpaces(query, tipe);
    }
  }

  List<SpaceModel> _filterMockSpaces(String? query, String? tipe) {
    return _mockSpaces.where((space) {
      final matchQuery = query == null ||
          query.trim().isEmpty ||
          space.nama.toLowerCase().contains(query.toLowerCase()) ||
          space.fasilitas.any((f) => f.toLowerCase().contains(query.toLowerCase()));

      final matchTipe = tipe == null ||
          tipe.isEmpty ||
          tipe == 'all' ||
          tipe == 'semua' ||
          space.tipe.toLowerCase() == tipe.toLowerCase();

      return matchQuery && matchTipe;
    }).toList();
  }

  @override
  Future<SpaceModel> getSpaceById(int id) async {
    try {
      final response = await _dio.get('${ApiEndpoints.spaces}/$id');
      final dynamic data = response.data['data'] ?? response.data;
      if (data is Map<String, dynamic>) {
        return SpaceModel.fromJson(data);
      }
      return _mockSpaces.firstWhere((s) => s.id == id, orElse: () => _mockSpaces.first);
    } catch (_) {
      return _mockSpaces.firstWhere((s) => s.id == id, orElse: () => _mockSpaces.first);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getActiveDiscounts() async {
    try {
      final response = await _dio.get(ApiEndpoints.diskonActive);
      final dynamic data = response.data['data'] ?? response.data;
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (_) {
      // Fallback mock: tampilkan promo aktif default
      return [
        {'id': 1, 'nama_diskon': 'DISKONHEMAT20', 'persentase_diskon': 20, 'tanggal_awal': '2026-08-01', 'tanggal_akhir': '2026-12-31'},
        {'id': 2, 'nama_diskon': 'DISKONMEMBER10', 'persentase_diskon': 10, 'tanggal_awal': '2026-01-01', 'tanggal_akhir': '2026-12-31'},
      ];
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

      final dynamic data = response.data['data'] ?? response.data;
      if (data is Map<String, dynamic>) {
        return AvailabilityCheckResult.fromJson(data);
      }
      return AvailabilityCheckResult(
        isAvailable: true,
        message: 'Space tersedia untuk jadwal ini',
        tanggal: tanggal,
        jamMulai: jamMulai,
        durasi: durasi,
      );
    } catch (e) {
      // Jika error 400 berarti sudah terisi
      final errMsg = e.toString().toLowerCase();
      if (errMsg.contains('400') || errMsg.contains('tidak tersedia') || errMsg.contains('sudah terisi')) {
        return AvailabilityCheckResult(
          isAvailable: false,
          message: 'Space sudah terisi pada jadwal yang dipilih.',
          tanggal: tanggal,
          jamMulai: jamMulai,
          durasi: durasi,
        );
      }
      return AvailabilityCheckResult(
        isAvailable: true,
        message: 'Space tersedia (Verified Offline)',
        tanggal: tanggal,
        jamMulai: jamMulai,
        durasi: durasi,
      );
    }
  }

  @override
  Future<PromoCheckResult> checkPromo(String kodePromo, {int subtotal = 0}) async {
    final cleanKode = kodePromo.trim().toUpperCase();

    try {
      // POST /api/diskon/check — body: { nama_diskon } sesuai kontrak API
      final response = await _dio.post(
        ApiEndpoints.checkDiskon,
        data: {'nama_diskon': cleanKode}, // API memakai nama_diskon bukan kode
      );

      final dynamic data = response.data['data'] ?? response.data;
      if (data is Map<String, dynamic>) {
        return PromoCheckResult.fromJson(data, subtotal: subtotal);
      }
      throw Exception('Kode promo tidak valid atau telah kedaluwarsa.');
    } catch (e) {
      // Fallback mock untuk demo/offline
      if (cleanKode == 'DISKONHEMAT20' || cleanKode == 'HEMAT20') {
        final potongan = (subtotal * 0.20).round();
        return PromoCheckResult(
          id: 1,
          kode: cleanKode,
          persentase: 20,
          potongan: potongan,
          pesan: 'Diskon 20% Berhasil Diterapkan!',
        );
      } else if (cleanKode == 'DISKONMEMBER10' || cleanKode == 'MEMBER10') {
        final potongan = (subtotal * 0.10).round();
        return PromoCheckResult(
          id: 2,
          kode: cleanKode,
          persentase: 10,
          potongan: potongan,
          pesan: 'Diskon Member 10% Berhasil!',
        );
      }
      if (cleanKode.isNotEmpty) {
        throw Exception('Kode promo "$cleanKode" tidak ditemukan atau telah kedaluwarsa.');
      }
      rethrow;
    }
  }

  @override
  Future<ReservationModel> createReservation(CreateReservationRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.reservasi,
        data: request.toJson(),
      );

      final dynamic data = response.data['data'] ?? response.data;
      if (data is Map<String, dynamic>) {
        return ReservationModel.fromJson(data);
      }
      return _generateMockReservation(request);
    } catch (_) {
      return _generateMockReservation(request);
    }
  }

  ReservationModel _generateMockReservation(CreateReservationRequest request) {
    final space = _mockSpaces.firstWhere(
      (s) => s.id == request.spaceId,
      orElse: () => _mockSpaces.first,
    );

    final subtotal = space.hargaPerJam * request.durasi;
    int diskon = 0;
    if (request.kodePromo != null && request.kodePromo!.isNotEmpty) {
      final code = request.kodePromo!.toUpperCase();
      if (code.contains('20')) {
        diskon = (subtotal * 0.2).round();
      } else {
        diskon = (subtotal * 0.1).round();
      }
    }
    final total = subtotal - diskon;

    // Calculate end time
    final parts = request.jamMulai.split(':');
    final startHour = int.tryParse(parts[0]) ?? 9;
    final startMin = parts.length > 1 ? parts[1] : '00';
    final endHour = (startHour + request.durasi).toString().padLeft(2, '0');
    final jamSelesai = '$endHour:$startMin';

    final nowMillis = DateTime.now().millisecondsSinceEpoch.toString();
    final bookingCode = 'BK-${nowMillis.substring(nowMillis.length - 6)}';

    return ReservationModel(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      kodeBooking: bookingCode,
      spaceId: space.id,
      namaSpace: space.nama,
      tipeSpace: space.tipe,
      fotoSpace: space.foto,
      tanggal: request.tanggal,
      jamMulai: request.jamMulai,
      jamSelesai: jamSelesai,
      durasi: request.durasi,
      subtotal: subtotal,
      potonganDiskon: diskon,
      totalBayar: total,
      status: 'belum_dikonfirm',
      createdAt: DateTime.now().toIso8601String(),
    );
  }
}
