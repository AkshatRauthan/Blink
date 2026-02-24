import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../app.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../providers/onboarding_provider.dart';

/// Onboarding screen — user picks a name + avatar before entering the app.
///
/// Design: iOS-inspired minimal layout with hero title, avatar picker,
/// name field, and gradient CTA button on a light #F8F9FC background.
/// Stitch screen: "Blink Welcome Screen" (e7644885a1d64e8782c1801285c42e6a)
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(onboardingNotifierProvider.notifier)
          .setName(_nameController.text.trim());
      ref.read(onboardingNotifierProvider.notifier).save();
      context.go(AppRoutes.discovery);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: BlinkSpacing.xl,
              vertical: BlinkSpacing.xxl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: BlinkSpacing.maxContentWidth,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Logo with glow ───────────────────────────
                    _BlinkLogo(glowController: _glowController)
                        .animate(effects: BlinkEffects.blurIn),
                    const Gap(BlinkSpacing.xxl),

                    // ── Hero title ───────────────────────────────
                    Text(
                      AppStrings.onboardingTitle,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(
                            duration: BlinkDurations.standard, delay: 200.ms)
                        .slideY(begin: 0.1, end: 0),
                    const Gap(BlinkSpacing.sm),

                    // ── Tagline ──────────────────────────────────
                    Text(
                      AppStrings.tagline,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(
                            duration: BlinkDurations.standard, delay: 350.ms)
                        .slideY(begin: 0.08, end: 0),
                    const Gap(BlinkSpacing.xxl),

                    // ── Avatar picker ────────────────────────────
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Open avatar picker
                        },
                        child: Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: BlinkColors.primary, width: 2),
                                color:
                                    BlinkColors.primary.withValues(alpha: 0.08),
                              ),
                              child: const Icon(Icons.person_rounded,
                                  size: 40, color: BlinkColors.primary),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: BlinkColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt_rounded,
                                    size: 14, color: BlinkColors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(
                            duration: BlinkDurations.standard, delay: 450.ms)
                        .scale(begin: const Offset(0.8, 0.8)),
                    const Gap(BlinkSpacing.lg),

                    // ── Name input ───────────────────────────────
                    TextFormField(
                      controller: _nameController,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: AppStrings.onboardingNameHint,
                        prefixIcon: const Icon(Icons.person_outline_rounded,
                            color: BlinkColors.lightTextTertiary),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Name required'
                          : null,
                      onFieldSubmitted: (_) => _onContinue(),
                    )
                        .animate()
                        .fadeIn(
                            duration: BlinkDurations.standard, delay: 550.ms)
                        .slideY(begin: 0.06, end: 0),
                    const Gap(BlinkSpacing.lg),

                    // ── CTA button ───────────────────────────────
                    _GradientButton(
                      label: AppStrings.onboardingContinue,
                      onPressed: _onContinue,
                    )
                        .animate()
                        .fadeIn(
                            duration: BlinkDurations.standard, delay: 650.ms)
                        .slideY(begin: 0.08, end: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Private widgets ─────────────────────────────────────────────────────────

/// Stylised lightning-bolt logo with pulsing purple glow.
class _BlinkLogo extends StatelessWidget {
  final AnimationController glowController;
  const _BlinkLogo({required this.glowController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowController,
      builder: (context, child) {
        final opacity = 0.15 + (glowController.value * 0.20);
        return Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0x306C63FF), Color(0x006C63FF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: BlinkColors.primary.withValues(alpha: opacity),
                  blurRadius: 40,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: const Icon(Icons.bolt_rounded,
                size: 56, color: BlinkColors.primary),
          ),
        );
      },
    );
  }
}

/// Full-width gradient button.
class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _GradientButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: BlinkSpacing.buttonHeight,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [BlinkColors.primary, BlinkColors.primaryLight],
        ),
        borderRadius: BorderRadius.circular(BlinkRadius.md),
        boxShadow: [
          BoxShadow(
            color: BlinkColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(BlinkRadius.md),
          child: Center(
            child: Text(label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: BlinkColors.white, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}
