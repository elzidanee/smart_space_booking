import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/auth_models.dart';
import '../../domain/repositories/auth_repository.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, UserSession?>(() {
  return AuthController();
});

class AuthController extends AsyncNotifier<UserSession?> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  Future<UserSession?> build() => _repo.getCurrentSession();

  Future<bool> login(String username, String password) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() => _repo.login(username, password));
    state = result;
    return !result.hasError;
  }

  Future<bool> registerMember(RegisterMemberRequest request, {File? photoFile}) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(
      () => _repo.registerMember(request, photoFile: photoFile),
    );
    state = result;
    return !result.hasError;
  }

  Future<bool> registerAdmin(RegisterAdminRequest request) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() => _repo.registerAdmin(request));
    state = result;
    return !result.hasError;
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await _repo.logout();
    state = const AsyncValue.data(null);
  }

  // Dipanggil otomatis oleh interceptor saat dapat 401
  void forceLogout() => state = const AsyncValue.data(null);
}
