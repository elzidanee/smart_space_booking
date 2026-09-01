import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/secure_storage_service.dart';

/// Interceptor Dio terpusat untuk menyisipkan header x-maker-key dan Authorization: Bearer,
/// serta merespons 401 Unauthorized sesuai PRD Bagian II §5.
class ApiHeaderInterceptor extends Interceptor {
  final SecureStorageService storage;
  final VoidCallback? onSessionExpired;

  ApiHeaderInterceptor(this.storage, {this.onSessionExpired});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 1. Normalisasi URL path untuk baseUrl bersubfolder (misal: /coworking)
    if (options.baseUrl.isNotEmpty) {
      if (!options.baseUrl.endsWith('/')) {
        options.baseUrl = '${options.baseUrl}/';
      }
      if (options.path.startsWith('/')) {
        options.path = options.path.substring(1);
      }
    }

    // 2. Sisipkan header x-maker-key jika tersedia
    final appKey = await storage.readAppKey();
    if (appKey != null && appKey.isNotEmpty) {
      options.headers['x-maker-key'] = appKey;
    }

    // 3. Sisipkan Authorization Bearer jika ada sesi aktif
    final token = await storage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Selalu terima respon JSON
    options.headers['Accept'] = 'application/json';

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle status 401 Unauthorized -> hapus sesi dan picu callback redirect login
    if (err.response?.statusCode == 401) {
      await storage.clearSession();
      onSessionExpired?.call();
    }
    handler.next(err);
  }
}
