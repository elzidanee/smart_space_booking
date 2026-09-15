import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_models.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(dioClientProvider));
});

class AuthRemoteDataSource {
  final Dio _dio;
  AuthRemoteDataSource(this._dio);

  Future<UserSession> login(String username, String password) async {
    final res = await _dio.post(ApiEndpoints.login, data: {
      'username': username,
      'password': password,
    });
    return _parseSession(res.data, 'login');
  }

  Future<UserSession> registerMember(RegisterMemberRequest request) async {
    final res = await _dio.post(ApiEndpoints.registerMember, data: request.toJson());
    return _parseSession(res.data, 'registrasi member');
  }

  Future<UserSession> registerAdmin(RegisterAdminRequest request) async {
    final res = await _dio.post(ApiEndpoints.registerAdmin, data: request.toJson());
    return _parseSession(res.data, 'registrasi admin');
  }

  // Upload file gambar/foto profil menggunakan format multipart/form-data.
  Future<String> uploadMemberPhoto(File file) async {
    // Ambil nama file aslinya dari path lokal HP (misal: 'foto_ktp.jpg')
    final fileName = file.path.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });
    final res = await _dio.post(ApiEndpoints.uploadMember, data: formData);
    final data = res.data;
    // Ambil nama file hasil generate server dari respon JSON
    if (data is Map<String, dynamic>) {
      return data['data']?['filename']?.toString() ??
             data['filename']?.toString() ??
             fileName;
    }
    return fileName;
  }

  Future<UserModel> getProfile() async {
    final res = await _dio.get(ApiEndpoints.profile);
    return _parseUserModel(res.data, 'profil');
  }

  // Helper fleksibel untuk membongkar JSON sesi user:
  // Backend UKK kadang membungkus responnya dalam properti 'data' (contoh: {data: {token: ...}}),
  // tapi kadang langsung di root JSON (contoh: {token: ...}).
  // Pengecekan ini bikin aplikasi kebal dari variasi respon backend.
  UserSession _parseSession(dynamic data, String label) {
    if (data is Map<String, dynamic>) {
      final payload = data['data'] is Map<String, dynamic> ? data['data'] : data;
      return UserSession.fromJson(payload as Map<String, dynamic>);
    }
    throw Exception('Format respons $label tidak valid.');
  }

  UserModel _parseUserModel(dynamic data, String label) {
    if (data is Map<String, dynamic>) {
      final payload = data['data'] is Map<String, dynamic> ? data['data'] : data;
      return UserModel.fromJson(payload as Map<String, dynamic>);
    }
    throw Exception('Format $label tidak valid.');
  }
}
