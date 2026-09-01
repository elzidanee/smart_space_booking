import 'dart:convert';

/// Model Pengguna (Member atau Admin Pengelola) sesuai DTO Kontrak API endpoint.md.
class UserModel {
  final int id;
  final String username;
  final String nama;
  final String? telepon; // API field: telp
  final String? alamat;
  final String? foto;
  final String role; // 'member' | 'admin_space'
  final String? instansi;
  final String? namaSpace; // untuk admin: nama_coworking

  const UserModel({
    required this.id,
    required this.username,
    required this.nama,
    this.telepon,
    this.alamat,
    this.foto,
    required this.role,
    this.instansi,
    this.namaSpace,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // API login/profile mengembalikan nested member: {...} atau space_owner: {...}
    final memberData = json['member'] as Map<String, dynamic>?;
    final ownerData = json['space_owner'] as Map<String, dynamic>?;

    // Nama: coba dari nested data dulu, lalu fallback ke root fields
    final nama = memberData?['nama_member']?.toString() ??
        ownerData?['nama_pemilik']?.toString() ??
        json['nama_member']?.toString() ??
        json['nama_pemilik']?.toString() ??
        json['nama']?.toString() ??
        json['name']?.toString() ?? '';

    // Telepon: API memakai 'telp' bukan 'telepon'
    final telepon = memberData?['telp']?.toString() ??
        ownerData?['telp']?.toString() ??
        json['telp']?.toString() ??
        json['telepon']?.toString() ??
        json['phone']?.toString();

    final alamat = memberData?['alamat']?.toString() ??
        json['alamat']?.toString() ?? json['address']?.toString();

    final foto = memberData?['foto']?.toString() ??
        json['foto']?.toString() ?? json['avatar']?.toString();

    final instansi = memberData?['instansi']?.toString() ??
        json['instansi']?.toString();

    final namaSpace = ownerData?['nama_coworking']?.toString() ??
        json['nama_coworking']?.toString() ??
        json['nama_space']?.toString();

    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      username: json['username']?.toString() ?? '',
      nama: nama,
      telepon: telepon,
      alamat: alamat,
      foto: foto,
      role: json['role']?.toString() ?? 'member',
      instansi: instansi,
      namaSpace: namaSpace,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nama': nama,
      'telp': telepon,
      'alamat': alamat,
      'foto': foto,
      'role': role,
      'instansi': instansi,
      'nama_space': namaSpace,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory UserModel.fromJsonString(String jsonStr) =>
      UserModel.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
}

/// Sesi autentikasi aktif pengguna — dari response POST /api/auth/login
class UserSession {
  final String token;
  final String role;
  final UserModel? user;

  const UserSession({
    required this.token,
    required this.role,
    this.user,
  });

  bool get isMember => role.toLowerCase() == 'member';
  bool get isAdmin => role.toLowerCase() == 'admin_space' || role.toLowerCase() == 'admin';

  /// API /api/auth/login mengembalikan:
  /// { id, username, role, maker_id, member: {...}|null, space_owner: {...}|null, access_token }
  factory UserSession.fromJson(Map<String, dynamic> json) {
    final token = json['access_token']?.toString() ?? json['token']?.toString() ?? '';
    final role = json['role']?.toString() ?? 'member';
    // Bangun UserModel dari root + nested member/space_owner
    final user = UserModel.fromJson(json);
    return UserSession(
      token: token,
      role: role,
      user: user,
    );
  }
}

/// Request model pendaftaran member (FR-02)
/// POST /api/auth/register/member
/// Body: { username, password, nama_member, instansi, alamat, telp, foto? }
class RegisterMemberRequest {
  final String namaMember; // API field: nama_member
  final String? instansi;
  final String telp;       // API field: telp (bukan telepon)
  final String alamat;
  final String username;
  final String password;
  final String? foto; // nama file dari /api/upload/members

  const RegisterMemberRequest({
    required this.namaMember,
    this.instansi,
    required this.telp,
    required this.alamat,
    required this.username,
    required this.password,
    this.foto,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'nama_member': namaMember, // sesuai kontrak API
      'telp': telp,              // sesuai kontrak API
      'alamat': alamat,
      'username': username,
      'password': password,
    };
    if (instansi != null && instansi!.trim().isNotEmpty) {
      map['instansi'] = instansi!.trim();
    }
    if (foto != null && foto!.isNotEmpty) {
      map['foto'] = foto;
    }
    return map;
  }
}

/// Request model pendaftaran admin space (FR-03)
/// POST /api/auth/register/admin-space
/// Body: { username, password, nama_coworking, nama_pemilik, telp }
class RegisterAdminRequest {
  final String namaCoworking; // API field: nama_coworking
  final String namaPemilik;   // API field: nama_pemilik
  final String telp;          // API field: telp (bukan telepon)
  final String username;
  final String password;

  const RegisterAdminRequest({
    required this.namaCoworking,
    required this.namaPemilik,
    required this.telp,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'nama_coworking': namaCoworking, // sesuai kontrak API
      'nama_pemilik': namaPemilik,     // sesuai kontrak API
      'telp': telp,                    // sesuai kontrak API
      'username': username,
      'password': password,
    };
  }
}
