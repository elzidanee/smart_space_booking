import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/providers/auth_controller.dart';

/// Shell Navigasi Admin 4-tab sesuai PRD Bagian III §3 (Information Architecture).
class AdminShellScreen extends ConsumerStatefulWidget {
  const AdminShellScreen({super.key});

  @override
  ConsumerState<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends ConsumerState<AdminShellScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.value?.user;

    final pages = [
      // Tab 1: Dashboard (Reservasi Hari Ini + Ringkasan)
      _buildPlaceholderTab(
        title: 'Dashboard Pengelola',
        subtitle: 'Reservasi hari ini dan ringkasan operasional',
        icon: Icons.dashboard_outlined,
        user: user,
      ),
      // Tab 2: Reservasi (Semua Reservasi + Filter)
      _buildPlaceholderTab(
        title: 'Kelola Reservasi',
        subtitle: 'Check-in, Check-out, dan Filter Reservasi',
        icon: Icons.assignment_outlined,
        user: user,
      ),
      // Tab 3: Master Data (Space & Diskon)
      _buildPlaceholderTab(
        title: 'Master Data Space & Promo',
        subtitle: 'Kelola data ruangan, meja, member, dan kode diskon',
        icon: Icons.meeting_room_outlined,
        user: user,
      ),
      // Tab 4: Akun & Lokasi (Profil Space)
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
          indicatorColor: AppColors.secondaryContainer,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard, color: AppColors.secondary),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              selectedIcon: Icon(Icons.assignment, color: AppColors.secondary),
              label: 'Reservasi',
            ),
            NavigationDestination(
              icon: Icon(Icons.meeting_room_outlined),
              selectedIcon: Icon(Icons.meeting_room, color: AppColors.secondary),
              label: 'Master Data',
            ),
            NavigationDestination(
              icon: Icon(Icons.store_outlined),
              selectedIcon: Icon(Icons.store, color: AppColors.secondary),
              label: 'Lokasi',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderTab({
    required String title,
    required String subtitle,
    required IconData icon,
    dynamic user,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.secondary),
            const SizedBox(height: 16),
            Text(title, style: AppTypography.h2, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle, style: AppTypography.caption, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            if (user != null)
              Text('Pengelola: ${user.namaSpace ?? user.nama} (@${user.username})',
                  style: AppTypography.captionMedium),
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
              backgroundColor: AppColors.secondaryContainer,
              child: Icon(Icons.store, size: 48, color: AppColors.secondary),
            ),
            const SizedBox(height: 16),
            Text(user?.namaSpace ?? user?.nama ?? 'Admin Pengelola', style: AppTypography.h2),
            Text('Owner: ${user?.nama ?? "-"} (@${user?.username ?? "-"})', style: AppTypography.caption),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => ref.read(authControllerProvider.notifier).logout(),
              icon: const Icon(Icons.logout),
              label: const Text('Keluar dari Akun Admin'),
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
