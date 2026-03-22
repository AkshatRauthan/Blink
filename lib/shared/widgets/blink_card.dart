import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';

/// A card component following Blink's Midnight Obsidian design system.
///
/// Uses background color shifts (no borders) per the "No-Line Rule".
class BlinkCard extends StatelessWidget {
  const BlinkCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.elevation = 1,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.showGlow = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? backgroundColor;
  final int elevation;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool showGlow;

  List<BoxShadow> get _shadow => switch (elevation) {
    0 => BlinkShadows.elevation0,
    1 => BlinkShadows.elevation1,
    2 => BlinkShadows.elevation2,
    3 => BlinkShadows.elevation3,
    _ => BlinkShadows.elevation4,
  };

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? BlinkColors.darkSurface;
    final effectiveBorderRadius = borderRadius ?? BlinkRadius.card;
    
    Widget card = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: padding ?? const EdgeInsets.all(BlinkSpacing.md),
      margin: margin,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        boxShadow: [
          ..._shadow,
          if (isSelected) ...BlinkShadows.glowPrimary,
          if (showGlow) ...BlinkShadows.glowAccent,
        ],
        border: isSelected
            ? Border.all(color: BlinkColors.primary, width: 2)
            : null,
      ),
      child: child,
    );

    if (onTap != null || onLongPress != null) {
      card = _InteractiveCard(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: effectiveBorderRadius,
        child: card,
      );
    }

    return card;
  }
}

class _InteractiveCard extends StatefulWidget {
  const _InteractiveCard({
    required this.child,
    this.onTap,
    this.onLongPress,
    required this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double borderRadius;

  @override
  State<_InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<_InteractiveCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              color: _isHovered
                  ? BlinkColors.darkHover.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// A surface container for grouping content (like settings sections).
class BlinkSurface extends StatelessWidget {
  const BlinkSurface({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(BlinkSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor ?? BlinkColors.darkSurface,
        borderRadius: BorderRadius.circular(borderRadius ?? BlinkRadius.card),
      ),
      child: child,
    );
  }
}

/// An elevated card for dialogs and modals.
class BlinkElevatedCard extends StatelessWidget {
  const BlinkElevatedCard({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? BlinkSpacing.dialogMaxWidth,
      ),
      padding: padding ?? const EdgeInsets.all(BlinkSpacing.lg),
      decoration: BoxDecoration(
        color: BlinkColors.darkElevated,
        borderRadius: BorderRadius.circular(BlinkRadius.dialog),
        boxShadow: BlinkShadows.elevation3,
      ),
      child: child,
    );
  }
}
