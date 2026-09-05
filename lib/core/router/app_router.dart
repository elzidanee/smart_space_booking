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
        pageBuilder: (context, state) {
          final role = state.uri.queryParameters['role'];
          return _buildSmoothPage(
            state: state,
            child: LoginScreen(initialRole: role),
          );
        },
      ),
      GoRoute(
        path: '/register-member',
        pageBuilder: (context, state) => _buildSmoothPage(
          state: state,
          child: const RegisterMemberScreen(),
        ),
      ),
      GoRoute(
        path: '/register-admin',
        pageBuilder: (context, state) => _buildSmoothPage(
          state: state,
          child: const RegisterAdminScreen(),
        ),
      ),

      // Member Shell Routes
      GoRoute(
        path: '/member',
        pageBuilder: (context, state) => _buildSmoothPage(
          state: state,
          child: const MemberShellScreen(),
        ),
      ),

      // Space Detail & Booking Route
      GoRoute(
        path: '/spaces/:id',
        pageBuilder: (context, state) {
          // QA-019: Jangan fallback ke ID 1 — jika ID tidak valid tampilkan error state.
          final idStr = state.pathParameters['id'];
          final id = int.tryParse(idStr ?? '');
          if (id == null || id <= 0) {
            return _buildSmoothPage(
              state: state,
              child: Scaffold(
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
              ),
            );
          }
          return _buildSmoothPage(
            state: state,
            child: SpaceDetailBookingScreen(spaceId: id),
          );
        },
      ),

      // Member Reservation History Route (Layar M6)
      GoRoute(
        path: '/reservations/history',
        pageBuilder: (context, state) => _buildSmoothPage(
          state: state,
          child: const ReservationsHistoryScreen(),
        ),
      ),

      // Member E-Ticket Detail Route (Layar M7)
      GoRoute(
        path: '/reservations/ticket/:id',
        pageBuilder: (context, state) {
          final idStr = state.pathParameters['id'];
          final id = int.tryParse(idStr ?? '');
          return _buildSmoothPage(
            state: state,
            child: ETicketScreen(reservationId: id),
          );
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
        pageBuilder: (context, state) => _buildSmoothPage(
          state: state,
          child: const AdminShellScreen(),
        ),
      ),
    ],
  );
});

/// Transisi halaman mulus (silky smooth transition) perpaduan micro-slide dan fade
CustomTransitionPage<void> _buildSmoothPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedIn = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final curvedOut = CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.06, 0.0),
          end: Offset.zero,
        ).animate(curvedIn),
        child: FadeTransition(
          opacity: curvedIn,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-0.03, 0.0),
            ).animate(curvedOut),
            child: child,
          ),
        ),
      );
    },
  );
}

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
