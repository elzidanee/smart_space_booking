import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage_service.dart';
import '../../features/auth/presentation/providers/auth_controller.dart';
import 'api_endpoints.dart';
import 'api_header_interceptor.dart';

// Provider penyedia instance Dio untuk dipakai di semua repository / datasource.
// Kalau sesi expired, otomatis manggil forceLogout() di AuthController.
final dioClientProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  return DioClient.create(storage, onSessionExpired: () {
    ref.read(authControllerProvider.notifier).forceLogout();
  });
});

// Pabrik pembuat instance Dio (HTTP Client) terpusat.
// Kenapa dibuat begini? Biar semua settingan penting (timeout, interceptor, logger) seragam
// dan gak perlu kita setup ulang-ulang di setiap repository.
class DioClient {
  DioClient._();

  static Dio create(SecureStorageService storage, {VoidCallback? onSessionExpired}) {
    final dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      // Batas waktu timeout 15 detik: kalau server gak ada respon dalam 15 detik (misal internet down),
      // batalkan request biar HP gak loading berputar-putar tanpa henti.
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      responseType: ResponseType.json,
    ));

    // Pasang interceptor buatan kita (buat nempelin token & handle auto-logout)
    dio.interceptors.add(ApiHeaderInterceptor(storage, onSessionExpired: onSessionExpired));

    // LogInterceptor cuma dinyalakan pas mode ngoding / debug (kDebugMode).
    // Fungsinya buat nampilin isi kiriman & balikan data JSON di console debug.
    // Pas aplikasi di-build jadi APK rilis, logger ini otomatis mati biar gak lemot & aman.
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
