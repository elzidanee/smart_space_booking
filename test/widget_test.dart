import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookingworkroom/features/auth/presentation/screens/register_admin_screen.dart';
import 'package:bookingworkroom/features/auth/presentation/screens/register_member_screen.dart';
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

    expect(find.text('Daftar Akun'), findsOneWidget);
    expect(find.text('Nama Lengkap'), findsOneWidget);
    expect(find.text('No. Telepon'), findsOneWidget);
    expect(find.text('Alamat'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Konfirmasi Password'), findsOneWidget);

    // Scroll down to reveal submit button
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -1200));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Daftar Akun Member'), findsOneWidget);
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

    expect(find.text('Daftar Pengelola Space'), findsOneWidget);
    expect(find.text('Nama Coworking Space'), findsOneWidget);
    expect(find.text('Nama Pemilik / Penanggung Jawab'), findsOneWidget);

    // Scroll down to reveal submit button
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -1200));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Daftarkan Lokasi Space'), findsOneWidget);
  });
}
