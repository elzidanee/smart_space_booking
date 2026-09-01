/// Konstanta URL & Endpoint API Panitia sesuai PRD dan Kontrak Soal.
class ApiEndpoints {
  ApiEndpoints._();

  /// Base URL API.
  /// Default menggunakan IP gateway emulator Android (10.0.2.2:8000) atau localhost jika diuji di web/desktop.
  /// Dapat diubah saat pengujian atau ketika panitia memberikan URL resmi.
  static String baseUrl = 'https://learn.smktelkom-mlg.sch.id/coworking';

  // --- 1. App Maker ---
  static const String makerRegister = '/api/maker/register';
  static const String makerMe = '/api/maker/me';

  // --- 2. Auth ---
  static const String registerMember = '/api/auth/register/member';
  static const String registerAdmin = '/api/auth/register/admin-space';
  static const String login = '/api/auth/login';
  static const String profile = '/api/auth/profile';

  // --- 3. Upload ---
  static const String uploadMember = '/api/upload/members';
  static const String uploadSpace = '/api/upload/spaces';

  // --- 4. Space & Katalog (Member) ---
  static const String spaceTypes = '/api/spaces/types';
  static const String spaces = '/api/spaces';
  static String spaceDetail(int id) => '/api/spaces/$id';
  static const String spaceAvailability = '/api/spaces/availability';

  // --- 5. Diskon & Promo ---
  static const String checkDiskon = '/api/diskon/check';

  // --- 6. Reservasi (Member) ---
  static const String reservasi = '/api/reservasi';
  static const String reservasiMy = '/api/reservasi/my';
  static const String reservasiMyHistory = '/api/reservasi/my/history';
  static String reservasiDetail(int id) => '/api/reservasi/$id';
  static String cancelReservasi(int id) => '/api/reservasi/$id/cancel';
  static String eTicket(int id) => '/api/reservasi/$id/e-ticket';

  // --- 7. Admin Modul ---
  static const String adminProfile = '/api/admin/profile';
  static const String adminMembers = '/api/admin/members';
  static String adminMemberDetail(int id) => '/api/admin/members/$id';

  static const String adminSpaces = '/api/admin/spaces';
  static String adminSpaceDetail(int id) => '/api/admin/spaces/$id';

  static const String adminDiskon = '/api/admin/diskon';
  static String adminDiskonDetail(int id) => '/api/admin/diskon/$id';

  static const String adminReservasi = '/api/admin/reservasi';
  static String adminUpdateReservasiStatus(int id) => '/api/admin/reservasi/$id/status';
  static String adminCheckIn(int id) => '/api/admin/reservasi/$id/check-in';
  static String adminCheckOut(int id) => '/api/admin/reservasi/$id/check-out';
  static const String adminMonthlyReport = '/api/admin/reports/monthly';
}
