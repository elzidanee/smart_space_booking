import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService(const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  ));
});

/// Layanan penyimpanan kredensial terenkripsi (Keystore Android) sesuai PRD Bagian II §6 & §10.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  static const String _keyBaseUrl = 'base_url';
  static const String _keyAppKey = 'app_key';
  static const String _keyAccessToken = 'access_token';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserData = 'user_data';

  // In-memory cache untuk performa latensi tinggi (menghindari overhead IPC/KeyStore di setiap request)
  String? _cachedBaseUrl;
  String? _cachedAppKey;
  String? _cachedAccessToken;
  String? _cachedUserRole;
  String? _cachedUserData;

  // --- Base URL Config ---
  Future<void> saveBaseUrl(String url) async {
    _cachedBaseUrl = url;
    await _storage.write(key: _keyBaseUrl, value: url);
  }

  Future<String?> readBaseUrl() async {
    if (_cachedBaseUrl != null) return _cachedBaseUrl;
    _cachedBaseUrl = await _storage.read(key: _keyBaseUrl);
    return _cachedBaseUrl;
  }

  Future<void> deleteBaseUrl() async {
    _cachedBaseUrl = null;
    await _storage.delete(key: _keyBaseUrl);
  }

  // --- App Maker Key ---
  Future<void> saveAppKey(String appKey) async {
    _cachedAppKey = appKey;
    await _storage.write(key: _keyAppKey, value: appKey);
  }

  Future<String?> readAppKey() async {
    if (_cachedAppKey != null) return _cachedAppKey;
    _cachedAppKey = await _storage.read(key: _keyAppKey);
    return _cachedAppKey;
  }

  Future<void> deleteAppKey() async {
    _cachedAppKey = null;
    await _storage.delete(key: _keyAppKey);
  }

  // --- User Access Token (JWT) ---
  Future<void> saveAccessToken(String token) async {
    _cachedAccessToken = token;
    await _storage.write(key: _keyAccessToken, value: token);
  }

  Future<String?> readAccessToken() async {
    if (_cachedAccessToken != null) return _cachedAccessToken;
    _cachedAccessToken = await _storage.read(key: _keyAccessToken);
    return _cachedAccessToken;
  }

  Future<void> deleteAccessToken() async {
    _cachedAccessToken = null;
    await _storage.delete(key: _keyAccessToken);
  }

  // --- User Role ('member' / 'admin_space') ---
  Future<void> saveUserRole(String role) async {
    _cachedUserRole = role;
    await _storage.write(key: _keyUserRole, value: role);
  }

  Future<String?> readUserRole() async {
    if (_cachedUserRole != null) return _cachedUserRole;
    _cachedUserRole = await _storage.read(key: _keyUserRole);
    return _cachedUserRole;
  }

  // --- User Data JSON (Cache Profil Ringkas) ---
  Future<void> saveUserData(String userDataJson) async {
    _cachedUserData = userDataJson;
    await _storage.write(key: _keyUserData, value: userDataJson);
  }

  Future<String?> readUserData() async {
    if (_cachedUserData != null) return _cachedUserData;
    _cachedUserData = await _storage.read(key: _keyUserData);
    return _cachedUserData;
  }

  // --- Session Management ---
  /// Hapus sesi login pengguna (access_token, role, userData), tetap mempertahankan app_key
  Future<void> clearSession() async {
    _cachedAccessToken = null;
    _cachedUserRole = null;
    _cachedUserData = null;
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyUserRole);
    await _storage.delete(key: _keyUserData);
  }

  /// Hapus seluruh data (termasuk app_key untuk reset total)
  Future<void> clearAll() async {
    _cachedBaseUrl = null;
    _cachedAppKey = null;
    _cachedAccessToken = null;
    _cachedUserRole = null;
    _cachedUserData = null;
    await _storage.deleteAll();
  }
}
