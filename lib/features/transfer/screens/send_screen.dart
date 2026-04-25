import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/transfer_session.dart';
import '../providers/transfer_provider.dart';
import '../widgets/transfer_card.dart';

class SendScreen extends ConsumerWidget {
  const SendScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(activeTransfersProvider);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;

    final sending = sessions
        .where((s) => s.direction == TransferDirection.send)
        .toList();
    final active =
        sending.where((s) => s.status == TransferStatus.transferring).toList();
    final queued = sending
        .where((s) =>
            s.status == TransferStatus.pending ||
            s.status == TransferStatus.connecting)
        .toList();
    final completed =
        sending.where((s) => s.status == TransferStatus.completed).toList();

    return Scaffold(
      backgroundColor: BlinkColors.darkBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxWidth: isDesktop ? 600 : double.infinity),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Transfers',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                      if (active.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: BlinkColors.primary.withValues(alpha: 0.15),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: BlinkColors.primary,
                                ),
                              ),
                              const Gap(6),
                              Text(
                                '${active.length} active',
                                style: const TextStyle(
                                  color: BlinkColors.primaryLight,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const Gap(16),
                // Content
                Expanded(
                  child: sending.isEmpty
                      ? _EmptyState()
                      : _TransferList(
                          active: active,
                          queued: queued,
                          completed: completed,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
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
              color: BlinkColors.primary.withValues(alpha: 0.08),
            ),
            child: Icon(
              Icons.swap_vert_rounded,
              size: 40,
              color: BlinkColors.primary.withValues(alpha: 0.3),
            ),
          ),
          const Gap(20),
          Text(
            'No active transfers',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(6),
          Text(
            'Select files from discovery to start',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.25),
              fontSize: 14,
            ),
          ),
        ],
      ).animate().fadeIn(duration: 500.ms),
    );
  }
}

class _TransferList extends StatelessWidget {
  final List<TransferSession> active;
  final List<TransferSession> queued;
  final List<TransferSession> completed;

  const _TransferList({
    required this.active,
    required this.queued,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        if (active.isNotEmpty) ...[
          _SectionHeader(label: 'In Progress', count: active.length),
          const Gap(8),
          for (final s in active) TransferCard(session: s),
          const Gap(16),
        ],
        if (queued.isNotEmpty) ...[
          _SectionHeader(label: 'Queued', count: queued.length),
          const Gap(8),
          for (final s in queued) TransferCard(session: s),
          const Gap(16),
        ],
        if (completed.isNotEmpty) ...[
          _SectionHeader(label: 'Completed', count: completed.length),
          const Gap(8),
          for (final s in completed) TransferCard(session: s),
        ],
        const Gap(24),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_rounded,
                size: 12,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              const Gap(4),
              Text(
                'Encrypted with XChaCha20-Poly1305',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.2),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        const Gap(16),
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
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const Gap(8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: BlinkColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: BlinkColors.primaryLight,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
