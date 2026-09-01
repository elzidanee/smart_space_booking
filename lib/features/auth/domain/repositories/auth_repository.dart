import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exception_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/auth_models.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final storage = ref.watch(secureStorageServiceProvider);
  return AuthRepositoryImpl(remoteDataSource, storage);
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
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _storage;

  AuthRepositoryImpl(this._remoteDataSource, this._storage);

  @override
  Future<UserSession?> getCurrentSession() async {
    try {
      final token = await _storage.readAccessToken();
      final role = await _storage.readUserRole();

      if (token == null || token.isEmpty || role == null || role.isEmpty) {
        return null;
      }

      final userDataStr = await _storage.readUserData();
      UserModel? user;
      if (userDataStr != null && userDataStr.isNotEmpty) {
        try {
          user = UserModel.fromJsonString(userDataStr);
        } catch (_) {}
      }

      return UserSession(token: token, role: role, user: user);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserSession> login(String username, String password) async {
    try {
      final session = await _remoteDataSource.login(username, password);
      await _storage.saveAccessToken(session.token);
      await _storage.saveUserRole(session.role);

      if (session.user != null) {
        await _storage.saveUserData(session.user!.toJsonString());
      }

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
          photoFilename = await _remoteDataSource.uploadMemberPhoto(photoFile);
        } catch (e) {
          // Tetap lanjutkan registrasi jika upload gagal atau rethrow
          throw ValidationFailure('Gagal mengunggah foto profil: ${e.toString()}');
        }
      }

      final finalRequest = RegisterMemberRequest(
        nama: request.nama,
        instansi: request.instansi,
        telepon: request.telepon,
        alamat: request.alamat,
        username: request.username,
        password: request.password,
        foto: photoFilename ?? request.foto,
      );

      final session = await _remoteDataSource.registerMember(finalRequest);
      await _storage.saveAccessToken(session.token);
      await _storage.saveUserRole(session.role);

      if (session.user != null) {
        await _storage.saveUserData(session.user!.toJsonString());
      }

      return session;
    } catch (e) {
      if (e is Failure) rethrow;
      throw ExceptionMapper.map(e);
    }
  }

  @override
  Future<UserSession> registerAdmin(RegisterAdminRequest request) async {
    try {
      final session = await _remoteDataSource.registerAdmin(request);
      await _storage.saveAccessToken(session.token);
      await _storage.saveUserRole(session.role);

      if (session.user != null) {
        await _storage.saveUserData(session.user!.toJsonString());
      }

      return session;
    } catch (e) {
      throw ExceptionMapper.map(e);
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final profile = await _remoteDataSource.getProfile();
      await _storage.saveUserData(profile.toJsonString());
      return profile;
    } catch (e) {
      throw ExceptionMapper.map(e);
    }
  }

  @override
  Future<void> logout() async {
    await _storage.clearSession();
  }
}
