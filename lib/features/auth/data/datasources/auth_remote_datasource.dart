import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_models.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return AuthRemoteDataSource(dio);
});

/// Remote Data Source untuk menangani pemanggilan API autentikasi panitia.
class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  /// POST /api/auth/login (FR-04)
  Future<UserSession> login(String username, String password) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: {
        'username': username,
        'password': password,
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      // Periksa format respons: { status: true, data: { access_token, role, user } }
      final payload = data['data'] is Map<String, dynamic> ? data['data'] : data;
      return UserSession.fromJson(payload as Map<String, dynamic>);
    }

    throw Exception('Format respons login tidak valid.');
  }

  /// POST /api/auth/register/member (FR-02)
  Future<UserSession> registerMember(RegisterMemberRequest request) async {
    final response = await _dio.post(
      ApiEndpoints.registerMember,
      data: request.toJson(),
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final payload = data['data'] is Map<String, dynamic> ? data['data'] : data;
      return UserSession.fromJson(payload as Map<String, dynamic>);
    }

    throw Exception('Format respons registrasi member tidak valid.');
  }

  /// POST /api/auth/register/admin-space (FR-03)
  Future<UserSession> registerAdmin(RegisterAdminRequest request) async {
    final response = await _dio.post(
      ApiEndpoints.registerAdmin,
      data: request.toJson(),
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final payload = data['data'] is Map<String, dynamic> ? data['data'] : data;
      return UserSession.fromJson(payload as Map<String, dynamic>);
    }

    throw Exception('Format respons registrasi admin tidak valid.');
  }

  /// POST /api/upload/members (Upload foto member terpisah sesuai PRD §8 & §10)
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
      // Ambil nama file dari respon { status: true, data: { filename: '...' } }
      if (data['data'] != null && data['data']['filename'] != null) {
        return data['data']['filename'].toString();
      }
      if (data['filename'] != null) {
        return data['filename'].toString();
      }
    }

    return fileName;
  }

  /// GET /api/auth/profile
  Future<UserModel> getProfile() async {
    final response = await _dio.get(ApiEndpoints.profile);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final payload = data['data'] is Map<String, dynamic> ? data['data'] : data;
      return UserModel.fromJson(payload as Map<String, dynamic>);
    }

    throw Exception('Format profil tidak valid.');
  }
}
