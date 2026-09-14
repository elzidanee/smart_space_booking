import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exception_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/auth_models.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(secureStorageServiceProvider),
  );
});

abstract class AuthRepository {
  Future<UserSession?> getCurrentSession();
  Future<UserSession> login(String username, String password);
  Future<UserSession> registerMember(RegisterMemberRequest request, {File? photoFile});
  Future<UserSession> registerAdmin(RegisterAdminRequest request);
  Future<UserModel> getProfile();
  Future<void> logout();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final SecureStorageService _storage;

  AuthRepositoryImpl(this._remote, this._storage);

  @override
  Future<UserSession?> getCurrentSession() async {
    try {
      final token = await _storage.readAccessToken();
      final role  = await _storage.readUserRole();
      if (token == null || token.isEmpty || role == null || role.isEmpty) return null;

      UserModel? user;
      final cached = await _storage.readUserData();
      if (cached != null && cached.isNotEmpty) {
        try { user = UserModel.fromJsonString(cached); } catch (_) {}
      }

      return UserSession(token: token, role: role, user: user);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserSession> login(String username, String password) async {
    try {
      final session = await _remote.login(username.trim(), password.trim());
      await _saveSession(session);
      return session;
    } catch (e) {
      throw ExceptionMapper.map(e);
    }
  }

  @override
  Future<UserSession> registerMember(RegisterMemberRequest request, {File? photoFile}) async {
    try {
      String? photoFilename;
      if (photoFile != null) {
        try {
          photoFilename = await _remote.uploadMemberPhoto(photoFile);
        } catch (e) {
          throw ValidationFailure('Gagal mengunggah foto profil: $e');
        }
      }

      final finalReq = RegisterMemberRequest(
        namaMember: request.namaMember,
        instansi: request.instansi,
        telp: request.telp,
        alamat: request.alamat,
        username: request.username,
        password: request.password,
        foto: photoFilename ?? request.foto,
      );

      final session = await _remote.registerMember(finalReq);
      await _saveSession(session);
      return session;
    } catch (e) {
      if (e is Failure) rethrow;
      throw ExceptionMapper.map(e);
    }
  }

  @override
  Future<UserSession> registerAdmin(RegisterAdminRequest request) async {
    try {
      final session = await _remote.registerAdmin(request);
      await _saveSession(session);
      return session;
    } catch (e) {
      throw ExceptionMapper.map(e);
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final profile = await _remote.getProfile();
      await _storage.saveUserData(profile.toJsonString());
      return profile;
    } catch (e) {
      final cached = await _storage.readUserData();
      if (cached != null && cached.isNotEmpty) {
        try { return UserModel.fromJsonString(cached); } catch (_) {}
      }
      throw ExceptionMapper.map(e);
    }
  }

  @override
  Future<void> logout() => _storage.clearSession();

  // Simpan token + role + data user ke storage setelah login/register
  Future<void> _saveSession(UserSession session) async {
    await _storage.saveAccessToken(session.token);
    await _storage.saveUserRole(session.role);
    if (session.user != null) {
      await _storage.saveUserData(session.user!.toJsonString());
    }
  }
}
