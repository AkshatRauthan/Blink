import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import 'blink_button.dart';

/// Shows a modal dialog following Blink's design system.
///
/// Returns the result from button actions, or null if dismissed.
Future<T?> showBlinkDialog<T>({
  required BuildContext context,
  required Widget child,
  bool barrierDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withValues(alpha: 0.7),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (_, __, ___) => child,
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ),
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ).drive(Tween(begin: 0.9, end: 1.0)),
          child: child,
        ),
      );
    },
  );
}

/// Alert dialog with title, message, and single action button.
Future<void> showBlinkAlert({
  required BuildContext context,
  required String title,
  required String message,
  String buttonText = 'OK',
  VoidCallback? onPressed,
}) {
  return showBlinkDialog(
    context: context,
    child: BlinkAlertDialog(
      title: title,
      message: message,
      buttonText: buttonText,
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
    ),
  );
}

/// Confirmation dialog with title, message, and two action buttons.
Future<bool?> showBlinkConfirm({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  bool isDestructive = false,
}) {
  return showBlinkDialog<bool>(
    context: context,
    child: BlinkConfirmDialog(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      isDestructive: isDestructive,
    ),
  );
}

/// Base dialog container with consistent styling.
class BlinkDialogContainer extends StatelessWidget {
  const BlinkDialogContainer({
    super.key,
    required this.child,
    this.maxWidth,
  });

  final Widget child;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(BlinkSpacing.lg),
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? BlinkSpacing.dialogMaxWidth,
        ),
        decoration: BoxDecoration(
          color: BlinkColors.darkElevated,
          borderRadius: BorderRadius.circular(BlinkRadius.dialog),
          boxShadow: BlinkShadows.elevation3,
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(BlinkSpacing.lg),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Simple alert dialog.
class BlinkAlertDialog extends StatelessWidget {
  const BlinkAlertDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = 'OK',
    required this.onPressed,
    this.icon,
    this.iconColor,
  });

  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return BlinkDialogContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 48,
              color: iconColor ?? BlinkColors.primary,
            ),
            const Gap(BlinkSpacing.md),
          ],
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: BlinkColors.darkTextPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(BlinkSpacing.sm),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: BlinkColors.darkTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(BlinkSpacing.lg),
          BlinkButton(
            label: buttonText,
            onPressed: onPressed,
            isExpanded: true,
          ),
        ],
      ),
    );
  }
}

/// Confirmation dialog with two buttons.
class BlinkConfirmDialog extends StatelessWidget {
  const BlinkConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.isDestructive = false,
    this.icon,
  });

  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return BlinkDialogContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 48,
              color: isDestructive ? BlinkColors.error : BlinkColors.warning,
            ),
            const Gap(BlinkSpacing.md),
          ],
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: BlinkColors.darkTextPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(BlinkSpacing.sm),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: BlinkColors.darkTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(BlinkSpacing.lg),
          Row(
            children: [
              Expanded(
                child: BlinkButton(
                  label: cancelText,
                  variant: BlinkButtonVariant.ghost,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
              const Gap(BlinkSpacing.sm),
              Expanded(
                child: BlinkButton(
                  label: confirmText,
                  variant: isDestructive
                      ? BlinkButtonVariant.danger
                      : BlinkButtonVariant.primary,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Input dialog for single text input.
class BlinkInputDialog extends StatefulWidget {
  const BlinkInputDialog({
    super.key,
    required this.title,
    this.message,
    this.hint,
    this.initialValue,
    this.confirmText = 'Save',
    this.cancelText = 'Cancel',
    this.validator,
    this.maxLength,
  });

  final String title;
  final String? message;
  final String? hint;
  final String? initialValue;
  final String confirmText;
  final String cancelText;
  final String? Function(String)? validator;
  final int? maxLength;

  @override
  State<BlinkInputDialog> createState() => _BlinkInputDialogState();
}

class _BlinkInputDialogState extends State<BlinkInputDialog> {
  late TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onConfirm() {
    final error = widget.validator?.call(_controller.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return BlinkDialogContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: BlinkColors.darkTextPrimary,
            ),
          ),
          if (widget.message != null) ...[
            const Gap(BlinkSpacing.sm),
            Text(
              widget.message!,
              style: const TextStyle(
                fontSize: 14,
                color: BlinkColors.darkTextSecondary,
              ),
            ),
          ],
          const Gap(BlinkSpacing.md),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: widget.maxLength,
            style: const TextStyle(
              fontSize: 16,
              color: BlinkColors.darkTextPrimary,
            ),
            cursorColor: BlinkColors.primary,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(
                color: BlinkColors.darkTextTertiary,
              ),
              errorText: _error,
              filled: true,
              fillColor: BlinkColors.darkSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(BlinkRadius.input),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(BlinkRadius.input),
                borderSide: const BorderSide(color: BlinkColors.primary),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(BlinkRadius.input),
                borderSide: const BorderSide(color: BlinkColors.error),
              ),
              counterText: '',
            ),
            onChanged: (_) {
              if (_error != null) {
                setState(() => _error = null);
              }
            },
            onSubmitted: (_) => _onConfirm(),
          ),
          const Gap(BlinkSpacing.lg),
          Row(
            children: [
              Expanded(
                child: BlinkButton(
                  label: widget.cancelText,
                  variant: BlinkButtonVariant.ghost,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const Gap(BlinkSpacing.sm),
              Expanded(
                child: BlinkButton(
                  label: widget.confirmText,
                  onPressed: _onConfirm,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Show an input dialog and return the entered text.
Future<String?> showBlinkInputDialog({
  required BuildContext context,
  required String title,
  String? message,
  String? hint,
  String? initialValue,
  String confirmText = 'Save',
  String cancelText = 'Cancel',
  String? Function(String)? validator,
  int? maxLength,
}) {
  return showBlinkDialog<String>(
    context: context,
    child: BlinkInputDialog(
      title: title,
      message: message,
      hint: hint,
      initialValue: initialValue,
      confirmText: confirmText,
      cancelText: cancelText,
      validator: validator,
      maxLength: maxLength,
    ),
  );
}
