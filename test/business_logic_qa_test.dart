import 'dart:io';
import 'package:bookingworkroom/core/storage/secure_storage_service.dart';
import 'package:bookingworkroom/features/admin/data/models/admin_models.dart';
import 'package:bookingworkroom/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:bookingworkroom/features/auth/data/models/auth_models.dart';
import 'package:bookingworkroom/features/auth/domain/repositories/auth_repository.dart';
import 'package:bookingworkroom/features/auth/presentation/providers/auth_controller.dart';
import 'package:bookingworkroom/features/spaces/data/models/space_models.dart';
import 'package:bookingworkroom/features/spaces/domain/repositories/spaces_repository.dart';
import 'package:bookingworkroom/features/spaces/presentation/providers/spaces_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Mock Classes for Business Logic Testing ─────────────────────────────────

class FakeSecureStorage implements SecureStorageService {
  String? accessToken;
  String? role;
  String? userData;
  String? appKey = 'test-maker-key';

  @override
  Future<void> saveAccessToken(String token) async => accessToken = token;

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<void> deleteAccessToken() async => accessToken = null;

  @override
  Future<void> saveUserRole(String userRole) async => role = userRole;

  @override
  Future<String?> readUserRole() async => role;

  @override
  Future<void> saveUserData(String data) async => userData = data;

  @override
  Future<String?> readUserData() async => userData;

  @override
  Future<void> clearSession() async {
    accessToken = null;
    role = null;
    userData = null;
  }

  @override
  Future<void> saveAppKey(String appKey) async => this.appKey = appKey;

  @override
  Future<String?> readAppKey() async => appKey;

  @override
  Future<void> deleteAppKey() async => appKey = null;

  @override
  Future<void> clearAll() async {
    accessToken = null;
    role = null;
    userData = null;
    appKey = null;
  }
}

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  bool shouldFail = false;

  @override
  Future<UserSession> login(String username, String password) async {
    if (shouldFail || password == 'wrongpass') {
      throw Exception('Username atau password salah.');
    }
    return UserSession(
      token: 'real_jwt_token_from_server',
      role: username == 'admin_user' ? 'admin_space' : 'member',
      user: UserModel(
        id: 1,
        username: username,
        nama: 'Test User',
        role: username == 'admin_user' ? 'admin_space' : 'member',
      ),
    );
  }

  @override
  Future<UserSession> registerMember(RegisterMemberRequest request) async {
    return UserSession(
      token: 'token_reg',
      role: 'member',
      user: UserModel(id: 2, username: request.username, nama: request.namaMember, role: 'member'),
    );
  }

  @override
  Future<UserSession> registerAdmin(RegisterAdminRequest request) async {
    return UserSession(
      token: 'token_admin',
      role: 'admin_space',
      user: UserModel(id: 3, username: request.username, nama: request.namaPemilik, role: 'admin_space'),
    );
  }

  @override
  Future<UserModel> getProfile() async {
    return const UserModel(id: 1, username: 'user1', nama: 'User Satu', role: 'member');
  }

  @override
  Future<String> uploadMemberPhoto(File file) async => 'member-photo-server.jpg';
}

class FakeSpacesRepository implements SpacesRepository {
  bool isSlotAvailable = true;
  bool createCalled = false;

  @override
  Future<AvailabilityCheckResult> checkAvailability({
    required int spaceId,
    required String tanggal,
    required String jamMulai,
    required int durasi,
  }) async {
    return AvailabilityCheckResult(
      isAvailable: isSlotAvailable,
      message: isSlotAvailable ? 'Tersedia' : 'Slot ruangan sudah penuh.',
      tanggal: tanggal,
      jamMulai: jamMulai,
      durasi: durasi,
    );
  }

  @override
  Future<ReservationModel> createReservation(CreateReservationRequest request) async {
    createCalled = true;
    return ReservationModel(
      id: 999,
      kodeBooking: 'BK-TEST-123',
      spaceId: request.spaceId,
      namaSpace: 'Test Desk',
      tanggal: request.tanggal,
      jamMulai: request.jamMulai,
      jamSelesai: '12:00',
      durasi: request.durasi,
      subtotal: 100000,
      potonganDiskon: 0,
      totalBayar: 100000,
      status: 'belum_dikonfirm',
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<List<SpaceModel>> getSpaces({String? query, String? tipe}) async => [];

  @override
  Future<List<Map<String, dynamic>>> getSpaceTypes() async => [];

  @override
  Future<SpaceModel> getSpaceById(int id) async => const SpaceModel(
        id: 1,
        nama: 'Test',
        tipe: 'personal_desk',
        hargaPerJam: 20000,
        kapasitas: 1,
        fasilitas: [],
        deskripsi: 'Test',
      );

  @override
  Future<List<Map<String, dynamic>>> getActiveDiscounts() async => [];

  @override
  Future<PromoCheckResult> checkPromo(String kodePromo, {int subtotal = 0}) async =>
      PromoCheckResult(id: 1, kode: kodePromo, persentase: 10, potongan: 10000, pesan: 'OK');
}

void main() {
  group('QA-002: Authentication Login Without Bypass', () {
    test('Login calls API and stores real token in SecureStorage', () async {
      final fakeStorage = FakeSecureStorage();
      final fakeRemote = FakeAuthRemoteDataSource();
      final authRepo = AuthRepositoryImpl(fakeRemote, fakeStorage);

      final session = await authRepo.login('myuser', 'correctpassword');

      expect(session.token, equals('real_jwt_token_from_server'));
      expect(fakeStorage.accessToken, equals('real_jwt_token_from_server'));
      expect(fakeStorage.role, equals('member'));
    });

    test('Login with wrong credentials throws Exception', () async {
      final fakeStorage = FakeSecureStorage();
      final fakeRemote = FakeAuthRemoteDataSource();
      final authRepo = AuthRepositoryImpl(fakeRemote, fakeStorage);

      expect(
        () => authRepo.login('myuser', 'wrongpass'),
        throwsA(anything),
      );
    });
  });

  group('QA-003: 401 Session Expiration and Force Logout', () {
    test('forceLogout resets AuthController state to null', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            AuthRepositoryImpl(FakeAuthRemoteDataSource(), FakeSecureStorage()),
          ),
        ],
      );

      final controller = container.read(authControllerProvider.notifier);
      controller.forceLogout();

      final state = container.read(authControllerProvider);
      expect(state.value, isNull);
    });
  });

  group('QA-004: Availability Re-Check Before Reservation Submit', () {
    test('Blocks reservation if re-check reveals slot is unavailable', () async {
      final fakeRepo = FakeSpacesRepository()..isSlotAvailable = false;
      final controller = BookingController(fakeRepo);

      final result = await controller.submitBooking(1);

      expect(result, isNull);
      expect(fakeRepo.createCalled, isFalse);
      expect(controller.state.errorMessage, contains('penuh'));
    });

    test('Allows reservation if re-check confirms slot is available', () async {
      final fakeRepo = FakeSpacesRepository()..isSlotAvailable = true;
      final controller = BookingController(fakeRepo);

      final result = await controller.submitBooking(1);

      expect(result, isNotNull);
      expect(fakeRepo.createCalled, isTrue);
      expect(result!.kodeBooking, equals('BK-TEST-123'));
    });
  });

  group('QA-005 & QA-006: Admin Member Password Payload', () {
    test('AdminMemberCreateRequest includes password in JSON', () {
      const request = AdminMemberCreateRequest(
        nama: 'Member Baru',
        instansi: 'SMK Telkom',
        telepon: '08123456789',
        alamat: 'Malang',
        username: 'member_baru',
        password: 'password123',
        foto: 'foto-123.jpg',
      );

      final json = request.toJson();
      expect(json['nama_member'], equals('Member Baru'));
      expect(json['username'], equals('member_baru'));
      expect(json['password'], equals('password123'));
      expect(json['telp'], equals('08123456789'));
      expect(json['foto'], equals('foto-123.jpg'));
    });

    test('AdminMemberModel.toJson(password: ...) includes password when provided', () {
      const member = AdminMemberModel(
        id: 5,
        nama: 'Ahmad Fauzi',
        instansi: 'SMK Telkom',
        telepon: '08123456789',
        alamat: 'Malang',
        username: 'ahmad_fauzi',
        createdAt: '2026-09-01',
      );

      final jsonWithPass = member.toJson(password: 'newsecretpass');
      expect(jsonWithPass['password'], equals('newsecretpass'));

      final jsonWithoutPass = member.toJson();
      expect(jsonWithoutPass.containsKey('password'), isFalse);
    });
  });

  group('QA-010: AdminProfileModel.toJson Payload', () {
    test('AdminProfileModel serializes correct API keys', () {
      const profile = AdminProfileModel(
        id: 1,
        namaSpace: 'Coworking Hub Malang',
        namaPemilik: 'Budi Santoso',
        telepon: '081298765432',
        alamat: 'Jl. Danau Ranau',
        deskripsiFasilitas: 'WiFi, AC, Free Coffee',
        foto: 'profile-hub.jpg',
      );

      final json = profile.toJson();
      expect(json['nama_coworking'], equals('Coworking Hub Malang'));
      expect(json['nama_pemilik'], equals('Budi Santoso'));
      expect(json['telp'], equals('081298765432'));
      expect(json['alamat'], equals('Jl. Danau Ranau'));
      expect(json['foto'], equals('profile-hub.jpg'));
    });
  });
}
