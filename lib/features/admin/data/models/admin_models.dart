import 'package:flutter/foundation.dart';
import '../../../../core/utils/app_url_helper.dart';

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
    final rawFoto = json['foto_url']?.toString() ?? json['foto']?.toString();
    return AdminProfileModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '1') ?? 1,
      // API mengembalikan nama_coworking, fallback ke nama_space (lama)
      namaSpace: json['nama_coworking']?.toString() ?? json['nama_space']?.toString() ?? 'Smart Space Hub',
      namaPemilik: json['nama_pemilik']?.toString() ?? json['pemilik']?.toString() ?? 'Admin Pengelola',
      // API memakai telp bukan telepon
      telepon: json['telp']?.toString() ?? json['telepon']?.toString() ?? json['no_telp']?.toString() ?? '',
      alamat: json['alamat']?.toString() ?? '',
      deskripsiFasilitas: json['deskripsi_fasilitas']?.toString() ?? json['deskripsi']?.toString() ?? '',
      foto: AppUrlHelper.resolveImageUrl(rawFoto, defaultFolder: 'spaces'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_coworking': namaSpace,   // API field: nama_coworking
      'nama_pemilik': namaPemilik,
      'telp': telepon,               // API field: telp (bukan telepon)
      if (alamat.isNotEmpty) 'alamat': alamat,
      if (deskripsiFasilitas.isNotEmpty) 'deskripsi_fasilitas': deskripsiFasilitas,
      if (foto != null && foto!.isNotEmpty) 'foto': foto,
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
      foto: AppUrlHelper.resolveImageUrl(
        json['foto_url']?.toString() ?? json['foto']?.toString(),
        defaultFolder: 'members',
      ),
      totalReservasi: json['total_reservasi'] is int
          ? json['total_reservasi']
          : int.tryParse(json['total_reservasi']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson({String? password}) {
    return {
      'nama_member': nama,   // API field: nama_member
      'instansi': instansi,
      'telp': telepon,       // API field: telp (bukan telepon)
      'alamat': alamat,
      'username': username,
      if (password != null && password.isNotEmpty) 'password': password,
      if (foto != null && foto!.isNotEmpty) 'foto': foto,
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

/// Model Request Tambah Member Baru oleh Admin (POST /api/admin/members) (QA-005)
class AdminMemberCreateRequest {
  final String nama;
  final String instansi;
  final String telepon;
  final String alamat;
  final String username;
  final String password;
  final String? foto;

  const AdminMemberCreateRequest({
    required this.nama,
    required this.instansi,
    required this.telepon,
    required this.alamat,
    required this.username,
    required this.password,
    this.foto,
  });

  Map<String, dynamic> toJson() {
    return {
      'nama_member': nama,
      'instansi': instansi,
      'telp': telepon,
      'alamat': alamat,
      'username': username,
      'password': password,
      if (foto != null && foto!.isNotEmpty) 'foto': foto,
    };
  }
}

/// Model Request Update Member oleh Admin (PUT /api/admin/members/{id}) (QA-006)
class AdminMemberUpdateRequest {
  final int id;
  final String? nama;
  final String? instansi;
  final String? telepon;
  final String? alamat;
  final String? username;
  final String? password;
  final String? foto;

  const AdminMemberUpdateRequest({
    required this.id,
    this.nama,
    this.instansi,
    this.telepon,
    this.alamat,
    this.username,
    this.password,
    this.foto,
  });

  Map<String, dynamic> toJson() {
    return {
      if (nama != null) 'nama_member': nama,
      if (instansi != null) 'instansi': instansi,
      if (telepon != null) 'telp': telepon,
      if (alamat != null) 'alamat': alamat,
      if (username != null) 'username': username,
      if (password != null && password!.isNotEmpty) 'password': password,
      if (foto != null && foto!.isNotEmpty) 'foto': foto,
    };
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
    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.round();
      return int.tryParse(v.toString().trim()) ?? double.tryParse(v.toString().trim())?.round() ?? 0;
    }

    return SpaceTypeDistribution(
      tipe: (json['tipe'] ?? json['tipe_space'] ?? json['type'] ?? 'personal_desk').toString(),
      namaTipe: (json['nama_tipe'] ?? json['nama'] ?? json['label'] ?? json['tipe'] ?? 'Space').toString(),
      totalBooking: parseInt(json['total_booking'] ?? json['booking'] ?? json['jumlah_booking'] ?? json['count']),
      totalJam: parseInt(json['total_jam'] ?? json['jam'] ?? json['durasi'] ?? json['total_durasi']),
      totalPendapatan: parseInt(
        json['total_pendapatan'] ?? json['pendapatan'] ?? json['total_harga'] ??
        json['total_bayar'] ?? json['income'] ?? json['revenue'],
      ),
      persentase: () {
        final v = json['persentase'] ?? json['percentage'] ?? json['persen'];
        if (v == null) return 0.0;
        if (v is num) return v.toDouble();
        return double.tryParse(v.toString().trim()) ?? 0.0;
      }(),
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
    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.round();
      return int.tryParse(v.toString().trim()) ?? double.tryParse(v.toString().trim())?.round() ?? 0;
    }

    String tipeLabel(String tipe) {
      switch (tipe.toLowerCase()) {
        case 'desk':
        case 'personal_desk': return 'Personal Desk';
        case 'meeting_room':  return 'Meeting Room';
        case 'private_office': return 'Private Office';
        default: return tipe;
      }
    }

    // ── Nested: periode { bulan, nama_bulan, tahun } ──────────────────────
    final periodeObj = json['periode'] is Map
        ? Map<String, dynamic>.from(json['periode'] as Map)
        : null;

    // ── Nested: ringkasan { total_reservasi, estimasi_pendapatan_total,
    //            realisasi_pendapatan, status_reservasi } ──────────────────
    final ringkasanObj = json['ringkasan'] is Map
        ? Map<String, dynamic>.from(json['ringkasan'] as Map)
        : null;

    // ── Pendapatan ────────────────────────────────────────────────────────
    // Kotor = estimasi_pendapatan_total (sebelum diskon)
    final kotor = parseInt(
      ringkasanObj?['estimasi_pendapatan_total'] ??
      ringkasanObj?['estimasi_pendapatan_kotor'] ??
      json['estimasi_pendapatan_total'] ??
      json['estimasi_pendapatan_kotor'] ??
      json['pendapatan_kotor'],
    );
    // Bersih = realisasi_pendapatan (setelah diskon)
    final bersih = parseInt(
      ringkasanObj?['realisasi_pendapatan'] ??
      ringkasanObj?['realisasi_pendapatan_bersih'] ??
      json['realisasi_pendapatan'] ??
      json['realisasi_pendapatan_bersih'] ??
      json['pendapatan_bersih'],
    );
    // Potongan tidak ada di response → hitung: kotor - bersih
    final potongan = (kotor - bersih) > 0 ? (kotor - bersih) : parseInt(
      json['total_potongan_diskon'] ?? json['potongan_diskon'],
    );

    // ── Total transaksi & jam ─────────────────────────────────────────────
    final totalTx = parseInt(
      ringkasanObj?['total_reservasi'] ??
      json['total_reservasi'] ??
      json['total_transaksi'],
    );
    final totalJam = parseInt(
      ringkasanObj?['total_jam'] ??
      json['total_jam_terpakai'] ??
      json['total_jam'],
    );

    // ── pendapatan_per_tipe_space: MAP { desk: {count, total_income}, ... }
    // Format BERBEDA dari ekspektasi — ini adalah object, bukan array!
    List<SpaceTypeDistribution> items = [];
    final perTipeRaw = json['pendapatan_per_tipe_space'] ?? json['per_tipe_space'] ?? json['rincian_per_tipe_space'];
    if (perTipeRaw is Map) {
      // Format baru: { "desk": { count, total_income }, "meeting_room": {...}, ... }
      perTipeRaw.forEach((key, value) {
        if (value is Map) {
          final m = Map<String, dynamic>.from(value);
          final income    = parseInt(m['total_income'] ?? m['income'] ?? m['total_pendapatan']);
          final booking   = parseInt(m['count'] ?? m['total_booking'] ?? m['booking']);
          final jam       = parseInt(m['total_jam'] ?? m['jam']);
          final pct       = bersih > 0 && income > 0 ? (income / bersih * 100) : 0.0;
          items.add(SpaceTypeDistribution(
            tipe: key.toString(),
            namaTipe: tipeLabel(key.toString()),
            totalBooking: booking,
            totalJam: jam,
            totalPendapatan: income,
            persentase: pct,
          ));
        }
      });
    } else if (perTipeRaw is List) {
      // Format lama: array of objects
      items = perTipeRaw
          .whereType<Map>()
          .map((e) => SpaceTypeDistribution.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return AdminMonthlyReportModel(
      bulan: parseInt(periodeObj?['bulan'] ?? json['bulan'] ?? json['month'] ?? DateTime.now().month),
      tahun: parseInt(periodeObj?['tahun'] ?? json['tahun'] ?? json['year'] ?? DateTime.now().year),
      pendapatanKotor:  kotor,
      potonganDiskon:   potongan,
      pendapatanBersih: bersih,
      totalTransaksi:   totalTx,
      totalJamTerpakai: totalJam,
      perTipeSpace:     items,
    );
  }

}
