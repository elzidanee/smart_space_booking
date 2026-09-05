import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../reservations/presentation/screens/e_ticket_screen.dart';
import '../../../reservations/presentation/screens/reservations_status_screen.dart';
import '../../../spaces/presentation/screens/spaces_catalog_screen.dart';
import 'member_profile_screen.dart';

/// Provider state index tab navigasi member (0: Katalog, 1: Reservasi, 2: Tiket, 3: Akun)
final memberNavIndexProvider = StateProvider<int>((ref) => 0);

/// Shell Navigasi Member 4-tab sesuai PRD Bagian III §3 (Information Architecture).
class MemberShellScreen extends ConsumerWidget {
  const MemberShellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(memberNavIndexProvider);

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: currentIndex,
          children: const [
            SpacesCatalogScreen(),
            ReservationsStatusScreen(),
            ETicketScreen(),
            MemberProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            ref.read(memberNavIndexProvider.notifier).state = index;
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
}
