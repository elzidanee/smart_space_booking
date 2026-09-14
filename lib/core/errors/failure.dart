sealed class Failure {
  final String message;
  final int? statusCode;
  const Failure(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.statusCode = 400});
}

class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure([super.message = 'Sesi berakhir, silakan login kembali.'])
      : super(statusCode: 401);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.statusCode = 404});
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Koneksi terputus atau timeout. Periksa internet Anda.']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server sedang bermasalah. Coba lagi nanti.'])
      : super(statusCode: 500);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message, {super.statusCode = 403});
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Terjadi kesalahan yang tidak terduga.', int? statusCode])
      : super(statusCode: statusCode);
}
