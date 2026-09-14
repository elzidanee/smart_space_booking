import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../widgets/onboarding_illustrations.dart';

/// Data model untuk setiap halaman onboarding
class _OnboardingPageData {
  final String title;
  final String subtitle;
  final Widget illustration;
  final Color accentColor;

  const _OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.illustration,
    required this.accentColor,
  });
}

/// Layar Onboarding dengan 3 halaman swipe + indikator + tombol navigasi
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;

  late AnimationController _contentController;
  late Animation<double> _contentOpacity;
  late Animation<Offset> _contentSlide;

  final List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      title: 'Temukan Ruang\nKerja Impianmu',
      subtitle:
          'Jelajahi beragam coworking space modern yang\nsiap menunjang produktivitasmu setiap hari.',
      illustration: const DiscoverWorkspacesIllustration(size: 260),
      accentColor: AppColors.primary,
    ),
    _OnboardingPageData(
      title: 'Booking Mudah\n& Cepat',
      subtitle:
          'Pilih tanggal, waktu, dan ruangan favoritmu.\nKonfirmasi instan tanpa ribet.',
      illustration: const EasyBookingIllustration(size: 260),
      accentColor: AppColors.secondary,
    ),
    _OnboardingPageData(
      title: 'Kelola Segalanya\nDalam Genggaman',
      subtitle:
          'E-Ticket, riwayat reservasi, dan dashboard —\nsemua terintegrasi dalam satu aplikasi.',
      illustration: const SmartManagementIllustration(size: 260),
      accentColor: AppColors.primary,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _contentController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onNextPressed() {
    if (_currentPage < _pages.length - 1) {
      _goToPage(_currentPage + 1);
    } else {
      widget.onComplete();
    }
  }

  void _onSkipPressed() {
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.surface50,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with skip button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedOpacity(
                    opacity: _currentPage < _pages.length - 1 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: TextButton(
                      onPressed: _currentPage < _pages.length - 1
                          ? _onSkipPressed
                          : null,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.ink600,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Lewati',
                        style: AppTypography.captionMedium.copyWith(
                          color: AppColors.ink600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                  _contentController.reset();
                  _contentController.forward();
                },
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Bottom section: indicators + nav buttons
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPageData data) {
    return AnimatedBuilder(
      animation: _contentController,
      builder: (context, child) {
        return SlideTransition(
          position: _contentSlide,
          child: Opacity(
            opacity: _contentOpacity.value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const Spacer(flex: 1),
            // Illustration with subtle background shape
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    data.accentColor.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                  radius: 0.8,
                ),
              ),
              child: data.illustration,
            ),
            const Spacer(flex: 1),
            // Title
            Text(
              data.title,
              style: GoogleFonts.sora(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.ink900,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Subtitle
            Text(
              data.subtitle,
              style: AppTypography.body.copyWith(
                color: AppColors.ink600,
                height: 1.6,
                fontSize: 14.5,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    final isLastPage = _currentPage == _pages.length - 1;
    final accent = _pages[_currentPage].accentColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
      child: Column(
        children: [
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pages.length, (index) {
              final isActive = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isActive
                      ? accent
                      : AppColors.ink300.withValues(alpha: 0.35),
                ),
              );
            }),
          ),
          const SizedBox(height: 36),

          // Navigation buttons
          Row(
            children: [
              // Back button (visible after first page)
              AnimatedOpacity(
                opacity: _currentPage > 0 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: AnimatedScale(
                  scale: _currentPage > 0 ? 1.0 : 0.8,
                  duration: const Duration(milliseconds: 250),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.surface0,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          offset: const Offset(0, 2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _currentPage > 0
                            ? () => _goToPage(_currentPage - 1)
                            : null,
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.ink600,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),

              // Next / Get Started button
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                height: 52,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _onNextPressed,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      padding: EdgeInsets.symmetric(
                        horizontal: isLastPage ? 32 : 24,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accent,
                            accent.withValues(alpha: 0.85),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.3),
                            offset: const Offset(0, 4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLastPage ? 'Mulai Sekarang' : 'Lanjut',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          if (!isLastPage) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                          if (isLastPage) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.rocket_launch_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
