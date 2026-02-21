import 'dart:math';
import 'package:flutter/material.dart';

/// Paints animated concentric radar rings — the AirDrop-style discovery UI.
///
/// Controlled by a [Ticker] in the parent widget.
/// TODO: Wire up an AnimationController for the sweep animation.
class RadarPainter extends CustomPainter {
  final double animationValue;

  RadarPainter({this.animationValue = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final maxRadius = min(size.width, size.height) / 2;

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFF6C63FF).withValues(alpha: 0.25);

    // Draw 4 concentric rings
    for (var i = 1; i <= 4; i++) {
      canvas.drawCircle(centre, maxRadius * (i / 4), ringPaint);
    }

    // Sweep line (rotating)
    final sweepAngle = animationValue * 2 * pi;
    final sweepPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF6C63FF).withValues(alpha: 0.8),
          const Color(0xFF6C63FF).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: centre, radius: maxRadius));

    canvas.drawLine(
      centre,
      centre + Offset(cos(sweepAngle), sin(sweepAngle)) * maxRadius,
      sweepPaint,
    );
  }

  @override
  bool shouldRepaint(RadarPainter oldDelegate) =>
      animationValue != oldDelegate.animationValue;
}
