import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// A text input field following Blink's Midnight Obsidian design system.
///
/// Features:
/// - Dark surface background (#1A1A2E)
/// - Subtle border, focus highlight (#6C63FF)
/// - Error state with red border
/// - Optional prefix/suffix icons
/// - Optional label and hint text
class BlinkInput extends StatefulWidget {
  const BlinkInput({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.autofocus = false,
    this.autocorrect = true,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool autofocus;
  final bool autocorrect;
  final TextCapitalization textCapitalization;

  @override
  State<BlinkInput> createState() => _BlinkInputState();
}

class _BlinkInputState extends State<BlinkInput> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  bool get _hasError => widget.errorText != null && widget.errorText!.isNotEmpty;

  Color get _borderColor {
    if (_hasError) return BlinkColors.error;
    if (_isFocused) return BlinkColors.primary;
    return BlinkColors.darkHover;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: BlinkColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: BlinkSpacing.sm),
        ],

        // Input field
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: widget.enabled
                ? BlinkColors.darkSurface
                : BlinkColors.darkSurface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(BlinkRadius.input),
            border: Border.all(color: _borderColor, width: 1),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            obscureText: widget.obscureText,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            inputFormatters: widget.inputFormatters,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            onTap: widget.onTap,
            autofocus: widget.autofocus,
            autocorrect: widget.autocorrect,
            textCapitalization: widget.textCapitalization,
            style: TextStyle(
              fontSize: 16,
              color: widget.enabled
                  ? BlinkColors.darkTextPrimary
                  : BlinkColors.darkTextTertiary,
            ),
            cursorColor: BlinkColors.primary,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(
                fontSize: 16,
                color: BlinkColors.darkTextTertiary,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      size: 20,
                      color: _isFocused
                          ? BlinkColors.primary
                          : BlinkColors.darkTextTertiary,
                    )
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? GestureDetector(
                      onTap: widget.onSuffixTap,
                      child: widget.suffixIcon,
                    )
                  : null,
              contentPadding: EdgeInsets.symmetric(
                horizontal: BlinkSpacing.md,
                vertical: (BlinkSpacing.inputHeight - 24) / 2,
              ),
              border: InputBorder.none,
              counterText: '', // Hide the maxLength counter
            ),
          ),
        ),

        // Error or helper text
        if (_hasError || widget.helperText != null) ...[
          const SizedBox(height: BlinkSpacing.xs),
          Text(
            _hasError ? widget.errorText! : widget.helperText!,
            style: TextStyle(
              fontSize: 12,
              color: _hasError ? BlinkColors.error : BlinkColors.darkTextTertiary,
            ),
          ),
        ],
      ],
    );
  }
}

/// A search input with search icon and clear button.
class BlinkSearchInput extends StatefulWidget {
  const BlinkSearchInput({
    super.key,
    this.controller,
    this.hint = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;

  @override
  State<BlinkSearchInput> createState() => _BlinkSearchInputState();
}

class _BlinkSearchInputState extends State<BlinkSearchInput> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _onClear() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return BlinkInput(
      controller: _controller,
      hint: widget.hint,
      prefixIcon: Icons.search_rounded,
      suffixIcon: _hasText
          ? Icon(
              Icons.close_rounded,
              size: 20,
              color: BlinkColors.darkTextSecondary,
            )
          : null,
      onSuffixTap: _onClear,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      autofocus: widget.autofocus,
    );
  }
}
