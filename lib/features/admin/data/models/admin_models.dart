import 'package:flutter/foundation.dart';

/// Model Profil Lokasi Coworking (Admin Profile) sesuai GET/PUT /api/admin/profile
@immutable
class AdminProfileModel {
  final int id;
  final String namaSpace;
  final String namaPemilik;
  final String telepon;
  final String alamat;
  final String deskripsiFasilitas;
  final String? foto;

  const AdminProfileModel({
    required this.id,
    required this.namaSpace,
    required this.namaPemilik,
    required this.telepon,
    required this.alamat,
    required this.deskripsiFasilitas,
    this.foto,
  });

  factory AdminProfileModel.fromJson(Map<String, dynamic> json) {
    return AdminProfileModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '1') ?? 1,
      namaSpace: json['nama_space'] ?? json['nama_coworking'] ?? 'Smart Space Hub',
      namaPemilik: json['nama_pemilik'] ?? json['pemilik'] ?? 'Admin Pengelola',
      telepon: json['telepon'] ?? json['no_telp'] ?? '',
      alamat: json['alamat'] ?? '',
      deskripsiFasilitas: json['deskripsi_fasilitas'] ?? json['deskripsi'] ?? '',
      foto: json['foto'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_space': namaSpace,
      'nama_pemilik': namaPemilik,
      'telepon': telepon,
      'alamat': alamat,
      'deskripsi_fasilitas': deskripsiFasilitas,
      if (foto != null) 'foto': foto,
    };
  }

  AdminProfileModel copyWith({
    int? id,
    String? namaSpace,
    String? namaPemilik,
    String? telepon,
    String? alamat,
    String? deskripsiFasilitas,
    String? foto,
  }) {
    return AdminProfileModel(
      id: id ?? this.id,
      namaSpace: namaSpace ?? this.namaSpace,
      namaPemilik: namaPemilik ?? this.namaPemilik,
      telepon: telepon ?? this.telepon,
      alamat: alamat ?? this.alamat,
      deskripsiFasilitas: deskripsiFasilitas ?? this.deskripsiFasilitas,
      foto: foto ?? this.foto,
    );
  }
}

/// Model Master Data Member sesuai CRUD /api/admin/members
@immutable
class AdminMemberModel {
  final int id;
  final String nama;
  final String instansi;
  final String telepon;
  final String alamat;
  final String username;
  final String? foto;
  final int totalReservasi;
  final String createdAt;

  const AdminMemberModel({
    required this.id,
    required this.nama,
    required this.instansi,
    required this.telepon,
    required this.alamat,
    required this.username,
    this.foto,
    this.totalReservasi = 0,
    required this.createdAt,
  });

  factory AdminMemberModel.fromJson(Map<String, dynamic> json) {
    return AdminMemberModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nama: json['nama'] ?? json['nama_lengkap'] ?? '',
      instansi: json['instansi'] ?? '-',
      telepon: json['telepon'] ?? json['no_telp'] ?? '',
      alamat: json['alamat'] ?? '',
      username: json['username'] ?? '',
      foto: json['foto'],
      totalReservasi: json['total_reservasi'] is int
          ? json['total_reservasi']
          : int.tryParse(json['total_reservasi']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'instansi': instansi,
      'telepon': telepon,
      'alamat': alamat,
      'username': username,
      if (foto != null) 'foto': foto,
    };
  }

  AdminMemberModel copyWith({
    int? id,
    String? nama,
    String? instansi,
    String? telepon,
    String? alamat,
    String? username,
    String? foto,
    int? totalReservasi,
    String? createdAt,
  }) {
    return AdminMemberModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      instansi: instansi ?? this.instansi,
      telepon: telepon ?? this.telepon,
      alamat: alamat ?? this.alamat,
      username: username ?? this.username,
      foto: foto ?? this.foto,
      totalReservasi: totalReservasi ?? this.totalReservasi,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Model Master Data Promo / Diskon sesuai CRUD /api/admin/diskon
@immutable
class AdminDiscountModel {
  final int id;
  final String kode;
  final int persentase;
  final String tanggalMulai;
  final String tanggalAkhir;
  final String status; // 'aktif' | 'kedaluwarsa'

  const AdminDiscountModel({
    required this.id,
    required this.kode,
    required this.persentase,
    required this.tanggalMulai,
    required this.tanggalAkhir,
    required this.status,
  });

  bool get isExpired {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final end = DateTime.parse(tanggalAkhir);
      return today.isAfter(end);
    } catch (_) {
      return status == 'kedaluwarsa';
    }
  }

  factory AdminDiscountModel.fromJson(Map<String, dynamic> json) {
    final tglAkhir = json['tanggal_akhir'] ?? json['tgl_akhir'] ?? '2026-12-31';
    final tglMulai = json['tanggal_mulai'] ?? json['tgl_mulai'] ?? '2026-01-01';

    String computedStatus = json['status'] ?? 'aktif';
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final end = DateTime.parse(tglAkhir);
      if (today.isAfter(end)) {
        computedStatus = 'kedaluwarsa';
      }
    } catch (_) {}

    return AdminDiscountModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      kode: (json['kode'] ?? json['kode_diskon'] ?? '').toString().toUpperCase(),
      persentase: json['persentase'] is int
          ? json['persentase']
          : int.tryParse(json['persentase']?.toString() ?? '0') ?? 0,
      tanggalMulai: tglMulai,
      tanggalAkhir: tglAkhir,
      status: computedStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode': kode,
      'persentase': persentase,
      'tanggal_mulai': tanggalMulai,
      'tanggal_akhir': tanggalAkhir,
      'status': status,
    };
  }

  AdminDiscountModel copyWith({
    int? id,
    String? kode,
    int? persentase,
    String? tanggalMulai,
    String? tanggalAkhir,
    String? status,
  }) {
    return AdminDiscountModel(
      id: id ?? this.id,
      kode: kode ?? this.kode,
      persentase: persentase ?? this.persentase,
      tanggalMulai: tanggalMulai ?? this.tanggalMulai,
      tanggalAkhir: tanggalAkhir ?? this.tanggalAkhir,
      status: status ?? this.status,
    );
  }
}

/// Distribusi tipe space untuk rekapitulasi finansial bulanan
@immutable
class SpaceTypeDistribution {
  final String tipe;
  final String namaTipe;
  final int totalBooking;
  final int totalJam;
  final int totalPendapatan;
  final double persentase;

  const SpaceTypeDistribution({
    required this.tipe,
    required this.namaTipe,
    required this.totalBooking,
    required this.totalJam,
    required this.totalPendapatan,
    required this.persentase,
  });

  factory SpaceTypeDistribution.fromJson(Map<String, dynamic> json) {
    return SpaceTypeDistribution(
      tipe: json['tipe'] ?? 'personal_desk',
      namaTipe: json['nama_tipe'] ?? 'Personal Desk',
      totalBooking: json['total_booking'] is int
          ? json['total_booking']
          : int.tryParse(json['total_booking']?.toString() ?? '0') ?? 0,
      totalJam: json['total_jam'] is int
          ? json['total_jam']
          : int.tryParse(json['total_jam']?.toString() ?? '0') ?? 0,
      totalPendapatan: json['total_pendapatan'] is int
          ? json['total_pendapatan']
          : int.tryParse(json['total_pendapatan']?.toString() ?? '0') ?? 0,
      persentase: json['persentase'] is num
          ? (json['persentase'] as num).toDouble()
          : double.tryParse(json['persentase']?.toString() ?? '0.0') ?? 0.0,
    );
  }
}

/// Model Rekapitulasi Pendapatan Bulanan sesuai GET /api/admin/reports/monthly
@immutable
class AdminMonthlyReportModel {
  final int bulan;
  final int tahun;
  final int pendapatanKotor;
  final int potonganDiskon;
  final int pendapatanBersih;
  final int totalTransaksi;
  final int totalJamTerpakai;
  final List<SpaceTypeDistribution> perTipeSpace;

  const AdminMonthlyReportModel({
    required this.bulan,
    required this.tahun,
    required this.pendapatanKotor,
    required this.potonganDiskon,
    required this.pendapatanBersih,
    required this.totalTransaksi,
    required this.totalJamTerpakai,
    required this.perTipeSpace,
  });

  factory AdminMonthlyReportModel.fromJson(Map<String, dynamic> json) {
    final listDistribusi = json['per_tipe_space'] ?? json['distribusi_space'] ?? [];
    final items = (listDistribusi as List)
        .map((e) => SpaceTypeDistribution.fromJson(e as Map<String, dynamic>))
        .toList();

    return AdminMonthlyReportModel(
      bulan: json['bulan'] is int ? json['bulan'] : int.tryParse(json['bulan']?.toString() ?? '8') ?? 8,
      tahun: json['tahun'] is int ? json['tahun'] : int.tryParse(json['tahun']?.toString() ?? '2026') ?? 2026,
      pendapatanKotor: json['pendapatan_kotor'] is int
          ? json['pendapatan_kotor']
          : int.tryParse(json['pendapatan_kotor']?.toString() ?? '0') ?? 0,
      potonganDiskon: json['potongan_diskon'] is int
          ? json['potongan_diskon']
          : int.tryParse(json['potongan_diskon']?.toString() ?? '0') ?? 0,
      pendapatanBersih: json['pendapatan_bersih'] is int
          ? json['pendapatan_bersih']
          : int.tryParse(json['pendapatan_bersih']?.toString() ?? '0') ?? 0,
      totalTransaksi: json['total_transaksi'] is int
          ? json['total_transaksi']
          : int.tryParse(json['total_transaksi']?.toString() ?? '0') ?? 0,
      totalJamTerpakai: json['total_jam_terpakai'] is int
          ? json['total_jam_terpakai']
          : int.tryParse(json['total_jam_terpakai']?.toString() ?? '0') ?? 0,
      perTipeSpace: items,
    );
  }
}
