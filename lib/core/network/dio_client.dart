import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage_service.dart';
import '../../features/auth/presentation/providers/auth_controller.dart';
import 'api_endpoints.dart';
import 'api_header_interceptor.dart';

final dioClientProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  return DioClient.create(storage, onSessionExpired: () {
    ref.read(authControllerProvider.notifier).forceLogout();
  });
});

class DioClient {
  DioClient._();

  static Dio create(SecureStorageService storage, {VoidCallback? onSessionExpired}) {
    final dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      responseType: ResponseType.json,
    ));

    dio.interceptors.add(ApiHeaderInterceptor(storage, onSessionExpired: onSessionExpired));

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ));
    }

    return dio;
  }
}
