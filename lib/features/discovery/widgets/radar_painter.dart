import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Paints animated concentric radar rings — the AirDrop-style discovery UI.
///
/// Uses cyan (#00D9FF) rings with decreasing opacity and a rotating sweep
/// cone in purple gradient.
class RadarPainter extends CustomPainter {
  final double animationValue;

  RadarPainter({this.animationValue = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final maxRadius = min(size.width, size.height) * 0.42;

    // ── Concentric rings (cyan, decreasing opacity) ──────────
    final opacities = [0.25, 0.18, 0.12, 0.06];
    for (var i = 0; i < 4; i++) {
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = BlinkColors.accent.withValues(alpha: opacities[i]);
      canvas.drawCircle(centre, maxRadius * ((i + 1) / 4), ringPaint);
    }

    // ── Sweep cone (rotating gradient) ───────────────────────
    final sweepAngle = animationValue * 2 * pi;
    final sweepPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.sweep(
        centre,
        [
          BlinkColors.primary.withValues(alpha: 0.0),
          BlinkColors.primary.withValues(alpha: 0.15),
          BlinkColors.primary.withValues(alpha: 0.0),
        ],
        [0.0, 0.5, 1.0],
        TileMode.clamp,
        sweepAngle - 0.5,
        sweepAngle + 0.5,
      );
    canvas.drawCircle(centre, maxRadius, sweepPaint);

    // ── Sweep line ───────────────────────────────────────────
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = ui.Gradient.linear(
        centre,
        centre + Offset(cos(sweepAngle), sin(sweepAngle)) * maxRadius,
        [
          BlinkColors.primary.withValues(alpha: 0.8),
          BlinkColors.primary.withValues(alpha: 0.0),
        ],
      );
    canvas.drawLine(
      centre,
      centre + Offset(cos(sweepAngle), sin(sweepAngle)) * maxRadius,
      linePaint,
    );

    // ── Centre dot glow ──────────────────────────────────────
    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(
        centre,
        20,
        [
          BlinkColors.primary.withValues(alpha: 0.3),
          BlinkColors.primary.withValues(alpha: 0.0),
        ],
      );
    canvas.drawCircle(centre, 20, glowPaint);
  }

  @override
  bool shouldRepaint(RadarPainter oldDelegate) =>
      animationValue != oldDelegate.animationValue;
}
