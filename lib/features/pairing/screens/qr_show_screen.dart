import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../app.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/pairing_provider.dart';

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
    final pairing = ref.watch(pairingNotifierProvider);
    final qrString = pairing.qrString;
    final qrError = pairing.error;
    final isExpiring = _secondsRemaining < 60;

    return Scaffold(
      backgroundColor: BlinkColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 20,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Pair Device',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Show QR Code',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ).animate().fadeIn(duration: 400.ms),
                      const Gap(8),
                      Text(
                        'Let the other device scan this code',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 15,
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                      const Gap(32),

                      // QR Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: BlinkColors.darkSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: BlinkColors.darkHover.withValues(alpha: 0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: BlinkColors.primary.withValues(alpha: 0.08),
                              blurRadius: 40,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            if (qrError != null)
                              SizedBox(
                                width: 220,
                                height: 220,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.error_outline,
                                          color: BlinkColors.error, size: 40),
                                      const Gap(8),
                                      Text(
                                        qrError,
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.5),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else if (qrString != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: QrImageView(
                                  data: qrString,
                                  version: QrVersions.auto,
                                  size: 200,
                                  eyeStyle: const QrEyeStyle(
                                    eyeShape: QrEyeShape.circle,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                  dataModuleStyle: const QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.circle,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                  backgroundColor: Colors.white,
                                ),
                              )
                            else
                              const SizedBox(
                                width: 220,
                                height: 220,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: BlinkColors.primary,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            const Gap(16),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lock_rounded,
                                    size: 13,
                                    color: BlinkColors.success.withValues(alpha: 0.7)),
                                const Gap(5),
                                Text(
                                  'End-to-end encrypted',
                                  style: TextStyle(
                                    color: BlinkColors.success.withValues(alpha: 0.7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 500.ms, delay: 200.ms).scale(
                            begin: const Offset(0.95, 0.95),
                            curve: Curves.easeOutBack,
                          ),
                      const Gap(24),

                      // Timer
                      Column(
                        children: [
                          Text(
                            'Expires in',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3),
                              fontSize: 12,
                            ),
                          ),
                          const Gap(8),
                          SizedBox(
                            width: 56,
                            height: 56,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: _secondsRemaining /
                                      AppConstants.qrTokenTtl.inSeconds,
                                  strokeWidth: 2.5,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.06),
                                  valueColor: AlwaysStoppedAnimation(
                                    isExpiring
                                        ? BlinkColors.error
                                        : BlinkColors.accent,
                                  ),
                                ),
                                Text(
                                  _formattedTime,
                                  style: TextStyle(
                                    color: isExpiring
                                        ? BlinkColors.error
                                        : Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Gap(20),

                      // Regenerate
                      GestureDetector(
                        onTap: () {
                          ref
                              .read(pairingNotifierProvider.notifier)
                              .regenerate();
                          setState(() {
                            _secondsRemaining =
                                AppConstants.qrTokenTtl.inSeconds;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white.withValues(alpha: 0.06),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.refresh_rounded,
                                  size: 16,
                                  color: Colors.white.withValues(alpha: 0.5)),
                              const Gap(6),
                              Text(
                                'Regenerate',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Gap(32),

                      // Toggle
                      _PairingToggle(activeTab: 0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PairingToggle extends StatelessWidget {
  final int activeTab;
  const _PairingToggle({required this.activeTab});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
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

  const _ToggleChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [BlinkColors.primary, Color(0xFF8B7BFF)],
                )
              : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.4),
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
