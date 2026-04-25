import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class RadarPainter extends CustomPainter {
  final double animationValue;
  final double pulseValue;
  final int deviceCount;

  RadarPainter({
    this.animationValue = 0.0,
    this.pulseValue = 0.0,
    this.deviceCount = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final maxRadius = min(size.width, size.height) * 0.40;

    _drawAmbientGlow(canvas, centre, maxRadius);
    _drawRings(canvas, centre, maxRadius);
    _drawRingDots(canvas, centre, maxRadius);
    _drawSweepCone(canvas, centre, maxRadius);
    _drawSweepLine(canvas, centre, maxRadius);
    _drawCentreGlow(canvas, centre);
  }

  void _drawAmbientGlow(Canvas canvas, Offset centre, double maxRadius) {
    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(
        centre,
        maxRadius * 1.2,
        [
          BlinkColors.primary.withValues(alpha: 0.06 + pulseValue * 0.03),
          BlinkColors.primary.withValues(alpha: 0.02),
          BlinkColors.accent.withValues(alpha: 0.01),
          Colors.transparent,
        ],
        [0.0, 0.4, 0.7, 1.0],
      );
    canvas.drawCircle(centre, maxRadius * 1.2, glowPaint);
  }

  void _drawRings(Canvas canvas, Offset centre, double maxRadius) {
    const ringCount = 5;
    for (var i = 1; i <= ringCount; i++) {
      final fraction = i / ringCount;
      final radius = maxRadius * fraction;
      final baseAlpha = 0.12 - (i * 0.015);
      final alpha = (baseAlpha + pulseValue * 0.02).clamp(0.0, 1.0);

      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = i == ringCount ? 0.5 : 0.8
        ..color = BlinkColors.accent.withValues(alpha: alpha);
      canvas.drawCircle(centre, radius, ringPaint);
    }
  }

  void _drawRingDots(Canvas canvas, Offset centre, double maxRadius) {
    final rng = Random(42);
    const dotCount = 24;
    for (var i = 0; i < dotCount; i++) {
      final ringFraction = (rng.nextInt(5) + 1) / 5;
      final baseAngle = (2 * pi / dotCount) * i + rng.nextDouble() * 0.3;
      final angle = baseAngle + animationValue * pi * 0.1;
      final radius = maxRadius * ringFraction;
      final pos = centre + Offset(cos(angle), sin(angle)) * radius;

      final distFromSweep =
          ((angle % (2 * pi)) - (animationValue * 2 * pi) % (2 * pi)).abs();
      final brightness = distFromSweep < 0.8 ? (0.8 - distFromSweep) / 0.8 : 0.0;
      final dotAlpha = (0.08 + brightness * 0.4).clamp(0.0, 1.0);

      final dotPaint = Paint()
        ..color = BlinkColors.accent.withValues(alpha: dotAlpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
      canvas.drawCircle(pos, 1.5 + brightness * 1.0, dotPaint);
    }
  }

  void _drawSweepCone(Canvas canvas, Offset centre, double maxRadius) {
    final sweepAngle = animationValue * 2 * pi;
    final sweepPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.sweep(
        centre,
        [
          Colors.transparent,
          BlinkColors.primary.withValues(alpha: 0.0),
          BlinkColors.primary.withValues(alpha: 0.12),
          BlinkColors.accent.withValues(alpha: 0.06),
          Colors.transparent,
        ],
        [0.0, 0.0, 0.3, 0.8, 1.0],
        TileMode.clamp,
        sweepAngle - 0.7,
        sweepAngle + 0.1,
      );
    canvas.drawCircle(centre, maxRadius, sweepPaint);
  }

  void _drawSweepLine(Canvas canvas, Offset centre, double maxRadius) {
    final sweepAngle = animationValue * 2 * pi;
    final endPoint = centre + Offset(cos(sweepAngle), sin(sweepAngle)) * maxRadius;

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..shader = ui.Gradient.linear(
        centre,
        endPoint,
        [
          BlinkColors.primary.withValues(alpha: 0.6),
          BlinkColors.accent.withValues(alpha: 0.3),
          Colors.transparent,
        ],
        [0.0, 0.6, 1.0],
      );
    canvas.drawLine(centre, endPoint, linePaint);

    final tipGlow = Paint()
      ..color = BlinkColors.accent.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(endPoint, 3, tipGlow);
  }

  void _drawCentreGlow(Canvas canvas, Offset centre) {
    final glowSize = 24.0 + pulseValue * 8.0;
    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(
        centre,
        glowSize,
        [
          BlinkColors.primary.withValues(alpha: 0.25 + pulseValue * 0.15),
          BlinkColors.accent.withValues(alpha: 0.08),
          Colors.transparent,
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawCircle(centre, glowSize, glowPaint);
  }

  @override
  bool shouldRepaint(RadarPainter oldDelegate) =>
      animationValue != oldDelegate.animationValue ||
      pulseValue != oldDelegate.pulseValue ||
      deviceCount != oldDelegate.deviceCount;
}
