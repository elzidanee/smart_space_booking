import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_alert.dart';
import '../../../../core/widgets/auth_illustration.dart';
import '../../../../core/widgets/server_config_bottom_sheet.dart';
import '../providers/auth_controller.dart';

/// Layar Login dengan Role Toggle sesuai Stitch Screen 01 (dbf3107b63324e40804cecf2554c0c4b).
class LoginScreen extends ConsumerStatefulWidget {
  final String? initialRole;

  const LoginScreen({super.key, this.initialRole});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late bool _isMemberRole;
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isMemberRole = widget.initialRole?.toLowerCase() != 'admin';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    final success = await ref
        .read(authControllerProvider.notifier)
        .login(username, password);

    if (mounted) {
      setState(() => _isLoading = false);
    }

    if (!mounted) return;

    if (!success) {
      final error = ref.read(authControllerProvider).error;
      final errorMsg = error?.toString() ?? 'Username atau password salah. Silakan periksa kembali.';
      AppAlert.showToast(
        context: context,
        type: AppAlertType.danger,
        title: 'Gagal Masuk',
        message: errorMsg,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Warna aksen dinamis menyesuaikan role terpilih (Ember untuk Member, Deep Teal untuk Pengelola)
    final activeColor = _isMemberRole ? AppColors.primary : AppColors.secondary;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Tombol Pengaturan Server & Key di Pojok Kanan Atas
            Positioned(
              top: 8,
              right: 12,
              child: IconButton(
                icon: const Icon(Icons.settings_ethernet, color: AppColors.ink600),
                tooltip: 'Pengaturan Server & Maker Key',
                onPressed: () => ServerConfigBottomSheet.show(context),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg16,
                  vertical: AppSpacing.xl24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                  // --- Ilustrasi Header ---
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.08),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: CoworkingIllustration(
                      key: ValueKey(_isMemberRole),
                      width: double.infinity,
                      height: 165,
                      isAdmin: !_isMemberRole,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg16),
                  Text(
                    'Smart Space',
                    style: AppTypography.h1.copyWith(
                      color: activeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs4),
                  Text(
                    _isMemberRole
                        ? 'Ruang kerja terbaik, satu ketuk dari sini'
                        : 'Portal pengelola space profesional',
                    style: AppTypography.caption,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl24),

                  // --- Role Toggle Pill (Stitch UI 01) ---
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFEEEC),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    ),
                    child: Row(
                      children: [
                        // Button Member
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (!_isMemberRole) {
                                setState(() => _isMemberRole = true);
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _isMemberRole
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusPill,
                                ),
                                boxShadow: _isMemberRole
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  'Member',
                                  style: AppTypography.captionMedium.copyWith(
                                    color: _isMemberRole
                                        ? Colors.white
                                        : AppColors.ink600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Button Pengelola
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (_isMemberRole) {
                                setState(() => _isMemberRole = false);
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !_isMemberRole
                                    ? AppColors.secondary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusPill,
                                ),
                                boxShadow: !_isMemberRole
                                    ? [
                                        BoxShadow(
                                          color: AppColors.secondary
                                              .withValues(alpha: 0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  'Pengelola Space',
                                  style: AppTypography.captionMedium.copyWith(
                                    color: !_isMemberRole
                                        ? Colors.white
                                        : AppColors.ink600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg16),

                  // --- Form Container Card ---
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl24),
                    decoration: BoxDecoration(
                      color: AppColors.surface0,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppSpacing.cardShadow,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Username Field
                          Text('Username', style: AppTypography.bodyMedium),
                          const SizedBox(height: AppSpacing.sm8),
                          TextFormField(
                            controller: _usernameController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              hintText: _isMemberRole
                                  ? 'Masukkan username member'
                                  : 'Masukkan username admin',
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: activeColor,
                                size: 20,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Username tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg16),

                          // Password Field
                          Text('Password', style: AppTypography.bodyMedium),
                          const SizedBox(height: AppSpacing.sm8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handleLogin(),
                            decoration: InputDecoration(
                              hintText: 'Masukkan password',
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: activeColor,
                                size: 20,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.ink600,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md12),

                          // Remember Me & Forgot Password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      activeColor: activeColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      onChanged: (val) {
                                        setState(() => _rememberMe = val ?? true);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs4),
                                  Text(
                                    'Ingat saya',
                                    style: AppTypography.caption,
                                  ),
                                ],
                              ),
                              Tooltip(
                                message:
                                    'Reset password hubungi administrator (sesuai spesifikasi soal).',
                                child: TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Fitur reset password tidak tersedia pada kontrak API ujian.',
                                        ),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    foregroundColor: activeColor,
                                  ),
                                  child: Text(
                                    'Lupa Password?',
                                    style: AppTypography.captionMedium.copyWith(
                                      color: activeColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xl24),

                          // Masuk Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: activeColor,
                                foregroundColor: Colors.white,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      'Masuk sebagai ${_isMemberRole ? "Member" : "Pengelola"}',
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg16),

                  // --- Footer Link ---
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Belum punya akun? ',
                        style: AppTypography.caption,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_isMemberRole) {
                            context.push('/register-member');
                          } else {
                            context.push('/register-admin');
                          }
                        },
                        child: Text(
                          _isMemberRole
                              ? 'Daftar Member di sini'
                              : 'Daftar Space di sini',
                          style: AppTypography.captionMedium.copyWith(
                            color: activeColor,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  ),
);
}
}

