import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/transfer_session.dart';
import 'progress_bar.dart';

/// A polished card showing the status and progress of a single [TransferSession].
class TransferCard extends StatelessWidget {
  final TransferSession session;

  const TransferCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSend = session.direction == TransferDirection.send;
    final fileCount = session.fileIds.length;
    final (statusLabel, statusColor) = _statusInfo(session.status);
    final sizeStr = _formatBytes(session.totalBytes);
    final transferredStr = _formatBytes(session.transferredBytes);

    return Container(
      margin: const EdgeInsets.only(bottom: BlinkSpacing.md),
      padding: const EdgeInsets.all(BlinkSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(BlinkRadius.lg),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────
          Row(
            children: [
              // Direction icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (isSend ? BlinkColors.primary : BlinkColors.accent)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(BlinkRadius.sm),
                ),
                child: Icon(
                  isSend
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: isSend ? BlinkColors.primary : BlinkColors.accent,
                  size: 18,
                ),
              ),
              const Gap(BlinkSpacing.sm),
              // File info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$fileCount file${fileCount == 1 ? '' : 's'}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$transferredStr / $sizeStr',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              // Status chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: BlinkSpacing.sm,
                  vertical: BlinkSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(BlinkRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (session.status == TransferStatus.transferring) ...[
                      SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: statusColor,
                        ),
                      ),
                      const Gap(4),
                    ],
                    if (session.status == TransferStatus.completed)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(Icons.check_circle_rounded,
                            size: 12, color: statusColor),
                      ),
                    Text(
                      statusLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(BlinkSpacing.md),
          // ── Progress bar ────────────────────────────
          TransferProgressBar(
            progress: session.progress,
            gradientColors: isSend
                ? [BlinkColors.primary, BlinkColors.accent]
                : [BlinkColors.accent, BlinkColors.mint],
          ),
          const Gap(BlinkSpacing.xs),
          // ── Percentage + action ─────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(session.progress * 100).toStringAsFixed(0)}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              if (session.status == TransferStatus.transferring)
                Icon(
                  Icons.pause_circle_outline_rounded,
                  size: 18,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              if (session.status == TransferStatus.completed)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded,
                        size: 14, color: BlinkColors.mint),
                    const Gap(4),
                    Text(
                      'BLAKE3 verified',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: BlinkColors.mint,
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: BlinkDurations.standard).slideY(
          begin: 0.05,
          duration: BlinkDurations.standard,
          curve: BlinkCurves.standard,
        );
  }

  (String, Color) _statusInfo(TransferStatus status) => switch (status) {
        TransferStatus.pending => ('Queued', BlinkColors.amber),
        TransferStatus.connecting => ('Connecting', BlinkColors.amber),
        TransferStatus.transferring => ('Sending', BlinkColors.primary),
        TransferStatus.paused => ('Paused', BlinkColors.amber),
        TransferStatus.completed => ('Done', BlinkColors.mint),
        TransferStatus.failed => ('Failed', BlinkColors.coral),
        TransferStatus.cancelled => ('Cancelled', Colors.grey),
      };

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1073741824) {
      return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1073741824).toStringAsFixed(2)} GB';
  }
}
