import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Blink "Midnight Obsidian" Design System — Elevation & Shadow Tokens
///
/// Four-level elevation system for depth and focus:
/// - **elevation0** — Flat surfaces, no shadow
/// - **elevation1** — Cards, containers
/// - **elevation2** — Dropdowns, popovers
/// - **elevation3** — Modals, dialogs
/// - **elevation4** — Full-screen overlays
///
/// Plus glow effects for interactive elements.
abstract class BlinkShadows {
  // ══════════════════════════════════════════════════════════════════════════
  // ELEVATION SYSTEM (DARK MODE - PRIMARY)
  // ══════════════════════════════════════════════════════════════════════════

  /// Level 0: No shadow (flat surfaces)
  static const List<BoxShadow> elevation0 = [];

  /// Level 1: Cards, containers — subtle lift
  static const List<BoxShadow> elevation1 = [
    BoxShadow(
      color: Color(0x66000000), // 40% black
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Level 2: Dropdowns, popovers
  static const List<BoxShadow> elevation2 = [
    BoxShadow(
      color: Color(0x80000000), // 50% black
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  /// Level 3: Modals, dialogs
  static const List<BoxShadow> elevation3 = [
    BoxShadow(
      color: Color(0x99000000), // 60% black
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
  ];

  /// Level 4: Full-screen overlays
  static const List<BoxShadow> elevation4 = [
    BoxShadow(
      color: Color(0xB3000000), // 70% black
      blurRadius: 48,
      offset: Offset(0, 16),
    ),
  ];

  // ══════════════════════════════════════════════════════════════════════════
  // GLOW EFFECTS (Interactive elements)
  // ══════════════════════════════════════════════════════════════════════════

  /// Primary button focus/hover glow
  static List<BoxShadow> glowPrimary = [
    BoxShadow(
      color: BlinkColors.primary.withValues(alpha: 0.5),
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];

  /// Accent highlight glow (active device, selected item)
  static List<BoxShadow> glowAccent = [
    BoxShadow(
      color: BlinkColors.accent.withValues(alpha: 0.5),
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];

  /// Success indicator glow (online status)
  static List<BoxShadow> glowSuccess = [
    BoxShadow(
      color: BlinkColors.success.withValues(alpha: 0.4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  /// Error indicator glow
  static List<BoxShadow> glowError = [
    BoxShadow(
      color: BlinkColors.error.withValues(alpha: 0.4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  // ══════════════════════════════════════════════════════════════════════════
  // LEGACY ALIASES (backward compatibility)
  // ══════════════════════════════════════════════════════════════════════════

  static const List<BoxShadow> smLight = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x05000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> mdLight = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> lgLight = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 32,
      offset: Offset(0, 16),
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> smDark = elevation1;
  static const List<BoxShadow> mdDark = elevation2;
  static const List<BoxShadow> lgDark = elevation3;

  static List<BoxShadow> primaryGlow = glowPrimary;
  static List<BoxShadow> accentGlow = glowAccent;

  /// Returns the correct shadow set for the given [brightness] and [level].
  static List<BoxShadow> of(
    Brightness brightness, {
    ShadowLevel level = ShadowLevel.sm,
  }) {
    return switch ((brightness, level)) {
      (Brightness.light, ShadowLevel.sm) => smLight,
      (Brightness.light, ShadowLevel.md) => mdLight,
      (Brightness.light, ShadowLevel.lg) => lgLight,
      (Brightness.dark, ShadowLevel.sm) => elevation1,
      (Brightness.dark, ShadowLevel.md) => elevation2,
      (Brightness.dark, ShadowLevel.lg) => elevation3,
    };
  }
}

enum ShadowLevel { sm, md, lg }
