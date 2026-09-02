import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/auth_models.dart';
import '../../domain/repositories/auth_repository.dart';

final authControllerProvider =
    AsyncNotifierProvider<AuthController, UserSession?>(() {
  return AuthController();
});

/// Controller State Sesi Autentikasi sesuai PRD Bagian II §4.
class AuthController extends AsyncNotifier<UserSession?> {
  @override
  Future<UserSession?> build() async {
    final repository = ref.read(authRepositoryProvider);
    return await repository.getCurrentSession();
  }

  /// Eksekusi login
  Future<bool> login(String username, String password) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      return await repository.login(username, password);
    });

    state = result;
    return !result.hasError;
  }

  /// Eksekusi pendaftaran member
  Future<bool> registerMember(RegisterMemberRequest request, {File? photoFile}) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      return await repository.registerMember(request, photoFile: photoFile);
    });

    state = result;
    return !result.hasError;
  }

  /// Eksekusi pendaftaran admin pengelola
  Future<bool> registerAdmin(RegisterAdminRequest request) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      return await repository.registerAdmin(request);
    });

    state = result;
    return !result.hasError;
  }

  /// Logout eksplisit
  Future<void> logout() async {
    state = const AsyncValue.loading();
    final repository = ref.read(authRepositoryProvider);
    await repository.logout();
    state = const AsyncValue.data(null);
  }

  /// Dipanggil otomatis oleh HTTP interceptor saat menerima 401 Unauthorized (QA-003)
  void forceLogout() {
    state = const AsyncValue.data(null);
  }
}
