import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../providers/live_folder_provider.dart';

/// Live Folders sync screen — watch local folders for changes.
///
/// Stitch screen: "Blink Live Folders Sync Screen" (31787a6643ad46b59daac2ec97cffeed)
class LiveFolderScreen extends ConsumerWidget {
  const LiveFolderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(liveFolderNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text('Live Folders',
            style: theme.textTheme.headlineMedium),
        centerTitle: true,
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BlinkRadius.full),
          gradient: const LinearGradient(
            colors: [BlinkColors.primary, BlinkColors.accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: BlinkColors.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () =>
              ref.read(liveFolderNotifierProvider.notifier).addFolder(''),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text('Add Folder',
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ),
      body: state.syncedFolders.isEmpty
          ? _EmptyState(theme: theme)
          : ListView(
              padding: const EdgeInsets.all(BlinkSpacing.md),
              children: [
                // ── Explanation card ───────────────────
                _InfoCard(theme: theme),
                const Gap(BlinkSpacing.lg),
                // ── Folder list ───────────────────────
                Text(
                  'SYNCED FOLDERS',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                ),
                const Gap(BlinkSpacing.sm),
                ...state.syncedFolders.asMap().entries.map(
                      (e) => _FolderCard(
                        folderPath: e.value,
                        index: e.key,
                        onRemove: () => ref
                            .read(liveFolderNotifierProvider.notifier)
                            .removeFolder(e.value),
                      ),
                    ),
                const Gap(80), // FAB clearance
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
      child: Padding(
        padding: const EdgeInsets.all(BlinkSpacing.xl),
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
                Icons.folder_copy_outlined,
                size: 40,
                color: BlinkColors.primary.withValues(alpha: 0.4),
              ),
            ),
            const Gap(BlinkSpacing.lg),
            Text(
              'No Live Folders yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const Gap(BlinkSpacing.xs),
            Text(
              'Add a folder to keep it synced with\nyour paired device in real time.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
              ),
            ),
            const Gap(BlinkSpacing.xl),
            _InfoCard(theme: theme),
          ],
        ),
      ).animate().fadeIn(duration: BlinkDurations.standard),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final ThemeData theme;
  const _InfoCard({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BlinkSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            BlinkColors.primary.withValues(alpha: 0.06),
            BlinkColors.accent.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(BlinkRadius.lg),
        border:
            Border.all(color: BlinkColors.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              color: BlinkColors.primary, size: 20),
          const Gap(BlinkSpacing.sm),
          Expanded(
            child: Text(
              'Live Folders auto-sync file changes to your paired device whenever modifications are detected.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FolderCard extends StatelessWidget {
  final String folderPath;
  final int index;
  final VoidCallback onRemove;

  const _FolderCard({
    required this.folderPath,
    required this.index,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final folderName =
        folderPath.isEmpty ? 'Untitled Folder' : p.basename(folderPath);
    // Placeholder — replace with actual sync state
    final isSyncing = folderPath.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: BlinkSpacing.sm),
      padding: const EdgeInsets.all(BlinkSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(BlinkRadius.lg),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Folder icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: BlinkColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(BlinkRadius.sm),
            ),
            child: const Icon(Icons.folder_rounded,
                color: BlinkColors.primary, size: 22),
          ),
          const Gap(BlinkSpacing.sm),
          // Name + path
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  folderName,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSyncing ? BlinkColors.mint : Colors.grey,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      isSyncing ? 'Watching' : 'Paused',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isSyncing ? BlinkColors.mint : Colors.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Remove button
          IconButton(
            icon: Icon(Icons.remove_circle_outline_rounded,
                color: BlinkColors.coral.withValues(alpha: 0.7), size: 20),
            onPressed: onRemove,
          ),
        ],
      ),
    ).animate().fadeIn(
          duration: BlinkDurations.standard,
          delay: Duration(milliseconds: 50 * index),
        );
  }
}
