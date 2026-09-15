import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/auth_models.dart';
import '../../domain/repositories/auth_repository.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, UserSession?>(() {
  return AuthController();
});

// Controller untuk ngatur status login/logout user di seluruh aplikasi.
// Tipe datanya UserSession? (berisi token, role 'member'/'admin_space', dan data profil).
class AuthController extends AsyncNotifier<UserSession?> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  // Fungsi build() ini dipanggil otomatis pertama kali aplikasi dibuka:
  // Ngecek ke secure storage apakah user pernah login sebelumnya (auto-login).
  @override
  Future<UserSession?> build() => _repo.getCurrentSession();

  // Proses login:
  Future<bool> login(String username, String password) async {
    // 1. Set state jadi loading biar tombol di layar muncul animasi spinner
    state = const AsyncValue.loading();

    // 2. AsyncValue.guard ini ngebungkus try-catch secara otomatis:
    // Kalau API sukses, hasil UserSession langsung masuk ke state.
    // Kalau API error (misal password salah), error-nya otomatis ditangkap tanpa bikin aplikasi crash.
    final result = await AsyncValue.guard(() => _repo.login(username, password));
    state = result;

    // Balikin boolean (true = sukses, false = gagal) biar gampang dicek di UI layar login
    return !result.hasError;
  }

  // Registrasi Member baru (bisa sekalian upload file foto KTP/profil)
  Future<bool> registerMember(RegisterMemberRequest request, {File? photoFile}) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(
      () => _repo.registerMember(request, photoFile: photoFile),
    );
    state = result;
    return !result.hasError;
  }

  // Registrasi Admin pengelola baru
  Future<bool> registerAdmin(RegisterAdminRequest request) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() => _repo.registerAdmin(request));
    state = result;
    return !result.hasError;
  }

  // Logout normal atas kemauan user
  Future<void> logout() async {
    state = const AsyncValue.loading();
    await _repo.logout(); // Hapus token di storage
    state = const AsyncValue.data(null); // Kosongkan session -> router otomatis lempar ke login
  }

  // Logout paksa: dipanggil otomatis oleh ApiHeaderInterceptor kalau dapet kode 401 (token expired)
  void forceLogout() => state = const AsyncValue.data(null);
}
