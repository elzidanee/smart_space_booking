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
    final queryTipe = (tipe == 'personal_desk' || tipe == 'desk') ? 'desk' : tipe;
    try {
      final response = await _dio.get(
        ApiEndpoints.spaces,
        queryParameters: {
          if (query != null && query.trim().isNotEmpty) 'search': query.trim(),
          if (queryTipe != null && queryTipe.trim().isNotEmpty && queryTipe != 'all' && queryTipe != 'semua')
            'tipe': queryTipe.trim(),
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

      final isDeskFilter = tipe == 'desk' || tipe == 'personal_desk';
      final isSpaceDesk = space.tipe == 'desk' || space.tipe == 'personal_desk';

      final matchTipe = tipe == null ||
          tipe.isEmpty ||
          tipe == 'all' ||
          tipe == 'semua' ||
          (isDeskFilter && isSpaceDesk) ||
          space.tipe.toLowerCase() == tipe.toLowerCase();

      return matchQuery && matchTipe;
    }).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getSpaceTypes() async {
    try {
      final response = await _dio.get(ApiEndpoints.spaceTypes);
      final dynamic data = response.data['data'] ?? response.data;
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
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
    final dynamic data = response.data['data'] ?? response.data;
    if (data is Map<String, dynamic>) {
      return SpaceModel.fromJson(data);
    }
    throw Exception('Detail ruangan dengan ID $id tidak ditemukan.');
  }

  @override
  Future<List<Map<String, dynamic>>> getActiveDiscounts() async {
    final response = await _dio.get(ApiEndpoints.diskonActive);
    final dynamic data = response.data['data'] ?? response.data;
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
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
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;
      String message = 'Space tidak tersedia pada jadwal yang dipilih.';
      if (responseData is Map<String, dynamic> && responseData['message'] != null) {
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
  }

  @override
  Future<ReservationModel> createReservation(CreateReservationRequest request) async {
    final response = await _dio.post(
      ApiEndpoints.reservasi,
      data: request.toJson(),
    );

    final dynamic data = response.data['data'] ?? response.data;
    if (data is Map<String, dynamic>) {
      return ReservationModel.fromJson(data);
    }
    throw Exception('Gagal membuat reservasi: format respon server tidak valid.');
  }
}
