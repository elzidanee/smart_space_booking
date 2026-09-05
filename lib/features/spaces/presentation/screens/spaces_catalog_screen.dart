import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_alert.dart';
import '../../../../core/widgets/app_illustrations.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../member/presentation/screens/member_shell_screen.dart';
import '../providers/spaces_controller.dart';
import '../../data/models/space_models.dart';

/// Layar Katalog & Beranda Member dengan Hero Carousel dan Card Coworking Elegan.
class SpacesCatalogScreen extends ConsumerStatefulWidget {
  const SpacesCatalogScreen({super.key});

  @override
  ConsumerState<SpacesCatalogScreen> createState() => _SpacesCatalogScreenState();
}

class _SpacesCatalogScreenState extends ConsumerState<SpacesCatalogScreen> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;

  final List<Map<String, dynamic>> _categories = const [
    {
      'id': 'all',
      'label': 'Semua',
      'icon': Icons.grid_view_rounded,
    },
    {
      'id': 'personal_desk',
      'label': 'Personal Desk',
      'icon': Icons.desk_rounded,
    },
    {
      'id': 'meeting_room',
      'label': 'Meeting Room',
      'icon': Icons.groups_rounded,
    },
    {
      'id': 'private_office',
      'label': 'Private Office',
      'icon': Icons.domain_rounded,
    },
  ];

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authSession = ref.watch(authControllerProvider).valueOrNull;
    final userName = authSession?.user?.nama ?? 'Member';
    final userAvatar = authSession?.user?.foto;

    final selectedCategory = ref.watch(selectedSpaceCategoryProvider);
    final spacesAsync = ref.watch(spacesListProvider);

    return Scaffold(
      backgroundColor: AppColors.surface50,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(spacesListProvider);
          },
          child: CustomScrollView(
            slivers: [
              // ── 1. Top Header / User Greeting ──────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg16,
                    AppSpacing.md12,
                    AppSpacing.lg16,
                    AppSpacing.sm8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primaryContainer,
                              backgroundImage: (userAvatar != null && userAvatar.isNotEmpty)
                                  ? NetworkImage(userAvatar) as ImageProvider
                                  : null,
                              child: (userAvatar == null || userAvatar.isEmpty)
                                  ? Text(
                                      userName.isNotEmpty ? userName[0].toUpperCase() : 'M',
                                      style: AppTypography.bodyEmphasis.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Smart Space',
                                style: AppTypography.h3.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Halo, $userName 👋',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.ink600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface0,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          color: AppColors.ink900,
                          iconSize: 20,
                          onPressed: () {
                            AppAlert.showToast(
                              context: context,
                              type: AppAlertType.info,
                              title: 'Notifikasi',
                              message: 'Belum ada notifikasi baru hari ini.',
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 2. Search Bar ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg16,
                    vertical: AppSpacing.xs4,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      _debounceTimer?.cancel();
                      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
                        if (mounted) {
                          ref.read(spaceSearchQueryProvider.notifier).state = val.trim();
                        }
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari ruangan atau fasilitas...',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.ink600,
                        size: 22,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _debounceTimer?.cancel();
                                _searchController.clear();
                                ref.read(spaceSearchQueryProvider.notifier).state = '';
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),

              // ── 3. Hero Promo Carousel ─────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 14, bottom: 6),
                  child: _MemberHeroCarousel(
                    onSelectMeetingRoom: () {
                      ref.read(selectedSpaceCategoryProvider.notifier).state = 'meeting_room';
                    },
                    onOpenTicket: () {
                      ref.read(memberNavIndexProvider.notifier).state = 2;
                    },
                    onSelectDesk: () {
                      ref.read(selectedSpaceCategoryProvider.notifier).state = 'personal_desk';
                    },
                  ),
                ),
              ),

              // ── 4. Quick Perks Strip ───────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg16, vertical: 8),
                  child: Row(
                    children: [
                      _buildQuickPerk(Icons.wifi_rounded, 'WiFi 100Mbps'),
                      const SizedBox(width: 8),
                      _buildQuickPerk(Icons.coffee_rounded, 'Free Flow Kopi'),
                      const SizedBox(width: 8),
                      _buildQuickPerk(Icons.qr_code_scanner_rounded, 'Check-in Digital'),
                    ],
                  ),
                ),
              ),

              // ── 5. Category Title & Filter Chips ───────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg16,
                    AppSpacing.md12,
                    AppSpacing.lg16,
                    AppSpacing.sm8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pilihan Ruang Kerja',
                        style: AppTypography.h3.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      spacesAsync.maybeWhen(
                        data: (spaces) => Text(
                          '${spaces.length} Ruangan',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.ink600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        orElse: () => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg16),
                    itemCount: _categories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm8),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = selectedCategory == cat['id'];
                      final IconData icon = cat['icon'] as IconData;

                      return GestureDetector(
                        onTap: () {
                          ref.read(selectedSpaceCategoryProvider.notifier).state = cat['id'] as String;
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.surface0,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.border,
                              width: 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.22),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                icon,
                                size: 16,
                                color: isSelected ? Colors.white : AppColors.ink600,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                cat['label'] as String,
                                style: AppTypography.captionMedium.copyWith(
                                  color: isSelected ? Colors.white : AppColors.ink600,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // ── 6. Space Grid Content ──────────────────────────────────────
              spacesAsync.when(
                data: (spaces) {
                  if (spaces.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: AppEmptyState(
                        illustration: const EmptySpacesIllustration(size: 160),
                        title: 'Space Tidak Ditemukan',
                        message: 'Coba gunakan kata kunci lain atau pilih filter kategori yang berbeda.',
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg16,
                      AppSpacing.xs4,
                      AppSpacing.lg16,
                      AppSpacing.xxl32,
                    ),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 420,
                        mainAxisSpacing: AppSpacing.md12,
                        crossAxisSpacing: AppSpacing.md12,
                        mainAxisExtent: 310,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final space = spaces[index];
                          return _SpaceCard(space: space);
                        },
                        childCount: spaces.length,
                      ),
                    ),
                  );
                },
                loading: () => SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => AppShimmer.spaceCard(),
                      childCount: 3,
                    ),
                  ),
                ),
                error: (error, _) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppEmptyState(
                    illustration: const NetworkErrorIllustration(size: 160),
                    title: 'Gagal Memuat Space',
                    message: error.toString(),
                    actionLabel: 'Coba Lagi',
                    onAction: () => ref.invalidate(spacesListProvider),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickPerk(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface0,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border, width: 0.8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: AppColors.secondary),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: AppTypography.caption.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.ink900,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hero Carousel elegan dengan foto arsitektural coworking dan indikator titik animasi.
class _MemberHeroCarousel extends StatefulWidget {
  final VoidCallback onSelectMeetingRoom;
  final VoidCallback onOpenTicket;
  final VoidCallback onSelectDesk;

  const _MemberHeroCarousel({
    required this.onSelectMeetingRoom,
    required this.onOpenTicket,
    required this.onSelectDesk,
  });

  @override
  State<_MemberHeroCarousel> createState() => _MemberHeroCarouselState();
}

class _MemberHeroCarouselState extends State<_MemberHeroCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _activePage = 0;

  late final List<_CarouselItemData> _items = [
    _CarouselItemData(
      tag: 'PROMO TERBATAS',
      tagColor: const Color(0xFFE87A2C),
      title: 'Diskon 50% Ruang Rapat',
      subtitle: 'Gunakan kode promo untuk meeting tim & presentasi klien lebih hemat.',
      actionLabel: 'Lihat Ruang Meeting',
      onTap: widget.onSelectMeetingRoom,
      imageUrl: 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800&auto=format&fit=crop&q=80',
      icon: Icons.groups_rounded,
    ),
    _CarouselItemData(
      tag: 'CHECK-IN DIGITAL',
      tagColor: AppColors.secondary,
      title: 'Akses Kilat dengan QR Code',
      subtitle: 'Tunjukkan E-Ticket di smartphone saat tiba di lokasi tanpa antre tiket fisik.',
      actionLabel: 'Buka Tiket Saya',
      onTap: widget.onOpenTicket,
      imageUrl: 'https://images.unsplash.com/photo-1527192491265-7e15c55b1ed2?w=800&auto=format&fit=crop&q=80',
      icon: Icons.qr_code_2_rounded,
    ),
    _CarouselItemData(
      tag: 'WORKSPACE NYAMAN',
      tagColor: AppColors.success,
      title: 'Personal Desk 100 Mbps',
      subtitle: 'Suasana tenang untuk fokus kerja, kursi ergonomis & free flow kopi/teh.',
      actionLabel: 'Pilih Meja Kerja',
      onTap: widget.onSelectDesk,
      imageUrl: 'https://images.unsplash.com/photo-1497215728101-856f4ea42174?w=800&auto=format&fit=crop&q=80',
      icon: Icons.desk_rounded,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 175,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _items.length,
            onPageChanged: (index) {
              setState(() => _activePage = index);
            },
            itemBuilder: (context, index) {
              final item = _items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: _buildBannerCard(item),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Animated Pill Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_items.length, (index) {
            final isSelected = index == _activePage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 5,
              width: isSelected ? 22 : 6,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.ink300.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBannerCard(_CarouselItemData item) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image with CachedNetworkImage
          CachedNetworkImage(
            imageUrl: item.imageUrl,
            fit: BoxFit.cover,
            placeholder: (ctx, url) => Container(
              color: const Color(0xFF2B2825),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
            errorWidget: (ctx, url, err) => Container(
              color: const Color(0xFF2B2825),
              child: Center(
                child: Icon(item.icon, size: 48, color: Colors.white24),
              ),
            ),
          ),

          // Refined Gradient Overlay
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.black.withValues(alpha: 0.30),
                  Colors.black.withValues(alpha: 0.82),
                ],
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Tag Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.tagColor.withValues(alpha: 0.90),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.tag,
                    style: AppTypography.sectionLabel.copyWith(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),

                // Title + Subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      style: AppTypography.h2.copyWith(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      style: AppTypography.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 11.5,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),

                // Bottom Action CTA
                InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.actionLabel,
                          style: AppTypography.captionMedium.copyWith(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CarouselItemData {
  final String tag;
  final Color tagColor;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;
  final String imageUrl;
  final IconData icon;

  const _CarouselItemData({
    required this.tag,
    required this.tagColor,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
    required this.imageUrl,
    required this.icon,
  });
}

/// Widget Kartu Space dengan estetika modern, micro-badges & rounded card.
class _SpaceCard extends StatelessWidget {
  final SpaceModel space;

  const _SpaceCard({required this.space});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.push('/spaces/${space.id}');
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface0,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Gambar Space & Category Pill Overlay ────────────────────────
              Stack(
                children: [
                  AppNetworkImage(
                    imageUrl: space.foto,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  // Category Pill Badge
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        space.tipeLabel.toUpperCase(),
                        style: AppTypography.captionMedium.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ── Informasi Space ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      space.nama,
                      style: AppTypography.bodyEmphasis.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          size: 15,
                          color: AppColors.ink600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${space.kapasitas} Kapasitas',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.ink600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.wifi_rounded,
                          size: 15,
                          color: AppColors.ink600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'High Speed',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.ink600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // ── Harga & Tombol Navigasi ────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mulai dari',
                              style: AppTypography.caption.copyWith(
                                fontSize: 10.5,
                                color: AppColors.ink600,
                              ),
                            ),
                            Text(
                              '${CurrencyFormatter.format(space.hargaPerJam)}/jam',
                              style: AppTypography.priceMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
