import 'package:bookingworkroom/core/errors/failure.dart';
import 'package:bookingworkroom/core/utils/app_url_helper.dart';
import 'package:bookingworkroom/features/spaces/data/models/space_models.dart';
import 'package:bookingworkroom/features/spaces/presentation/providers/spaces_controller.dart';
import 'package:bookingworkroom/features/spaces/presentation/screens/space_detail_booking_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DETAIL SPACE QA REGRESSION TESTS', () {
    // DETAIL-09: valid response -> SpaceModel parsed successfully
    test('DETAIL-09: SpaceModel.fromJson parses standard backend response with int, double, and string types', () {
      final json = {
        'id': 5,
        'nama_space': 'Executive Meeting Suite',
        'tipe': 'meeting_room',
        'kapasitas': '12',
        'harga_per_jam': '150000.00',
        'fasilitas': ['WiFi Cepat', 'TV 65 Inch', 'Whiteboard'],
        'foto': '1788319712456.png',
        'deskripsi': 'Ruang pertemuan representatif untuk presentasi.',
        'status': 'tersedia',
      };

      final space = SpaceModel.fromJson(json);

      expect(space.id, equals(5));
      expect(space.nama, equals('Executive Meeting Suite'));
      expect(space.tipe, equals('meeting_room'));
      expect(space.tipeLabel, equals('Meeting Room'));
      expect(space.kapasitas, equals(12));
      expect(space.hargaPerJam, equals(150000));
      expect(space.fasilitas, contains('WiFi Cepat'));
      expect(space.foto, isNotNull);
      expect(space.foto, contains('1788319712456.png'));
    });

    // DETAIL-10: invalid / alternate response keys -> defensive fallback, no crash
    test('DETAIL-10: SpaceModel.fromJson handles null, comma string fasilitas, and missing keys without crash', () {
      final json = {
        'id': 'abc', // invalid id
        'nama': 'Mini Pod',
        'kapasitas': null,
        'harga': 25000.50,
        'fasilitas': 'WiFi, AC, Power Outlet', // comma separated string
        'foto': null,
        'status': null,
      };

      final space = SpaceModel.fromJson(json);

      expect(space.id, equals(0));
      expect(space.nama, equals('Mini Pod'));
      expect(space.kapasitas, equals(1));
      expect(space.hargaPerJam, equals(25001));
      expect(space.fasilitas.length, equals(3));
      expect(space.fasilitas, contains('WiFi'));
      expect(space.fasilitas, contains('AC'));
      expect(space.foto, isNull);
      expect(space.status, equals('tersedia'));
    });

    // Image URL Resolution Tests
    test('IMAGE-01: AppUrlHelper resolves filename to uploads/spaces URL', () {
      final resolved = AppUrlHelper.resolveImageUrl('space_101.jpg', defaultFolder: 'spaces');
      expect(resolved, isNotNull);
      expect(resolved, contains('/uploads/spaces/space_101.jpg'));
    });

    test('IMAGE-02: AppUrlHelper normalizes localhost URLs to active base domain', () {
      final resolved = AppUrlHelper.resolveImageUrl('http://localhost:3000/uploads/spaces/space_101.jpg');
      expect(resolved, isNotNull);
      expect(resolved, isNot(contains('localhost:3000')));
      expect(resolved, contains('/uploads/spaces/space_101.jpg'));
    });

    test('IMAGE-03: AppUrlHelper returns null for empty or whitespace rawUrl', () {
      expect(AppUrlHelper.resolveImageUrl(null), isNull);
      expect(AppUrlHelper.resolveImageUrl(''), isNull);
      expect(AppUrlHelper.resolveImageUrl('   '), isNull);
    });

    // DETAIL-01: Valid Space ID -> detail renders properly
    testWidgets('DETAIL-01: Valid Space ID renders space name, type, facilities in detail screen',
        (WidgetTester tester) async {
      const space = SpaceModel(
        id: 10,
        nama: 'Creative Focus Desk',
        tipe: 'personal_desk',
        kapasitas: 1,
        hargaPerJam: 30000,
        fasilitas: ['WiFi', 'AC', 'Coffee'],
        foto: null, // null to avoid HTTP in test env
        deskripsi: 'Deskripsi lengkap ruangan kerja personal.',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            spaceDetailProvider(10).overrideWith((ref) => Future.value(space)),
          ],
          child: const MaterialApp(
            home: SpaceDetailBookingScreen(spaceId: 10),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Creative Focus Desk'), findsOneWidget);
      expect(find.text('Personal Desk'), findsOneWidget);
      expect(find.text('Fasilitas Termasuk'), findsOneWidget);
      // Scroll down to reveal facilities
      await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -200));
      await tester.pump();
      expect(find.text('WiFi'), findsOneWidget);
      expect(find.text('AC'), findsOneWidget);
    });

    // DETAIL-07: foto is null -> renders placeholder, does not crash
    testWidgets('DETAIL-07: Space with null foto renders placeholder and does not crash',
        (WidgetTester tester) async {
      const spaceWithoutPhoto = SpaceModel(
        id: 11,
        nama: 'No Photo Desk',
        tipe: 'personal_desk',
        kapasitas: 1,
        hargaPerJam: 20000,
        foto: null,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            spaceDetailProvider(11).overrideWith((ref) => Future.value(spaceWithoutPhoto)),
          ],
          child: const MaterialApp(
            home: SpaceDetailBookingScreen(spaceId: 11),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('No Photo Desk'), findsOneWidget);
      expect(find.byIcon(Icons.meeting_room_rounded), findsWidgets);
    });

    // DETAIL-08: foto is invalid local path -> renders placeholder safely, does not crash
    testWidgets('DETAIL-08: Space with invalid local file path renders placeholder safely without crashing',
        (WidgetTester tester) async {
      const spaceWithInvalidPath = SpaceModel(
        id: 12,
        nama: 'Local Path Desk',
        tipe: 'personal_desk',
        kapasitas: 1,
        hargaPerJam: 25000,
        foto: 'C:\\non_existent_folder\\invalid_photo.jpg',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            spaceDetailProvider(12).overrideWith((ref) => Future.value(spaceWithInvalidPath)),
          ],
          child: const MaterialApp(
            home: SpaceDetailBookingScreen(spaceId: 12),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Local Path Desk'), findsOneWidget);
      expect(find.byIcon(Icons.meeting_room_rounded), findsWidgets);
    });

    // DETAIL-03: API 404 / NotFoundFailure -> shows clean error state and retry button
    testWidgets('DETAIL-03: API 404 NotFoundFailure renders controlled error state and retry button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            spaceDetailProvider(999).overrideWith(
              (ref) => Future.error(const NotFoundFailure('Ruangan dengan ID 999 tidak ditemukan.')),
            ),
          ],
          child: const MaterialApp(
            home: SpaceDetailBookingScreen(spaceId: 999),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Gagal Memuat Detail Space'), findsOneWidget);
      expect(find.text('Ruangan dengan ID 999 tidak ditemukan.'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    // DETAIL-05: Server 500 error -> shows controlled error state, does not crash
    testWidgets('DETAIL-05: ServerFailure (HTTP 500) renders error state without crashing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            spaceDetailProvider(500).overrideWith(
              (ref) => Future.error(const ServerFailure('Server sedang mengalami gangguan.')),
            ),
          ],
          child: const MaterialApp(
            home: SpaceDetailBookingScreen(spaceId: 500),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Gagal Memuat Detail Space'), findsOneWidget);
      expect(find.text('Server sedang mengalami gangguan.'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    // DETAIL-06: Network timeout -> shows network failure message and retry button
    testWidgets('DETAIL-06: NetworkFailure (Timeout) renders error state with retry option',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            spaceDetailProvider(100).overrideWith(
              (ref) => Future.error(const NetworkFailure('Koneksi terputus atau timeout.')),
            ),
          ],
          child: const MaterialApp(
            home: SpaceDetailBookingScreen(spaceId: 100),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Gagal Memuat Detail Space'), findsOneWidget);
      expect(find.text('Koneksi terputus atau timeout.'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    // PROMO-01: 50% discount parsing from varied formats
    test('PROMO-01: PromoCheckResult parses 50% discount correctly from number, decimal, and string', () {
      final json1 = {
        'id': 1,
        'nama_diskon': 'DISKON50',
        'persentase_diskon': 50,
      };
      final promo1 = PromoCheckResult.fromJson(json1, subtotal: 70000);
      expect(promo1.persentase, equals(50));
      expect(promo1.potongan, equals(35000));

      final json2 = {
        'data': {
          'id': 2,
          'kode_promo': 'HEMAT50',
          'persentase_diskon': '50.00',
        }
      };
      final promo2 = PromoCheckResult.fromJson(json2, subtotal: 100000);
      expect(promo2.persentase, equals(50));
      expect(promo2.potongan, equals(50000));
    });

    // RESERVATION-PRICE-01: ReservationModel calculates non-zero total when harga_per_jam is 70000
    test('RESERVATION-PRICE-01: ReservationModel computes subtotal 70000 and total 70000 from space object', () {
      final json = {
        'id': 101,
        'kode_booking': 'BOOK-101',
        'id_space': 1,
        'tanggal_reservasi': '2026-09-02T00:00:00.000Z',
        'jam_mulai': '09:00',
        'jam_selesai': '10:00',
        'durasi_jam': 1,
        'status': 'belum_dikonfirm',
        'space': {
          'id': 1,
          'nama_space': 'Coworking Desk Alpha',
          'harga_per_jam': 70000,
        },
      };

      final res = ReservationModel.fromJson(json);
      expect(res.tanggal, equals('2026-09-02'));
      expect(res.subtotal, equals(70000));
      expect(res.totalBayar, equals(70000));
    });
  });
}
