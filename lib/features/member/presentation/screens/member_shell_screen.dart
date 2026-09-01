import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/providers/auth_controller.dart';

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
      // Tab 1: Beranda (Katalog Space)
      _buildPlaceholderTab(
        title: 'Katalog Space (Beranda)',
        subtitle: 'Jelajahi dan sewa ruangan atau meja kerja',
        icon: Icons.storefront_outlined,
        user: user,
      ),
      // Tab 2: Reservasi (Status & Histori)
      _buildPlaceholderTab(
        title: 'Status & Histori Reservasi',
        subtitle: 'Pantau status dan riwayat pemesanan Anda',
        icon: Icons.calendar_today_outlined,
        user: user,
      ),
      // Tab 3: Tiket (E-Ticket QR)
      _buildPlaceholderTab(
        title: 'E-Ticket Aktif',
        subtitle: 'Tunjukkan QR Code reservasi ke admin di lokasi',
        icon: Icons.qr_code_2_rounded,
        user: user,
      ),
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
            Icon(icon, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(title, style: AppTypography.h2, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle, style: AppTypography.caption, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            if (user != null)
              Text('Login sebagai: ${user.nama} (${user.username})', style: AppTypography.captionMedium),
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
