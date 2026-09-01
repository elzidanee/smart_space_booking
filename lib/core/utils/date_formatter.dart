import 'package:intl/intl.dart';

/// Formatter tanggal & waktu Indonesia untuk aplikasi Smart Space Booking.
class DateFormatter {
  DateFormatter._();

  static final DateFormat _fullDate = DateFormat('d MMMM yyyy', 'id_ID');
  static final DateFormat _shortDate = DateFormat('d MMM yyyy', 'id_ID');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy', 'id_ID');
  static final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');

  /// Format tanggal lengkap: `15 Oktober 2026`
  static String formatFullDate(DateTime date) => _fullDate.format(date);

  /// Format tanggal pendek: `15 Okt 2026`
  static String formatShortDate(DateTime date) => _shortDate.format(date);

  /// Format bulan dan tahun: `Oktober 2026`
  static String formatMonthYear(DateTime date) => _monthYear.format(date);

  /// Format untuk parameter API: `2026-10-15`
  static String toApiDate(DateTime date) => _apiDateFormat.format(date);

  /// Helper untuk merapikan jam mulai - selesai (misal: "09:00 - 12:00")
  static String formatTimeRange(String jamMulai, String jamSelesai) {
    return '$jamMulai - $jamSelesai WIB';
  }
}
