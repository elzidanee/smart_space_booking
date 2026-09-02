import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_illustrations.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../data/models/admin_models.dart';
import '../providers/admin_controller.dart';
import '../widgets/confirmation_dialog.dart';

class AdminDiscountsScreen extends ConsumerStatefulWidget {
  const AdminDiscountsScreen({super.key});

  @override
  ConsumerState<AdminDiscountsScreen> createState() =>
      _AdminDiscountsScreenState();
}

class _AdminDiscountsScreenState extends ConsumerState<AdminDiscountsScreen> {
  void _showDiscountFormDialog({AdminDiscountModel? discount}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _DiscountFormBottomSheet(
        discount: discount,
        onSave: (savedDisc) {
          if (discount == null) {
            ref
                .read(adminDiscountsControllerProvider.notifier)
                .createDiscount(savedDisc);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Kode promo baru berhasil dibuat!'),
                backgroundColor: AppColors.secondary,
              ),
            );
          } else {
            ref
                .read(adminDiscountsControllerProvider.notifier)
                .updateDiscount(savedDisc);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Kode promo berhasil diperbarui!'),
                backgroundColor: AppColors.secondary,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _handleDeleteDiscount(AdminDiscountModel discount) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Hapus Kode Promo',
      message:
          'Apakah Anda yakin ingin menghapus kode promo "${discount.kode}"? Member tidak dapat lagi menggunakan kode diskon ini.',
      confirmLabel: 'Hapus Promo',
      confirmColor: AppColors.danger,
      icon: Icons.discount_outlined,
    );

    if (confirmed == true) {
      ref
          .read(adminDiscountsControllerProvider.notifier)
          .deleteDiscount(discount.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kode promo "${discount.kode}" berhasil dihapus'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final discountsAsync = ref.watch(adminDiscountsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.surface50,
      body: discountsAsync.when(
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 3,
          separatorBuilder: (context, _) => const SizedBox(height: 12),
          itemBuilder: (context, _) => const AppShimmer(
            child: ShimmerPlaceholder(height: 100, borderRadius: 16),
          ),
        ),
        error: (err, _) => AppEmptyState(
          illustration: const NetworkErrorIllustration(size: 160),
          title: 'Gagal Memuat Promo',
          message: '$err',
          actionLabel: 'Coba Lagi',
          actionColor: AppColors.secondary,
          onAction: () => ref.invalidate(adminDiscountsControllerProvider),
        ),
        data: (discounts) {
          if (discounts.isEmpty) {
            return AppEmptyState(
              illustration: const EmptyPromoIllustration(size: 160),
              title: 'Belum Ada Kode Promo',
              message: 'Buat kupon diskon menarik untuk meningkatkan okupansi coworking space Anda.',
              actionLabel: 'Buat Promo Baru',
              actionColor: AppColors.secondary,
              onAction: () => _showDiscountFormDialog(),
            );
          }

          return RefreshIndicator(
            color: AppColors.secondary,
            onRefresh: () async {
              ref.invalidate(adminDiscountsControllerProvider);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: discounts.length,
              separatorBuilder: (context, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = discounts[index];
                return _buildDiscountCard(item);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDiscountFormDialog(),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Promo'),
      ),
    );
  }

  Widget _buildDiscountCard(AdminDiscountModel discount) {
    final isExpired = discount.isExpired;

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
        children: [
          // Percentage Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isExpired
                  ? AppColors.surface50
                  : AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isExpired ? AppColors.border : AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${discount.persentase}%',
                  style: AppTypography.h2.copyWith(
                    color: isExpired ? AppColors.ink600 : AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'POTONGAN',
                  style: AppTypography.sectionLabel.copyWith(
                    color: isExpired ? AppColors.ink300 : AppColors.primary,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Code & Date Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      discount.kode,
                      style: AppTypography.h2.copyWith(
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isExpired
                            ? AppColors.danger.withValues(alpha: 0.12)
                            : AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isExpired ? 'Kedaluwarsa' : 'Aktif',
                        style: AppTypography.captionMedium.copyWith(
                          color: isExpired ? AppColors.danger : AppColors.success,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.date_range, size: 13, color: AppColors.ink600),
                    const SizedBox(width: 4),
                    Text(
                      'Berlaku: ${DateFormatter.formatIndonesian(discount.tanggalMulai)} - ${DateFormatter.formatIndonesian(discount.tanggalAkhir)}',
                      style: AppTypography.caption.copyWith(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Popup Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20, color: AppColors.ink600),
            onSelected: (val) {
              if (val == 'edit') {
                _showDiscountFormDialog(discount: discount);
              } else if (val == 'delete') {
                _handleDeleteDiscount(discount);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18, color: AppColors.secondary),
                    SizedBox(width: 8),
                    Text('Edit Promo'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                    SizedBox(width: 8),
                    Text('Hapus Promo', style: TextStyle(color: AppColors.danger)),
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

class _DiscountFormBottomSheet extends StatefulWidget {
  final AdminDiscountModel? discount;
  final ValueChanged<AdminDiscountModel> onSave;

  const _DiscountFormBottomSheet({
    this.discount,
    required this.onSave,
  });

  @override
  State<_DiscountFormBottomSheet> createState() =>
      _DiscountFormBottomSheetState();
}

class _DiscountFormBottomSheetState extends State<_DiscountFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _kodeCtrl;
  late TextEditingController _persenCtrl;
  late TextEditingController _mulaiCtrl;
  late TextEditingController _akhirCtrl;

  @override
  void initState() {
    super.initState();
    _kodeCtrl = TextEditingController(text: widget.discount?.kode ?? '');
    _persenCtrl = TextEditingController(
        text: widget.discount?.persentase.toString() ?? '15');
    _mulaiCtrl = TextEditingController(
        text: widget.discount?.tanggalMulai ?? '2026-09-01');
    _akhirCtrl = TextEditingController(
        text: widget.discount?.tanggalAkhir ?? '2026-12-31');
  }

  @override
  void dispose() {
    _kodeCtrl.dispose();
    _persenCtrl.dispose();
    _mulaiCtrl.dispose();
    _akhirCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final disc = AdminDiscountModel(
      id: widget.discount?.id ?? 0,
      kode: _kodeCtrl.text.trim().toUpperCase(),
      persentase: int.tryParse(_persenCtrl.text) ?? 10,
      tanggalMulai: _mulaiCtrl.text.trim(),
      tanggalAkhir: _akhirCtrl.text.trim(),
      status: widget.discount?.status ?? 'aktif',
    );

    widget.onSave(disc);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.discount != null;

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
                    isEdit ? 'Edit Kode Promo' : 'Tambah Promo Baru',
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
                controller: _kodeCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Kode Voucher Promo *',
                  hintText: 'Contoh: HEMAT20 / DISKONUKK',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Kode promo wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _persenCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Persentase Potongan (%) *',
                  hintText: 'Contoh: 10, 20, 50',
                ),
                validator: (v) {
                  if (v == null || int.tryParse(v) == null) return 'Wajib angka';
                  final val = int.parse(v);
                  if (val <= 0 || val > 100) return 'Persentase harus 1 - 100%';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _mulaiCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Mulai (YYYY-MM-DD) *',
                        hintText: '2026-09-01',
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _akhirCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Akhir (YYYY-MM-DD) *',
                        hintText: '2026-12-31',
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                  ),
                ],
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
                  child: Text(isEdit ? 'Simpan Perubahan' : 'Buat Kode Promo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
