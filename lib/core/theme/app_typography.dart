import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Blink's type scale — built on **Inter** (the closest OSS match to SF Pro).
///
/// Follows Material 3 naming (`displayLarge`, `bodyMedium`, etc.) but with
/// custom sizing and letter-spacing tuned for a clean, editorial aesthetic.
///
/// Usage: `Theme.of(context).textTheme.headlineMedium`
///   or:  `BlinkTypography.light.headlineMedium`
abstract class BlinkTypography {
  /// Generates the complete [TextTheme] for the given brightness.
  static TextTheme textTheme(Brightness brightness) {
    final color = brightness == Brightness.light
        ? const Color(0xFF1A1A2E)
        : const Color(0xFFF3F4F8);

    final secondary = brightness == Brightness.light
        ? const Color(0xFF6B7280)
        : const Color(0xFF9CA3AF);

    return GoogleFonts.interTextTheme(
      TextTheme(
        // ── Display (hero numbers, splash screens) ─────────────────────
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.5,
          height: 1.1,
          color: color,
        ),
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.0,
          height: 1.15,
          color: color,
        ),
        displaySmall: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          height: 1.2,
          color: color,
        ),

        // ── Headline (section titles, screen titles) ───────────────────
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          height: 1.25,
          color: color,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          height: 1.3,
          color: color,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
          height: 1.35,
          color: color,
        ),

        // ── Title (cards, list tiles, app bars) ────────────────────────
        titleLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.35,
          color: color,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          height: 1.4,
          color: color,
        ),
        titleSmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          height: 1.4,
          color: color,
        ),

        // ── Body (descriptions, paragraphs) ───────────────────────────
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.15,
          height: 1.5,
          color: color,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.15,
          height: 1.5,
          color: color,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
          height: 1.5,
          color: secondary,
        ),

        // ── Label (buttons, chips, badges) ────────────────────────────
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          height: 1.4,
          color: color,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
          height: 1.4,
          color: secondary,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.4,
          color: secondary,
        ),
      ),
    );
  }
}
