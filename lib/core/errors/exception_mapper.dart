import 'package:dio/dio.dart';
import 'failure.dart';

class ExceptionMapper {
  ExceptionMapper._();

  static Failure map(dynamic error) {
    if (error is Failure) return error;
    if (error is DioException) return _fromDio(error);
    return UnknownFailure(error?.toString() ?? 'Terjadi kesalahan yang tidak terduga.');
  }

  static Failure _fromDio(DioException error) {
    // Timeout & koneksi
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return const NetworkFailure();
    }

    // Request dibatalkan
    if (error.type == DioExceptionType.cancel) {
      return const NetworkFailure('Permintaan dibatalkan.');
    }

    // Respons dari server
    final response = error.response;
    if (response != null) {
      final code = response.statusCode ?? 500;
      final msg = _extractMessage(response.data) ?? error.message ?? 'Terjadi kesalahan sistem.';

      return switch (code) {
        400 => ValidationFailure(msg),
        401 => SessionExpiredFailure(msg),
        403 => UnauthorizedFailure(msg),
        404 => NotFoundFailure(msg),
        500 || 502 || 503 => ServerFailure(msg),
        _ => ValidationFailure(msg, statusCode: code),
      };
    }

    return UnknownFailure(error.message ?? 'Gagal menghubungi server.');
  }

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
