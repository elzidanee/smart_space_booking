import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/onboarding_illustrations.dart';

// Model data tiap halaman onboarding
class _PageData {
  final String title;
  final String subtitle;
  final Widget illustration;
  final Color accent;

  const _PageData(this.title, this.subtitle, this.illustration, this.accent);
}

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _page = 0;

  late final AnimationController _animCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..forward();

  final _pages = const [
    _PageData(
      'Temukan Ruang\nKerja Impianmu',
      'Jelajahi beragam coworking space modern yang\nsiap menunjang produktivitasmu setiap hari.',
      DiscoverWorkspacesIllustration(size: 260),
      AppColors.primary,
    ),
    _PageData(
      'Booking Mudah\n& Cepat',
      'Pilih tanggal, waktu, dan ruangan favoritmu.\nKonfirmasi instan tanpa ribet.',
      EasyBookingIllustration(size: 260),
      AppColors.secondary,
    ),
    _PageData(
      'Kelola Segalanya\nDalam Genggaman',
      'E-Ticket, riwayat reservasi, dan dashboard —\nsemua terintegrasi dalam satu aplikasi.',
      SmartManagementIllustration(size: 260),
      AppColors.primary,
    ),
  ];

  bool get _isLast => _page == _pages.length - 1;

  @override
  void dispose() {
    _pageCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_isLast) {
      widget.onComplete();
    } else {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _back() {
    _pageCtrl.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: AppColors.surface50,
      body: SafeArea(
        child: Column(
          children: [
            // Tombol lewati
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: AnimatedOpacity(
                  opacity: _isLast ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  child: TextButton(
                    onPressed: _isLast ? null : widget.onComplete,
                    child: Text(
                      'Lewati',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.ink600,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Konten halaman
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: _pages.length,
                onPageChanged: (i) {
                  setState(() => _page = i);
                  _animCtrl
                    ..reset()
                    ..forward();
                },
                itemBuilder: (_, i) => _buildPage(_pages[i]),
              ),
            ),

            // Indikator & tombol navigasi
            _buildBottom(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_PageData data) {
    return FadeTransition(
      opacity: _animCtrl,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxImgSize = (constraints.maxHeight * 0.42).clamp(160.0, 260.0);
          final titleSize = constraints.maxHeight < 620 ? 22.0 : 26.0;
          final subtitleSize = constraints.maxHeight < 620 ? 13.0 : 14.0;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),
                SizedBox(
                  height: maxImgSize,
                  width: maxImgSize,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: data.illustration,
                  ),
                ),
                const Spacer(flex: 2),
                Text(
                  data.title,
                  style: GoogleFonts.sora(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink900,
                    height: 1.25,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  data.subtitle,
                  style: GoogleFonts.inter(
                    fontSize: subtitleSize,
                    color: AppColors.ink600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 3),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottom() {
    final accent = _pages[_page].accent;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
      child: Column(
        children: [
          // Page indicator dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pages.length, (i) {
              final active = i == _page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: active ? accent : AppColors.ink300.withValues(alpha: 0.35),
                ),
              );
            }),
          ),
          const SizedBox(height: 32),

          // Tombol navigasi
          Row(
            children: [
              // Tombol back
              AnimatedOpacity(
                opacity: _page > 0 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: GestureDetector(
                  onTap: _page > 0 ? _back : null,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.ink600,
                    ),
                  ),
                ),
              ),
              const Spacer(),

              // Tombol lanjut / mulai
              GestureDetector(
                onTap: _next,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.symmetric(
                    horizontal: _isLast ? 28 : 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.3),
                        offset: const Offset(0, 4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isLast ? 'Mulai Sekarang' : 'Lanjut',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _isLast ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
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
