import 'package:dio/dio.dart';
import 'failure.dart';

// Class ini bertugas nerjemahin error teknis (DioException, HTTP status code, timeout)
// jadi pesan Failure yang ramah dalam bahasa Indonesia, biar pas dimunculin di Snackbar/Alert
// user atau penguji langsung paham apa masalahnya (bukan pesan error kodingan yang bikin bingung).
class ExceptionMapper {
  ExceptionMapper._();

  static Failure map(dynamic error) {
    if (error is Failure) return error;
    if (error is DioException) return _fromDio(error);
    return UnknownFailure(error?.toString() ?? 'Terjadi kesalahan yang tidak terduga.');
  }

  static Failure _fromDio(DioException error) {
    // 1. Masalah jaringan / koneksi internet (HP offline, server mati, atau timeout 15 detik habis)
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return const NetworkFailure();
    }

    // 2. Request sengaja dibatalkan oleh aplikasi
    if (error.type == DioExceptionType.cancel) {
      return const NetworkFailure('Permintaan dibatalkan.');
    }

    // 3. Ada respon dari server, tinggal kita bedah kode HTTP status-nya:
    final response = error.response;
    if (response != null) {
      final code = response.statusCode ?? 500;
      final msg = _extractMessage(response.data) ?? error.message ?? 'Terjadi kesalahan sistem.';

      return switch (code) {
        // 400: User salah isi data form (misal password kurang panjang / format salah)
        400 => ValidationFailure(msg),
        // 401: Token JWT kadaluarsa atau belum login
        401 => SessionExpiredFailure(msg),
        // 403: Dilarang (misal akun member nyoba buka menu admin)
        403 => UnauthorizedFailure(msg),
        // 404: Data yang dicari (ruangan, user, reservasi) gak ada di database backend
        404 => NotFoundFailure(msg),
        // 500 / 502 / 503: Backend crash atau database server lagi bermasalah
        500 || 502 || 503 => ServerFailure(msg),
        _ => ValidationFailure(msg, statusCode: code),
      };
    }

    return UnknownFailure(error.message ?? 'Gagal menghubungi server.');
  }

  // Helper buat ngambil teks pesan error dari JSON balikan backend:
  // Kadang backend ngasih format {"message": "..."} atau {"error": "..."}.
  // Fungsi ini otomatis ngecek kedua kemungkinan itu.
  static String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final msg = data['message']?.toString();
      if (msg != null && msg.isNotEmpty) return msg;
      final err = data['error']?.toString();
      if (err != null && err.isNotEmpty) return err;
    } else if (data is String && data.isNotEmpty) {
      return data;
    }
    return null;
  }
}
