import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/data/models/auth_models.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../reservations/presentation/providers/reservations_controller.dart';

class MemberProfileScreen extends ConsumerWidget {
  const MemberProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState  = ref.watch(authControllerProvider);
    final user       = authState.valueOrNull?.user;
    final statsAsync = ref.watch(memberUsageStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface50,
      body: CustomScrollView(
        slivers: [
          // ── Hero Header ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _HeroHeader(user: user),
          ),

          // ── Stats Row ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: statsAsync.when(
                data: (stats) => _StatsRow(
                  totalTransaksi: stats.totalBooking,
                  totalJam: stats.totalJam,
                  totalPengeluaran: stats.totalPengeluaran,
                ),
                loading: () => const _StatsRow(totalTransaksi: 0, totalJam: 0, totalPengeluaran: 0),
                error: (e, s) => const _StatsRow(totalTransaksi: 0, totalJam: 0, totalPengeluaran: 0),
              ),
            ),
          ),

          // ── Info Section ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _InfoSection(user: user),
            ),
          ),

          // ── Quick Links ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _QuickLinks(ref: ref),
            ),
          ),

          // ── Logout ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: _LogoutButton(ref: ref),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Header with gradient + avatar
// ─────────────────────────────────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  final UserModel? user;
  const _HeroHeader({this.user});

  @override
  Widget build(BuildContext context) {
    final nama     = user?.nama ?? 'Member';
    final username = user?.username ?? '';
    final instansi = user?.instansi;
    final foto     = user?.foto;
    final initial  = nama.isNotEmpty ? nama[0].toUpperCase() : 'M';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Gradient background panel
        Container(
          height: 220,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, Color(0xFF0E7C6B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -30, right: -30,
                child: Container(
                  width: 160, height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              Positioned(
                top: 40, right: 60,
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: 30, left: -20,
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
              ),
              // Greeting text
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 56, 24, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profil Saya',
                          style: AppTypography.captionMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.75),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          nama,
                          style: AppTypography.h1.copyWith(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (username.isNotEmpty)
                          Text(
                            '@$username',
                            style: AppTypography.caption.copyWith(
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                        if (instansi != null && instansi.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.business_rounded, size: 12, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  instansi,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Floating Avatar
        Positioned(
          right: 24,
          top: 110,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.primaryContainer,
              backgroundImage: (foto != null && foto.isNotEmpty)
                  ? NetworkImage(foto) as ImageProvider
                  : null,
              child: (foto == null || foto.isEmpty)
                  ? Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
          ),
        ),

        // White card area spacer (untuk mendorong konten di bawah)
        const SizedBox(height: 220 + 32),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats Row
// ─────────────────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final int totalTransaksi;
  final int totalJam;
  final int totalPengeluaran;

  const _StatsRow({
    required this.totalTransaksi,
    required this.totalJam,
    required this.totalPengeluaran,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface0,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.border),
        boxShadow: AppSpacing.cardShadow,
      ),
      child: Row(
        children: [
          _StatItem(
            icon: Icons.receipt_long_rounded,
            iconColor: AppColors.primary,
            value: '$totalTransaksi',
            label: 'Booking',
          ),
          _divider(),
          _StatItem(
            icon: Icons.access_time_filled_rounded,
            iconColor: AppColors.info,
            value: '$totalJam',
            label: 'Total Jam',
          ),
          _divider(),
          _StatItem(
            icon: Icons.account_balance_wallet_rounded,
            iconColor: AppColors.success,
            value: _formatPengeluaran(totalPengeluaran),
            label: 'Pengeluaran',
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1, height: 40,
        color: AppColors.border,
        margin: const EdgeInsets.symmetric(horizontal: 8),
      );

  String _formatPengeluaran(int n) {
    if (n <= 0) return 'Rp 0';
    if (n >= 1000000) {
      final val = n / 1000000;
      final str = val.toStringAsFixed(1).replaceAll('.0', '');
      return 'Rp ${str}jt';
    }
    if (n >= 1000) {
      final val = n / 1000;
      final str = val.toStringAsFixed(1).replaceAll('.0', '');
      return 'Rp ${str}rb';
    }
    return 'Rp $n';
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.h3.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: AppTypography.caption.copyWith(color: AppColors.ink600, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info Section
// ─────────────────────────────────────────────────────────────────────────────
class _InfoSection extends StatelessWidget {
  final UserModel? user;
  const _InfoSection({this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface0,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.border),
        boxShadow: AppSpacing.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person_rounded, size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text('Informasi Akun', style: AppTypography.h3.copyWith(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 16),
          _InfoRow(icon: Icons.badge_rounded, label: 'Nama Lengkap', value: user?.nama ?? '-'),
          _InfoRow(icon: Icons.alternate_email_rounded, label: 'Username', value: '@${user?.username ?? "-"}'),
          if (user?.telepon != null && user!.telepon!.isNotEmpty)
            _InfoRow(icon: Icons.phone_rounded, label: 'Telepon', value: user!.telepon!),
          if (user?.instansi != null && user!.instansi!.isNotEmpty)
            _InfoRow(icon: Icons.business_rounded, label: 'Instansi', value: user!.instansi!),
          if (user?.alamat != null && user!.alamat!.isNotEmpty)
            _InfoRow(icon: Icons.location_on_rounded, label: 'Alamat', value: user!.alamat!, isLast: true),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.ink600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.caption.copyWith(color: AppColors.ink600, fontSize: 11)),
                const SizedBox(height: 2),
                Text(value, style: AppTypography.bodyMedium.copyWith(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick Links
// ─────────────────────────────────────────────────────────────────────────────
class _QuickLinks extends StatelessWidget {
  final WidgetRef ref;
  const _QuickLinks({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface0,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.border),
        boxShadow: AppSpacing.cardShadow,
      ),
      child: Column(
        children: [
          _LinkTile(
            icon: Icons.history_rounded,
            iconColor: AppColors.info,
            title: 'Histori & Pengeluaran',
            subtitle: 'Lihat riwayat reservasi bulanan',
            onTap: () => context.push('/reservations/history'),
            showDivider: true,
          ),
          _LinkTile(
            icon: Icons.calendar_today_rounded,
            iconColor: AppColors.primary,
            title: 'Status Pemesanan',
            subtitle: 'Pantau reservasi aktif kamu',
            onTap: () => context.push('/reservations'),
            showDivider: true,
          ),
          _LinkTile(
            icon: Icons.qr_code_rounded,
            iconColor: AppColors.secondary,
            title: 'E-Ticket',
            subtitle: 'Akses tiket digital reservasi',
            onTap: () => context.push('/ticket'),
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showDivider;

  const _LinkTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                      Text(subtitle, style: AppTypography.caption.copyWith(color: AppColors.ink600, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.ink600),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.border),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Logout Button
// ─────────────────────────────────────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  final WidgetRef ref;
  const _LogoutButton({required this.ref});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => _confirmLogout(context, ref),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.danger),
        foregroundColor: AppColors.danger,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.logout_rounded, size: 18),
          const SizedBox(width: 8),
          Text('Keluar dari Akun', style: AppTypography.bodyMedium.copyWith(color: AppColors.danger)),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusCard)),
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.danger, size: 24),
            const SizedBox(width: 8),
            Text('Keluar Akun?', style: AppTypography.h3),
          ],
        ),
        content: Text(
          'Kamu akan keluar dari akun ini. Pastikan semua data sudah tersimpan.',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authControllerProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );
  }
}
