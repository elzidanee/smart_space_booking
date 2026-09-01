import 'package:intl/intl.dart';

/// Formatter mata uang Rupiah konsisten untuk seluruh aplikasi.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Format angka ke Rupiah: contoh `50000` -> `Rp 50.000`
  static String format(num amount) {
    return _formatter.format(amount);
  }

  /// Format harga per jam: contoh `50000` -> `Rp 50.000/jam`
  static String formatPerHour(num amount) {
    return '${_formatter.format(amount)}/jam';
  }
}
