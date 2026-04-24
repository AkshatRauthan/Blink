import 'dart:math';
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
import '../../../core/utils/logger.dart';
import '../../../data/models/device.dart';
import '../providers/discovery_provider.dart';
import '../widgets/device_bubble.dart';
import '../widgets/radar_painter.dart';

/// Main discovery screen — dark, atmospheric AirDrop-style radar.
///
/// Stitch screen: "Blink Radar Discovery Screen" (f51b3e7b2aac455d87c56b51a6582942)
class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    Log.i(
      'Discovery screen initialised',
      source: LogSource.ui,
      component: 'DiscoveryScreen',
    );
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    Log.i(
      'Discovery screen disposed',
      source: LogSource.ui,
      component: 'DiscoveryScreen',
    );
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context, ) {
    final devicesAsync = ref.watch(discoveryNotifierProvider);
    final theme = Theme.of(context);

    return Theme(
      // Force dark for the radar screen regardless of system theme
      data: theme.copyWith(
        scaffoldBackgroundColor: BlinkColors.darkBackground,
        appBarTheme: theme.appBarTheme.copyWith(
          backgroundColor: Colors.transparent,
          foregroundColor: BlinkColors.darkTextPrimary,
        ),
      ),
      child: Scaffold(
        backgroundColor: BlinkColors.darkBackground,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            AppStrings.appName,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: BlinkColors.darkTextPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.qr_code_scanner_rounded,
                  color: BlinkColors.darkTextPrimary),
              tooltip: AppStrings.pairingScanQr,
              onPressed: () {
                Log.l(
                  'Navigate to QR scanner',
                  source: LogSource.ui,
                  component: 'DiscoveryScreen',
                );
                context.push(AppRoutes.qrScan);
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings_rounded,
                  color: BlinkColors.darkTextPrimary),
              onPressed: () {
                Log.l(
                  'Navigate to settings',
                  source: LogSource.ui,
                  component: 'DiscoveryScreen',
                );
                context.push(AppRoutes.settings);
              },
            ),
            const Gap(BlinkSpacing.xs),
          ],
        ),
        body: devicesAsync.when(
          loading: () => _buildRadar(context, []),
          error: (e, _) => Center(
            child: Text('Error: $e',
                style: TextStyle(color: BlinkColors.error)),
          ),
          data: (devices) => _buildRadar(context, devices),
        ),
      ),
    );
  }

  Widget _buildRadar(BuildContext context, List<Device> devices) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // ── Animated radar rings ──────────────────────────────
        AnimatedBuilder(
          animation: _radarController,
          builder: (context, _) => CustomPaint(
            painter: RadarPainter(animationValue: _radarController.value),
            size: Size.infinite,
          ),
        ),

        // ── Device bubbles positioned around radar ───────────
        ...devices.asMap().entries.map((entry) {
          final i = entry.key;
          final device = entry.value;
          final angle = (2 * pi / max(devices.length, 1)) * i - (pi / 2);
          final radius = MediaQuery.of(context).size.width * 0.28;
          return Positioned(
            left: MediaQuery.of(context).size.width / 2 +
                cos(angle) * radius -
                28,
            top: MediaQuery.of(context).size.height / 2 +
                sin(angle) * radius -
                28,
            child: DeviceBubble(
              device: device,
              onTap: () => context.push(AppRoutes.send),
            )
                .animate()
                .fadeIn(
                  duration: BlinkDurations.standard,
                  delay: Duration(milliseconds: 100 * i),
                )
                .scale(begin: const Offset(0.6, 0.6)),
          );
        }),

        // ── Centre: "You" avatar ─────────────────────────────
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: BlinkColors.primary, width: 2.5),
            color: BlinkColors.darkSurface,
            boxShadow: [
              BoxShadow(
                color: BlinkColors.primary.withValues(alpha: 0.4),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(Icons.person_rounded,
              size: 32, color: BlinkColors.primaryLight),
        ).animate(effects: BlinkEffects.scaleIn),

        // ── Bottom status ────────────────────────────────────
        Positioned(
          bottom: 120,
          left: BlinkSpacing.xl,
          right: BlinkSpacing.xl,
          child: Text(
            devices.isEmpty
                ? AppStrings.discoverySearching
                : '${devices.length} device${devices.length == 1 ? '' : 's'} nearby — Tap to send',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: BlinkColors.darkTextSecondary,
                ),
          ).animate().fadeIn(duration: BlinkDurations.standard),
        ),

        // ── FAB: Select Files ────────────────────────────────
        Positioned(
          bottom: BlinkSpacing.xxl,
          child: _RadarFab(
            onPressed: () {
                Log.l(
                  'Select files action tapped',
                  source: LogSource.ui,
                  component: 'DiscoveryScreen',
                );
              // TODO: Open file picker
            },
          ).animate(effects: BlinkEffects.fadeSlideUp),
        ),
      ],
    );
  }
}

/// Floating pill button for the radar screen.
class _RadarFab extends StatelessWidget {
  final VoidCallback onPressed;
  const _RadarFab({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [BlinkColors.primary, BlinkColors.primaryLight],
        ),
        borderRadius: BorderRadius.circular(BlinkRadius.full),
        boxShadow: [
          BoxShadow(
            color: BlinkColors.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(BlinkRadius.full),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: BlinkSpacing.lg),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.attach_file_rounded,
                    color: BlinkColors.white, size: 20),
                const Gap(BlinkSpacing.sm),
                Text(
                  'Select Files',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: BlinkColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
