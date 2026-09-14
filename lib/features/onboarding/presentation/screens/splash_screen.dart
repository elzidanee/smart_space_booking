import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../widgets/onboarding_illustrations.dart';

/// Splash Screen dengan animasi logo dan transisi otomatis ke onboarding
class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late AnimationController _ringController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _ringScale;
  late Animation<double> _subtitleOpacity;

  @override
  void initState() {
    super.initState();

    // Logo entrance animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Ring pulse animation
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _ringScale = Tween<double>(begin: 0.8, end: 1.15).animate(
      CurvedAnimation(
        parent: _ringController,
        curve: Curves.easeInOut,
      ),
    );

    // Text fade in
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    _ringController.repeat(reverse: true);

    await Future.delayed(const Duration(milliseconds: 800));
    _fadeController.forward();

    // Navigate after splash
    await Future.delayed(const Duration(milliseconds: 2200));
    if (mounted) {
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    _ringController.dispose();
    super.dispose();
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surface50,
              AppColors.primaryContainer.withValues(alpha: 0.3),
              AppColors.surface50,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              // Animated Logo
              AnimatedBuilder(
                animation: Listenable.merge([_logoController, _ringController]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScale.value,
                    child: Opacity(
                      opacity: _logoOpacity.value,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Pulsating ring behind
                          Transform.scale(
                            scale: _ringScale.value,
                            child: Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          // Logo illustration
                          const SplashLogoIllustration(size: 150),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              // App name
              AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) {
                  return SlideTransition(
                    position: _textSlide,
                    child: Opacity(
                      opacity: _textOpacity.value,
                      child: Column(
                        children: [
                          Text(
                            'Smart Space',
                            style: GoogleFonts.sora(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'BOOKING',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              letterSpacing: 4.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Subtitle
              AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _subtitleOpacity.value,
                    child: Text(
                      'Ruang kerja cerdas, satu genggaman.',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.ink600,
                        fontSize: 14,
                      ),
                    ),
                  );
                },
              ),
              const Spacer(flex: 3),
              // Loading indicator
              AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _subtitleOpacity.value,
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primary.withValues(alpha: 0.6),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
