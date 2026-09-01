import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/auth_illustration.dart';
import '../../data/models/auth_models.dart';
import '../providers/auth_controller.dart';

/// Layar Registrasi Admin / Pengelola Space sesuai PRD Layar A1.
class RegisterAdminScreen extends ConsumerStatefulWidget {
  const RegisterAdminScreen({super.key});

  @override
  ConsumerState<RegisterAdminScreen> createState() => _RegisterAdminScreenState();
}

class _RegisterAdminScreenState extends ConsumerState<RegisterAdminScreen> {
  final _formKey = GlobalKey<FormState>();

  final _namaSpaceController = TextEditingController();
  final _namaPemilikController = TextEditingController();
  final _teleponController = TextEditingController();
  final _alamatController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaSpaceController.dispose();
    _namaPemilikController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final request = RegisterAdminRequest(
      namaSpace: _namaSpaceController.text.trim(),
      namaPemilik: _namaPemilikController.text.trim(),
      telepon: _teleponController.text.trim(),
      alamat: _alamatController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    final success = await ref
        .read(authControllerProvider.notifier)
        .registerAdmin(request);

    if (mounted) {
      setState(() => _isLoading = false);
    }

    if (!mounted) return;

    if (!success) {
      final error = ref.read(authControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error?.toString() ?? 'Pendaftaran pengelola gagal. Periksa kembali data Anda.',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.surface50,
      body: CustomScrollView(
        slivers: [
          // ── Banner Header Bergradien (Deep Teal) ───────────────────────────
          SliverAppBar(
            expandedHeight: 210,
            pinned: true,
            backgroundColor: AppColors.secondary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            title: const Text(
              'Daftar Pengelola Space',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A7A72),
                      Color(0xFF0E5C56),
                      Color(0xFF093D39),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 48, 16, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Daftarkan\nSpace Anda',
                                style: AppTypography.h1.copyWith(
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Kelola reservasi workstation &\ncoworking secara profesional.',
                                style: AppTypography.caption.copyWith(
                                  color: Colors.white.withValues(alpha: 0.82),
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],
                          ),
                        ),
                        // Ilustrasi gedung di sudut kanan
                        const BuildingIllustration(
                          width: 130,
                          height: 100,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Konten Form ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg16,
                vertical: AppSpacing.md12,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Container(
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
                      // Nama Coworking Space
                      Text('Nama Coworking Space', style: AppTypography.bodyMedium),
                      const SizedBox(height: AppSpacing.xs4),
                      TextFormField(
                        controller: _namaSpaceController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'Contoh: Ruang Kerja Bersama Malang',
                          prefixIcon: Icon(Icons.business_outlined, size: 20),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Nama coworking space wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md12),

                      // Nama Pemilik
                      Text('Nama Pemilik / Penanggung Jawab', style: AppTypography.bodyMedium),
                      const SizedBox(height: AppSpacing.xs4),
                      TextFormField(
                        controller: _namaPemilikController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'Masukkan nama lengkap pemilik',
                          prefixIcon: Icon(Icons.badge_outlined, size: 20),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Nama pemilik wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md12),

                      // No. Telepon
                      Text('No. Telepon / WhatsApp', style: AppTypography.bodyMedium),
                      const SizedBox(height: AppSpacing.xs4),
                      TextFormField(
                        controller: _teleponController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'Contoh: 08123456789',
                          prefixIcon: Icon(Icons.phone_outlined, size: 20),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Nomor telepon wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md12),

                      // Alamat Lokasi
                      Text('Alamat Lengkap Coworking', style: AppTypography.bodyMedium),
                      const SizedBox(height: AppSpacing.xs4),
                      TextFormField(
                        controller: _alamatController,
                        maxLines: 2,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'Masukkan alamat fisik lokasi coworking',
                          prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Alamat fisik wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md12),

                      // Username Admin
                      Text('Username Akun Admin', style: AppTypography.bodyMedium),
                      const SizedBox(height: AppSpacing.xs4),
                      TextFormField(
                        controller: _usernameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'Pilih username untuk login admin',
                          prefixIcon: Icon(Icons.person_outline, size: 20),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Username admin wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md12),

                      // Password
                      Text('Password', style: AppTypography.bodyMedium),
                      const SizedBox(height: AppSpacing.xs4),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'Minimal 6 karakter',
                          prefixIcon: const Icon(Icons.lock_outline, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Password wajib diisi';
                          }
                          if (val.length < 6) {
                            return 'Password minimal 6 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md12),

                      // Konfirmasi Password
                      Text('Konfirmasi Password', style: AppTypography.bodyMedium),
                      const SizedBox(height: AppSpacing.xs4),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: 'Ulangi password',
                          prefixIcon: const Icon(Icons.lock_reset_outlined, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() =>
                                  _obscureConfirmPassword = !_obscureConfirmPassword);
                            },
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Konfirmasi password wajib diisi';
                          }
                          if (val != _passwordController.text) {
                            return 'Konfirmasi password tidak cocok';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
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
                              : const Text('Daftarkan Lokasi Space'),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md12),

                      // Link to Login
                      Center(
                        child: TextButton(
                          onPressed: () => context.pop(),
                          child: RichText(
                            text: TextSpan(
                              text: 'Sudah punya akun pengelola? ',
                              style: AppTypography.caption,
                              children: [
                                TextSpan(
                                  text: 'Masuk di sini',
                                  style: AppTypography.captionMedium.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
