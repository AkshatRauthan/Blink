import 'package:flutter/material.dart';

/// Animated linear progress bar for a file transfer.
class TransferProgressBar extends StatelessWidget {
  /// Progress value between 0.0 and 1.0.
  final double progress;

  const TransferProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 8,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        valueColor: AlwaysStoppedAnimation(
          Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
