import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Blink elevation / shadow tokens.
///
/// Designed for a soft, layered aesthetic (think iOS depth system):
/// - **sm**  — subtle lift for cards, list tiles
/// - **md**  — modals, bottom sheets
/// - **lg**  — floating action buttons, top-level overlays
/// - **glow** — brand-colored ambient glow for primary actions
abstract class BlinkShadows {
  // ── Light mode ────────────────────────────────────────────────────
  static const List<BoxShadow> smLight = [
    BoxShadow(
      color: Color(0x0A000000), // 4 % black
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x05000000), // 2 % black
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> mdLight = [
    BoxShadow(
      color: Color(0x12000000), // 7 % black
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x08000000), // 3 % black
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> lgLight = [
    BoxShadow(
      color: Color(0x1A000000), // 10 % black
      blurRadius: 32,
      offset: Offset(0, 16),
    ),
    BoxShadow(
      color: Color(0x0D000000), // 5 % black
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  // ── Dark mode ─────────────────────────────────────────────────────
  static const List<BoxShadow> smDark = [
    BoxShadow(
      color: Color(0x30000000), // 19 % black
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> mdDark = [
    BoxShadow(
      color: Color(0x50000000), // 31 % black
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> lgDark = [
    BoxShadow(
      color: Color(0x70000000), // 44 % black
      blurRadius: 40,
      offset: Offset(0, 16),
    ),
  ];

  // ── Brand glow (primary button hover / pressed) ───────────────────
  static List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: BlinkColors.primary.withValues(alpha: 0.35),
      blurRadius: 24,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> accentGlow = [
    BoxShadow(
      color: BlinkColors.accent.withValues(alpha: 0.30),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  /// Returns the correct shadow set for the given [brightness] and [level].
  static List<BoxShadow> of(
    Brightness brightness, {
    ShadowLevel level = ShadowLevel.sm,
  }) {
    return switch ((brightness, level)) {
      (Brightness.light, ShadowLevel.sm) => smLight,
      (Brightness.light, ShadowLevel.md) => mdLight,
      (Brightness.light, ShadowLevel.lg) => lgLight,
      (Brightness.dark, ShadowLevel.sm) => smDark,
      (Brightness.dark, ShadowLevel.md) => mdDark,
      (Brightness.dark, ShadowLevel.lg) => lgDark,
    };
  }
}

enum ShadowLevel { sm, md, lg }
