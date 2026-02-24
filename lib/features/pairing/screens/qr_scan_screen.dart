import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../app.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../providers/pairing_provider.dart';

/// QR code scanner screen for secure device pairing.
///
/// Stitch screen: "Blink Secure QR Scanner Screen" (bc1b72bd074a4bf196e53400da767396)
class QrScanScreen extends ConsumerStatefulWidget {
  const QrScanScreen({super.key});

  @override
  ConsumerState<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends ConsumerState<QrScanScreen> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
  );
  bool _scanned = false;
  bool _torchEnabled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null) return;
    _scanned = true;
    ref.read(pairingNotifierProvider.notifier).handleScannedQr(code);
    // Navigate back on successful scan
    if (mounted) context.pop();
  }

  void _toggleTorch() {
    _controller.toggleTorch();
    setState(() => _torchEnabled = !_torchEnabled);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Scan QR Code',
          style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // ── Camera ──────────────────────────────────────
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // ── Dark overlay with cutout ────────────────────
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.55),
              BlendMode.srcOver,
            ),
            child: const SizedBox.expand(),
          ),

          // ── Viewfinder frame ────────────────────────────
          Center(
            child: SizedBox(
              width: 260,
              height: 260,
              child: CustomPaint(
                painter: _ViewfinderPainter(color: BlinkColors.accent),
              ),
            ),
          ).animate(effects: BlinkEffects.scaleIn),

          // ── Scanning line animation ─────────────────────
          Center(
            child: SizedBox(
              width: 240,
              height: 260,
              child: _ScanningLine(),
            ),
          ),

          // ── Instructions ────────────────────────────────
          Positioned(
            bottom: 180,
            left: BlinkSpacing.xl,
            right: BlinkSpacing.xl,
            child: Column(
              children: [
                Text(
                  'Point at the other device\'s QR code',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const Gap(BlinkSpacing.sm),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_rounded,
                        size: 14, color: BlinkColors.accent),
                    const Gap(BlinkSpacing.xs),
                    Text(
                      'Offline encrypted exchange',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: BlinkColors.accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ).animate().fadeIn(duration: BlinkDurations.standard),
          ),

          // ── Bottom controls ────────────────────────────
          Positioned(
            bottom: BlinkSpacing.xxl,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Torch toggle
                GestureDetector(
                  onTap: _toggleTorch,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _torchEnabled
                          ? BlinkColors.accent.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.15),
                      border: Border.all(
                        color: _torchEnabled
                            ? BlinkColors.accent
                            : Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      _torchEnabled
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      color: _torchEnabled
                          ? BlinkColors.accent
                          : Colors.white.withValues(alpha: 0.7),
                      size: 20,
                    ),
                  ),
                ),
                const Gap(BlinkSpacing.lg),
                // Toggle: Show QR / Scan QR
                _PairingToggle(activeTab: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated horizontal scanning line.
class _ScanningLine extends StatefulWidget {
  @override
  State<_ScanningLine> createState() => _ScanningLineState();
}

class _ScanningLineState extends State<_ScanningLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Align(
          alignment: Alignment(0, -1 + 2 * _controller.value),
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  BlinkColors.accent.withValues(alpha: 0.0),
                  BlinkColors.accent,
                  BlinkColors.accent.withValues(alpha: 0.0),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: BlinkColors.accent.withValues(alpha: 0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Corner-bracket viewfinder painter.
class _ViewfinderPainter extends CustomPainter {
  final Color color;
  _ViewfinderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 30.0;
    const r = 16.0;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(0, cornerLength)
        ..lineTo(0, r)
        ..quadraticBezierTo(0, 0, r, 0)
        ..lineTo(cornerLength, 0),
      paint,
    );

    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerLength, 0)
        ..lineTo(size.width - r, 0)
        ..quadraticBezierTo(size.width, 0, size.width, r)
        ..lineTo(size.width, cornerLength),
      paint,
    );

    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width, size.height - cornerLength)
        ..lineTo(size.width, size.height - r)
        ..quadraticBezierTo(
            size.width, size.height, size.width - r, size.height)
        ..lineTo(size.width - cornerLength, size.height),
      paint,
    );

    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(cornerLength, size.height)
        ..lineTo(r, size.height)
        ..quadraticBezierTo(0, size.height, 0, size.height - r)
        ..lineTo(0, size.height - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Segmented toggle between Show QR and Scan QR modes.
class _PairingToggle extends StatelessWidget {
  final int activeTab;
  const _PairingToggle({required this.activeTab});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(BlinkRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleChip(
            label: 'Show QR',
            isActive: activeTab == 0,
            onTap: () => context.pushReplacement(AppRoutes.qrShow),
          ),
          _ToggleChip(
            label: 'Scan QR',
            isActive: activeTab == 1,
            onTap: () {},
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
                    : Colors.white.withValues(alpha: 0.6),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
        ),
      ),
    );
  }
}
