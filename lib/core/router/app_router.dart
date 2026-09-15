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
import '../../features/onboarding/presentation/screens/onboarding_flow_screen.dart';
import '../widgets/app_illustrations.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding',
    debugLogDiagnostics: false,
    // refreshListenable ini kayak 'antena'. Kalau status login atau onboarding berubah,
    // dia bakal otomatis nyuruh GoRouter ngecek ulang fungsi redirect di bawah ini.
    refreshListenable: _ListenableAuth(ref),
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final onboardingDone = ref.read(onboardingCompleteProvider);

      // 1. Cek status onboarding dulu:
      // Kalau user baru pertama kali buka aplikasi (belum beres onboarding), tahan di /onboarding.
      if (!onboardingDone) {
        if (state.matchedLocation == '/onboarding') return null;
        return '/onboarding';
      }

      // Kalau user udah beres onboarding tapi masih nyasar di /onboarding, lempar langsung ke /login.
      if (state.matchedLocation == '/onboarding') return '/login';

      // 2. Pas aplikasi baru kebuka dan lagi proses baca token dari secure storage (loading),
      // biarin dulu jangan dipaksa pindah halaman biar layarnya gak kedip/flicker.
      if (authState.isLoading) return null;

      final session = authState.value;
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register-member' ||
          state.matchedLocation == '/register-admin';

      // 3. Kalau belum ada sesi (user belum login atau udah logout):
      // Kunci halaman utama, cuma boleh buka halaman login atau daftar.
      if (session == null) {
        return isLoggingIn ? null : '/login';
      }

      // 4. Role Guard - Kalau login sebagai Member biasa:
      // Jangan kasih akses ke route /admin, balikin ke dashboard member (/member).
      // Dan kalau lagi di halaman login, langsung lempar masuk ke /member.
      if (session.isMember) {
        if (isLoggingIn || state.matchedLocation.startsWith('/admin')) {
          return '/member';
        }
        return null;
      }

      // 5. Role Guard - Kalau login sebagai Admin Pengelola:
      // Jangan kasih masuk ke route /member, arahkan ke dashboard admin (/admin).
      if (session.isAdmin) {
        if (isLoggingIn || state.matchedLocation.startsWith('/member')) {
          return '/admin';
        }
        return null;
      }

      return null;
    },
    routes: [
      // Onboarding Flow (Splash + 3 Screens)
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => _buildSmoothPage(
          state: state,
          child: const OnboardingFlowScreen(),
        ),
      ),

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

// Helper animasi transisi antar halaman:
// Gabungan efek geser tipis (micro-slide 6%) sama fading (transparan ke jelas).
// Sengaja dibuat durasi 260ms pake kurva easeOutCubic biar feel-nya luwes & mulus kayak aplikasi modern, gak kaku.
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

// Jembatan (bridge) penghubung Riverpod ke GoRouter:
// GoRouter itu gak kenal langsung sama State Riverpod. Jadi kita bikin ChangeNotifier ini buat
// 'dengerin' (ref.listen) perubahan status login (AuthController) dan status onboarding.
// Begitu user berhasil login / logout, notifyListeners() bakal dipanggil biar GoRouter
// langsung ngejalanin ulang logika 'redirect' di atas tanpa harus reload aplikasi.
class _ListenableAuth extends ChangeNotifier {
  _ListenableAuth(Ref ref) {
    ref.listen(authControllerProvider, (previous, next) {
      if (previous != next) {
        // Pakai addPostFrameCallback biar event notifikasi dikirim setelah Flutter selesai ngerender frame ini,
        // jadi gak bentrok atau muncul error 'setState() called during build'.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      }
    });
    ref.listen(onboardingCompleteProvider, (previous, next) {
      if (previous != next) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      }
    });
  }
}
