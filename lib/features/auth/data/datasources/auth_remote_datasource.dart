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

  Future<String> uploadMemberPhoto(File file) async {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });
    final res = await _dio.post(ApiEndpoints.uploadMember, data: formData);
    final data = res.data;
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

  // Helpers
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
