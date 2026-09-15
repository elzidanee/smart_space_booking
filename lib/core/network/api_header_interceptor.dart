import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/secure_storage_service.dart';

// Interceptor ini ibarat 'pos satpam' otomatis untuk semua request keluar dan respon masuk di Dio:
// 1. Setiap mau request ke server (onRequest): otomatis pasang header token, key, dan cek alamat IP server.
// 2. Setiap ada respon error dari server (onError): kalau sesi habis (401), langsung auto-logout.
class ApiHeaderInterceptor extends Interceptor {
  final SecureStorageService storage;
  final VoidCallback? onSessionExpired;

  ApiHeaderInterceptor(this.storage, {this.onSessionExpired});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 1. Cek apakah penguji / user pernah ganti IP server (misal pas demo pake laptop lokal 192.168.x.x)
    // Kalau ada settingan custom tersimpan di HP, pakai yang itu.
    final customBase = await storage.readBaseUrl();
    if (customBase != null && customBase.trim().isNotEmpty) {
      options.baseUrl = customBase.trim();
    }

    // 2. Normalisasi garis miring (slash) biar URL gak cacat / error 404:
    // Pastikan base URL selalu diakhiri slash '/' dan path endpoint gak diawali slash.
    // Jadi gak bakal kejadian dobel slash kayak: 'https://domain.com//api/login'.
    if (options.baseUrl.isNotEmpty) {
      if (!options.baseUrl.endsWith('/')) options.baseUrl = '${options.baseUrl}/';
      if (options.path.startsWith('/')) options.path = options.path.substring(1);
    }

    // 3. Sisipkan x-maker-key sebagai identitas pembuat aplikasi (wajib untuk backend UKK)
    final appKey = await storage.readAppKey();
    if (appKey != null && appKey.isNotEmpty) {
      options.headers['x-maker-key'] = appKey;
    }

    // 4. Kalau user sudah login dan punya token JWT, otomatis tempel Bearer token di header.
    // Jadi di controller kita gak perlu repot ngetik header Authorization satu per satu.
    final token = await storage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    options.headers['Accept'] = 'application/json';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Kalau backend ngebalikin kode 401 (Unauthorized / token kadaluarsa / akun dihapus):
    // Langsung bersihin sisa sesi di secure storage & suruh aplikasi balik ke layar login.
    if (err.response?.statusCode == 401) {
      await storage.clearSession();
      onSessionExpired?.call();
    }
    handler.next(err);
  }
}
