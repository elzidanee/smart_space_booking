import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_illustrations.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../providers/spaces_controller.dart';
import '../../data/models/space_models.dart';

/// Layar Katalog & Beranda Member sesuai Stitch Screen 05 (e1e0dcbdde3f4a61887eb5570baab2a7).
class SpacesCatalogScreen extends ConsumerStatefulWidget {
  const SpacesCatalogScreen({super.key});

  @override
  ConsumerState<SpacesCatalogScreen> createState() => _SpacesCatalogScreenState();
}

class _SpacesCatalogScreenState extends ConsumerState<SpacesCatalogScreen> {
  final _searchController = TextEditingController();

  final List<Map<String, String>> _categories = const [
    {'id': 'all', 'label': 'Semua'},
    {'id': 'personal_desk', 'label': 'Personal Desk'},
    {'id': 'meeting_room', 'label': 'Meeting Room'},
    {'id': 'private_office', 'label': 'Private Office'},
  ];

  @override
  void dispose() {
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
              // ── Top Header / User Greeting ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg16,
                    AppSpacing.md12,
                    AppSpacing.lg16,
                    AppSpacing.md12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
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
                                    ),
                                  )
                                : null,
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
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        color: AppColors.ink600,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tidak ada notifikasi baru.'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // ── Search Bar ──────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg16,
                    vertical: AppSpacing.xs4,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      ref.read(spaceSearchQueryProvider.notifier).state = val;
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari space atau fasilitas...',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.ink600,
                        size: 22,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(spaceSearchQueryProvider.notifier).state = '';
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),

              // ── Filter Kategori Chips ───────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md12),
                  child: SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg16),
                      itemCount: _categories.length,
                      separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm8),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = selectedCategory == cat['id'];

                        return GestureDetector(
                          onTap: () {
                            ref.read(selectedSpaceCategoryProvider.notifier).state = cat['id']!;
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.surface0,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.border,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.25),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            child: Text(
                              cat['label']!,
                              style: AppTypography.captionMedium.copyWith(
                                color: isSelected ? Colors.white : AppColors.ink600,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // ── Space Grid List Content ─────────────────────────────────────
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
                        mainAxisExtent: 290,
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
                    title: 'Gagal Memuat Data Space',
                    message: '$error',
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
}

/// Widget Kartu Space sesuai Stitch Screen 05 (05_katalog_space.html)
class _SpaceCard extends StatelessWidget {
  final SpaceModel space;

  const _SpaceCard({required this.space});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/spaces/${space.id}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface0,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(color: AppColors.border),
          boxShadow: AppSpacing.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Gambar Space & Category Pill Overlay ────────────────────────
            Stack(
              children: [
                SizedBox(
                  height: 155,
                  width: double.infinity,
                  child: space.foto != null && space.foto!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: space.foto!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const AppShimmer(
                            height: 155,
                          ),
                          errorWidget: (context, url, error) => _defaultImagePlaceholder(),
                        )
                      : _defaultImagePlaceholder(),
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
                      color: AppColors.secondary.withValues(alpha: 0.9),
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
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 16,
                        color: AppColors.ink600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${space.kapasitas} Kapasitas',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.ink600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm8),

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
                            style: AppTypography.bodyEmphasis.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
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
    );
  }

  Widget _defaultImagePlaceholder() {
    return Container(
      color: AppColors.surface50,
      child: const Center(
        child: Icon(
          Icons.meeting_room_rounded,
          color: AppColors.ink300,
          size: 40,
        ),
      ),
    );
  }
}
