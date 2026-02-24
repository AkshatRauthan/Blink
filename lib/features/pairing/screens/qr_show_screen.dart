import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../app.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../providers/pairing_provider.dart';

/// QR code display screen for secure device pairing.
///
/// Stitch screen: "Blink Secure Pairing QR Screen" (010361a38b3544f99221564fdcd1c899)
class QrShowScreen extends ConsumerStatefulWidget {
  const QrShowScreen({super.key});

  @override
  ConsumerState<QrShowScreen> createState() => _QrShowScreenState();
}

class _QrShowScreenState extends ConsumerState<QrShowScreen> {
  late Timer _countdownTimer;
  int _secondsRemaining = AppConstants.qrTokenTtl.inSeconds;

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _countdownTimer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final m = _secondsRemaining ~/ 60;
    final s = _secondsRemaining % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final pairingState = ref.watch(pairingNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text('Pair Device', style: theme.textTheme.headlineMedium),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: BlinkSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Title ──────────────────────────────────────
              Text(
                AppStrings.pairingShowQr,
                style: theme.textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: BlinkDurations.standard),
              const Gap(BlinkSpacing.sm),
              Text(
                AppStrings.pairingInstructions,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(
                  duration: BlinkDurations.standard, delay: 100.ms),
              const Gap(BlinkSpacing.xl),

              // ── QR Card ────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(BlinkSpacing.lg),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(BlinkRadius.xl),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.5),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    pairingState.when(
                      loading: () => const SizedBox(
                        width: 240,
                        height: 240,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => SizedBox(
                        width: 240,
                        height: 240,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline,
                                  color: BlinkColors.error, size: 48),
                              const Gap(BlinkSpacing.sm),
                              Text('Error: $e',
                                  style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ),
                      data: (qrString) => qrString != null
                          ? QrImageView(
                              data: qrString,
                              version: QrVersions.auto,
                              size: 240,
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.circle,
                                color: BlinkColors.primary,
                              ),
                              dataModuleStyle: const QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.circle,
                                color: BlinkColors.primary,
                              ),
                              backgroundColor: Colors.white,
                            )
                          : const SizedBox(
                              width: 240,
                              height: 240,
                              child:
                                  Center(child: CircularProgressIndicator()),
                            ),
                    ),
                    const Gap(BlinkSpacing.md),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_rounded,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant),
                        const Gap(BlinkSpacing.xs),
                        Text(
                          'End-to-end encrypted',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate(effects: BlinkEffects.scaleIn),
              const Gap(BlinkSpacing.lg),

              // ── Countdown timer ────────────────────────────
              Column(
                children: [
                  Text('Expires in',
                      style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                  const Gap(BlinkSpacing.sm),
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: _secondsRemaining /
                              AppConstants.qrTokenTtl.inSeconds,
                          strokeWidth: 3,
                          backgroundColor: theme.colorScheme.outline
                              .withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation(
                            _secondsRemaining < 60
                                ? BlinkColors.coral
                                : BlinkColors.accent,
                          ),
                        ),
                        Text(
                          _formattedTime,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: _secondsRemaining < 60
                                ? BlinkColors.coral
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(BlinkSpacing.md),

              // ── Regenerate button ──────────────────────────
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(pairingNotifierProvider.notifier).regenerate();
                  setState(() {
                    _secondsRemaining = AppConstants.qrTokenTtl.inSeconds;
                  });
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Regenerate'),
              ),
              const Gap(BlinkSpacing.xl),

              // ── Toggle: Show QR / Scan QR ──────────────────
              _PairingToggle(activeTab: 0),
            ],
          ),
        ),
      ),
    );
  }
}

/// Segmented toggle between Show QR and Scan QR modes.
class _PairingToggle extends StatelessWidget {
  final int activeTab;
  const _PairingToggle({required this.activeTab});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(BlinkRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleChip(
            label: 'Show QR',
            isActive: activeTab == 0,
            onTap: () {},
          ),
          _ToggleChip(
            label: 'Scan QR',
            isActive: activeTab == 1,
            onTap: () => context.pushReplacement(AppRoutes.qrScan),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _ToggleChip(
      {required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: BlinkSpacing.lg,
          vertical: BlinkSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isActive ? BlinkColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(BlinkRadius.full),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isActive
                    ? BlinkColors.white
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
        ),
      ),
    );
  }
}
