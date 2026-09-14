import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'splash_screen.dart';
import 'onboarding_screen.dart';

/// Provider untuk menyimpan status onboarding telah selesai (dalam sesi ini)
final onboardingCompleteProvider = StateProvider<bool>((ref) => false);

/// Wrapper yang menampilkan Splash → Onboarding → redirect ke login
class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  ConsumerState<OnboardingFlowScreen> createState() =>
      _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  /// 0 = splash, 1 = onboarding
  int _step = 0;

  void _onSplashComplete() {
    if (mounted) {
      setState(() {
        _step = 1;
      });
    }
  }

  void _onOnboardingComplete() {
    ref.read(onboardingCompleteProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: _step == 0
          ? SplashScreen(
              key: const ValueKey('splash'),
              onComplete: _onSplashComplete,
            )
          : OnboardingScreen(
              key: const ValueKey('onboarding'),
              onComplete: _onOnboardingComplete,
            ),
    );
  }
}
