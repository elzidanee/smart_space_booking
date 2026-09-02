import 'dart:convert';

/// Model Ruangan / Workstation sesuai PRD Bagian II §5.3 & Kontrak API.
class SpaceModel {
  final int id;
  final String nama;
  final String tipe; // 'personal_desk' | 'meeting_room' | 'private_office'
  final int kapasitas;
  final int hargaPerJam;
  final List<String> fasilitas;
  final String? foto;
  final String? deskripsi;
  final String status; // 'tersedia' | 'tidak_tersedia'

  const SpaceModel({
    required this.id,
    required this.nama,
    required this.tipe,
    required this.kapasitas,
    required this.hargaPerJam,
    this.fasilitas = const [],
    this.foto,
    this.deskripsi,
    this.status = 'tersedia',
  });

  /// Label tipe yang mudah dibaca
  String get tipeLabel {
    switch (tipe.toLowerCase()) {
      case 'personal_desk':
        return 'Personal Desk';
      case 'meeting_room':
        return 'Meeting Room';
      case 'private_office':
        return 'Private Office';
      default:
        return tipe;
    }
  }

  factory SpaceModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedFasilitas = [];
    if (json['fasilitas'] is List) {
      parsedFasilitas = (json['fasilitas'] as List)
          .map((e) => e.toString())
          .toList();
    } else if (json['fasilitas'] is String && (json['fasilitas'] as String).isNotEmpty) {
      try {
        final decoded = jsonDecode(json['fasilitas'] as String);
        if (decoded is List) {
          parsedFasilitas = decoded.map((e) => e.toString()).toList();
        } else {
          parsedFasilitas = (json['fasilitas'] as String).split(',').map((e) => e.trim()).toList();
        }
      } catch (_) {
        parsedFasilitas = (json['fasilitas'] as String).split(',').map((e) => e.trim()).toList();
      }
    }

    // foto_url (full URL dari server) diutamakan vs foto (nama file saja)
    final foto = json['foto_url']?.toString() ?? json['foto']?.toString();

    return SpaceModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nama: json['nama_space']?.toString() ?? json['nama']?.toString() ?? 'Space',
      tipe: json['tipe']?.toString() ?? 'personal_desk',
      kapasitas: json['kapasitas'] is int
          ? json['kapasitas']
          : int.tryParse(json['kapasitas']?.toString() ?? '1') ?? 1,
      hargaPerJam: json['harga_per_jam'] is int
          ? json['harga_per_jam']
          : int.tryParse(json['harga_per_jam']?.toString() ?? '0') ?? 0,
      fasilitas: parsedFasilitas,
      foto: foto,
      deskripsi: json['deskripsi']?.toString(),
      status: json['status']?.toString() ?? 'tersedia',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_space': nama, // API key untuk create/update
      'tipe': tipe,
      'kapasitas': kapasitas,
      'harga_per_jam': hargaPerJam,
      'fasilitas': fasilitas,
      if (foto != null) 'foto': foto,
      if (deskripsi != null) 'deskripsi': deskripsi,
    };
  }

  SpaceModel copyWith({
    int? id,
    String? nama,
    String? tipe,
    int? kapasitas,
    int? hargaPerJam,
    List<String>? fasilitas,
    String? foto,
    String? deskripsi,
    String? status,
  }) {
    return SpaceModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      tipe: tipe ?? this.tipe,
      kapasitas: kapasitas ?? this.kapasitas,
      hargaPerJam: hargaPerJam ?? this.hargaPerJam,
      fasilitas: fasilitas ?? this.fasilitas,
      foto: foto ?? this.foto,
      deskripsi: deskripsi ?? this.deskripsi,
      status: status ?? this.status,
    );
  }

  String toJsonString() => jsonEncode(toJson());
}

/// Hasil pengecekan ketersediaan space (FR-08)
class AvailabilityCheckResult {
  final bool isAvailable;
  final String message;
  final String? tanggal;
  final String? jamMulai;
  final int? durasi;

  const AvailabilityCheckResult({
    required this.isAvailable,
    required this.message,
    this.tanggal,
    this.jamMulai,
    this.durasi,
  });

  factory AvailabilityCheckResult.fromJson(Map<String, dynamic> json) {
    final available = json['is_available'] == true ||
        json['tersedia'] == true ||
        json['available'] == true ||
        json['status'] == 'tersedia';
    return AvailabilityCheckResult(
      isAvailable: available,
      message: json['message']?.toString() ?? (available ? 'Space tersedia' : 'Space sudah terisi'),
      tanggal: json['tanggal']?.toString(),
      jamMulai: json['jam_mulai']?.toString(),
      durasi: json['durasi'] is int ? json['durasi'] : int.tryParse(json['durasi']?.toString() ?? '1'),
    );
  }
}

/// Hasil validasi kode voucher / diskon (FR-09)
class PromoCheckResult {
  final int id;
  final String kode;
  final int persentase;
  final int potongan;
  final String? pesan;

  const PromoCheckResult({
    required this.id,
    required this.kode,
    required this.persentase,
    required this.potongan,
    this.pesan,
  });

  factory PromoCheckResult.fromJson(Map<String, dynamic> json, {int subtotal = 0}) {
    // API /api/diskon/check mengembalikan: persentase_diskon, nama_diskon, is_active
    final persentaseVal = json['persentase_diskon'] is int
        ? json['persentase_diskon']
        : json['persentase'] is int
            ? json['persentase']
            : int.tryParse((json['persentase_diskon'] ?? json['persentase'])?.toString() ?? '0') ?? 0;

    int potonganVal = json['potongan'] is int
        ? json['potongan']
        : int.tryParse(json['potongan']?.toString() ?? '0') ?? 0;

    if (potonganVal == 0 && persentaseVal > 0 && subtotal > 0) {
      potonganVal = (subtotal * persentaseVal / 100).round();
    }

    // API mengembalikan nama_diskon sebagai nama/kode voucher
    final kode = json['nama_diskon']?.toString() ?? json['kode']?.toString() ?? '';

    return PromoCheckResult(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      kode: kode,
      persentase: persentaseVal,
      potongan: potonganVal,
      pesan: json['message']?.toString() ?? 'Promo berhasil diterapkan',
    );
  }
}

/// Request pembuatan reservasi baru (FR-11)
/// POST /api/reservasi
/// Body: { id_space, tanggal_reservasi, jam_mulai, durasi_jam, id_diskon?, kode_promo? }
class CreateReservationRequest {
  final int spaceId;
  final String tanggal;    // YYYY-MM-DD → API key: tanggal_reservasi
  final String jamMulai;   // HH:mm      → API key: jam_mulai
  final int durasi;        // jam        → API key: durasi_jam
  final String? kodePromo; // → API key: kode_promo
  final int? idDiskon;     // → API key: id_diskon

  const CreateReservationRequest({
    required this.spaceId,
    required this.tanggal,
    required this.jamMulai,
    required this.durasi,
    this.kodePromo,
    this.idDiskon,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id_space': spaceId,           // API: id_space (bukan space_id)
      'tanggal_reservasi': tanggal,  // API: tanggal_reservasi
      'jam_mulai': jamMulai,
      'durasi_jam': durasi,          // API: durasi_jam (bukan durasi)
    };
    if (idDiskon != null) {
      map['id_diskon'] = idDiskon;
    }
    if (kodePromo != null && kodePromo!.trim().isNotEmpty) {
      map['kode_promo'] = kodePromo!.trim();
    }
    return map;
  }
}

/// Response pembuatan reservasi baru (FR-12, FR-16)
class ReservationModel {
  final int id;
  final String kodeBooking;
  final int spaceId;
  final String? namaSpace;
  final String? tipeSpace;
  final String? fotoSpace;
  final String tanggal;
  final String jamMulai;
  final String jamSelesai;
  final int durasi;
  final int subtotal;
  final int potonganDiskon;
  final int totalBayar;
  final String status; // 'belum_dikonfirm' | 'disetujui' | 'aktif' | 'selesai' | 'dibatalkan'
  final String? namaMember;
  final String? teleponMember;
  final String? createdAt;

  const ReservationModel({
    required this.id,
    required this.kodeBooking,
    required this.spaceId,
    this.namaSpace,
    this.tipeSpace,
    this.fotoSpace,
    required this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
    required this.durasi,
    required this.subtotal,
    this.potonganDiskon = 0,
    required this.totalBayar,
    required this.status,
    this.namaMember,
    this.teleponMember,
    this.createdAt,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    // Ambil nested space object jika ada
    final spaceObj = json['space'] as Map<String, dynamic>?;
    // Ambil nested member object jika ada
    final memberObj = json['member'] as Map<String, dynamic>?;

    // id_space bisa dari 'id_space', 'space_id', atau dari space.id
    final rawSpaceId = json['id_space'] ?? json['space_id'] ?? spaceObj?['id'];
    final parsedSpaceId = rawSpaceId is int ? rawSpaceId : int.tryParse(rawSpaceId?.toString() ?? '0') ?? 0;

    // foto_url diutamakan vs foto dari space
    final fotoSpaceRaw = json['foto_space']?.toString() ??
        spaceObj?['foto_url']?.toString() ??
        spaceObj?['foto']?.toString();

    // tanggal: API pakai 'tanggal_reservasi', fallback ke 'tanggal'
    final tanggalRaw = (json['tanggal_reservasi'] ?? json['tanggal'])?.toString() ?? '';

    // durasi: API pakai 'durasi_jam', fallback ke 'durasi'
    final durasiRaw = json['durasi_jam'] ?? json['durasi'];
    final parsedDurasi = durasiRaw is int ? durasiRaw : int.tryParse(durasiRaw?.toString() ?? '1') ?? 1;

    // subtotal: API pakai 'total_harga_awal', fallback ke 'subtotal'
    final subtotalRaw = json['total_harga_awal'] ?? json['subtotal'];
    final parsedSubtotal = subtotalRaw is int ? subtotalRaw : int.tryParse(subtotalRaw?.toString() ?? '0') ?? 0;

    // member info
    final namaMemberRaw = json['nama_member']?.toString() ??
        memberObj?['nama_member']?.toString() ??
        memberObj?['nama']?.toString();
    final teleponMemberRaw = json['telepon_member']?.toString() ??
        memberObj?['telp']?.toString() ??
        memberObj?['telepon']?.toString();

    return ReservationModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      kodeBooking: json['kode_booking']?.toString() ?? json['booking_code']?.toString() ?? '',
      spaceId: parsedSpaceId,
      namaSpace: json['nama_space']?.toString() ?? spaceObj?['nama_space']?.toString() ?? spaceObj?['nama']?.toString(),
      tipeSpace: json['tipe_space']?.toString() ?? spaceObj?['tipe']?.toString(),
      fotoSpace: fotoSpaceRaw,
      tanggal: tanggalRaw,
      jamMulai: json['jam_mulai']?.toString() ?? '',
      jamSelesai: json['jam_selesai']?.toString() ?? '',
      durasi: parsedDurasi,
      subtotal: parsedSubtotal,
      potonganDiskon: json['potongan_diskon'] is int
          ? json['potongan_diskon']
          : int.tryParse(json['potongan_diskon']?.toString() ?? '0') ?? 0,
      totalBayar: json['total_bayar'] is int
          ? json['total_bayar']
          : int.tryParse(json['total_bayar']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? 'belum_dikonfirm',
      namaMember: namaMemberRaw,
      teleponMember: teleponMemberRaw,
      createdAt: json['created_at']?.toString(),
    );
  }

  ReservationModel copyWith({
    int? id,
    String? kodeBooking,
    int? spaceId,
    String? namaSpace,
    String? tipeSpace,
    String? fotoSpace,
    String? tanggal,
    String? jamMulai,
    String? jamSelesai,
    int? durasi,
    int? subtotal,
    int? potonganDiskon,
    int? totalBayar,
    String? status,
    String? namaMember,
    String? teleponMember,
    String? createdAt,
  }) {
    return ReservationModel(
      id: id ?? this.id,
      kodeBooking: kodeBooking ?? this.kodeBooking,
      spaceId: spaceId ?? this.spaceId,
      namaSpace: namaSpace ?? this.namaSpace,
      tipeSpace: tipeSpace ?? this.tipeSpace,
      fotoSpace: fotoSpace ?? this.fotoSpace,
      tanggal: tanggal ?? this.tanggal,
      jamMulai: jamMulai ?? this.jamMulai,
      jamSelesai: jamSelesai ?? this.jamSelesai,
      durasi: durasi ?? this.durasi,
      subtotal: subtotal ?? this.subtotal,
      potonganDiskon: potonganDiskon ?? this.potonganDiskon,
      totalBayar: totalBayar ?? this.totalBayar,
      status: status ?? this.status,
      namaMember: namaMember ?? this.namaMember,
      teleponMember: teleponMember ?? this.teleponMember,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
