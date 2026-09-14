import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  /// Format angka ke Rupiah. Contoh: 50000 → Rp 50.000
  static String format(num amount) {
    try {
      return _fmt.format(amount);
    } catch (_) {
      // Fallback manual jika locale belum ter-load
      final isNeg = amount < 0;
      final s = amount.abs().truncate().toString();
      final buf = StringBuffer();
      for (int i = 0; i < s.length; i++) {
        final rev = s.length - i;
        buf.write(s[i]);
        if (rev > 1 && rev % 3 == 1) buf.write('.');
      }
      return '${isNeg ? '-Rp ' : 'Rp '}$buf';
    }
  }

  /// Format harga per jam. Contoh: 50000 → Rp 50.000/jam
  static String formatPerHour(num amount) => '${format(amount)}/jam';

  /// Alias format rupiah
  static String formatRupiah(num amount) => format(amount);
}
