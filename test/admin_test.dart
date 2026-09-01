import 'package:bookingworkroom/features/admin/data/models/admin_models.dart';
import 'package:bookingworkroom/features/admin/presentation/screens/admin_master_data_screen.dart';
import 'package:bookingworkroom/features/admin/presentation/screens/admin_monthly_report_screen.dart';
import 'package:bookingworkroom/features/admin/presentation/screens/admin_profile_screen.dart';
import 'package:bookingworkroom/features/admin/presentation/screens/admin_reservation_detail_screen.dart';
import 'package:bookingworkroom/features/admin/presentation/screens/admin_reservations_screen.dart';
import 'package:bookingworkroom/features/admin/presentation/screens/admin_shell_screen.dart';
import 'package:bookingworkroom/features/admin/presentation/widgets/admin_stat_card.dart';
import 'package:bookingworkroom/features/spaces/data/models/space_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget buildTestApp(Widget home) {
  return ProviderScope(
    child: MaterialApp(
      home: home,
      navigatorObservers: [],
    ),
  );
}

void main() {
  // ============================================================
  // 1. AdminShellScreen: renders 4 Navigation Destinations
  // ============================================================
  testWidgets('AdminShellScreen renders 4 navigation destinations', (tester) async {
    await tester.pumpWidget(buildTestApp(const AdminShellScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Reservasi'), findsOneWidget);
    expect(find.text('Master Data'), findsOneWidget);
    expect(find.text('Lokasi'), findsOneWidget);
  });

  // ============================================================
  // 2. AdminStatCard: renders title, value, icon
  // ============================================================
  testWidgets('AdminStatCard renders title and value', (tester) async {
    await tester.pumpWidget(buildTestApp(const Scaffold(
      body: AdminStatCard(
        title: 'Menunggu Konfirmasi',
        value: '3',
        subtitle: 'Perlu ditinjau',
        icon: Icons.hourglass_top,
        iconColor: Colors.orange,
      ),
    )));
    await tester.pump();

    expect(find.textContaining('MENUNGGU'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Perlu ditinjau'), findsOneWidget);
  });

  // ============================================================
  // 3. AdminReservationsScreen: renders filter chips
  // ============================================================
  testWidgets('AdminReservationsScreen renders status filter chips', (tester) async {
    await tester.pumpWidget(buildTestApp(const AdminReservationsScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Menunggu'), findsOneWidget);
    expect(find.text('Disetujui'), findsOneWidget);
    expect(find.text('Aktif'), findsOneWidget);
  });

  // ============================================================
  // 4. AdminReservationDetailScreen: renders all sections
  // ============================================================
  testWidgets('AdminReservationDetailScreen renders booking detail and action buttons', (tester) async {
    const mockReservation = ReservationModel(
      id: 201,
      kodeBooking: '#BK-20260901-001',
      spaceId: 1,
      namaSpace: 'Flexi Desk 01',
      tipeSpace: 'personal_desk',
      fotoSpace: null,
      tanggal: '2026-09-01',
      jamMulai: '09:00',
      jamSelesai: '12:00',
      durasi: 3,
      subtotal: 60000,
      potonganDiskon: 0,
      totalBayar: 60000,
      status: 'belum_dikonfirm',
      namaMember: 'Ahmad Fauzi',
      teleponMember: '081234567890',
    );

    await tester.pumpWidget(buildTestApp(
      const AdminReservationDetailScreen(reservation: mockReservation),
    ));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Detail Reservasi Tamu'), findsOneWidget);
    expect(find.text('#BK-20260901-001'), findsOneWidget);
    expect(find.text('Flexi Desk 01'), findsOneWidget);
    expect(find.text('Ahmad Fauzi'), findsOneWidget);
    // Action button for belum_dikonfirm
    expect(find.text('Setujui Reservasi'), findsOneWidget);
  });

  // ============================================================
  // 5. AdminReservationDetailScreen – aktif status shows Check-out
  // ============================================================
  testWidgets('AdminReservationDetailScreen aktif shows checkout button', (tester) async {
    const mockActive = ReservationModel(
      id: 202,
      kodeBooking: '#BK-202',
      spaceId: 1,
      namaSpace: 'Meeting Room Alpha',
      tanggal: '2026-09-01',
      jamMulai: '10:00',
      jamSelesai: '13:00',
      durasi: 3,
      subtotal: 300000,
      totalBayar: 270000,
      status: 'aktif',
      namaMember: 'Siti',
    );

    await tester.pumpWidget(buildTestApp(
      const AdminReservationDetailScreen(reservation: mockActive),
    ));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('Check-out'), findsOneWidget);
  });

  // ============================================================
  // 6. AdminMasterDataScreen: renders tab bar
  // ============================================================
  testWidgets('AdminMasterDataScreen renders 3 tab labels', (tester) async {
    await tester.pumpWidget(buildTestApp(const AdminMasterDataScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Space / Ruang'), findsOneWidget);
    expect(find.text('Data Member'), findsOneWidget);
    expect(find.text('Kode Promo'), findsOneWidget);
  });

  // ============================================================
  // 7. AdminSpacesScreen: rendered inside master tab
  // ============================================================
  testWidgets('AdminSpacesScreen renders search bar and FAB', (tester) async {
    await tester.pumpWidget(buildTestApp(const AdminMasterDataScreen(initialTabIndex: 0)));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Tambah Space'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  // ============================================================
  // 8. AdminMembersScreen: rendered in Master tab 1
  // ============================================================
  testWidgets('AdminMembersScreen renders search bar and FAB', (tester) async {
    await tester.pumpWidget(buildTestApp(const AdminMasterDataScreen(initialTabIndex: 1)));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Tambah Member'), findsOneWidget);
  });

  // ============================================================
  // 9. AdminDiscountsScreen: rendered in Master tab 2
  // ============================================================
  testWidgets('AdminDiscountsScreen renders promo list and FAB', (tester) async {
    await tester.pumpWidget(buildTestApp(const AdminMasterDataScreen(initialTabIndex: 2)));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Tambah Promo'), findsOneWidget);
  });

  // ============================================================
  // 10. AdminMonthlyReportScreen: renders month selector and heading
  // ============================================================
  testWidgets('AdminMonthlyReportScreen renders month selector', (tester) async {
    await tester.pumpWidget(buildTestApp(const AdminMonthlyReportScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Laporan Finansial Bulanan'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  // ============================================================
  // 11. AdminProfileScreen: renders Profil & Lokasi header
  // ============================================================
  testWidgets('AdminProfileScreen renders app bar and logout button', (tester) async {
    await tester.pumpWidget(buildTestApp(const AdminProfileScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Profil & Lokasi Coworking'), findsOneWidget);
    expect(find.textContaining('Keluar dari Akun'), findsOneWidget);
  });

  // ============================================================
  // 12. AdminDiscountModel: isExpired returns correct value
  // ============================================================
  test('AdminDiscountModel.isExpired returns true for past date', () {
    const expired = AdminDiscountModel(
      id: 1,
      kode: 'TEST',
      persentase: 10,
      tanggalMulai: '2025-01-01',
      tanggalAkhir: '2025-03-31',
      status: 'kedaluwarsa',
    );
    expect(expired.isExpired, isTrue);
  });

  test('AdminDiscountModel.isExpired returns false for future date', () {
    const active = AdminDiscountModel(
      id: 2,
      kode: 'FUTURE',
      persentase: 20,
      tanggalMulai: '2026-01-01',
      tanggalAkhir: '2099-12-31',
      status: 'aktif',
    );
    expect(active.isExpired, isFalse);
  });

  // ============================================================
  // 13. AdminMonthlyReportModel: fromJson parses correctly
  // ============================================================
  test('AdminMonthlyReportModel.fromJson parses report data correctly', () {
    final json = {
      'bulan': 9,
      'tahun': 2026,
      'pendapatan_kotor': 5000000,
      'potongan_diskon': 400000,
      'pendapatan_bersih': 4600000,
      'total_transaksi': 20,
      'total_jam_terpakai': 48,
      'per_tipe_space': [
        {
          'tipe': 'personal_desk',
          'nama_tipe': 'Personal Desk',
          'total_booking': 10,
          'total_jam': 20,
          'total_pendapatan': 1500000,
          'persentase': 32.6,
        },
        {
          'tipe': 'meeting_room',
          'nama_tipe': 'Meeting Room',
          'total_booking': 8,
          'total_jam': 18,
          'total_pendapatan': 2000000,
          'persentase': 43.5,
        },
        {
          'tipe': 'private_office',
          'nama_tipe': 'Private Office',
          'total_booking': 2,
          'total_jam': 10,
          'total_pendapatan': 1100000,
          'persentase': 23.9,
        },
      ],
    };

    final report = AdminMonthlyReportModel.fromJson(json);
    expect(report.bulan, 9);
    expect(report.tahun, 2026);
    expect(report.pendapatanKotor, 5000000);
    expect(report.pendapatanBersih, 4600000);
    expect(report.totalTransaksi, 20);
    expect(report.perTipeSpace.length, 3);
    expect(report.perTipeSpace.first.tipe, 'personal_desk');
    expect(report.perTipeSpace.first.persentase, closeTo(32.6, 0.1));
  });

  // ============================================================
  // 14. ReservationModel.copyWith mutates status correctly
  // ============================================================
  test('ReservationModel.copyWith changes status immutably', () {
    const original = ReservationModel(
      id: 1,
      kodeBooking: '#BK-001',
      spaceId: 1,
      tanggal: '2026-09-01',
      jamMulai: '09:00',
      jamSelesai: '12:00',
      durasi: 3,
      subtotal: 60000,
      totalBayar: 60000,
      status: 'belum_dikonfirm',
    );

    final confirmed = original.copyWith(status: 'disetujui');
    expect(confirmed.status, 'disetujui');
    expect(original.status, 'belum_dikonfirm'); // Immutable
    expect(confirmed.kodeBooking, '#BK-001');    // Other fields preserved
  });

  // ============================================================
  // 15. AdminProfileModel.fromJson parses correctly
  // ============================================================
  test('AdminProfileModel.fromJson parses profile data correctly', () {
    final json = {
      'id': 1,
      'nama_space': 'Smart Coworking Malang',
      'nama_pemilik': 'Budi Santoso',
      'telepon': '081234567890',
      'alamat': 'Jl. Danau Ranau No. 1, Malang',
      'deskripsi_fasilitas': 'WiFi kenceng, coffee shop, AC',
    };

    final profile = AdminProfileModel.fromJson(json);
    expect(profile.namaSpace, 'Smart Coworking Malang');
    expect(profile.namaPemilik, 'Budi Santoso');
    expect(profile.telepon, '081234567890');
  });

  // ============================================================
  // 16. AdminMemberModel.fromJson handles total_reservasi parsing
  // ============================================================
  test('AdminMemberModel.fromJson parses member data correctly', () {
    final json = {
      'id': 5,
      'nama': 'Zidane Pratama',
      'instansi': 'SMK Telkom Malang',
      'telepon': '085123456789',
      'alamat': 'Jl. Danau Toba No. 5, Malang',
      'username': 'zidane_p',
      'total_reservasi': 7,
      'created_at': '2026-06-01',
    };

    final member = AdminMemberModel.fromJson(json);
    expect(member.nama, 'Zidane Pratama');
    expect(member.username, 'zidane_p');
    expect(member.totalReservasi, 7);
    expect(member.instansi, 'SMK Telkom Malang');
  });
}
