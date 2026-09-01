import 'package:flutter/foundation.dart';

/// Model Profil Lokasi Coworking (Admin Profile) sesuai GET/PUT /api/admin/profile
@immutable
class AdminProfileModel {
  final int id;
  final String namaSpace;          // API field: nama_coworking
  final String namaPemilik;        // API field: nama_pemilik
  final String telepon;            // API field: telp
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
      // API mengembalikan nama_coworking, fallback ke nama_space (lama)
      namaSpace: json['nama_coworking']?.toString() ?? json['nama_space']?.toString() ?? 'Smart Space Hub',
      namaPemilik: json['nama_pemilik']?.toString() ?? json['pemilik']?.toString() ?? 'Admin Pengelola',
      // API memakai telp bukan telepon
      telepon: json['telp']?.toString() ?? json['telepon']?.toString() ?? json['no_telp']?.toString() ?? '',
      alamat: json['alamat']?.toString() ?? '',
      deskripsiFasilitas: json['deskripsi_fasilitas']?.toString() ?? json['deskripsi']?.toString() ?? '',
      foto: json['foto_url']?.toString() ?? json['foto']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_coworking': namaSpace,   // API field: nama_coworking
      'nama_pemilik': namaPemilik,
      'telp': telepon,               // API field: telp (bukan telepon)
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
  final String nama;       // API field: nama_member
  final String instansi;
  final String telepon;    // API field: telp
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
      // API mengembalikan nama_member bukan nama
      nama: json['nama_member']?.toString() ?? json['nama']?.toString() ?? json['nama_lengkap']?.toString() ?? '',
      instansi: json['instansi']?.toString() ?? '-',
      // API menggunakan telp bukan telepon
      telepon: json['telp']?.toString() ?? json['telepon']?.toString() ?? json['no_telp']?.toString() ?? '',
      alamat: json['alamat']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      foto: json['foto_url']?.toString() ?? json['foto']?.toString(),
      totalReservasi: json['total_reservasi'] is int
          ? json['total_reservasi']
          : int.tryParse(json['total_reservasi']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_member': nama,   // API field: nama_member
      'instansi': instansi,
      'telp': telepon,       // API field: telp (bukan telepon)
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
/// API fields: nama_diskon, persentase_diskon, tanggal_awal, tanggal_akhir
@immutable
class AdminDiscountModel {
  final int id;
  final String kode;       // API field: nama_diskon
  final int persentase;    // API field: persentase_diskon
  final String tanggalMulai; // API field: tanggal_awal
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
    // API panitia mengembalikan nama_diskon (bukan kode), persentase_diskon (bukan persentase)
    // tanggal_awal (bukan tanggal_mulai)
    final tglAkhir = json['tanggal_akhir']?.toString() ?? json['tgl_akhir']?.toString() ?? '2026-12-31';
    final tglMulai = json['tanggal_awal']?.toString() ?? json['tanggal_mulai']?.toString() ?? json['tgl_mulai']?.toString() ?? '2026-01-01';

    String computedStatus = json['status']?.toString() ?? 'aktif';
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final end = DateTime.parse(tglAkhir);
      if (today.isAfter(end)) computedStatus = 'kedaluwarsa';
    } catch (_) {}

    return AdminDiscountModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      kode: (json['nama_diskon'] ?? json['kode'] ?? json['kode_diskon'] ?? '').toString().toUpperCase(),
      persentase: json['persentase_diskon'] is int
          ? json['persentase_diskon']
          : json['persentase'] is int
              ? json['persentase']
              : int.tryParse((json['persentase_diskon'] ?? json['persentase'])?.toString() ?? '0') ?? 0,
      tanggalMulai: tglMulai,
      tanggalAkhir: tglAkhir,
      status: computedStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_diskon': kode,           // API field: nama_diskon
      'persentase_diskon': persentase, // API field: persentase_diskon
      'tanggal_awal': tanggalMulai,  // API field: tanggal_awal (bukan tanggal_mulai)
      'tanggal_akhir': tanggalAkhir,
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
/// API fields: realisasi_pendapatan_bersih, estimasi_pendapatan_kotor, total_potongan_diskon,
///             total_jam_terpakai, total_reservasi, rincian_per_tipe_space
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
    // API mengembalikan rincian_per_tipe_space atau per_tipe_space
    final listDistribusi = json['rincian_per_tipe_space'] ?? json['per_tipe_space'] ?? json['distribusi_space'] ?? [];
    final items = (listDistribusi as List)
        .map((e) => SpaceTypeDistribution.fromJson(e as Map<String, dynamic>))
        .toList();

    return AdminMonthlyReportModel(
      bulan: json['bulan'] is int ? json['bulan'] : int.tryParse(json['bulan']?.toString() ?? '8') ?? 8,
      tahun: json['tahun'] is int ? json['tahun'] : int.tryParse(json['tahun']?.toString() ?? '2026') ?? 2026,
      // API mengembalikan estimasi_pendapatan_kotor
      pendapatanKotor: json['estimasi_pendapatan_kotor'] is int
          ? json['estimasi_pendapatan_kotor']
          : json['pendapatan_kotor'] is int
              ? json['pendapatan_kotor']
              : int.tryParse((json['estimasi_pendapatan_kotor'] ?? json['pendapatan_kotor'])?.toString() ?? '0') ?? 0,
      // API mengembalikan total_potongan_diskon
      potonganDiskon: json['total_potongan_diskon'] is int
          ? json['total_potongan_diskon']
          : json['potongan_diskon'] is int
              ? json['potongan_diskon']
              : int.tryParse((json['total_potongan_diskon'] ?? json['potongan_diskon'])?.toString() ?? '0') ?? 0,
      // API mengembalikan realisasi_pendapatan_bersih
      pendapatanBersih: json['realisasi_pendapatan_bersih'] is int
          ? json['realisasi_pendapatan_bersih']
          : json['pendapatan_bersih'] is int
              ? json['pendapatan_bersih']
              : int.tryParse((json['realisasi_pendapatan_bersih'] ?? json['pendapatan_bersih'])?.toString() ?? '0') ?? 0,
      totalTransaksi: json['total_reservasi'] is int
          ? json['total_reservasi']
          : json['total_transaksi'] is int
              ? json['total_transaksi']
              : int.tryParse((json['total_reservasi'] ?? json['total_transaksi'])?.toString() ?? '0') ?? 0,
      totalJamTerpakai: json['total_jam_terpakai'] is int
          ? json['total_jam_terpakai']
          : int.tryParse(json['total_jam_terpakai']?.toString() ?? '0') ?? 0,
      perTipeSpace: items,
    );
  }
}
