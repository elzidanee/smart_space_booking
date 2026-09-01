import 'dart:convert';

/// Model Pengguna (Member atau Admin Pengelola) sesuai DTO Kontrak Soal.
class UserModel {
  final int id;
  final String username;
  final String nama;
  final String? telepon;
  final String? alamat;
  final String? foto;
  final String role; // 'member' | 'admin_space'
  final String? instansi;
  final String? namaSpace;

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
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      username: json['username']?.toString() ?? '',
      nama: json['nama']?.toString() ?? json['nama_pemilik']?.toString() ?? json['name']?.toString() ?? '',
      telepon: json['telepon']?.toString() ?? json['phone']?.toString(),
      alamat: json['alamat']?.toString() ?? json['address']?.toString(),
      foto: json['foto']?.toString() ?? json['avatar']?.toString(),
      role: json['role']?.toString() ?? 'member',
      instansi: json['instansi']?.toString(),
      namaSpace: json['nama_space']?.toString() ?? json['nama_coworking']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nama': nama,
      'telepon': telepon,
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

/// Sesi autentikasi aktif pengguna
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

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      token: json['token']?.toString() ?? json['access_token']?.toString() ?? '',
      role: json['role']?.toString() ?? 'member',
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Request model pendaftaran member (FR-02)
class RegisterMemberRequest {
  final String nama;
  final String? instansi;
  final String telepon;
  final String alamat;
  final String username;
  final String password;
  final String? foto; // nama file dari /api/upload/members

  const RegisterMemberRequest({
    required this.nama,
    this.instansi,
    required this.telepon,
    required this.alamat,
    required this.username,
    required this.password,
    this.foto,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'nama': nama,
      'telepon': telepon,
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
class RegisterAdminRequest {
  final String namaSpace;
  final String namaPemilik;
  final String telepon;
  final String alamat;
  final String username;
  final String password;

  const RegisterAdminRequest({
    required this.namaSpace,
    required this.namaPemilik,
    required this.telepon,
    required this.alamat,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'nama_space': namaSpace,
      'nama_pemilik': namaPemilik,
      'telepon': telepon,
      'alamat': alamat,
      'username': username,
      'password': password,
    };
  }
}
