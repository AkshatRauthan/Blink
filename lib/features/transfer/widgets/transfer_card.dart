import 'package:flutter/material.dart';
import '../../../data/models/transfer_session.dart';
import 'progress_bar.dart';

/// A card showing the status and progress of a single [TransferSession].
class TransferCard extends StatelessWidget {
  final TransferSession session;

  const TransferCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  session.direction == TransferDirection.send
                      ? Icons.upload
                      : Icons.download,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${session.fileIds.length} file${session.fileIds.length == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _StatusChip(status: session.status),
              ],
            ),
            const SizedBox(height: 12),
            TransferProgressBar(progress: session.progress),
            const SizedBox(height: 4),
            Text(
              '${(session.progress * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final TransferStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      TransferStatus.transferring => ('Transferring', Colors.blue),
      TransferStatus.completed => ('Done', Colors.green),
      TransferStatus.failed => ('Failed', Colors.red),
      TransferStatus.paused => ('Paused', Colors.orange),
      TransferStatus.cancelled => ('Cancelled', Colors.grey),
      _ => (status.name, Colors.grey),
    };
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      backgroundColor: color.withValues(alpha: 0.15),
    );
  }
}
