import '../../core/network/api_endpoints.dart';

class AppUrlHelper {
  static String get _base => ApiEndpoints.baseUrl.replaceAll(RegExp(r'/+$'), '');

  /// Resolusi URL gambar dari server — handle berbagai format yang dikembalikan API
  static String? resolveImageUrl(String? rawUrl, {String defaultFolder = 'spaces'}) {
    if (rawUrl == null) return null;
    final url = rawUrl.trim();
    if (url.isEmpty) return null;

    // File lokal (Windows path, Android storage, dll)
    if (url.startsWith('file://') ||
        url.contains(RegExp(r'^[a-zA-Z]:[/\\]')) ||
        url.startsWith('/data/') ||
        url.startsWith('/storage/')) {
      return url;
    }

    final base = _base;

    // Normalisasi localhost / emulator ke base URL panitia
    if (url.contains(RegExp(r'https?://(localhost|127\.0\.0\.1|10\.0\.2\.2)(:\d+)?/uploads/'))) {
      return url.replaceFirst(
        RegExp(r'https?://(localhost|127\.0\.0\.1|10\.0\.2\.2)(:\d+)?/uploads/'),
        '$base/uploads/',
      );
    }

    // Perbaiki domain tanpa prefix /coworking
    if (url.startsWith('http://learn.smktelkom-mlg.sch.id/uploads/')) {
      return url.replaceFirst('http://learn.smktelkom-mlg.sch.id/uploads/', '$base/uploads/');
    }
    if (url.startsWith('https://learn.smktelkom-mlg.sch.id/uploads/')) {
      return url.replaceFirst('https://learn.smktelkom-mlg.sch.id/uploads/', '$base/uploads/');
    }

    // URL lengkap
    if (url.startsWith('http://') || url.startsWith('https://')) {
      if (url.contains('learn.smktelkom-mlg.sch.id') && !url.contains('/coworking/')) {
        return url
            .replaceFirst('http://', 'https://')
            .replaceFirst('learn.smktelkom-mlg.sch.id', 'learn.smktelkom-mlg.sch.id/coworking');
      }
      return url;
    }

    // Path relatif /coworking/...
    if (url.startsWith('/coworking/')) {
      final domainOnly = base.endsWith('/coworking')
          ? base.substring(0, base.length - '/coworking'.length)
          : base;
      return '$domainOnly$url';
    }

    // Path /uploads/... atau uploads/...
    if (url.startsWith('/uploads/')) return '$base$url';
    if (url.startsWith('uploads/')) return '$base/$url';

    // Hanya nama file
    final filename = url.split(RegExp(r'[/\\]')).last;
    if (filename.contains('.')) return '$base/uploads/$defaultFolder/$filename';

    return '$base${url.startsWith('/') ? url : '/$url'}';
  }
}
