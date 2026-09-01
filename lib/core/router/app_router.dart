import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin/presentation/screens/admin_shell_screen.dart';
import '../../features/auth/presentation/providers/auth_controller.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_admin_screen.dart';
import '../../features/auth/presentation/screens/register_member_screen.dart';
import '../../features/member/presentation/screens/member_shell_screen.dart';

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
    ref.listen(authControllerProvider, (previous, next) => notifyListeners());
  }
}
