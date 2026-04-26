import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../app.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final AnimationController _pulseController;
  late final AnimationController _orbController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pulseController.dispose();
    _orbController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(onboardingNotifierProvider.notifier)
          .setName(_nameController.text.trim());
      final success =
          await ref.read(onboardingNotifierProvider.notifier).save();
      if (success && mounted) {
        context.go(AppRoutes.discovery);
      }
    }
  }

  Future<void> _pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      ref
          .read(onboardingNotifierProvider.notifier)
          .setAvatar(result.files.single.path!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;
    final onboardingState = ref.watch(onboardingNotifierProvider);

    return Scaffold(
      backgroundColor: BlinkColors.darkBackground,
      body: Stack(
        children: [
          // Ambient gradient orbs
          _AmbientOrbs(controller: _orbController),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 64 : 32,
                  vertical: 48,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo with pulsing glow
                        _LogoWithGlow(controller: _pulseController)
                            .animate()
                            .fadeIn(duration: 800.ms)
                            .scale(
                              begin: const Offset(0.8, 0.8),
                              duration: 800.ms,
                              curve: Curves.easeOutBack,
                            ),
                        const Gap(40),

                        // Title
                        Text(
                          'Blink',
                          style: theme.textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 52,
                            letterSpacing: -2,
                          ),
                          textAlign: TextAlign.center,
                        )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 300.ms)
                            .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),

                        const Gap(8),

                        // Tagline
                        Text(
                          'Share anything. Instantly. Privately.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: BlinkColors.darkTextSecondary,
                            fontSize: 16,
                            letterSpacing: 0.3,
                          ),
                          textAlign: TextAlign.center,
                        )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 500.ms)
                            .slideY(begin: 0.1, end: 0),

                        const Gap(56),

                        // Avatar picker
                        GestureDetector(
                          onTap: _pickAvatar,
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  BlinkColors.primary.withValues(alpha: 0.15),
                                  BlinkColors.accent.withValues(alpha: 0.08),
                                ],
                              ),
                              border: Border.all(
                                color: BlinkColors.primary.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if (onboardingState.avatarPath != null)
                                  ClipOval(
                                    child: Image.file(
                                      File(onboardingState.avatarPath!),
                                      width: 96,
                                      height: 96,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                else
                                  Icon(
                                    Icons.person_rounded,
                                    size: 44,
                                    color: BlinkColors.primary.withValues(alpha: 0.6),
                                  ),
                                Positioned(
                                  bottom: 2,
                                  right: 2,
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [BlinkColors.primary, BlinkColors.accent],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: BlinkColors.primary.withValues(alpha: 0.4),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 700.ms)
                            .scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOutBack),

                        const Gap(32),

                        // Name input
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: BlinkColors.darkSurface,
                            border: Border.all(
                              color: BlinkColors.darkHover.withValues(alpha: 0.5),
                            ),
                          ),
                          child: TextFormField(
                            controller: _nameController,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                              fontSize: 17,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Your name',
                              hintStyle: TextStyle(
                                color: BlinkColors.darkTextTertiary,
                                fontSize: 17,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 18,
                              ),
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                            onFieldSubmitted: (_) => _onContinue(),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 850.ms)
                            .slideY(begin: 0.06, end: 0),

                        const Gap(24),

                        // CTA Button
                        _GetStartedButton(
                          onPressed: _onContinue,
                          isLoading: onboardingState.isSaving,
                        )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 1000.ms)
                            .slideY(begin: 0.08, end: 0),

                        const Gap(40),

                        // Security badges
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SecurityBadge(
                              icon: Icons.wifi_off_rounded,
                              label: '100% Offline',
                            ),
                            const Gap(16),
                            _SecurityBadge(
                              icon: Icons.lock_rounded,
                              label: 'E2E Encrypted',
                            ),
                            const Gap(16),
                            _SecurityBadge(
                              icon: Icons.devices_rounded,
                              label: 'Cross-Platform',
                            ),
                          ],
                        )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 1200.ms),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbientOrbs extends StatelessWidget {
  final AnimationController controller;
  const _AmbientOrbs({required this.controller});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        return Stack(
          children: [
            Positioned(
              top: size.height * 0.1 + 20 * t,
              right: -60 + 30 * t,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      BlinkColors.primary.withValues(alpha: 0.12),
                      BlinkColors.primary.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: size.height * 0.15 - 15 * t,
              left: -80 + 25 * t,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      BlinkColors.accent.withValues(alpha: 0.08),
                      BlinkColors.accent.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LogoWithGlow extends StatelessWidget {
  final AnimationController controller;
  const _LogoWithGlow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final glow = 0.2 + controller.value * 0.3;
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: BlinkColors.primary.withValues(alpha: glow),
                blurRadius: 60,
                spreadRadius: 10,
              ),
              BoxShadow(
                color: BlinkColors.accent.withValues(alpha: glow * 0.4),
                blurRadius: 80,
                spreadRadius: 5,
              ),
            ],
          ),
          child: child,
        );
      },
      child: SvgPicture.asset(
        'assets/svg/logo/blink_logo.svg',
        width: 120,
        height: 120,
      ),
    );
  }
}

class _GetStartedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  const _GetStartedButton({required this.onPressed, this.isLoading = false});

  @override
  State<_GetStartedButton> createState() => _GetStartedButtonState();
}

class _GetStartedButtonState extends State<_GetStartedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [BlinkColors.primary, Color(0xFF8B7BFF)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: BlinkColors.primary.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Get Started',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _SecurityBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SecurityBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: BlinkColors.darkSurface,
            border: Border.all(
              color: BlinkColors.darkHover.withValues(alpha: 0.5),
            ),
          ),
          child: Icon(icon, size: 18, color: BlinkColors.darkTextSecondary),
        ),
        const Gap(6),
        Text(
          label,
          style: TextStyle(
            color: BlinkColors.darkTextTertiary,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
