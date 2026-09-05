import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin/presentation/screens/admin_shell_screen.dart';
import '../../features/auth/presentation/providers/auth_controller.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_admin_screen.dart';
import '../../features/auth/presentation/screens/register_member_screen.dart';
import '../../features/member/presentation/screens/member_shell_screen.dart';
import '../../features/reservations/presentation/screens/e_ticket_screen.dart';
import '../../features/reservations/presentation/screens/reservations_history_screen.dart';
import '../../features/spaces/presentation/screens/space_detail_booking_screen.dart';
import '../widgets/app_illustrations.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: false,
    refreshListenable: _ListenableAuth(ref),
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);

      // 1. Jika masih loading memeriksa sesi, jangan redirect
      if (authState.isLoading) return null;

      final session = authState.value;
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register-member' ||
          state.matchedLocation == '/register-admin';

      // 2. Belum login
      if (session == null) {
        return isLoggingIn ? null : '/login';
      }

      // 3. Sudah login sebagai Member
      if (session.isMember) {
        if (isLoggingIn || state.matchedLocation.startsWith('/admin')) {
          return '/member';
        }
        return null;
      }

      // 4. Sudah login sebagai Admin Pengelola
      if (session.isAdmin) {
        if (isLoggingIn || state.matchedLocation.startsWith('/member')) {
          return '/admin';
        }
        return null;
      }

      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'];
          return LoginScreen(initialRole: role);
        },
      ),
      GoRoute(
        path: '/register-member',
        builder: (context, state) => const RegisterMemberScreen(),
      ),
      GoRoute(
        path: '/register-admin',
        builder: (context, state) => const RegisterAdminScreen(),
      ),

      // Member Shell Routes
      GoRoute(
        path: '/member',
        builder: (context, state) => const MemberShellScreen(),
      ),

      // Space Detail & Booking Route
      GoRoute(
        path: '/spaces/:id',
        builder: (context, state) {
          // QA-019: Jangan fallback ke ID 1 — jika ID tidak valid tampilkan error state.
          final idStr = state.pathParameters['id'];
          final id = int.tryParse(idStr ?? '');
          if (id == null || id <= 0) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Detail Space'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/member');
                    }
                  },
                ),
              ),
              body: AppEmptyState(
                illustration: const NetworkErrorIllustration(size: 160),
                title: 'Space Tidak Ditemukan',
                message: 'ID ruangan "$idStr" tidak valid atau format URL salah.',
                actionLabel: 'Kembali ke Katalog',
                onAction: () => context.go('/member'),
              ),
            );
          }
          return SpaceDetailBookingScreen(spaceId: id);
        },
      ),

      // Member Reservation History Route (Layar M6)
      GoRoute(
        path: '/reservations/history',
        builder: (context, state) => const ReservationsHistoryScreen(),
      ),

      // Member E-Ticket Detail Route (Layar M7)
      GoRoute(
        path: '/reservations/ticket/:id',
        builder: (context, state) {
          final idStr = state.pathParameters['id'];
          final id = int.tryParse(idStr ?? '');
          return ETicketScreen(reservationId: id);
        },
      ),

      // Shortcut Routes to Member Tabs
      GoRoute(
        path: '/reservations',
        redirect: (context, state) {
          ref.read(memberNavIndexProvider.notifier).state = 1;
          return '/member';
        },
      ),
      GoRoute(
        path: '/ticket',
        redirect: (context, state) {
          ref.read(memberNavIndexProvider.notifier).state = 2;
          return '/member';
        },
      ),

      // Admin Shell Routes
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminShellScreen(),
      ),
    ],
  );
});

/// Listenable bridge untuk memicu evaluasi redirect GoRouter saat AuthController berubah
class _ListenableAuth extends ChangeNotifier {
  _ListenableAuth(Ref ref) {
    ref.listen(authControllerProvider, (previous, next) {
      if (previous != next) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      }
    });
  }
}
