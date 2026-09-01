import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage_service.dart';
import 'api_endpoints.dart';
import 'api_header_interceptor.dart';

final dioClientProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  return DioClient.createDio(storage);
});

/// Client konfigurasi Dio dengan interceptor terpusat dan timeout 15 detik.
class DioClient {
  DioClient._();

  static Dio createDio(SecureStorageService storage, {VoidCallback? onSessionExpired}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        responseType: ResponseType.json,
      ),
    );

    // 1. Interceptor Header Otomatis (x-maker-key & Authorization)
    dio.interceptors.add(
      ApiHeaderInterceptor(storage, onSessionExpired: onSessionExpired),
    );

    // 2. Logging Interceptor hanya pada mode debug (kReleaseMode guard sesuai PRD §10)
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
        ),
      );
    }

    return dio;
  }
}
