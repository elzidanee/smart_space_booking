import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/secure_storage_service.dart';

class ApiHeaderInterceptor extends Interceptor {
  final SecureStorageService storage;
  final VoidCallback? onSessionExpired;

  ApiHeaderInterceptor(this.storage, {this.onSessionExpired});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Gunakan custom base URL jika tersimpan
    final customBase = await storage.readBaseUrl();
    if (customBase != null && customBase.trim().isNotEmpty) {
      options.baseUrl = customBase.trim();
    }

    // Normalisasi trailing slash agar path tidak double-slash
    if (options.baseUrl.isNotEmpty) {
      if (!options.baseUrl.endsWith('/')) options.baseUrl = '${options.baseUrl}/';
      if (options.path.startsWith('/')) options.path = options.path.substring(1);
    }

    // Sisipkan x-maker-key
    final appKey = await storage.readAppKey();
    if (appKey != null && appKey.isNotEmpty) {
      options.headers['x-maker-key'] = appKey;
    }

    // Sisipkan Bearer token
    final token = await storage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    options.headers['Accept'] = 'application/json';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await storage.clearSession();
      onSessionExpired?.call();
    }
    handler.next(err);
  }
}
