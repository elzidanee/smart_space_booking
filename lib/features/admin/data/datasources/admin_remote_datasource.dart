import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../spaces/data/models/space_models.dart';
import '../models/admin_models.dart';

final adminRemoteDataSourceProvider = Provider<AdminRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return AdminRemoteDataSourceImpl(dio);
});

abstract class AdminRemoteDataSource {
  // 1. Profil Lokasi Coworking
  Future<AdminProfileModel> getProfile();
  Future<AdminProfileModel> updateProfile(AdminProfileModel profile);

  // 2. Master Data Member
  Future<List<AdminMemberModel>> getMembers({String? query});
  Future<AdminMemberModel> createMember(AdminMemberModel member, {String? password});
  Future<AdminMemberModel> updateMember(AdminMemberModel member, {String? password});
  Future<bool> deleteMember(int id);

  // 3. Master Data Space
  Future<List<SpaceModel>> getSpaces({String? query, String? tipe});
  Future<SpaceModel> createSpace(SpaceModel space);
  Future<SpaceModel> updateSpace(SpaceModel space);
  Future<bool> deleteSpace(int id);

  // 4. Master Data Diskon
  Future<List<AdminDiscountModel>> getDiscounts();
  Future<AdminDiscountModel> createDiscount(AdminDiscountModel discount);
  Future<AdminDiscountModel> updateDiscount(AdminDiscountModel discount);
  Future<bool> deleteDiscount(int id);

  // 5. Kelola Reservasi Admin
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

  // 6. Rekapitulasi Pendapatan Bulanan
  Future<AdminMonthlyReportModel> getMonthlyReport({int? month, int? year});
  Future<Map<String, dynamic>> getIncomeReport({int? month, int? year});

  // 7. App Maker Multi-Tenancy Info
  Future<Map<String, dynamic>> getMakerStats();

  // 8. Upload Media
  Future<String> uploadSpacePhoto(File file);
  Future<String> uploadMemberPhoto(File file);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final Dio _dio;

  AdminRemoteDataSourceImpl(this._dio);

  // ==========================================
  // 1. Profil Lokasi Coworking (Admin)
  // ==========================================
  @override
  Future<AdminProfileModel> getProfile() async {
    final response = await _dio.get(ApiEndpoints.adminProfile);
    final dynamic data = response.data['data'] ?? response.data;
    if (data is Map<String, dynamic>) {
      return AdminProfileModel.fromJson(data);
    }
    throw Exception('Format data profil coworking tidak valid.');
  }

  @override
  Future<AdminProfileModel> updateProfile(AdminProfileModel profile) async {
    final response = await _dio.put(
      ApiEndpoints.adminProfile,
      data: profile.toJson(),
    );
    final dynamic data = response.data['data'] ?? response.data;
    if (data is Map<String, dynamic>) {
      return AdminProfileModel.fromJson(data);
    }
    return profile;
  }

  // ==========================================
  // 2. Master Data Member CRUD
  // ==========================================
  @override
  Future<List<AdminMemberModel>> getMembers({String? query}) async {
    final response = await _dio.get(
      ApiEndpoints.adminMembers,
      queryParameters: {
        if (query != null && query.trim().isNotEmpty) 'search': query.trim(),
      },
    );
    final dynamic data = response.data['data'] ?? response.data;
    if (data is List) {
      return data.map((e) => AdminMemberModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<AdminMemberModel> createMember(AdminMemberModel member, {String? password}) async {
    final response = await _dio.post(
      ApiEndpoints.adminMembers,
      data: member.toJson(password: password),
    );
    final dynamic data = response.data['data'] ?? response.data;
    if (data is Map<String, dynamic>) {
      return AdminMemberModel.fromJson(data);
    }
    return member;
  }

  @override
  Future<AdminMemberModel> updateMember(AdminMemberModel member, {String? password}) async {
    final response = await _dio.put(
      ApiEndpoints.adminMemberDetail(member.id),
      data: member.toJson(password: password),
    );
    final dynamic data = response.data['data'] ?? response.data;
    if (data is Map<String, dynamic>) {
      return AdminMemberModel.fromJson(data);
    }
    return member;
  }

  @override
  Future<bool> deleteMember(int id) async {
    await _dio.delete(ApiEndpoints.adminMemberDetail(id));
    return true;
  }

  // ==========================================
  // 3. Master Data Space CRUD
  // ==========================================
  @override
  // ==========================================
  // 3. Master Data Space CRUD
  // ==========================================
  @override
  Future<List<SpaceModel>> getSpaces({String? query, String? tipe}) async {
    final response = await _dio.get(
      ApiEndpoints.adminSpaces,
      queryParameters: {
        if (query != null && query.trim().isNotEmpty) 'search': query.trim(),
        if (tipe != null && tipe.trim().isNotEmpty && tipe != 'all' && tipe != 'semua')
          'tipe': tipe.trim(),
      },
    );
    final dynamic data = response.data['data'] ?? response.data;
    if (data is List) {
      return data.map((e) => SpaceModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<SpaceModel> createSpace(SpaceModel space) async {
    final response = await _dio.post(
      ApiEndpoints.adminSpaces,
      data: space.toJson(),
    );
    final dynamic data = response.data['data'] ?? response.data;
    if (data is Map<String, dynamic>) {
      final parsed = SpaceModel.fromJson(data);
      return parsed.copyWith(
        foto: parsed.foto ?? space.foto,
        fasilitas: parsed.fasilitas.isNotEmpty ? parsed.fasilitas : space.fasilitas,
        deskripsi: parsed.deskripsi ?? space.deskripsi,
      );
    }
    return space;
  }

  @override
  Future<SpaceModel> updateSpace(SpaceModel space) async {
    final response = await _dio.put(
      ApiEndpoints.adminSpaceDetail(space.id),
      data: space.toJson(),
    );
    final dynamic data = response.data['data'] ?? response.data;
    if (data is Map<String, dynamic>) {
      final parsed = SpaceModel.fromJson(data);
      return parsed.copyWith(
        foto: parsed.foto ?? space.foto,
        fasilitas: parsed.fasilitas.isNotEmpty ? parsed.fasilitas : space.fasilitas,
        deskripsi: parsed.deskripsi ?? space.deskripsi,
      );
    }
    return space;
  }

  @override
  Future<bool> deleteSpace(int id) async {
    await _dio.delete(ApiEndpoints.adminSpaceDetail(id));
    return true;
  }

  // ==========================================
  // 4. Master Data Diskon CRUD
  // ==========================================
  @override
  Future<List<AdminDiscountModel>> getDiscounts() async {
    final response = await _dio.get(ApiEndpoints.adminDiskon);
    final dynamic data = response.data['data'] ?? response.data;
    if (data is List) {
      return data.map((e) => AdminDiscountModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<AdminDiscountModel> createDiscount(AdminDiscountModel discount) async {
    final response = await _dio.post(
      ApiEndpoints.adminDiskon,
      data: discount.toJson(),
    );
    final dynamic data = response.data['data'] ?? response.data;
    if (data is Map<String, dynamic>) {
      return AdminDiscountModel.fromJson(data);
    }
    return discount;
  }

  @override
  Future<AdminDiscountModel> updateDiscount(AdminDiscountModel discount) async {
    final response = await _dio.put(
      ApiEndpoints.adminDiskonDetail(discount.id),
      data: discount.toJson(),
    );
    final dynamic data = response.data['data'] ?? response.data;
    if (data is Map<String, dynamic>) {
      return AdminDiscountModel.fromJson(data);
    }
    return discount;
  }

  @override
  Future<bool> deleteDiscount(int id) async {
    await _dio.delete(ApiEndpoints.adminDiskonDetail(id));
    return true;
  }

  // ==========================================
  // 5. Kelola Reservasi Admin & Check-in / Check-out
  // ==========================================
  @override
  Future<List<ReservationModel>> getReservations({
    String? status,
    int? month,
    int? year,
    int? idSpace,
    String? tanggal,
    String? query,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.adminReservasi,
      queryParameters: {
        if (status != null && status.isNotEmpty && status != 'all') 'status': status,
        'month': ?month,
        'year': ?year,
        'id_space': ?idSpace,
        if (tanggal != null && tanggal.isNotEmpty) 'tanggal': tanggal,
        if (query != null && query.trim().isNotEmpty) 'search': query.trim(),
      },
    );
    final dynamic data = response.data['data'] ?? response.data;
    if (data is List) {
      return data.map((e) => ReservationModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<ReservationModel> getReservationById(int id) async {
    final response = await _dio.get(ApiEndpoints.adminReservasiDetail(id));
    final dynamic data = response.data['data'] ?? response.data;
    if (data is Map<String, dynamic>) {
      return ReservationModel.fromJson(data);
    }
    throw Exception('Reservasi dengan ID $id tidak ditemukan di server.');
  }

  @override
  Future<ReservationModel> updateReservationStatus(int id, String status) async {
    final response = await _dio.patch(
      ApiEndpoints.adminUpdateReservasiStatus(id),
      data: {'status': status},
    );
    final dynamic data = response.data['data'] ?? response.data;
    if (data is Map<String, dynamic>) {
      return ReservationModel.fromJson(data);
    }
    throw Exception('Gagal memperbarui status reservasi.');
  }

  @override
  Future<ReservationModel> checkInReservation(int id) async {
    final response = await _dio.post(ApiEndpoints.adminCheckIn(id));
    final dynamic data = response.data['data'] ?? response.data;
    if (data is Map<String, dynamic>) {
      return ReservationModel.fromJson(data);
    }
    throw Exception('Gagal melakukan check-in reservasi.');
  }

  @override
  Future<ReservationModel> checkOutReservation(int id) async {
    final response = await _dio.post(ApiEndpoints.adminCheckOut(id));
    final dynamic data = response.data['data'] ?? response.data;
    if (data is Map<String, dynamic>) {
      return ReservationModel.fromJson(data);
    }
    throw Exception('Gagal melakukan check-out reservasi.');
  }

  // ==========================================
  // 6. Rekapitulasi Pendapatan Bulanan
  // ==========================================
  @override
  Future<AdminMonthlyReportModel> getMonthlyReport({int? month, int? year}) async {
    final targetMonth = month ?? DateTime.now().month;
    final targetYear = year ?? DateTime.now().year;

    final response = await _dio.get(
      ApiEndpoints.adminMonthlyReport,
      queryParameters: {
        'month': targetMonth,
        'year': targetYear,
      },
    );
    final dynamic data = response.data['data'] ?? response.data;
    if (data is Map<String, dynamic>) {
      return AdminMonthlyReportModel.fromJson(data);
    }
    return AdminMonthlyReportModel(
      bulan: targetMonth,
      tahun: targetYear,
      pendapatanKotor: 0,
      potonganDiskon: 0,
      pendapatanBersih: 0,
      totalTransaksi: 0,
      totalJamTerpakai: 0,
      perTipeSpace: const [],
    );
  }

  @override
  Future<Map<String, dynamic>> getIncomeReport({int? month, int? year}) async {
    final response = await _dio.get(
      ApiEndpoints.adminIncomeReport,
      queryParameters: {
        'month': ?month,
        'year': ?year,
      },
    );
    final dynamic data = response.data['data'] ?? response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> getMakerStats() async {
    final response = await _dio.get(ApiEndpoints.makerStats);
    final dynamic data = response.data['data'] ?? response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    return {};
  }

  // ==========================================
  // 8. Upload Media
  // ==========================================
  @override
  Future<String> uploadSpacePhoto(File file) async {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });

    final response = await _dio.post(
      ApiEndpoints.uploadSpace,
      data: formData,
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data['data'] != null && data['data']['filename'] != null) {
        return data['data']['filename'].toString();
      }
      if (data['data'] != null && data['data']['foto_url'] != null) {
        return data['data']['foto_url'].toString();
      }
      if (data['filename'] != null) {
        return data['filename'].toString();
      }
    }
    throw Exception('Gagal mengunggah foto ruangan: Respon server tidak valid.');
  }

  @override
  Future<String> uploadMemberPhoto(File file) async {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });

    final response = await _dio.post(
      ApiEndpoints.uploadMember,
      data: formData,
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data['data'] != null && data['data']['filename'] != null) {
        return data['data']['filename'].toString();
      }
      if (data['data'] != null && data['data']['foto_url'] != null) {
        return data['data']['foto_url'].toString();
      }
      if (data['filename'] != null) {
        return data['filename'].toString();
      }
    }
    throw Exception('Gagal mengunggah foto member: Respon server tidak valid.');
  }
}
