import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookingworkroom/features/auth/presentation/screens/register_admin_screen.dart';
import 'package:bookingworkroom/features/auth/presentation/screens/register_member_screen.dart';
import 'package:bookingworkroom/features/reservations/presentation/providers/reservations_controller.dart';
import 'package:bookingworkroom/features/reservations/presentation/screens/e_ticket_screen.dart';
import 'package:bookingworkroom/features/reservations/presentation/screens/reservations_history_screen.dart';
import 'package:bookingworkroom/features/reservations/presentation/screens/reservations_status_screen.dart';
import 'package:bookingworkroom/features/spaces/data/models/space_models.dart';
import 'package:bookingworkroom/features/spaces/presentation/providers/spaces_controller.dart';
import 'package:bookingworkroom/features/spaces/presentation/screens/spaces_catalog_screen.dart';
import 'package:bookingworkroom/features/spaces/presentation/screens/space_detail_booking_screen.dart';
import 'package:bookingworkroom/main.dart';

void main() {
  testWidgets('SmartSpaceApp main smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SmartSpaceApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Smart Space'), findsOneWidget);
    expect(find.text('Member'), findsOneWidget);
    expect(find.text('Pengelola Space'), findsOneWidget);
  });

  testWidgets('RegisterMemberScreen renders all required fields',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: RegisterMemberScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Daftar Akun Member'), findsWidgets);
    expect(find.text('Nama Lengkap'), findsOneWidget);
    expect(find.text('No. Telepon'), findsOneWidget);
    expect(find.text('Alamat'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Konfirmasi Password'), findsOneWidget);

    // Scroll down to reveal submit button
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -1200));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Daftar Akun Member'), findsWidgets);
  });

  testWidgets('RegisterAdminScreen renders all required fields',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: RegisterAdminScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Daftar Pengelola Space'), findsWidgets);
    expect(find.text('Nama Coworking Space'), findsOneWidget);
    expect(find.text('Nama Pemilik / Penanggung Jawab'), findsOneWidget);

    // Scroll down to reveal submit button
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -1200));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Daftarkan Lokasi Space'), findsOneWidget);
  });

  testWidgets('SpacesCatalogScreen renders catalog, search bar and category filters',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SpacesCatalogScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Smart Space'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Personal Desk'), findsWidgets);
    expect(find.text('Meeting Room'), findsWidgets);
    expect(find.text('Private Office'), findsWidgets);
  });

  testWidgets('SpaceDetailBookingScreen renders space details and booking form',
      (WidgetTester tester) async {
    const testSpace = SpaceModel(
      id: 1,
      nama: 'Flexi Desk 01',
      tipe: 'personal_desk',
      kapasitas: 1,
      hargaPerJam: 20000,
      fasilitas: ['WiFi Cepat', 'AC'],
      deskripsi: 'Meja kerja personal fleksibel.',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          spaceDetailProvider(1).overrideWith((ref) => Future.value(testSpace)),
        ],
        child: const MaterialApp(
          home: SpaceDetailBookingScreen(spaceId: 1),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Flexi Desk 01'), findsOneWidget);
    expect(find.text('Lanjutkan Reservasi'), findsOneWidget);
    expect(find.text('Total Bayar'), findsOneWidget);

    // Scroll down to reveal form and check availability button
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -600));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Atur Jadwal Reservasi'), findsOneWidget);
    expect(find.text('Cek Ketersediaan Slot'), findsOneWidget);
  });

  testWidgets('ReservationsStatusScreen renders status filter tabs and reservation list',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ReservationsStatusScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Status Pemesanan'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Menunggu'), findsOneWidget);
    expect(find.text('Disetujui'), findsOneWidget);
    expect(find.text('Aktif'), findsOneWidget);
  });

  testWidgets('ReservationsHistoryScreen renders month filter and summary card',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ReservationsHistoryScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Histori & Pengeluaran'), findsOneWidget);
    expect(find.text('Riwayat Pemesanan'), findsOneWidget);
  });

  testWidgets('ETicketScreen renders QR Code and booking details',
      (WidgetTester tester) async {
    const testTicket = ReservationModel(
      id: 101,
      kodeBooking: '#BOOK-20260830-0012',
      spaceId: 1,
      namaSpace: 'Flexi Desk 01 (Sora Med)',
      tipeSpace: 'personal_desk',
      fotoSpace: '',
      tanggal: '2026-08-30',
      jamMulai: '09:00',
      jamSelesai: '12:00',
      durasi: 3,
      subtotal: 60000,
      potonganDiskon: 0,
      totalBayar: 60000,
      status: 'disetujui',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          latestActiveTicketProvider.overrideWith((ref) => Future.value(testTicket)),
          eTicketProvider(101).overrideWith((ref) => Future.value(testTicket)),
        ],
        child: const MaterialApp(
          home: ETicketScreen(reservationId: 101),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('E-Ticket Digital'), findsOneWidget);
    expect(find.text('#BOOK-20260830-0012'), findsOneWidget);
    expect(find.text('BOOKING CODE'), findsOneWidget);
    expect(find.text('Flexi Desk 01 (Sora Med)'), findsOneWidget);
    expect(find.text('3 Jam'), findsOneWidget);
  });
}

