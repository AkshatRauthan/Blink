import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart' as p;

import '../../../core/theme/app_colors.dart';
import '../providers/live_folder_provider.dart';

class LiveFolderScreen extends ConsumerWidget {
  const LiveFolderScreen({super.key});

  Future<void> _pickFolder(WidgetRef ref) async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null && result.isNotEmpty) {
      ref.read(liveFolderNotifierProvider.notifier).addFolder(result);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(liveFolderNotifierProvider);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;

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
                          'Live Folders',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                      _AddFolderButton(onTap: () => _pickFolder(ref)),
                    ],
                  ),
                ),
                const Gap(16),
                // Content
                Expanded(
                  child: state.folders.isEmpty
                      ? _EmptyState(onAdd: () => _pickFolder(ref))
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            _InfoBanner(),
                            const Gap(12),
                            if (state.pairedDeviceId == null)
                              _NoPairedDeviceBanner(),
                            if (state.pairedDeviceId == null) const Gap(12),
                            Text(
                              'SYNCED FOLDERS',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.3),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const Gap(10),
                            ...state.folders.asMap().entries.map(
                                  (e) => _FolderCard(
                                    folder: e.value,
                                    index: e.key,
                                    onRemove: () => ref
                                        .read(
                                            liveFolderNotifierProvider.notifier)
                                        .removeFolder(e.value.path),
                                    onTogglePause: () => ref
                                        .read(
                                            liveFolderNotifierProvider.notifier)
                                        .togglePause(e.value.path),
                                  ),
                                ),
                            const Gap(80),
                          ],
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

class _AddFolderButton extends StatefulWidget {
  final VoidCallback onTap;
  const _AddFolderButton({required this.onTap});

  @override
  State<_AddFolderButton> createState() => _AddFolderButtonState();
}

class _AddFolderButtonState extends State<_AddFolderButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              colors: [BlinkColors.primary, Color(0xFF8B7BFF)],
            ),
            boxShadow: [
              BoxShadow(
                color: BlinkColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 18),
              Gap(4),
              Text(
                'Add Folder',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              'No Live Folders yet',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(6),
            Text(
              'Add a folder to keep it synced with\nyour paired device in real time.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.25),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const Gap(28),
            _AddFolderButton(onTap: onAdd),
            const Gap(24),
            _InfoBanner(),
          ],
        ).animate().fadeIn(duration: 500.ms),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            BlinkColors.primary.withValues(alpha: 0.08),
            BlinkColors.accent.withValues(alpha: 0.04),
          ],
        ),
        border: Border.all(
          color: BlinkColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              color: BlinkColors.primary.withValues(alpha: 0.7), size: 18),
          const Gap(10),
          Expanded(
            child: Text(
              'Live Folders auto-sync changes to your paired device in real time.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoPairedDeviceBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: BlinkColors.error.withValues(alpha: 0.08),
        border: Border.all(
          color: BlinkColors.error.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: BlinkColors.error.withValues(alpha: 0.7), size: 18),
          const Gap(10),
          Expanded(
            child: Text(
              'No paired device. Pair via QR to enable live sync.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FolderCard extends StatefulWidget {
  final WatchedFolder folder;
  final int index;
  final VoidCallback onRemove;
  final VoidCallback onTogglePause;

  const _FolderCard({
    required this.folder,
    required this.index,
    required this.onRemove,
    required this.onTogglePause,
  });

  @override
  State<_FolderCard> createState() => _FolderCardState();
}

class _FolderCardState extends State<_FolderCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final folderName = widget.folder.path.isEmpty
        ? 'Untitled Folder'
        : p.basename(widget.folder.path);
    final isWatching = !widget.folder.isPaused;
    final pending = widget.folder.pendingChanges;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _isHovered
              ? BlinkColors.darkSurface.withValues(alpha: 0.8)
              : BlinkColors.darkSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: BlinkColors.darkHover.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: BlinkColors.primary.withValues(alpha: 0.1),
              ),
              child: const Icon(Icons.folder_rounded,
                  color: BlinkColors.primary, size: 20),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    folderName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(3),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isWatching ? BlinkColors.success : Colors.grey,
                          boxShadow: isWatching
                              ? [
                                  BoxShadow(
                                    color: BlinkColors.success
                                        .withValues(alpha: 0.4),
                                    blurRadius: 4,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      const Gap(5),
                      Text(
                        isWatching ? 'Watching' : 'Paused',
                        style: TextStyle(
                          color: isWatching ? BlinkColors.success : Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (pending > 0) ...[
                        const Gap(8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: BlinkColors.accent.withValues(alpha: 0.15),
                          ),
                          child: Text(
                            '$pending pending',
                            style: TextStyle(
                              color: BlinkColors.accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: widget.onTogglePause,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
                child: Icon(
                  isWatching
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ),
            const Gap(6),
            GestureDetector(
              onTap: widget.onRemove,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: BlinkColors.error.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: BlinkColors.error.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(
          duration: 400.ms,
          delay: Duration(milliseconds: 60 * widget.index),
        );
  }
}
