import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_alert.dart';
import '../../../../core/widgets/app_photo_picker_field.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/server_config_bottom_sheet.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../data/models/admin_models.dart';
import '../providers/admin_controller.dart';

class AdminProfileScreen extends ConsumerStatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  ConsumerState<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends ConsumerState<AdminProfileScreen> {
  String? _appKey;

  @override
  void initState() {
    super.initState();
    _loadAppKey();
  }

  Future<void> _loadAppKey() async {
    final storage = ref.read(secureStorageServiceProvider);
    final key = await storage.readAppKey();
    if (mounted) {
      setState(() => _appKey = key ?? 'ukkrpl_smartspace_2026_key');
    }
  }

  void _showEditProfileDialog(AdminProfileModel profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _EditProfileBottomSheet(
        profile: profile,
        onSave: (updated, photoFile) {
          ref.read(adminProfileControllerProvider.notifier).updateProfile(
                updated,
                photoFile: photoFile,
              );
          AppAlert.showToast(
            context: context,
            type: AppAlertType.success,
            title: 'Profil Diperbarui',
            message: 'Profil coworking space berhasil diperbarui.',
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(adminProfileControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final user = authState.value?.user;

    return Scaffold(
      backgroundColor: AppColors.surface50,
      appBar: AppBar(
        title: const Text('Profil & Lokasi Coworking'),
        backgroundColor: AppColors.surface0,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            profileAsync.when(
              loading: () => const Column(
                children: [
                  AppShimmer(child: ShimmerPlaceholder(height: 120, borderRadius: 16)),
                  SizedBox(height: 16),
                  AppShimmer(child: ShimmerPlaceholder(height: 200, borderRadius: 16)),
                ],
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
                      const SizedBox(height: 12),
                      Text('Gagal memuat profil', style: AppTypography.h2),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(adminProfileControllerProvider),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (profile) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Space Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface0,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(28, 25, 23, 0.04),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.secondaryContainer,
                          child: Icon(Icons.store, size: 36, color: AppColors.secondary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(profile.namaSpace, style: AppTypography.h2),
                              const SizedBox(height: 4),
                              Text(
                                'Penanggung Jawab: ${profile.namaPemilik}',
                                style: AppTypography.caption.copyWith(color: AppColors.ink600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Username: @${user?.username ?? "admin"}',
                                style: AppTypography.captionMedium.copyWith(color: AppColors.secondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Detail Info & Facility Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface0,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('IDENTITAS & FASILITAS', style: AppTypography.sectionLabel),
                            TextButton.icon(
                              onPressed: () => _showEditProfileDialog(profile),
                              icon: const Icon(Icons.edit, size: 16, color: AppColors.secondary),
                              label: const Text('Edit Profil', style: TextStyle(color: AppColors.secondary)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.phone_outlined, 'Nomor Kontak', profile.telepon),
                        const SizedBox(height: 10),
                        _buildInfoRow(Icons.location_on_outlined, 'Alamat Lokasi', profile.alamat),
                        const SizedBox(height: 10),
                        _buildInfoRow(Icons.info_outline, 'Deskripsi Fasilitas', profile.deskripsiFasilitas),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Developer / App Maker Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface0,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('INFORMASI APP MAKER (DEVELOPER)', style: AppTypography.sectionLabel),
                  const SizedBox(height: 10),
                  Text(
                    'Kunci Maker Multi-Tenancy (x-maker-key):',
                    style: AppTypography.caption.copyWith(color: AppColors.ink600),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _appKey ?? 'Memuat key...',
                            style: AppTypography.captionMedium.copyWith(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18, color: AppColors.secondary),
                          tooltip: 'Salin Key',
                          onPressed: () {
                            if (_appKey != null) {
                              Clipboard.setData(ClipboardData(text: _appKey!));
                              AppAlert.showToast(
                                context: context,
                                type: AppAlertType.success,
                                title: 'Key Disalin',
                                message: 'App Key berhasil disalin ke clipboard.',
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await ServerConfigBottomSheet.show(context);
                        _loadAppKey();
                      },
                      icon: const Icon(Icons.tune, size: 16),
                      label: const Text('Ubah Server URL & Maker Key'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.secondary,
                        side: const BorderSide(color: AppColors.secondary),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await AppAlert.showConfirmation(
                    context: context,
                    title: 'Keluar dari Akun Pengelola?',
                    message: 'Sesi pengelola akan diakhiri dan kamu harus masuk kembali dengan kredensial admin.',
                    confirmLabel: 'Ya, Keluar',
                    cancelLabel: 'Batal',
                    type: AppAlertType.danger,
                    icon: Icons.logout_rounded,
                  );
                  if (confirmed == true) {
                    ref.read(authControllerProvider.notifier).logout();
                  }
                },
                icon: const Icon(Icons.logout, color: AppColors.danger),
                label: const Text('Keluar dari Akun Pengelola', style: TextStyle(color: AppColors.danger)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.danger),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.secondary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.caption.copyWith(color: AppColors.ink600)),
              const SizedBox(height: 2),
              Text(
                value.isNotEmpty ? value : '-',
                style: AppTypography.captionMedium.copyWith(color: AppColors.ink900),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EditProfileBottomSheet extends StatefulWidget {
  final AdminProfileModel profile;
  final void Function(AdminProfileModel profile, File? photoFile) onSave;

  const _EditProfileBottomSheet({
    required this.profile,
    required this.onSave,
  });

  @override
  State<_EditProfileBottomSheet> createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<_EditProfileBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaSpaceCtrl;
  late TextEditingController _namaPemilikCtrl;
  late TextEditingController _teleponCtrl;
  late TextEditingController _alamatCtrl;
  late TextEditingController _deskripsiCtrl;
  File? _selectedPhotoFile;
  String? _existingFotoUrl;

  @override
  void initState() {
    super.initState();
    _namaSpaceCtrl = TextEditingController(text: widget.profile.namaSpace);
    _namaPemilikCtrl = TextEditingController(text: widget.profile.namaPemilik);
    _teleponCtrl = TextEditingController(text: widget.profile.telepon);
    _alamatCtrl = TextEditingController(text: widget.profile.alamat);
    _deskripsiCtrl = TextEditingController(text: widget.profile.deskripsiFasilitas);
    _existingFotoUrl = widget.profile.foto;
  }

  @override
  void dispose() {
    _namaSpaceCtrl.dispose();
    _namaPemilikCtrl.dispose();
    _teleponCtrl.dispose();
    _alamatCtrl.dispose();
    _deskripsiCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final updated = widget.profile.copyWith(
      namaSpace: _namaSpaceCtrl.text.trim(),
      namaPemilik: _namaPemilikCtrl.text.trim(),
      telepon: _teleponCtrl.text.trim(),
      alamat: _alamatCtrl.text.trim(),
      deskripsiFasilitas: _deskripsiCtrl.text.trim(),
      foto: _selectedPhotoFile?.path ?? _existingFotoUrl,
    );

    widget.onSave(updated, _selectedPhotoFile);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Edit Profil Coworking', style: AppTypography.h2),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Foto Coworking Space Picker (Kamera / Galeri)
              AppPhotoPickerField(
                label: 'Foto Coworking Space',
                helperText: 'Pilih dari kamera atau galeri untuk foto profil lokasi',
                selectedFile: _selectedPhotoFile,
                initialUrl: _existingFotoUrl,
                height: 140,
                onPhotoChanged: (file) {
                  setState(() {
                    _selectedPhotoFile = file;
                    if (file == null) {
                      _existingFotoUrl = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _namaSpaceCtrl,
                decoration: const InputDecoration(labelText: 'Nama Coworking Space *'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _namaPemilikCtrl,
                decoration: const InputDecoration(labelText: 'Nama Penanggung Jawab *'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _teleponCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Nomor Telepon Kontak *'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _alamatCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Alamat Lokasi Lengkap *'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _deskripsiCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Deskripsi & Fasilitas'),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Simpan Perubahan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
