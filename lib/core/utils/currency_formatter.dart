import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  /// Format angka ke Rupiah. Contoh: 50000 → Rp 50.000
  static String format(num amount) {
    try {
      return _fmt.format(amount);
    } catch (_) {
      // Algoritma manual pembagi ribuan (fallback kalau package intl/locale id_ID bermasalah di HP lama):
      final isNeg = amount < 0;
      final s = amount.abs().truncate().toString(); // Buang koma dan ambil nilai positifnya
      final buf = StringBuffer();
      
      // Loop tiap karakter angka dari depan ke belakang:
      for (int i = 0; i < s.length; i++) {
        final rev = s.length - i; // Sisa digit yang ada di sebelah kanan
        buf.write(s[i]);
        // Rumus matematika: Kalau sisa digit adalah kelipatan 3 (ribuan/jutaan), selipkan titik (.)
        if (rev > 1 && rev % 3 == 1) buf.write('.');
      }
      // Gabungkan tanda minus (kalau ada) dan simbol Rp
      return '${isNeg ? '-Rp ' : 'Rp '}$buf';
    }
  }

  /// Format harga per jam. Contoh: 50000 → Rp 50.000/jam
  static String formatPerHour(num amount) => '${format(amount)}/jam';

  /// Alias format rupiah
  static String formatRupiah(num amount) => format(amount);
}
