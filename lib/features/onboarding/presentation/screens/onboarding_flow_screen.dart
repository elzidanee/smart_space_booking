import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'splash_screen.dart';
import 'onboarding_screen.dart';

// Provider: true = onboarding sudah selesai, langsung redirect ke login
final onboardingCompleteProvider = StateProvider<bool>((ref) => false);

class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  ConsumerState<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  bool _showOnboarding = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: _showOnboarding
          ? OnboardingScreen(
              key: const ValueKey('onboarding'),
              onComplete: () {
                ref.read(onboardingCompleteProvider.notifier).state = true;
              },
            )
          : SplashScreen(
              key: const ValueKey('splash'),
              onComplete: () => setState(() => _showOnboarding = true),
            ),
    );
  }
}
