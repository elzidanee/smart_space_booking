/// Konstanta URL & endpoint API. Ganti baseUrl saat ujian dimulai.
class ApiEndpoints {
  ApiEndpoints._();

  static String baseUrl = 'https://learn.smktelkom-mlg.sch.id/coworking';

  // Auth
  static const String registerMember = '/api/auth/register/member';
  static const String registerAdmin  = '/api/auth/register/admin-space';
  static const String login          = '/api/auth/login';
  static const String profile        = '/api/auth/profile';

  // Spaces
  static const String spaceTypes        = '/api/spaces/types';
  static const String spaceAvailability = '/api/spaces/availability';
  static const String spaces            = '/api/spaces';
  static String spaceDetail(int id)     => '/api/spaces/$id';

  // Diskon
  static const String diskonActive      = '/api/diskon/active';
  static const String checkDiskon       = '/api/diskon/check';
  static String diskonDetail(int id)    => '/api/diskon/$id';

  // Reservasi Member
  static const String reservasi            = '/api/reservasi';
  static const String reservasiMy         = '/api/reservasi/my';
  static const String reservasiMyHistory  = '/api/reservasi/my/history';
  static String eTicket(int id)           => '/api/reservasi/$id/e-ticket';
  static String reservasiDetail(int id)   => '/api/reservasi/$id';
  static String cancelReservasi(int id)   => '/api/reservasi/$id/cancel';

  // Admin
  static const String adminProfile        = '/api/admin/profile';
  static const String adminMembers        = '/api/admin/members';
  static String adminMemberDetail(int id) => '/api/admin/members/$id';
  static const String adminSpaces         = '/api/admin/spaces';
  static String adminSpaceDetail(int id)  => '/api/admin/spaces/$id';
  static const String adminDiskon         = '/api/admin/diskon';
  static String adminDiskonDetail(int id) => '/api/admin/diskon/$id';
  static const String adminReservasi      = '/api/admin/reservasi';
  static String adminReservasiDetail(int id)        => '/api/admin/reservasi/$id';
  static String adminUpdateReservasiStatus(int id)  => '/api/admin/reservasi/$id/status';
  static String adminCheckIn(int id)                => '/api/admin/reservasi/$id/check-in';
  static String adminCheckOut(int id)               => '/api/admin/reservasi/$id/check-out';
  static const String adminMonthlyReport  = '/api/admin/reports/monthly';
  static const String adminIncomeReport   = '/api/admin/reports/income';

  // Upload
  static const String uploadImage  = '/api/upload/image';
  static const String uploadSpace  = '/api/upload/spaces';
  static const String uploadMember = '/api/upload/members';

  // Maker
  static const String makerStats   = '/api/maker/stats';
}
