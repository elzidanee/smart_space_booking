/// Representasi error terstruktur sesuai PRD Bagian II §8.
sealed class Failure {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Error validasi atau logika bisnis (HTTP 400), mis. jadwal bentrok, kode promo tidak valid
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.statusCode = 400});
}

/// Sesi berakhir atau token tidak valid (HTTP 401)
class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure([super.message = 'Sesi berakhir, silakan login kembali.'])
      : super(statusCode: 401);
}

/// Data tidak ditemukan (HTTP 404)
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.statusCode = 404});
}

/// Masalah koneksi internet atau timeout (HTTP client error)
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Koneksi terputus atau timeout. Periksa internet Anda lalu coba lagi.']);
}

/// Kesalahan internal server panitia (HTTP 500)
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server sedang mengalami gangguan. Silakan coba lagi nanti.'])
      : super(statusCode: 500);
}

/// Error otorisasi atau hak akses ditolak (HTTP 403)
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message, {super.statusCode = 403});
}

/// Kesalahan tak terduga lainnya
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Terjadi kesalahan yang tidak terduga.', int? statusCode])
      : super(statusCode: statusCode);
}
