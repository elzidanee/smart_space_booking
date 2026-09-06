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
    try {
      return _formatter.format(amount);
    } catch (_) {
      // Fallback manual jika locale id_ID belum ter-load (tanpa throw ke UI)
      final isNegative = amount < 0;
      final absStr = amount.abs().truncate().toString();
      final buf = StringBuffer();
      for (int i = 0; i < absStr.length; i++) {
        final rev = absStr.length - i;
        buf.write(absStr[i]);
        if (rev > 1 && rev % 3 == 1) buf.write('.');
      }
      return '${isNegative ? '-Rp ' : 'Rp '}$buf';
    }
  }

  /// Alias format untuk Rupiah
  static String formatRupiah(num amount) => format(amount);

  /// Format harga per jam: contoh `50000` -> `Rp 50.000/jam`
  static String formatPerHour(num amount) {
    return '${format(amount)}/jam';
  }
}
