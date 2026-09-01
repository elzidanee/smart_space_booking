import 'package:dio/dio.dart';
import 'failure.dart';

/// Mengubah DioException dan format JSON error backend ke objek Failure terstruktur.
class ExceptionMapper {
  ExceptionMapper._();

  static Failure map(dynamic error) {
    if (error is Failure) {
      return error;
    }

    if (error is DioException) {
      return fromDio(error);
    }

    return UnknownFailure(error?.toString() ?? 'Terjadi kesalahan yang tidak terduga.');
  }

  static Failure fromDio(DioException error) {
    // 1. Tangani Timeout & Koneksi
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return const NetworkFailure();
    }

    // 2. Tangani Respons Server
    final response = error.response;
    if (response != null) {
      final statusCode = response.statusCode ?? 500;
      final message = _extractMessage(response.data) ?? error.message ?? 'Terjadi kesalahan sistem.';

      switch (statusCode) {
        case 400:
          return ValidationFailure(message);
        case 401:
          return SessionExpiredFailure(message);
        case 403:
          return UnauthorizedFailure(message);
        case 404:
          return NotFoundFailure(message);
        case 500:
        case 502:
        case 503:
          return ServerFailure(message);
        default:
          return ValidationFailure(message, statusCode: statusCode);
      }
    }

    // 3. Fallback cancel atau error lain
    if (error.type == DioExceptionType.cancel) {
      return const NetworkFailure('Permintaan dibatalkan.');
    }

    return UnknownFailure(error.message ?? 'Gagal menghubungi server.');
  }

  static String? _extractMessage(dynamic data) {
    if (data == null) return null;

    if (data is Map<String, dynamic>) {
      // Backend format: {status: false, statusCode: ..., message: "...", error: "..."}
      if (data['message'] != null && data['message'].toString().isNotEmpty) {
        return data['message'].toString();
      }
      if (data['error'] != null && data['error'].toString().isNotEmpty) {
        return data['error'].toString();
      }
    } else if (data is String && data.isNotEmpty) {
      return data;
    }

    return null;
  }
}
