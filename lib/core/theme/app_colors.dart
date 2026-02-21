import 'package:flutter/material.dart';

/// Blink's semantic colour palette.
///
/// Designed for an AirDrop-like aesthetic: deep purples, electric accents,
/// soft neutrals. Works in both light and dark modes via [BlinkColorScheme].
///
/// Usage: `BlinkColors.primary` for raw values,
///        `context.colors.surface` for theme-aware access (via extension).
abstract class BlinkColors {
  // ── Brand ────────────────────────────────────────────────────────────────
  /// Core brand purple — used for primary actions, FABs, active states.
  static const Color primary = Color(0xFF6C63FF);

  /// Lighter tint for hover/focus/pressed states.
  static const Color primaryLight = Color(0xFF9D97FF);

  /// Dark variant for text-on-primary contexts.
  static const Color primaryDark = Color(0xFF4A42DB);

  // ── Accent ───────────────────────────────────────────────────────────────
  /// Electric cyan — discovery radar rings, active connections.
  static const Color accent = Color(0xFF00D9FF);

  /// Warm coral — notifications, alerts, send actions.
  static const Color coral = Color(0xFFFF6B6B);

  /// Fresh mint — success states, completed transfers.
  static const Color mint = Color(0xFF2ED47A);

  /// Amber — warning, paused states.
  static const Color amber = Color(0xFFFFBB33);

  // ── Neutral ──────────────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // ── Light mode surfaces ──────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF8F9FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF0F1F5);
  static const Color lightCardBorder = Color(0xFFE8E9EE);

  // ── Dark mode surfaces ───────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0D0D12);
  static const Color darkSurface = Color(0xFF1A1A24);
  static const Color darkSurfaceVariant = Color(0xFF252533);
  static const Color darkCardBorder = Color(0xFF2E2E3E);

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextTertiary = Color(0xFFA0A5B5);

  static const Color darkTextPrimary = Color(0xFFF3F4F8);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextTertiary = Color(0xFF6B7280);

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF2ED47A);
  static const Color warning = Color(0xFFFFBB33);
  static const Color info = Color(0xFF3B82F6);

  // ── Gradients (raw stops) ────────────────────────────────────────────────
  /// Hero gradient for the discovery radar background.
  static const List<Color> radarGradient = [
    Color(0xFF6C63FF),
    Color(0xFF00D9FF),
  ];

  /// Gradient for active transfer progress bars.
  static const List<Color> progressGradient = [
    Color(0xFF6C63FF),
    Color(0xFF9D97FF),
  ];

  /// Subtle surface gradient for card backgrounds.
  static const List<Color> cardGradientLight = [
    Color(0xFFF8F9FC),
    Color(0xFFFFFFFF),
  ];

  static const List<Color> cardGradientDark = [
    Color(0xFF1A1A24),
    Color(0xFF252533),
  ];
}

/// Pre-built [LinearGradient] instances for the most common UI patterns.
abstract class BlinkGradients {
  static const LinearGradient radar = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: BlinkColors.radarGradient,
  );

  static const LinearGradient progress = LinearGradient(
    colors: BlinkColors.progressGradient,
  );

  static const LinearGradient primaryButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [BlinkColors.primary, BlinkColors.primaryLight],
  );

  static LinearGradient get cardLight => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: BlinkColors.cardGradientLight,
      );

  static LinearGradient get cardDark => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: BlinkColors.cardGradientDark,
      );
}
