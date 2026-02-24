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

/// Active file transfers / send screen.
///
/// Stitch screen: "Blink Active File Transfers / Send Screen" (deaab363a66443ae9ed469c76ee54647)
class SendScreen extends ConsumerWidget {
  const SendScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(activeTransfersProvider);
    final theme = Theme.of(context);

    final sending = sessions
        .where((s) => s.direction == TransferDirection.send)
        .toList();
    final active =
        sending.where((s) => s.status == TransferStatus.transferring).toList();
    final queued = sending
        .where(
            (s) => s.status == TransferStatus.pending || s.status == TransferStatus.connecting)
        .toList();
    final completed =
        sending.where((s) => s.status == TransferStatus.completed).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Sending',
          style: theme.textTheme.headlineMedium,
        ),
        centerTitle: true,
        actions: [
          if (sending.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: BlinkSpacing.sm),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: BlinkSpacing.sm, vertical: BlinkSpacing.xs),
                decoration: BoxDecoration(
                  color: BlinkColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(BlinkRadius.full),
                ),
                child: Text(
                  '${active.length} active',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: BlinkColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: sending.isEmpty ? _EmptyState(theme: theme) : _TransferList(
        theme: theme,
        active: active,
        queued: queued,
        completed: completed,
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
          Icon(
            Icons.cloud_upload_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          const Gap(BlinkSpacing.md),
          Text(
            'No active transfers',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          const Gap(BlinkSpacing.xs),
          Text(
            'Select files from discovery to start sending',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
        ],
      ).animate().fadeIn(duration: BlinkDurations.standard),
    );
  }
}

class _TransferList extends StatelessWidget {
  final ThemeData theme;
  final List<TransferSession> active;
  final List<TransferSession> queued;
  final List<TransferSession> completed;

  const _TransferList({
    required this.theme,
    required this.active,
    required this.queued,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(BlinkSpacing.md),
      children: [
        if (active.isNotEmpty) ...[
          _SectionHeader(label: 'In Progress', count: active.length),
          const Gap(BlinkSpacing.sm),
          for (final s in active) TransferCard(session: s),
          const Gap(BlinkSpacing.md),
        ],
        if (queued.isNotEmpty) ...[
          _SectionHeader(label: 'Queued', count: queued.length),
          const Gap(BlinkSpacing.sm),
          for (final s in queued) TransferCard(session: s),
          const Gap(BlinkSpacing.md),
        ],
        if (completed.isNotEmpty) ...[
          _SectionHeader(label: 'Completed', count: completed.length),
          const Gap(BlinkSpacing.sm),
          for (final s in completed) TransferCard(session: s),
        ],
        const Gap(BlinkSpacing.xl),
        // Encryption footer
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_rounded,
                  size: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
              const Gap(4),
              Text(
                'Encrypted with XChaCha20-Poly1305',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        const Gap(BlinkSpacing.md),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  const _SectionHeader({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
          ),
        ),
        const Gap(BlinkSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: BlinkColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(BlinkRadius.full),
          ),
          child: Text(
            '$count',
            style: theme.textTheme.labelSmall?.copyWith(
              color: BlinkColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}
