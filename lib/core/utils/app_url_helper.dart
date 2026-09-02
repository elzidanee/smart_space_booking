import '../../core/network/api_endpoints.dart';

class AppUrlHelper {
  /// Base domain backend panitia
  static String get baseDomain {
    return ApiEndpoints.baseUrl.replaceAll(RegExp(r'/+$'), '');
  }

  /// Memperbaiki dan menormalkan URL foto dari server panitia
  /// Menangani masalah server yang mengembalikan URL tanpa prefix /coworking
  /// atau hanya mengembalikan nama file saja.
  static String? resolveImageUrl(String? rawUrl, {String defaultFolder = 'spaces'}) {
    if (rawUrl == null) return null;
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return null;

    // 1. Cek apakah ini path file lokal (desktop Windows atau mobile storage)
    if (trimmed.startsWith('file://') ||
        trimmed.contains(RegExp(r'^[a-zA-Z]:[/\\]')) ||
        trimmed.startsWith('/data/') ||
        trimmed.startsWith('/storage/')) {
      return trimmed;
    }

    final base = baseDomain;

    // 2. Normalisasi domain learn.smktelkom-mlg.sch.id yang kekurangan prefix /coworking
    if (trimmed.startsWith('http://learn.smktelkom-mlg.sch.id/uploads/')) {
      return trimmed.replaceFirst(
        'http://learn.smktelkom-mlg.sch.id/uploads/',
        '$base/uploads/',
      );
    }
    if (trimmed.startsWith('https://learn.smktelkom-mlg.sch.id/uploads/')) {
      return trimmed.replaceFirst(
        'https://learn.smktelkom-mlg.sch.id/uploads/',
        '$base/uploads/',
      );
    }
    if (trimmed.startsWith('http://localhost:3000/uploads/')) {
      return trimmed.replaceFirst(
        'http://localhost:3000/uploads/',
        '$base/uploads/',
      );
    }

    // 3. Jika URL sudah diawali http:// atau https://
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      if (trimmed.contains('learn.smktelkom-mlg.sch.id') && !trimmed.contains('/coworking/')) {
        return trimmed
            .replaceFirst('http://', 'https://')
            .replaceFirst('learn.smktelkom-mlg.sch.id', 'learn.smktelkom-mlg.sch.id/coworking');
      }
      return trimmed;
    }

    // 4. Jika URL berupa path relatif
    if (trimmed.startsWith('/uploads/')) {
      return '$base$trimmed';
    }
    if (trimmed.startsWith('uploads/')) {
      return '$base/$trimmed';
    }

    // 5. Jika hanya berupa nama file (misal "1788319712456-985097890.png")
    final filename = trimmed.split(RegExp(r'[/\\]')).last;
    if (filename.contains('.')) {
      return '$base/uploads/$defaultFolder/$filename';
    }

    final clean = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$base$clean';
  }
}
