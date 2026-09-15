import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static const _bulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  static const _bulanShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  /// 15 Oktober 2026
  static String formatFullDate(DateTime date) {
    try {
      return DateFormat('d MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return '${date.day} ${_bulan[date.month - 1]} ${date.year}';
    }
  }

  /// 15 Okt 2026
  static String formatShortDate(DateTime date) {
    try {
      return DateFormat('d MMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return '${date.day} ${_bulanShort[date.month - 1]} ${date.year}';
    }
  }

  /// Oktober 2026
  static String formatMonthYear(DateTime date) {
    try {
      return DateFormat('MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return '${_bulan[date.month - 1]} ${date.year}';
    }
  }

  // Format tanggal standar buat dikirim ke parameter API backend (YYYY-MM-DD).
  // padLeft(2, '0') dipake biar kalau angka bulan/hari cuma 1 digit (misal Mei = 5),
  // otomatis jadi '05' sesuai format database MySQL backend.
  static String toApiDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 09:00 - 12:00 WIB
  static String formatTimeRange(String jamMulai, String jamSelesai) =>
      '$jamMulai - $jamSelesai WIB';

  // Ubah tanggal ISO dari server (misal: '2026-10-15T08:00:00.000Z' atau '2026-10-15')
  // jadi format santai Indonesia (contoh: 15 Oktober 2026).
  // Dibedah manual pake split('-') biar cepat dan gak berat parsing DateTime.
  static String formatIndonesian(String isoDate) {
    try {
      final parts = isoDate.split('T').first.split('-');
      if (parts.length < 3) return isoDate;
      return '${int.parse(parts[2])} ${_bulan[int.parse(parts[1]) - 1]} ${parts[0]}';
    } catch (_) {
      return isoDate;
    }
  }

  /// Nama bulan dari angka 1–12
  static String getMonthName(int month) =>
      (month >= 1 && month <= 12) ? _bulan[month - 1] : 'Bulan $month';
}
