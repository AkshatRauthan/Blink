import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';

/// Blink button variants following the Midnight Obsidian design system.
enum BlinkButtonVariant {
  /// Solid purple background, white text
  primary,

  /// Transparent with purple border
  secondary,

  /// No background, subtle text
  ghost,

  /// Red for destructive actions
  danger,
}

/// Blink button sizes
enum BlinkButtonSize {
  small,  // 40px height
  medium, // 48px height (default)
  large,  // 56px height
}

/// A customizable button following Blink's design system.
///
/// Supports multiple variants (primary, secondary, ghost, danger),
/// sizes, icons, and loading states.
class BlinkButton extends StatefulWidget {
  const BlinkButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = BlinkButtonVariant.primary,
    this.size = BlinkButtonSize.medium,
    this.icon,
    this.iconPosition = IconPosition.leading,
    this.isLoading = false,
    this.isExpanded = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final BlinkButtonVariant variant;
  final BlinkButtonSize size;
  final IconData? icon;
  final IconPosition iconPosition;
  final bool isLoading;
  final bool isExpanded;
  final bool enabled;

  @override
  State<BlinkButton> createState() => _BlinkButtonState();
}

class _BlinkButtonState extends State<BlinkButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  double get _height => switch (widget.size) {
    BlinkButtonSize.small => BlinkSpacing.buttonHeightSm,
    BlinkButtonSize.medium => BlinkSpacing.buttonHeight,
    BlinkButtonSize.large => 56,
  };

  double get _fontSize => switch (widget.size) {
    BlinkButtonSize.small => 13,
    BlinkButtonSize.medium => 14,
    BlinkButtonSize.large => 16,
  };

  double get _iconSize => switch (widget.size) {
    BlinkButtonSize.small => 18,
    BlinkButtonSize.medium => 20,
    BlinkButtonSize.large => 22,
  };

  EdgeInsets get _padding => switch (widget.size) {
    BlinkButtonSize.small => const EdgeInsets.symmetric(horizontal: 16),
    BlinkButtonSize.medium => const EdgeInsets.symmetric(horizontal: 24),
    BlinkButtonSize.large => const EdgeInsets.symmetric(horizontal: 32),
  };

  Color get _backgroundColor {
    if (!widget.enabled) {
      return BlinkColors.darkSurface.withValues(alpha: 0.5);
    }
    return switch (widget.variant) {
      BlinkButtonVariant.primary => _isPressed
          ? BlinkColors.primaryDark
          : _isHovered
              ? BlinkColors.primaryHover
              : BlinkColors.primary,
      BlinkButtonVariant.secondary => _isPressed
          ? BlinkColors.primaryMuted
          : _isHovered
              ? BlinkColors.primaryMuted.withValues(alpha: 0.1)
              : Colors.transparent,
      BlinkButtonVariant.ghost => _isPressed
          ? BlinkColors.darkHover
          : _isHovered
              ? BlinkColors.darkSurface
              : Colors.transparent,
      BlinkButtonVariant.danger => _isPressed
          ? BlinkColors.error.withValues(alpha: 0.8)
          : _isHovered
              ? BlinkColors.error.withValues(alpha: 0.9)
              : BlinkColors.error,
    };
  }

  Color get _foregroundColor {
    if (!widget.enabled) {
      return BlinkColors.darkTextTertiary;
    }
    return switch (widget.variant) {
      BlinkButtonVariant.primary => BlinkColors.white,
      BlinkButtonVariant.secondary => BlinkColors.primary,
      BlinkButtonVariant.ghost => BlinkColors.darkTextSecondary,
      BlinkButtonVariant.danger => BlinkColors.white,
    };
  }

  Border? get _border {
    if (widget.variant == BlinkButtonVariant.secondary && widget.enabled) {
      return Border.all(
        color: _isHovered ? BlinkColors.primaryHover : BlinkColors.primary,
        width: 1.5,
      );
    }
    return null;
  }

  List<BoxShadow> get _shadow {
    if (!widget.enabled || widget.variant == BlinkButtonVariant.ghost) {
      return [];
    }
    if (_isHovered && widget.variant == BlinkButtonVariant.primary) {
      return BlinkShadows.glowPrimary;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: widget.isExpanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: _iconSize,
            height: _iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(_foregroundColor),
            ),
          ),
          const SizedBox(width: BlinkSpacing.sm),
        ] else if (widget.icon != null && widget.iconPosition == IconPosition.leading) ...[
          Icon(widget.icon, size: _iconSize, color: _foregroundColor),
          const SizedBox(width: BlinkSpacing.sm),
        ],
        Text(
          widget.label,
          style: TextStyle(
            fontSize: _fontSize,
            fontWeight: FontWeight.w600,
            color: _foregroundColor,
          ),
        ),
        if (widget.icon != null && widget.iconPosition == IconPosition.trailing && !widget.isLoading) ...[
          const SizedBox(width: BlinkSpacing.sm),
          Icon(widget.icon, size: _iconSize, color: _foregroundColor),
        ],
      ],
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.enabled && !widget.isLoading
          ? SystemMouseCursors.click
          : SystemMouseCursors.forbidden,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.enabled && !widget.isLoading ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: _height,
          padding: _padding,
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(BlinkRadius.button),
            border: _border,
            boxShadow: _shadow,
          ),
          child: content,
        ),
      ),
    );
  }
}

/// Icon button variant — circular touch target
class BlinkIconButton extends StatefulWidget {
  const BlinkIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 44,
    this.iconSize = 24,
    this.color,
    this.backgroundColor,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color? color;
  final Color? backgroundColor;
  final String? tooltip;

  @override
  State<BlinkIconButton> createState() => _BlinkIconButtonState();
}

class _BlinkIconButtonState extends State<BlinkIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final button = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onPressed != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isHovered
                ? (widget.backgroundColor ?? BlinkColors.darkSurface)
                : (widget.backgroundColor ?? Colors.transparent),
          ),
          child: Icon(
            widget.icon,
            size: widget.iconSize,
            color: widget.color ?? BlinkColors.darkTextPrimary,
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }
    return button;
  }
}

enum IconPosition { leading, trailing }
