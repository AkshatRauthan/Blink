import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/transfer_session.dart';
import '../providers/transfer_provider.dart';
import '../widgets/transfer_card.dart';

class ReceiveScreen extends ConsumerWidget {
  const ReceiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(activeTransfersProvider);

    final receiving = sessions
        .where((s) => s.direction == TransferDirection.receive)
        .toList();
    final pending =
        receiving.where((s) => s.status == TransferStatus.pending).toList();
    final active = receiving
        .where((s) => s.status == TransferStatus.transferring)
        .toList();
    final completed =
        receiving.where((s) => s.status == TransferStatus.completed).toList();

    return Scaffold(
      backgroundColor: BlinkColors.darkBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 20,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Receiving',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (active.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: BlinkColors.accent.withValues(alpha: 0.12),
                      ),
                      child: Text(
                        '${active.length} active',
                        style: const TextStyle(
                          color: BlinkColors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),
            const Gap(8),
            // Content
            Expanded(
              child: receiving.isEmpty
                  ? _EmptyState()
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        if (pending.isNotEmpty) ...[
                          _SectionHeader(label: 'Incoming Requests'),
                          const Gap(8),
                          for (final s in pending)
                            _IncomingRequestCard(
                              session: s,
                              onAccept: () => ref
                                  .read(activeTransfersProvider.notifier)
                                  .acceptTransfer(s.sessionId),
                              onDecline: () => ref
                                  .read(activeTransfersProvider.notifier)
                                  .declineTransfer(s.sessionId),
                            ),
                          const Gap(16),
                        ],
                        if (active.isNotEmpty) ...[
                          _SectionHeader(label: 'Receiving'),
                          const Gap(8),
                          for (final s in active) TransferCard(session: s),
                          const Gap(16),
                        ],
                        if (completed.isNotEmpty) ...[
                          _SectionHeader(label: 'Completed'),
                          const Gap(8),
                          for (final s in completed)
                            TransferCard(session: s),
                        ],
                        const Gap(24),
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock_rounded,
                                  size: 12,
                                  color: Colors.white.withValues(alpha: 0.2)),
                              const Gap(4),
                              Text(
                                'All transfers are end-to-end encrypted',
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
                    ),
            ),
          ],
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
          Lottie.asset(
            'assets/lottie/loading.json',
            width: 80,
            height: 80,
            repeat: true,
          ),
          const Gap(20),
          Text(
            'Waiting for incoming files...',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(6),
          Text(
            'Files from paired devices will appear here',
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

class _IncomingRequestCard extends StatelessWidget {
  final TransferSession session;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  const _IncomingRequestCard({
    required this.session,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final fileCount = session.fileIds.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            BlinkColors.accent.withValues(alpha: 0.08),
            BlinkColors.primary.withValues(alpha: 0.04),
          ],
        ),
        border: Border.all(
          color: BlinkColors.accent.withValues(alpha: 0.15),
        ),
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
                  borderRadius: BorderRadius.circular(10),
                  color: BlinkColors.accent.withValues(alpha: 0.12),
                ),
                child: const Icon(Icons.arrow_downward_rounded,
                    color: BlinkColors.accent, size: 20),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Incoming Transfer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$fileCount file${fileCount == 1 ? '' : 's'} · ${_formatBytes(session.totalBytes)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(14),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onDecline,
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withValues(alpha: 0.06),
                      border: Border.all(
                        color: BlinkColors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Decline',
                        style: TextStyle(
                          color: BlinkColors.error.withValues(alpha: 0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(10),
              Expanded(
                child: GestureDetector(
                  onTap: onAccept,
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: [BlinkColors.accent, Color(0xFF00B8D9)],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Accept',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(
          begin: 0.04,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
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

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.3),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }
}
