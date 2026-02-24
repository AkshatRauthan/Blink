import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/transfer_session.dart';
import '../providers/transfer_provider.dart';
import '../widgets/transfer_card.dart';

/// Screen for receiving files from paired devices.
///
/// Stitch screen: "Blink Receiving Files Screen" (752074d96b414e74b8483b85954e0629)
class ReceiveScreen extends ConsumerWidget {
  const ReceiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(activeTransfersProvider);
    final theme = Theme.of(context);

    final receiving = sessions
        .where((s) => s.direction == TransferDirection.receive)
        .toList();
    final pending =
        receiving.where((s) => s.status == TransferStatus.pending).toList();
    final active =
        receiving.where((s) => s.status == TransferStatus.transferring).toList();
    final completed =
        receiving.where((s) => s.status == TransferStatus.completed).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Receiving',
          style: theme.textTheme.headlineMedium,
        ),
        centerTitle: true,
        actions: [
          if (receiving.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: BlinkSpacing.sm),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: BlinkSpacing.sm, vertical: BlinkSpacing.xs),
                decoration: BoxDecoration(
                  color: BlinkColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(BlinkRadius.full),
                ),
                child: Text(
                  '${active.length} active',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: BlinkColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: receiving.isEmpty
          ? _EmptyState(theme: theme)
          : ListView(
              padding: const EdgeInsets.all(BlinkSpacing.md),
              children: [
                // ── Incoming requests ──────────────────
                if (pending.isNotEmpty) ...[
                  _SectionLabel('Incoming Requests'),
                  const Gap(BlinkSpacing.sm),
                  for (final s in pending) _IncomingRequestCard(session: s),
                  const Gap(BlinkSpacing.md),
                ],
                // ── Actively receiving ─────────────────
                if (active.isNotEmpty) ...[
                  _SectionLabel('Receiving'),
                  const Gap(BlinkSpacing.sm),
                  for (final s in active) TransferCard(session: s),
                  const Gap(BlinkSpacing.md),
                ],
                // ── Completed ──────────────────────────
                if (completed.isNotEmpty) ...[
                  _SectionLabel('Completed'),
                  const Gap(BlinkSpacing.sm),
                  for (final s in completed) TransferCard(session: s),
                ],
                const Gap(BlinkSpacing.xl),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_rounded,
                          size: 12,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.3)),
                      const Gap(4),
                      Text(
                        'All transfers are end-to-end encrypted',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.3),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ThemeData theme;
  const _EmptyState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: BlinkColors.accent.withValues(alpha: 0.08),
            ),
            child: Icon(
              Icons.cloud_download_outlined,
              size: 40,
              color: BlinkColors.accent.withValues(alpha: 0.4),
            ),
          ),
          const Gap(BlinkSpacing.lg),
          Text(
            'Waiting for incoming files…',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          const Gap(BlinkSpacing.xs),
          Text(
            'Files from paired devices will appear here',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
        ],
      ).animate().fadeIn(duration: BlinkDurations.standard),
    );
  }
}

/// Incoming request card with accept/decline actions.
class _IncomingRequestCard extends StatelessWidget {
  final TransferSession session;
  const _IncomingRequestCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fileCount = session.fileIds.length;

    return Container(
      margin: const EdgeInsets.only(bottom: BlinkSpacing.md),
      padding: const EdgeInsets.all(BlinkSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            BlinkColors.accent.withValues(alpha: 0.06),
            BlinkColors.primary.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(BlinkRadius.lg),
        border: Border.all(color: BlinkColors.accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: BlinkColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(BlinkRadius.sm),
                ),
                child: const Icon(Icons.arrow_downward_rounded,
                    color: BlinkColors.accent, size: 20),
              ),
              const Gap(BlinkSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Incoming Transfer',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '$fileCount file${fileCount == 1 ? '' : 's'} • ${_formatBytes(session.totalBytes)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(BlinkSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {/* decline */},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: BlinkColors.coral,
                    side: const BorderSide(color: BlinkColors.coral),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(BlinkRadius.full),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: BlinkSpacing.sm),
                  ),
                  child: const Text('Decline'),
                ),
              ),
              const Gap(BlinkSpacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: () {/* accept */},
                  style: FilledButton.styleFrom(
                    backgroundColor: BlinkColors.accent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(BlinkRadius.full),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: BlinkSpacing.sm),
                  ),
                  child: const Text('Accept'),
                ),
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

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1073741824) {
      return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1073741824).toStringAsFixed(2)} GB';
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
      ),
    );
  }
}
