import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/auth_illustration.dart';
import '../../data/models/auth_models.dart';
import '../providers/auth_controller.dart';

/// Layar Registrasi Member sesuai Stitch Screen 03 (d467563055354facbf8cd7e6b526236e).
class RegisterMemberScreen extends ConsumerStatefulWidget {
  const RegisterMemberScreen({super.key});

  @override
  ConsumerState<RegisterMemberScreen> createState() => _RegisterMemberScreenState();
}

class _RegisterMemberScreenState extends ConsumerState<RegisterMemberScreen> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _instansiController = TextEditingController();
  final _teleponController = TextEditingController();
  final _alamatController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  File? _selectedPhoto;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _instansiController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _selectedPhoto = File(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusBottomSheet),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg16,
            vertical: AppSpacing.xl24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pilih Foto Profil', style: AppTypography.h2),
              const SizedBox(height: AppSpacing.md12),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                title: const Text('Ambil dari Kamera'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus menyetujui Syarat & Ketentuan terlebih dahulu.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final request = RegisterMemberRequest(
      namaMember: _namaController.text.trim(),
      instansi: _instansiController.text.trim(),
      telp: _teleponController.text.trim(),
      alamat: _alamatController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    final success = await ref
        .read(authControllerProvider.notifier)
        .registerMember(request, photoFile: _selectedPhoto);

    if (mounted) {
      setState(() => _isLoading = false);
    }

    if (!mounted) return;

    if (!success) {
      final error = ref.read(authControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error?.toString() ?? 'Pendaftaran gagal. Periksa data Anda.',
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
          // ── Banner Header Bergradien ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 210,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            title: const Text(
              'Daftar Akun Member',
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
                      Color(0xFFD9621A),
                      Color(0xFFC2540E),
                      Color(0xFF9E3F06),
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
                                'Bergabung\nbersama kami',
                                style: AppTypography.h1.copyWith(
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Pesan coworking space kapan saja,\ndari mana saja.',
                                style: AppTypography.caption.copyWith(
                                  color: Colors.white.withValues(alpha: 0.82),
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],
                          ),
                        ),
                        // Ilustrasi kecil di sudut kanan
                        const CoworkingIllustration(
                          width: 130,
                          height: 100,
                          isAdmin: false,
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
                      // --- Photo Upload Circle (Stitch 03) ---
                      Center(
                        child: GestureDetector(
                          onTap: _showImageSourceDialog,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.surface50,
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 1.5,
                                    strokeAlign: BorderSide.strokeAlignInside,
                                  ),
                                  image: _selectedPhoto != null
                                      ? DecorationImage(
                                          image: FileImage(_selectedPhoto!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: _selectedPhoto == null
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.add_a_photo_outlined,
                                            size: 28,
                                            color: AppColors.primary,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Foto',
                                            style: AppTypography.captionMedium.copyWith(
                                              color: AppColors.primary,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      )
                                    : null,
                              ),
                              if (_selectedPhoto != null)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl24),

                      // Nama Lengkap
                      Text('Nama Lengkap', style: AppTypography.bodyMedium),
                      const SizedBox(height: AppSpacing.xs4),
                      TextFormField(
                        controller: _namaController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'Masukkan nama lengkap',
                          prefixIcon: Icon(Icons.badge_outlined, size: 20),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Nama lengkap wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md12),

                      // Instansi (Opsional)
                      Text('Instansi (Opsional)', style: AppTypography.bodyMedium),
                      const SizedBox(height: AppSpacing.xs4),
                      TextFormField(
                        controller: _instansiController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'Contoh: Universitas / Perusahaan',
                          prefixIcon: Icon(Icons.apartment_outlined, size: 20),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md12),

                      // No. Telepon
                      Text('No. Telepon', style: AppTypography.bodyMedium),
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
                          if (val.length < 9) {
                            return 'Nomor telepon minimal 9 digit';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md12),

                      // Alamat
                      Text('Alamat', style: AppTypography.bodyMedium),
                      const SizedBox(height: AppSpacing.xs4),
                      TextFormField(
                        controller: _alamatController,
                        maxLines: 2,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'Masukkan alamat lengkap',
                          prefixIcon: Icon(Icons.home_outlined, size: 20),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Alamat wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md12),

                      // Username
                      Text('Username', style: AppTypography.bodyMedium),
                      const SizedBox(height: AppSpacing.xs4),
                      TextFormField(
                        controller: _usernameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'Pilih username unik',
                          prefixIcon: Icon(Icons.person_outline, size: 20),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Username wajib diisi';
                          }
                          if (val.contains(' ')) {
                            return 'Username tidak boleh mengandung spasi';
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
                      const SizedBox(height: AppSpacing.lg16),

                      // Terms & Conditions Checkbox
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _agreeTerms,
                              activeColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: (val) {
                                setState(() => _agreeTerms = val ?? false);
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm8),
                          Expanded(
                            child: Text(
                              'Saya menyetujui Syarat & Ketentuan reservasi coworking space yang berlaku.',
                              style: AppTypography.caption,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text('Daftar Akun Member'),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md12),

                      // Link to Login
                      Center(
                        child: TextButton(
                          onPressed: () => context.pop(),
                          child: RichText(
                            text: TextSpan(
                              text: 'Sudah punya akun? ',
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
