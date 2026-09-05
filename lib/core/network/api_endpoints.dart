/// Konstanta URL & Endpoint API Panitia sesuai endpoint.md (50 endpoint).
/// Base URL dapat diubah saat panitia memberikan URL resmi ujian.
class ApiEndpoints {
  ApiEndpoints._();

  /// Base URL API. Ganti dengan URL panitia saat ujian dimulai.
  static String baseUrl = 'https://bias-cakes-progressive-battery.trycloudflare.com';

  // ─────────────────────────────────────────────────
  // 1. Root & Health Check  (#1, #2)
  // ─────────────────────────────────────────────────
  static const String root = '/';
  static const String health = '/health';

  // ─────────────────────────────────────────────────
  // 2. App Maker  (#3-#7)
  // ─────────────────────────────────────────────────
  static const String makerRegister = '/api/maker/register'; // POST
  static const String makerLogin = '/api/maker/login';       // POST
  static const String makerMe = '/api/maker/me';             // GET Bearer Maker
  static const String makerStats = '/api/maker/stats';       // GET
  static const String makerList = '/api/maker/list';         // GET publik

  // ─────────────────────────────────────────────────
  // 3. Autentikasi User  (#8-#11)
  // ─────────────────────────────────────────────────
  static const String registerMember = '/api/auth/register/member';       // POST
  static const String registerAdmin = '/api/auth/register/admin-space';   // POST
  static const String login = '/api/auth/login';                          // POST
  static const String profile = '/api/auth/profile';                      // GET Bearer

  // ─────────────────────────────────────────────────
  // 4. Space Coworking  (#12-#15)
  // ─────────────────────────────────────────────────
  static const String spaceTypes = '/api/spaces/types';          // GET
  static const String spaceAvailability = '/api/spaces/availability'; // GET ?id_space,tanggal,jam_mulai,durasi_jam
  static const String spaces = '/api/spaces';                     // GET ?tipe,search
  static String spaceDetail(int id) => '/api/spaces/$id';         // GET

  // ─────────────────────────────────────────────────
  // 5. Diskon & Promo  (#16-#18)
  // ─────────────────────────────────────────────────
  static const String diskonActive = '/api/diskon/active';        // GET
  static const String checkDiskon = '/api/diskon/check';          // POST { nama_diskon }
  static String diskonDetail(int id) => '/api/diskon/$id';        // GET

  // ─────────────────────────────────────────────────
  // 6. Reservasi Member  (#19-#24)
  // ─────────────────────────────────────────────────
  static const String reservasi = '/api/reservasi';               // POST Bearer Member
  static const String reservasiMy = '/api/reservasi/my';          // GET Bearer Member
  static const String reservasiMyHistory = '/api/reservasi/my/history'; // GET ?month,year
  static String eTicket(int id) => '/api/reservasi/$id/e-ticket'; // GET Bearer
  static String reservasiDetail(int id) => '/api/reservasi/$id';  // GET Bearer
  static String cancelReservasi(int id) => '/api/reservasi/$id/cancel'; // PATCH Bearer Member

  // ─────────────────────────────────────────────────
  // 7. Profil Lokasi Admin  (#25-#26)
  // ─────────────────────────────────────────────────
  static const String adminProfile = '/api/admin/profile';        // GET/PUT Bearer Admin

  // ─────────────────────────────────────────────────
  // 8. Manajemen Member Admin  (#27-#31)
  // ─────────────────────────────────────────────────
  static const String adminMembers = '/api/admin/members';                // GET/POST
  static String adminMemberDetail(int id) => '/api/admin/members/$id';   // GET/PUT/DELETE

  // ─────────────────────────────────────────────────
  // 9. Manajemen Space Admin  (#32-#36)
  // ─────────────────────────────────────────────────
  static const String adminSpaces = '/api/admin/spaces';                  // GET/POST
  static String adminSpaceDetail(int id) => '/api/admin/spaces/$id';     // GET/PUT/DELETE

  // ─────────────────────────────────────────────────
  // 10. Manajemen Diskon Admin  (#37-#41)
  // ─────────────────────────────────────────────────
  static const String adminDiskon = '/api/admin/diskon';                  // GET/POST
  static String adminDiskonDetail(int id) => '/api/admin/diskon/$id';    // GET/PUT/DELETE

  // ─────────────────────────────────────────────────
  // 11. Reservasi & Check-in/out Admin  (#42-#45)
  // ─────────────────────────────────────────────────
  static const String adminReservasi = '/api/admin/reservasi';            // GET ?month,year,status,id_space,tanggal
  static String adminReservasiDetail(int id) => '/api/admin/reservasi/$id'; // GET
  static String adminUpdateReservasiStatus(int id) => '/api/admin/reservasi/$id/status'; // PATCH { status }
  static String adminCheckIn(int id) => '/api/admin/reservasi/$id/check-in';   // POST
  static String adminCheckOut(int id) => '/api/admin/reservasi/$id/check-out'; // POST

  // ─────────────────────────────────────────────────
  // 12. Laporan Pendapatan Admin  (#46-#47)
  // ─────────────────────────────────────────────────
  static const String adminMonthlyReport = '/api/admin/reports/monthly'; // GET ?month,year
  static const String adminIncomeReport = '/api/admin/reports/income';   // GET ?month,year (alias ringkas)

  // ─────────────────────────────────────────────────
  // 13. Upload Media  (#48-#50)
  // ─────────────────────────────────────────────────
  static const String uploadImage = '/api/upload/image';   // POST multipart
  static const String uploadSpace = '/api/upload/spaces';  // POST multipart Bearer Admin
  static const String uploadMember = '/api/upload/members'; // POST multipart
}

