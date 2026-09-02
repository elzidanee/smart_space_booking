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

  // --- Base URL Config ---
  Future<void> saveBaseUrl(String url) async {
    await _storage.write(key: _keyBaseUrl, value: url);
  }

  Future<String?> readBaseUrl() async {
    return await _storage.read(key: _keyBaseUrl);
  }

  Future<void> deleteBaseUrl() async {
    await _storage.delete(key: _keyBaseUrl);
  }

  // --- App Maker Key ---
  Future<void> saveAppKey(String appKey) async {
    await _storage.write(key: _keyAppKey, value: appKey);
  }

  Future<String?> readAppKey() async {
    return await _storage.read(key: _keyAppKey);
  }

  Future<void> deleteAppKey() async {
    await _storage.delete(key: _keyAppKey);
  }

  // --- User Access Token (JWT) ---
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
  }

  Future<String?> readAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  Future<void> deleteAccessToken() async {
    await _storage.delete(key: _keyAccessToken);
  }

  // --- User Role ('member' / 'admin_space') ---
  Future<void> saveUserRole(String role) async {
    await _storage.write(key: _keyUserRole, value: role);
  }

  Future<String?> readUserRole() async {
    return await _storage.read(key: _keyUserRole);
  }

  // --- User Data JSON (Cache Profil Ringkas) ---
  Future<void> saveUserData(String userDataJson) async {
    await _storage.write(key: _keyUserData, value: userDataJson);
  }

  Future<String?> readUserData() async {
    return await _storage.read(key: _keyUserData);
  }

  // --- Session Management ---
  /// Hapus sesi login pengguna (access_token, role, userData), tetap mempertahankan app_key
  Future<void> clearSession() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyUserRole);
    await _storage.delete(key: _keyUserData);
  }

  /// Hapus seluruh data (termasuk app_key untuk reset total)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
