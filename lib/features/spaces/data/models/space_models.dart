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

    return SpaceModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nama: json['nama']?.toString() ?? json['nama_space']?.toString() ?? 'Space',
      tipe: json['tipe']?.toString() ?? 'personal_desk',
      kapasitas: json['kapasitas'] is int
          ? json['kapasitas']
          : int.tryParse(json['kapasitas']?.toString() ?? '1') ?? 1,
      hargaPerJam: json['harga_per_jam'] is int
          ? json['harga_per_jam']
          : int.tryParse(json['harga_per_jam']?.toString() ?? '0') ?? 0,
      fasilitas: parsedFasilitas,
      foto: json['foto']?.toString(),
      deskripsi: json['deskripsi']?.toString(),
      status: json['status']?.toString() ?? 'tersedia',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'tipe': tipe,
      'kapasitas': kapasitas,
      'harga_per_jam': hargaPerJam,
      'fasilitas': fasilitas,
      'foto': foto,
      'deskripsi': deskripsi,
      'status': status,
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
    final persentaseVal = json['persentase'] is int
        ? json['persentase']
        : int.tryParse(json['persentase']?.toString() ?? '0') ?? 0;
    
    int potonganVal = json['potongan'] is int
        ? json['potongan']
        : int.tryParse(json['potongan']?.toString() ?? '0') ?? 0;

    if (potonganVal == 0 && persentaseVal > 0 && subtotal > 0) {
      potonganVal = (subtotal * persentaseVal / 100).round();
    }

    return PromoCheckResult(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      kode: json['kode']?.toString() ?? '',
      persentase: persentaseVal,
      potongan: potonganVal,
      pesan: json['message']?.toString() ?? 'Promo berhasil diterapkan',
    );
  }
}

/// Request pembuatan reservasi baru (FR-11)
class CreateReservationRequest {
  final int spaceId;
  final String tanggal; // YYYY-MM-DD
  final String jamMulai; // HH:mm
  final int durasi; // Durasi jam
  final String? kodePromo;

  const CreateReservationRequest({
    required this.spaceId,
    required this.tanggal,
    required this.jamMulai,
    required this.durasi,
    this.kodePromo,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'space_id': spaceId,
      'tanggal': tanggal,
      'jam_mulai': jamMulai,
      'durasi': durasi,
    };
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
    return ReservationModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      kodeBooking: json['kode_booking']?.toString() ?? json['booking_code']?.toString() ?? '',
      spaceId: json['space_id'] is int ? json['space_id'] : int.tryParse(json['space_id']?.toString() ?? '0') ?? 0,
      namaSpace: json['nama_space']?.toString() ?? json['space']?['nama']?.toString(),
      tipeSpace: json['tipe_space']?.toString() ?? json['space']?['tipe']?.toString(),
      fotoSpace: json['foto_space']?.toString() ?? json['space']?['foto']?.toString(),
      tanggal: json['tanggal']?.toString() ?? '',
      jamMulai: json['jam_mulai']?.toString() ?? '',
      jamSelesai: json['jam_selesai']?.toString() ?? '',
      durasi: json['durasi'] is int ? json['durasi'] : int.tryParse(json['durasi']?.toString() ?? '1') ?? 1,
      subtotal: json['subtotal'] is int ? json['subtotal'] : int.tryParse(json['subtotal']?.toString() ?? '0') ?? 0,
      potonganDiskon: json['potongan_diskon'] is int
          ? json['potongan_diskon']
          : int.tryParse(json['potongan_diskon']?.toString() ?? '0') ?? 0,
      totalBayar: json['total_bayar'] is int
          ? json['total_bayar']
          : int.tryParse(json['total_bayar']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? 'belum_dikonfirm',
      namaMember: json['nama_member']?.toString() ?? json['member']?['nama']?.toString(),
      teleponMember: json['telepon_member']?.toString() ?? json['member']?['telepon']?.toString(),
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
