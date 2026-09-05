import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import 'admin_dashboard_screen.dart';
import 'admin_master_data_screen.dart';
import 'admin_profile_screen.dart';
import 'admin_reservations_screen.dart';

/// Shell Navigasi Admin 4-tab sesuai PRD Bagian III §3 (Information Architecture).
class AdminShellScreen extends ConsumerStatefulWidget {
  const AdminShellScreen({super.key});

  @override
  ConsumerState<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends ConsumerState<AdminShellScreen> {
  int _currentIndex = 0;

  void _onNavigateToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      // Tab 1: Dashboard (Reservasi Hari Ini + Ringkasan KPI)
      AdminDashboardScreen(
        onNavigateToReservations: () => _onNavigateToTab(1),
        onNavigateToMasterData: () => _onNavigateToTab(2),
      ),
      // Tab 2: Reservasi (Semua Reservasi + Filter A8 & A7)
      const AdminReservationsScreen(),
      // Tab 3: Master Data (Space A5, Member A4, Diskon A6)
      const AdminMasterDataScreen(),
      // Tab 4: Akun & Lokasi (Profil Lokasi A3)
      const AdminProfileScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.018),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: KeyedSubtree(
            key: ValueKey<int>(_currentIndex),
            child: pages[_currentIndex.clamp(0, pages.length - 1)],
          ),
        ),
      ),
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
}
