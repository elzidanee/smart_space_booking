import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../spaces/data/models/space_models.dart';
import '../providers/admin_controller.dart';
import '../widgets/confirmation_dialog.dart';

class AdminSpacesScreen extends ConsumerStatefulWidget {
  const AdminSpacesScreen({super.key});

  @override
  ConsumerState<AdminSpacesScreen> createState() => _AdminSpacesScreenState();
}

class _AdminSpacesScreenState extends ConsumerState<AdminSpacesScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<({String label, String value})> _typeFilters = const [
    (label: 'Semua', value: 'all'),
    (label: 'Personal Desk', value: 'personal_desk'),
    (label: 'Meeting Room', value: 'meeting_room'),
    (label: 'Private Office', value: 'private_office'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSpaceFormDialog({SpaceModel? space}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _SpaceFormBottomSheet(
        space: space,
        onSave: (savedSpace) {
          if (space == null) {
            ref.read(adminSpacesControllerProvider.notifier).createSpace(savedSpace);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Space berhasil ditambahkan!'),
                backgroundColor: AppColors.secondary,
              ),
            );
          } else {
            ref.read(adminSpacesControllerProvider.notifier).updateSpace(savedSpace);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Space berhasil diperbarui!'),
                backgroundColor: AppColors.secondary,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _handleDeleteSpace(SpaceModel space) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Hapus Space',
      message:
          'Apakah Anda yakin ingin menghapus ruangan "${space.nama}"? Data yang sudah dihapus tidak dapat dipulihkan.',
      confirmLabel: 'Hapus',
      confirmColor: AppColors.danger,
      icon: Icons.delete_outline_rounded,
    );

    if (confirmed == true) {
      ref.read(adminSpacesControllerProvider.notifier).deleteSpace(space.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Space "${space.nama}" berhasil dihapus'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeTipe = ref.watch(adminSpacesFilterTipeProvider);
    final spacesAsync = ref.watch(adminSpacesControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.surface50,
      body: Column(
        children: [
          // Filter & Search Header
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface0,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (q) =>
                      ref.read(adminSpacesControllerProvider.notifier).search(q),
                  decoration: InputDecoration(
                    hintText: 'Cari nama ruangan atau fasilitas...',
                    hintStyle: AppTypography.caption.copyWith(color: AppColors.ink300),
                    prefixIcon: const Icon(Icons.search, color: AppColors.ink600, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(adminSpacesControllerProvider.notifier)
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
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _typeFilters.map((t) {
                      final isSelected = activeTipe == t.value;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(t.label),
                          selected: isSelected,
                          selectedColor: AppColors.secondary,
                          labelStyle: AppTypography.captionMedium.copyWith(
                            color: isSelected ? Colors.white : AppColors.ink600,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          backgroundColor: AppColors.surface50,
                          side: BorderSide(
                            color: isSelected ? AppColors.secondary : AppColors.border,
                          ),
                          onSelected: (_) {
                            ref
                                .read(adminSpacesControllerProvider.notifier)
                                .setFilterTipe(t.value);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          // Spaces Grid / List
          Expanded(
            child: spacesAsync.when(
              loading: () => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, __) => AppShimmer(
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
                      const SizedBox(height: 12),
                      Text('Gagal memuat data space', style: AppTypography.h2),
                      const SizedBox(height: 6),
                      Text('$err', style: AppTypography.caption),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(adminSpacesControllerProvider),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (spaces) {
                if (spaces.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.meeting_room_outlined, size: 64, color: AppColors.ink300),
                          const SizedBox(height: 16),
                          Text('Belum ada data space', style: AppTypography.h2),
                          const SizedBox(height: 6),
                          Text(
                            'Tambahkan inventaris ruangan atau meja kerja dengan tombol di bawah.',
                            style: AppTypography.caption,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.secondary,
                  onRefresh: () async {
                    ref.invalidate(adminSpacesControllerProvider);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: spaces.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = spaces[index];
                      return _buildSpaceCard(item);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSpaceFormDialog(),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Space'),
      ),
    );
  }

  Widget _buildSpaceCard(SpaceModel space) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image + Tipe Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: space.foto ?? '',
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => AppShimmer(
                    child: Container(
                      height: 140,
                      color: Colors.white,
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 140,
                    color: AppColors.secondaryContainer,
                    child: const Icon(Icons.business, size: 48, color: AppColors.secondary),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    space.tipe.replaceAll('_', ' ').toUpperCase(),
                    style: AppTypography.captionMedium.copyWith(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.people, size: 13, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        '${space.kapasitas} Orang',
                        style: AppTypography.captionMedium.copyWith(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Content Details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        space.nama,
                        style: AppTypography.h2.copyWith(fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.formatPerHour(space.hargaPerJam),
                      style: AppTypography.h2.copyWith(
                        color: AppColors.secondary,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  space.deskripsi ?? '',
                  style: AppTypography.caption.copyWith(color: AppColors.ink600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Facilities wrap
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: space.fasilitas.take(3).map((f) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surface50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        f,
                        style: AppTypography.caption.copyWith(fontSize: 11),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 8),

                // Actions: Edit & Delete
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showSpaceFormDialog(space: space),
                      icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.secondary),
                      label: const Text('Edit Space', style: TextStyle(color: AppColors.secondary)),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _handleDeleteSpace(space),
                      icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.danger),
                      label: const Text('Hapus', style: TextStyle(color: AppColors.danger)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpaceFormBottomSheet extends StatefulWidget {
  final SpaceModel? space;
  final ValueChanged<SpaceModel> onSave;

  const _SpaceFormBottomSheet({
    this.space,
    required this.onSave,
  });

  @override
  State<_SpaceFormBottomSheet> createState() => _SpaceFormBottomSheetState();
}

class _SpaceFormBottomSheetState extends State<_SpaceFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaCtrl;
  late TextEditingController _hargaCtrl;
  late TextEditingController _kapasitasCtrl;
  late TextEditingController _deskripsiCtrl;
  late TextEditingController _fasilitasCtrl;
  late TextEditingController _fotoCtrl;
  late String _selectedTipe;

  @override
  void initState() {
    super.initState();
    _namaCtrl = TextEditingController(text: widget.space?.nama ?? '');
    _hargaCtrl =
        TextEditingController(text: widget.space?.hargaPerJam.toString() ?? '25000');
    _kapasitasCtrl =
        TextEditingController(text: widget.space?.kapasitas.toString() ?? '1');
    _deskripsiCtrl = TextEditingController(text: widget.space?.deskripsi ?? '');
    _fasilitasCtrl = TextEditingController(
        text: widget.space?.fasilitas.join(', ') ?? 'WiFi Cepat, AC, Power Outlet');
    _fotoCtrl = TextEditingController(
        text: widget.space?.foto ??
            'https://images.unsplash.com/photo-1527192491265-7e15c55b1ed2?w=800&q=80');
    _selectedTipe = widget.space?.tipe ?? 'personal_desk';
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _hargaCtrl.dispose();
    _kapasitasCtrl.dispose();
    _deskripsiCtrl.dispose();
    _fasilitasCtrl.dispose();
    _fotoCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final fasList = _fasilitasCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final space = SpaceModel(
      id: widget.space?.id ?? 0,
      nama: _namaCtrl.text.trim(),
      tipe: _selectedTipe,
      kapasitas: int.tryParse(_kapasitasCtrl.text) ?? 1,
      hargaPerJam: int.tryParse(_hargaCtrl.text) ?? 20000,
      fasilitas: fasList.isNotEmpty ? fasList : ['WiFi Cepat', 'AC'],
      deskripsi: _deskripsiCtrl.text.trim(),
      foto: _fotoCtrl.text.trim(),
      status: widget.space?.status ?? 'tersedia',
    );

    widget.onSave(space);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.space != null;

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
                    isEdit ? 'Edit Data Space' : 'Tambah Space Baru',
                    style: AppTypography.h2,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Nama Space
              TextFormField(
                controller: _namaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Ruangan / Meja *',
                  hintText: 'Contoh: Flexi Desk 01 / Meeting Alpha',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Nama space wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              // Dropdown Tipe Space
              DropdownButtonFormField<String>(
                initialValue: _selectedTipe,
                decoration: const InputDecoration(
                  labelText: 'Tipe Space *',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'personal_desk',
                    child: Text('Personal Desk'),
                  ),
                  DropdownMenuItem(
                    value: 'meeting_room',
                    child: Text('Meeting Room'),
                  ),
                  DropdownMenuItem(
                    value: 'private_office',
                    child: Text('Private Office'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedTipe = val);
                },
              ),
              const SizedBox(height: 12),

              // Kapasitas & Harga Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _kapasitasCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Kapasitas (Orang) *',
                      ),
                      validator: (v) =>
                          v == null || int.tryParse(v) == null ? 'Wajib angka' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _hargaCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Harga / Jam (Rp) *',
                      ),
                      validator: (v) =>
                          v == null || int.tryParse(v) == null ? 'Wajib angka' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Fasilitas (Koma)
              TextFormField(
                controller: _fasilitasCtrl,
                decoration: const InputDecoration(
                  labelText: 'Fasilitas (Pisahkan dengan koma) *',
                  hintText: 'WiFi Cepat, TV, AC, Sound System',
                ),
              ),
              const SizedBox(height: 12),

              // Deskripsi
              TextFormField(
                controller: _deskripsiCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Space',
                  hintText: 'Tuliskan rincian fasilitas dan keunggulan ruangan...',
                ),
              ),
              const SizedBox(height: 12),

              // Foto URL
              TextFormField(
                controller: _fotoCtrl,
                decoration: const InputDecoration(
                  labelText: 'URL Foto Space',
                  hintText: 'https://...',
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
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
                  child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Space'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
