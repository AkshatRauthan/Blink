import 'package:flutter/material.dart';

/// Blink "Midnight Obsidian" Design System — Colour Tokens
///
/// A modern dark-first palette with electric purple primary and cyan accents.
/// Follows the "No-Line Rule": visual hierarchy through background shifts, not borders.
///
/// Usage:
/// - Raw values: `BlinkColors.primary`
/// - Theme-aware: `context.colors.surface` (via extension)
abstract class BlinkColors {
  // ══════════════════════════════════════════════════════════════════════════
  // BRAND COLORS
  // ══════════════════════════════════════════════════════════════════════════

  /// Electric Violet — primary actions, FABs, active states, buttons
  static const Color primary = Color(0xFF6C63FF);

  /// Hover/focus state for primary
  static const Color primaryHover = Color(0xFF7C74FF);

  /// Muted primary (20% opacity) — backgrounds, subtle highlights
  static const Color primaryMuted = Color(0x336C63FF);

  /// Darker variant for pressed states
  static const Color primaryDark = Color(0xFF5A52E0);

  /// Legacy alias
  static const Color primaryLight = Color(0xFF9D97FF);

  // ══════════════════════════════════════════════════════════════════════════
  // ACCENT COLORS
  // ══════════════════════════════════════════════════════════════════════════

  /// Cyan — highlights, progress bars, active indicators
  static const Color accent = Color(0xFF00D9FF);

  /// Muted accent (20% opacity) — glows, subtle backgrounds
  static const Color accentMuted = Color(0x3300D9FF);

  // ══════════════════════════════════════════════════════════════════════════
  // SEMANTIC COLORS
  // ══════════════════════════════════════════════════════════════════════════

  /// Success — completed, online, verified
  static const Color success = Color(0xFF4ADE80);
  static const Color successMuted = Color(0x334ADE80);

  /// Warning — pending, caution, paused
  static const Color warning = Color(0xFFFBBF24);
  static const Color warningMuted = Color(0x33FBBF24);

  /// Error — failed, offline, errors
  static const Color error = Color(0xFFF87171);
  static const Color errorMuted = Color(0x33F87171);

  /// Info — informational
  static const Color info = Color(0xFF60A5FA);
  static const Color infoMuted = Color(0x3360A5FA);

  // Legacy aliases
  static const Color mint = success;
  static const Color coral = error;
  static const Color amber = warning;

  // ══════════════════════════════════════════════════════════════════════════
  // NEUTRAL COLORS
  // ══════════════════════════════════════════════════════════════════════════

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // ══════════════════════════════════════════════════════════════════════════
  // DARK MODE SURFACES (Primary theme)
  // ══════════════════════════════════════════════════════════════════════════

  /// True black base — OLED optimization, splash screens
  static const Color darkBase = Color(0xFF000000);

  /// Main app background
  static const Color darkBackground = Color(0xFF0D0D12);

  /// Cards, containers, elevated surfaces
  static const Color darkSurface = Color(0xFF1A1A2E);

  /// Modals, dialogs, dropdowns
  static const Color darkElevated = Color(0xFF2A2A3C);

  /// Hover states on surfaces
  static const Color darkHover = Color(0xFF35354A);

  /// Legacy aliases
  static const Color darkSurfaceVariant = darkElevated;
  static const Color darkCardBorder = Color(0xFF35354A);

  // ══════════════════════════════════════════════════════════════════════════
  // LIGHT MODE SURFACES
  // ══════════════════════════════════════════════════════════════════════════

  static const Color lightBackground = Color(0xFFF8F9FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF0F1F5);
  static const Color lightElevated = Color(0xFFFFFFFF);
  static const Color lightHover = Color(0xFFE8E9EE);
  static const Color lightCardBorder = Color(0xFFE8E9EE);

  // ══════════════════════════════════════════════════════════════════════════
  // TEXT COLORS
  // ══════════════════════════════════════════════════════════════════════════

  // Dark mode text (on dark backgrounds)
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFA0A0B0);
  static const Color darkTextTertiary = Color(0xFF666680);

  // Light mode text (on light backgrounds)
  static const Color lightTextPrimary = Color(0xFF0D0D12);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextTertiary = Color(0xFFA0A5B5);

  // Inverse text (on colored backgrounds)
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFF0D0D12);

  // ══════════════════════════════════════════════════════════════════════════
  // GRADIENTS (raw color stops)
  // ══════════════════════════════════════════════════════════════════════════

  /// Hero gradient for discovery radar
  static const List<Color> radarGradient = [primary, accent];

  /// Progress bars
  static const List<Color> progressGradient = [primary, primaryHover];

  /// Card backgrounds (dark)
  static const List<Color> cardGradientDark = [darkSurface, darkElevated];

  /// Card backgrounds (light)
  static const List<Color> cardGradientLight = [lightSurface, lightSurfaceVariant];
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
