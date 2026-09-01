import 'package:intl/intl.dart';

/// Formatter tanggal & waktu Indonesia untuk aplikasi Smart Space Booking.
class DateFormatter {
  DateFormatter._();

  static const List<String> _bulanIndo = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  static const List<String> _bulanIndoShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  /// Format tanggal lengkap: `15 Oktober 2026`
  static String formatFullDate(DateTime date) {
    try {
      return DateFormat('d MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return '${date.day} ${_bulanIndo[date.month - 1]} ${date.year}';
    }
  }

  /// Format tanggal pendek: `15 Okt 2026`
  static String formatShortDate(DateTime date) {
    try {
      return DateFormat('d MMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return '${date.day} ${_bulanIndoShort[date.month - 1]} ${date.year}';
    }
  }

  /// Format bulan dan tahun: `Oktober 2026`
  static String formatMonthYear(DateTime date) {
    try {
      return DateFormat('MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return '${_bulanIndo[date.month - 1]} ${date.year}';
    }
  }

  /// Format untuk parameter API: `2026-10-15`
  static String toApiDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Helper untuk merapikan jam mulai - selesai (misal: "09:00 - 12:00")
  static String formatTimeRange(String jamMulai, String jamSelesai) {
    return '$jamMulai - $jamSelesai WIB';
  }
}
