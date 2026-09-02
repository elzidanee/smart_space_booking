import 'dart:convert';
import '../../../../core/utils/app_url_helper.dart';

int _parseInt(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is num) return value.round();
  if (value is String) {
    final trimmed = value.trim();
    return int.tryParse(trimmed) ?? double.tryParse(trimmed)?.round() ?? defaultValue;
  }
  return defaultValue;
}

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
      case 'desk':
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
    final rawFasilitas = json['fasilitas'];
    if (rawFasilitas is List) {
      parsedFasilitas = rawFasilitas
          .where((e) => e != null)
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } else if (rawFasilitas is String && rawFasilitas.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(rawFasilitas);
        if (decoded is List) {
          parsedFasilitas = decoded
              .where((e) => e != null)
              .map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList();
        } else {
          parsedFasilitas = rawFasilitas
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        }
      } catch (_) {
        parsedFasilitas = rawFasilitas
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }

    // foto_url (full URL dari server) diutamakan vs foto (nama file saja)
    final rawFoto = json['foto_url']?.toString() ?? json['foto']?.toString();
    final foto = AppUrlHelper.resolveImageUrl(rawFoto, defaultFolder: 'spaces');

    final rawId = json['id'] ?? json['id_space'];
    final id = _parseInt(rawId, defaultValue: 0);

    final nama = json['nama_space']?.toString() ??
        json['nama']?.toString() ??
        json['name']?.toString() ??
        'Space';

    final tipe = json['tipe']?.toString() ??
        json['type']?.toString() ??
        json['kategori']?.toString() ??
        'desk';

    final rawKapasitas = json['kapasitas'] ?? json['capacity'];
    final kapasitas = _parseInt(rawKapasitas, defaultValue: 1);

    final rawHarga = json['harga_per_jam'] ?? json['harga'] ?? json['price'];
    final hargaPerJam = _parseInt(rawHarga, defaultValue: 0);

    final deskripsi = json['deskripsi']?.toString() ?? json['description']?.toString();
    final status = json['status']?.toString() ?? 'tersedia';

    return SpaceModel(
      id: id,
      nama: nama,
      tipe: tipe,
      kapasitas: kapasitas > 0 ? kapasitas : 1,
      hargaPerJam: hargaPerJam >= 0 ? hargaPerJam : 0,
      fasilitas: parsedFasilitas,
      foto: foto,
      deskripsi: deskripsi,
      status: status,
    );
  }

  Map<String, dynamic> toJson() {
    final serverTipe = (tipe == 'personal_desk' || tipe == 'desk') ? 'desk' : tipe;
    return {
      'nama_space': nama, // API key untuk create/update
      'tipe': serverTipe,
      'kapasitas': kapasitas,
      'harga_per_jam': hargaPerJam,
      'deskripsi': deskripsi ?? '',
      if (foto != null && !foto!.startsWith('http')) 'foto': foto,
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
      durasi: _parseInt(json['durasi'] ?? json['durasi_jam'], defaultValue: 1),
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
    // Unpack nested map if returned under 'data', 'diskon', or 'promo'
    final rawData = json['data'] is Map
        ? (json['data'] as Map)
        : (json['diskon'] is Map
            ? (json['diskon'] as Map)
            : (json['promo'] is Map ? (json['promo'] as Map) : json));
    final map = Map<String, dynamic>.from(rawData);

    // Parse percentage safely (supports 50, 0.5, "50%", "50.00")
    final rawPersen = map['persentase_diskon'] ??
        map['persentase'] ??
        map['diskon'] ??
        map['persen'] ??
        map['discount'] ??
        map['discount_percentage'] ??
        map['nilai_diskon'] ??
        map['potongan_persen'];

    int persentaseVal = 0;
    if (rawPersen != null) {
      if (rawPersen is num) {
        if (rawPersen > 0 && rawPersen <= 1) {
          persentaseVal = (rawPersen * 100).round();
        } else {
          persentaseVal = rawPersen.round();
        }
      } else if (rawPersen is String) {
        final clean = rawPersen.replaceAll('%', '').trim();
        final parsed = double.tryParse(clean);
        if (parsed != null) {
          if (parsed > 0 && parsed <= 1) {
            persentaseVal = (parsed * 100).round();
          } else {
            persentaseVal = parsed.round();
          }
        }
      }
    }

    int potonganVal = _parseInt(
      map['potongan'] ??
          map['potongan_diskon'] ??
          map['discount_amount'] ??
          map['total_potongan'] ??
          map['nilai_potongan'],
      defaultValue: 0,
    );

    if (potonganVal == 0 && persentaseVal > 0 && subtotal > 0) {
      potonganVal = (subtotal * persentaseVal / 100).round();
    } else if (potonganVal > 0 && persentaseVal == 0 && subtotal > 0) {
      persentaseVal = ((potonganVal / subtotal) * 100).round();
    }

    // API mengembalikan nama_diskon / kode_promo sebagai nama/kode voucher
    final kode = map['nama_diskon']?.toString() ??
        map['kode_promo']?.toString() ??
        map['kode_diskon']?.toString() ??
        map['kode']?.toString() ??
        map['name']?.toString() ??
        '';

    return PromoCheckResult(
      id: _parseInt(map['id'] ?? map['id_diskon'] ?? map['diskon_id'], defaultValue: 0),
      kode: kode,
      persentase: persentaseVal,
      potongan: potonganVal,
      pesan: map['message']?.toString() ?? json['message']?.toString() ?? 'Promo berhasil diterapkan',
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
      'id_space': spaceId,
      'space_id': spaceId,
      'tanggal_reservasi': tanggal,
      'tanggal': tanggal,
      'jam_mulai': jamMulai,
      'durasi_jam': durasi,
      'durasi': durasi,
    };
    if (idDiskon != null && idDiskon! > 0) {
      map['id_diskon'] = idDiskon;
      map['diskon_id'] = idDiskon;
    }
    if (kodePromo != null && kodePromo!.trim().isNotEmpty) {
      final clean = kodePromo!.trim();
      map['kode_promo'] = clean;
      map['nama_diskon'] = clean;
      map['kode'] = clean;
      map['kode_diskon'] = clean;
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
    final spaceObj = json['space'] is Map ? Map<String, dynamic>.from(json['space'] as Map) : null;
    // Ambil nested member object jika ada
    final memberObj = json['member'] is Map ? Map<String, dynamic>.from(json['member'] as Map) : null;
    // Ambil nested rincian pembayaran jika ada
    final rincianObj = json['rincian_pembayaran'] is Map ? Map<String, dynamic>.from(json['rincian_pembayaran'] as Map) : null;

    // id_space bisa dari 'id_space', 'space_id', atau dari space.id
    final rawSpaceId = json['id_space'] ?? json['space_id'] ?? spaceObj?['id'];
    final parsedSpaceId = _parseInt(rawSpaceId, defaultValue: 0);

    // foto_url diutamakan vs foto dari space
    final fotoSpaceRaw = json['foto_space']?.toString() ??
        spaceObj?['foto_url']?.toString() ??
        spaceObj?['foto']?.toString();

    // tanggal: API pakai 'tanggal_reservasi', fallback ke 'tanggal'
    var tanggalRaw = (json['tanggal_reservasi'] ?? json['tanggal'] ?? json['tgl_reservasi'] ?? json['created_at'])?.toString() ?? '';
    if (tanggalRaw.contains('T')) {
      tanggalRaw = tanggalRaw.split('T').first;
    } else if (tanggalRaw.contains(' ')) {
      tanggalRaw = tanggalRaw.split(' ').first;
    }

    // durasi: API pakai 'durasi_jam', fallback ke 'durasi'
    final parsedDurasi = _parseInt(json['durasi_jam'] ?? json['durasi'] ?? json['durasi_sewa'], defaultValue: 1);

    final spaceHarga = _parseInt(
      spaceObj?['harga_per_jam'] ?? spaceObj?['harga'] ?? json['harga_per_jam'] ?? json['harga'],
      defaultValue: 0,
    );

    // subtotal: API pakai 'total_harga_awal', fallback ke 'subtotal'
    int parsedSubtotal = _parseInt(
      json['total_harga_awal'] ?? json['subtotal'] ?? json['total_biaya'] ?? json['total_harga'] ?? rincianObj?['total_harga_awal'] ?? rincianObj?['subtotal'],
      defaultValue: 0,
    );
    if (parsedSubtotal == 0 && spaceHarga > 0) {
      parsedSubtotal = spaceHarga * parsedDurasi;
    }

    final parsedPotongan = _parseInt(
      json['potongan_diskon'] ?? json['diskon'] ?? json['potongan'] ?? rincianObj?['potongan_diskon'],
      defaultValue: 0,
    );

    int parsedTotalBayar = _parseInt(
      json['total_bayar'] ?? json['total_biaya'] ?? json['total_harga'] ?? json['total'] ?? json['tagihan'] ?? json['amount'] ?? rincianObj?['total_bayar'],
      defaultValue: 0,
    );
    if (parsedTotalBayar == 0 && parsedSubtotal > 0) {
      parsedTotalBayar = (parsedSubtotal - parsedPotongan) > 0 ? (parsedSubtotal - parsedPotongan) : parsedSubtotal;
    }

    // member info
    final namaMemberRaw = json['nama_member']?.toString() ??
        memberObj?['nama_member']?.toString() ??
        memberObj?['nama']?.toString();
    final teleponMemberRaw = json['telepon_member']?.toString() ??
        memberObj?['telp']?.toString() ??
        memberObj?['telepon']?.toString();

    return ReservationModel(
      id: _parseInt(json['id'], defaultValue: 0),
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
      potonganDiskon: parsedPotongan,
      totalBayar: parsedTotalBayar,
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
