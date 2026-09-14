import 'dart:convert';
import '../../../../core/utils/app_url_helper.dart';

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
    final m = json['member'] as Map<String, dynamic>?;
    final o = json['space_owner'] as Map<String, dynamic>?;

    final nama = m?['nama_member']?.toString() ??
        o?['nama_pemilik']?.toString() ??
        json['nama_member']?.toString() ??
        json['nama_pemilik']?.toString() ??
        json['nama']?.toString() ??
        json['name']?.toString() ?? '';

    final telepon = m?['telp']?.toString() ??
        o?['telp']?.toString() ??
        json['telp']?.toString() ??
        json['telepon']?.toString();

    final alamat = m?['alamat']?.toString() ?? json['alamat']?.toString();

    final rawFoto = m?['foto_url']?.toString() ??
        m?['foto']?.toString() ??
        json['foto_url']?.toString() ??
        json['foto']?.toString();
    final foto = AppUrlHelper.resolveImageUrl(rawFoto, defaultFolder: 'members');

    final instansi = m?['instansi']?.toString() ?? json['instansi']?.toString();
    final namaSpace = o?['nama_coworking']?.toString() ?? json['nama_coworking']?.toString();

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

  Map<String, dynamic> toJson() => {
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

  String toJsonString() => jsonEncode(toJson());

  factory UserModel.fromJsonString(String s) =>
      UserModel.fromJson(jsonDecode(s) as Map<String, dynamic>);
}

class UserSession {
  final String token;
  final String role;
  final UserModel? user;

  const UserSession({required this.token, required this.role, this.user});

  bool get isMember => role.toLowerCase() == 'member';
  bool get isAdmin  => role.toLowerCase() == 'admin_space' || role.toLowerCase() == 'admin';

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      token: json['access_token']?.toString() ?? json['token']?.toString() ?? '',
      role: json['role']?.toString() ?? 'member',
      user: UserModel.fromJson(json),
    );
  }
}

// POST /api/auth/register/member
class RegisterMemberRequest {
  final String namaMember;
  final String? instansi;
  final String telp;
  final String alamat;
  final String username;
  final String password;
  final String? foto;

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
      'nama_member': namaMember,
      'telp': telp,
      'alamat': alamat,
      'username': username,
      'password': password,
    };
    if (instansi != null && instansi!.trim().isNotEmpty) map['instansi'] = instansi!.trim();
    if (foto != null && foto!.isNotEmpty) map['foto'] = foto;
    return map;
  }
}

// POST /api/auth/register/admin-space
class RegisterAdminRequest {
  final String namaCoworking;
  final String namaPemilik;
  final String telp;
  final String username;
  final String password;

  const RegisterAdminRequest({
    required this.namaCoworking,
    required this.namaPemilik,
    required this.telp,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'nama_coworking': namaCoworking,
    'nama_pemilik': namaPemilik,
    'telp': telp,
    'username': username,
    'password': password,
  };
}
