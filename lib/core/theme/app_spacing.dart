/// Blink "Midnight Obsidian" Design System — Spacing & Radius Tokens
///
/// Based on 4px base grid system. Consistent spacing creates visual rhythm.
///
/// Usage:
/// ```dart
/// Padding(padding: EdgeInsets.all(BlinkSpacing.md))
/// BorderRadius.circular(BlinkRadius.card)
/// ```
abstract class BlinkSpacing {
  // ══════════════════════════════════════════════════════════════════════════
  // SPACING SCALE (padding / margin / gap)
  // ══════════════════════════════════════════════════════════════════════════

  static const double space0 = 0;
  static const double space1 = 4;   // Tight inline spacing
  static const double space2 = 8;   // Icon gaps, compact padding
  static const double space3 = 12;  // List item padding
  static const double space4 = 16;  // Standard padding
  static const double space5 = 20;  // Section gaps
  static const double space6 = 24;  // Card padding
  static const double space8 = 32;  // Section separation
  static const double space10 = 40; // Large gaps
  static const double space12 = 48; // Screen margins

  // Legacy aliases for backward compatibility
  static const double xxs = 2;
  static const double xs = space1;
  static const double sm = space2;
  static const double md = space4;
  static const double lg = space6;
  static const double xl = space8;
  static const double xxl = space12;
  static const double xxxl = 64;

  // ══════════════════════════════════════════════════════════════════════════
  // ICON SIZES
  // ══════════════════════════════════════════════════════════════════════════

  static const double iconXs = 16;
  static const double iconSm = 20;  // Compact icons
  static const double iconMd = 24;  // Standard icons
  static const double iconLg = 32;  // Featured icons
  static const double iconXl = 48;
  static const double iconXxl = 64; // Large empty state icons

  // ══════════════════════════════════════════════════════════════════════════
  // COMPONENT HEIGHTS
  // ══════════════════════════════════════════════════════════════════════════

  static const double touchTarget = 44;     // Minimum touch target (iOS standard)
  static const double buttonHeight = 48;    // Standard button
  static const double buttonHeightSm = 40;  // Compact button
  static const double inputHeight = 48;     // Mobile inputs
  static const double inputHeightDesktop = 44; // Desktop inputs
  static const double appBarHeight = 56;
  static const double bottomNavHeight = 80; // Including safe area
  static const double sidebarWidth = 72;    // Collapsed sidebar rail
  static const double sidebarExpandedWidth = 240; // Expanded sidebar

  // ══════════════════════════════════════════════════════════════════════════
  // AVATAR SIZES
  // ══════════════════════════════════════════════════════════════════════════

  static const double avatarXs = 32;
  static const double avatarSm = 40;
  static const double avatarMd = 56;
  static const double avatarLg = 80;
  static const double avatarXl = 120;

  // ══════════════════════════════════════════════════════════════════════════
  // CONTENT WIDTHS
  // ══════════════════════════════════════════════════════════════════════════

  static const double maxContentWidth = 600;   // Mobile max
  static const double maxContentWidthTablet = 720;
  static const double maxContentWidthDesktop = 1200;
  static const double cardMinWidth = 280;
  static const double dialogMaxWidth = 400;    // Mobile dialogs
  static const double dialogMaxWidthDesktop = 480;
}

/// Border-radius presets aligned with design system.
abstract class BlinkRadius {
  static const double none = 0;
  static const double xs = 4;
  static const double sm = 6;     // Chips, small badges
  static const double md = 12;    // Buttons, inputs, cards
  static const double lg = 16;    // Larger cards
  static const double xl = 24;    // Bottom sheets, large cards
  static const double xxl = 32;
  static const double full = 9999; // Pill / circle

  // Semantic aliases
  static const double button = md;
  static const double input = md;
  static const double card = lg;
  static const double dialog = xl;
  static const double avatar = full;
}
