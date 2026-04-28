import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/file_utils.dart';
import '../../../services/transfer/transfer_manager.dart';
import '../../../data/models/transfer_session.dart';
import '../../../data/models/transfer_file.dart';
import 'progress_bar.dart';

class TransferCard extends StatelessWidget {
  final TransferSession session;

  const TransferCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final isSend = session.direction == TransferDirection.send;
    final fileCount = session.fileIds.length;
    final (statusLabel, statusColor) = _statusInfo(session.status);
    final sizeStr = _formatBytes(session.totalBytes);
    final transferredStr = _formatBytes(session.transferredBytes);
    final files = TransferManager.instance.filesForSession(session.sessionId);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BlinkColors.darkSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: BlinkColors.darkHover.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isSend
                        ? [
                            BlinkColors.primary.withValues(alpha: 0.15),
                            BlinkColors.primary.withValues(alpha: 0.05),
                          ]
                        : [
                            BlinkColors.accent.withValues(alpha: 0.15),
                            BlinkColors.accent.withValues(alpha: 0.05),
                          ],
                  ),
                ),
                child: Icon(
                  isSend
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: isSend ? BlinkColors.primary : BlinkColors.accent,
                  size: 18,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$fileCount file${fileCount == 1 ? '' : 's'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$transferredStr / $sizeStr',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
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
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(14),
          TransferProgressBar(
            progress: session.progress,
            gradientColors: isSend
                ? [BlinkColors.primary, const Color(0xFF8B7BFF)]
                : [BlinkColors.accent, BlinkColors.success],
          ),
          const Gap(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(session.progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (session.status == TransferStatus.transferring)
                Icon(
                  Icons.pause_circle_outline_rounded,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              if (session.status == TransferStatus.completed)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded,
                        size: 13, color: BlinkColors.success),
                    const Gap(4),
                    Text(
                      'BLAKE3 verified',
                      style: TextStyle(
                        color: BlinkColors.success,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (files.isNotEmpty) ...[
            const Gap(12),
            Divider(height: 1, color: BlinkColors.darkHover.withValues(alpha: 0.2)),
            const Gap(10),
            for (final file in files) _FileProgressRow(file: file),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(
          begin: 0.04,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }

  (String, Color) _statusInfo(TransferStatus status) => switch (status) {
        TransferStatus.pending => ('Queued', BlinkColors.warning),
        TransferStatus.connecting => ('Connecting', BlinkColors.warning),
        TransferStatus.transferring => ('Sending', BlinkColors.primary),
        TransferStatus.paused => ('Paused', BlinkColors.warning),
        TransferStatus.completed => ('Done', BlinkColors.success),
        TransferStatus.failed => ('Failed', BlinkColors.error),
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

class _FileProgressRow extends StatelessWidget {
  final TransferFile file;

  const _FileProgressRow({required this.file});

  @override
  Widget build(BuildContext context) {
    final progress = file.progress;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  file.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Gap(8),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Gap(6),
          TransferProgressBar(
            progress: progress,
            height: 4,
            gradientColors: [
              BlinkColors.primary.withValues(alpha: 0.8),
              BlinkColors.accent.withValues(alpha: 0.8),
            ],
          ),
          const Gap(4),
          Text(
            '${FileUtils.formatSize(file.transferredBytes)} / ${FileUtils.formatSize(file.sizeBytes)}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
