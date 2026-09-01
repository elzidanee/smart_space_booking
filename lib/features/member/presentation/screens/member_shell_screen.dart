import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../reservations/presentation/screens/e_ticket_screen.dart';
import '../../../reservations/presentation/screens/reservations_status_screen.dart';
import '../../../spaces/presentation/screens/spaces_catalog_screen.dart';

/// Shell Navigasi Member 4-tab sesuai PRD Bagian III §3 (Information Architecture).
class MemberShellScreen extends ConsumerStatefulWidget {
  const MemberShellScreen({super.key});

  @override
  ConsumerState<MemberShellScreen> createState() => _MemberShellScreenState();
}

class _MemberShellScreenState extends ConsumerState<MemberShellScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.value?.user;

    final pages = [
      // Tab 1: Beranda (Katalog Space Stitch 05)
      const SpacesCatalogScreen(),
      // Tab 2: Reservasi (Status & Histori Stitch 07)
      const ReservationsStatusScreen(),
      // Tab 3: Tiket (E-Ticket QR Stitch 09)
      const ETicketScreen(),
      // Tab 4: Akun (Profil Member)
      _buildAccountTab(user),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_currentIndex]),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          backgroundColor: AppColors.surface0,
          indicatorColor: AppColors.primaryContainer,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront, color: AppColors.primary),
              label: 'Katalog',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              selectedIcon: Icon(Icons.calendar_today, color: AppColors.primary),
              label: 'Reservasi',
            ),
            NavigationDestination(
              icon: Icon(Icons.qr_code_2_rounded),
              selectedIcon: Icon(Icons.qr_code_2_rounded, color: AppColors.primary),
              label: 'Tiket',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: AppColors.primary),
              label: 'Akun',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTab(dynamic user) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primaryContainer,
              child: Icon(Icons.person, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(user?.nama ?? 'Member', style: AppTypography.h2),
            Text('@${user?.username ?? "user"}', style: AppTypography.caption),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => ref.read(authControllerProvider.notifier).logout(),
              icon: const Icon(Icons.logout),
              label: const Text('Keluar dari Akun'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
