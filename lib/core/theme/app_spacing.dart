/// Blink spacing & radius tokens — 4 px base grid.
///
/// Usage:
/// ```dart
/// Padding(padding: EdgeInsets.all(BlinkSpacing.md))
/// BorderRadius.circular(BlinkRadius.lg)
/// ```
abstract class BlinkSpacing {
  // ── Spacing (padding / margin / gap) ──────────────────────────────
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  // ── Icon sizes ────────────────────────────────────────────────────
  static const double iconSm = 16;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 48;

  // ── Touch-target & hit-test minimums ──────────────────────────────
  static const double touchTarget = 48;
  static const double buttonHeight = 52;
  static const double inputHeight = 52;
  static const double appBarHeight = 56;

  // ── Content widths ────────────────────────────────────────────────
  static const double maxContentWidth = 600;
  static const double cardMinWidth = 280;
}

/// Border-radius presets.
abstract class BlinkRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double full = 999; // pill / circle
}
