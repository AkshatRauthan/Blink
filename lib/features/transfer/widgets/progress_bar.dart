import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Gradient-animated linear progress bar for a file transfer.
class TransferProgressBar extends StatelessWidget {
  /// Progress value between 0.0 and 1.0.
  final double progress;

  /// Optional height override (default 6).
  final double height;

  /// Optional gradient colours override.
  final List<Color>? gradientColors;

  const TransferProgressBar({
    super.key,
    required this.progress,
    this.height = 6,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final colors =
        gradientColors ?? [BlinkColors.primary, BlinkColors.accent];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(BlinkRadius.full),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: width * progress.clamp(0.0, 1.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                borderRadius: BorderRadius.circular(BlinkRadius.full),
                boxShadow: progress > 0
                    ? [
                        BoxShadow(
                          color: colors.first.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}
