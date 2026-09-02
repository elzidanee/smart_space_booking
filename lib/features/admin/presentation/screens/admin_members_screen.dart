import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_illustrations.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../data/models/admin_models.dart';
import '../providers/admin_controller.dart';
import '../widgets/confirmation_dialog.dart';

class AdminMembersScreen extends ConsumerStatefulWidget {
  const AdminMembersScreen({super.key});

  @override
  ConsumerState<AdminMembersScreen> createState() => _AdminMembersScreenState();
}

class _AdminMembersScreenState extends ConsumerState<AdminMembersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showMemberFormDialog({AdminMemberModel? member}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _MemberFormBottomSheet(
        member: member,
        onSave: (savedMember) {
          if (member == null) {
            ref.read(adminMembersControllerProvider.notifier).createMember(savedMember);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Member baru berhasil didaftarkan!'),
                backgroundColor: AppColors.secondary,
              ),
            );
          } else {
            ref.read(adminMembersControllerProvider.notifier).updateMember(savedMember);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Data member berhasil diperbarui!'),
                backgroundColor: AppColors.secondary,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _handleDeleteMember(AdminMemberModel member) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Hapus Member',
      message:
          'Apakah Anda yakin ingin menghapus akun member "${member.nama}" (@${member.username})? Data riwayat pemesanan member ini akan tetap tersimpan di arsip.',
      confirmLabel: 'Hapus Member',
      confirmColor: AppColors.danger,
      icon: Icons.person_remove_outlined,
    );

    if (confirmed == true) {
      ref.read(adminMembersControllerProvider.notifier).deleteMember(member.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Member "${member.nama}" berhasil dihapus'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(adminMembersControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.surface50,
      body: Column(
        children: [
          // Search Input Header
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface0,
            child: TextField(
              controller: _searchController,
              onChanged: (q) =>
                  ref.read(adminMembersControllerProvider.notifier).search(q),
              decoration: InputDecoration(
                hintText: 'Cari nama, username, instansi, atau no. telepon...',
                hintStyle: AppTypography.caption.copyWith(color: AppColors.ink300),
                prefixIcon: const Icon(Icons.search, color: AppColors.ink600, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(adminMembersControllerProvider.notifier)
                              .search('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
                ),
              ),
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          // Member List
          Expanded(
            child: membersAsync.when(
              loading: () => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, __) => const AppShimmer(
                  child: ShimmerPlaceholder(height: 90, borderRadius: 16),
                ),
              ),
              error: (err, _) => AppEmptyState(
                illustration: const NetworkErrorIllustration(size: 160),
                title: 'Gagal Memuat Member',
                message: '$err',
                actionLabel: 'Coba Lagi',
                actionColor: AppColors.secondary,
                onAction: () => ref.invalidate(adminMembersControllerProvider),
              ),
              data: (members) {
                if (members.isEmpty) {
                  return AppEmptyState(
                    illustration: const EmptyMembersIllustration(size: 160),
                    title: 'Belum Ada Data Member',
                    message: 'Data pengguna atau pelanggan terdaftar akan muncul di sini. Tambahkan member baru dengan tombol di bawah.',
                    actionLabel: 'Tambah Member',
                    actionColor: AppColors.secondary,
                    onAction: () => _showMemberFormDialog(),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.secondary,
                  onRefresh: () async {
                    ref.invalidate(adminMembersControllerProvider);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: members.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = members[index];
                      return _buildMemberCard(item);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMemberFormDialog(),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Tambah Member'),
      ),
    );
  }

  Widget _buildMemberCard(AdminMemberModel member) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.secondaryContainer,
            backgroundImage: member.foto != null && member.foto!.startsWith('http')
                ? NetworkImage(member.foto!)
                : null,
            child: member.foto == null || !member.foto!.startsWith('http')
                ? const Icon(Icons.person, color: AppColors.secondary, size: 28)
                : null,
          ),
          const SizedBox(width: 14),

          // Member Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.nama,
                  style: AppTypography.h2.copyWith(fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '@${member.username} • ${member.instansi}',
                  style: AppTypography.caption.copyWith(color: AppColors.ink600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 13, color: AppColors.secondary),
                    const SizedBox(width: 4),
                    Text(
                      member.telepon,
                      style: AppTypography.captionMedium.copyWith(fontSize: 12),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${member.totalReservasi} Reservasi',
                        style: AppTypography.captionMedium.copyWith(
                          color: AppColors.secondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20, color: AppColors.ink600),
            onSelected: (val) {
              if (val == 'edit') {
                _showMemberFormDialog(member: member);
              } else if (val == 'delete') {
                _handleDeleteMember(member);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18, color: AppColors.secondary),
                    SizedBox(width: 8),
                    Text('Edit Member'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                    SizedBox(width: 8),
                    Text('Hapus Member', style: TextStyle(color: AppColors.danger)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MemberFormBottomSheet extends StatefulWidget {
  final AdminMemberModel? member;
  final ValueChanged<AdminMemberModel> onSave;

  const _MemberFormBottomSheet({
    this.member,
    required this.onSave,
  });

  @override
  State<_MemberFormBottomSheet> createState() => _MemberFormBottomSheetState();
}

class _MemberFormBottomSheetState extends State<_MemberFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaCtrl;
  late TextEditingController _usernameCtrl;
  late TextEditingController _instansiCtrl;
  late TextEditingController _teleponCtrl;
  late TextEditingController _alamatCtrl;
  late TextEditingController _fotoCtrl;

  @override
  void initState() {
    super.initState();
    _namaCtrl = TextEditingController(text: widget.member?.nama ?? '');
    _usernameCtrl = TextEditingController(text: widget.member?.username ?? '');
    _instansiCtrl = TextEditingController(text: widget.member?.instansi ?? '');
    _teleponCtrl = TextEditingController(text: widget.member?.telepon ?? '');
    _alamatCtrl = TextEditingController(text: widget.member?.alamat ?? '');
    _fotoCtrl = TextEditingController(text: widget.member?.foto ?? '');
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _usernameCtrl.dispose();
    _instansiCtrl.dispose();
    _teleponCtrl.dispose();
    _alamatCtrl.dispose();
    _fotoCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final member = AdminMemberModel(
      id: widget.member?.id ?? 0,
      nama: _namaCtrl.text.trim(),
      username: _usernameCtrl.text.trim(),
      instansi: _instansiCtrl.text.trim().isNotEmpty ? _instansiCtrl.text.trim() : '-',
      telepon: _teleponCtrl.text.trim(),
      alamat: _alamatCtrl.text.trim(),
      foto: _fotoCtrl.text.trim().isNotEmpty ? _fotoCtrl.text.trim() : null,
      totalReservasi: widget.member?.totalReservasi ?? 0,
      createdAt: widget.member?.createdAt ?? DateTime.now().toIso8601String(),
    );

    widget.onSave(member);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.member != null;

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
                  Text(
                    isEdit ? 'Edit Data Member' : 'Tambah Member Baru',
                    style: AppTypography.h2,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _namaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap *',
                  hintText: 'Contoh: Ahmad Fauzi',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Nama lengkap wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _usernameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Username *',
                  hintText: 'Contoh: ahmad_fauzi',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Username wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _teleponCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Telepon *',
                        hintText: '081234567890',
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Nomor telepon wajib diisi' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _instansiCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Instansi / Kampus',
                        hintText: 'Universitas / Perusahaan',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _alamatCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Alamat Lengkap',
                  hintText: 'Jl. ... Kota Malang',
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _fotoCtrl,
                decoration: const InputDecoration(
                  labelText: 'URL Foto Profil (Opsional)',
                  hintText: 'https://...',
                ),
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
                  child: Text(isEdit ? 'Simpan Perubahan' : 'Daftarkan Member'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
