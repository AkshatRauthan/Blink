import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:path/path.dart' as p;

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/file_utils.dart';
import '../providers/file_selection_provider.dart';

class FileReviewSheet extends ConsumerWidget {
  final VoidCallback onConfirm;

  const FileReviewSheet({super.key, required this.onConfirm});

  static IconData _iconForExtension(String path) {
    final ext = p.extension(path).toLowerCase().replaceFirst('.', '');
    return switch (ext) {
      'jpg' || 'jpeg' || 'png' || 'gif' || 'webp' || 'bmp' => Icons.image_rounded,
      'mp4' || 'mkv' || 'mov' || 'avi' || 'webm' => Icons.videocam_rounded,
      'mp3' || 'wav' || 'flac' || 'aac' || 'ogg' => Icons.audiotrack_rounded,
      'pdf' => Icons.picture_as_pdf_rounded,
      'zip' || 'rar' || '7z' || 'tar' || 'gz' => Icons.folder_zip_rounded,
      'apk' => Icons.android_rounded,
      'doc' || 'docx' || 'txt' || 'rtf' => Icons.description_rounded,
      'xls' || 'xlsx' || 'csv' => Icons.table_chart_rounded,
      'ppt' || 'pptx' => Icons.slideshow_rounded,
      _ => Icons.insert_drive_file_rounded,
    };
  }

  static Color _colorForExtension(String path) {
    final ext = p.extension(path).toLowerCase().replaceFirst('.', '');
    return switch (ext) {
      'jpg' || 'jpeg' || 'png' || 'gif' || 'webp' || 'bmp' => const Color(0xFF4CAF50),
      'mp4' || 'mkv' || 'mov' || 'avi' || 'webm' => const Color(0xFFE91E63),
      'mp3' || 'wav' || 'flac' || 'aac' || 'ogg' => const Color(0xFFFF9800),
      'pdf' => const Color(0xFFF44336),
      'zip' || 'rar' || '7z' || 'tar' || 'gz' => const Color(0xFF795548),
      'apk' => const Color(0xFF4CAF50),
      _ => BlinkColors.primary,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(fileSelectionProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.65,
      ),
      decoration: BoxDecoration(
        color: BlinkColors.darkSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: BlinkColors.darkHover.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          const Gap(8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Selected Files',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (selection.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: BlinkColors.primary.withValues(alpha: 0.12),
                    ),
                    child: Text(
                      '${selection.files.length} file${selection.files.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                        color: BlinkColors.primaryLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const Gap(8),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white.withValues(alpha: 0.4),
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
          const Gap(8),
          Divider(height: 1, color: BlinkColors.darkHover.withValues(alpha: 0.2)),

          // File list
          if (selection.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.upload_file_rounded,
                    size: 48,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  const Gap(12),
                  Text(
                    'No files selected',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                itemCount: selection.files.length,
                itemBuilder: (_, i) {
                  final file = selection.files[i];
                  return _FileCard(
                    file: file,
                    icon: _iconForExtension(file.path),
                    iconColor: _colorForExtension(file.path),
                    onRemove: () => ref
                        .read(fileSelectionProvider.notifier)
                        .removeFile(file.path),
                  ).animate().fadeIn(
                        duration: 300.ms,
                        delay: Duration(milliseconds: 40 * i),
                      );
                },
              ),
            ),

          // Footer — total size + confirm button
          if (selection.isNotEmpty) ...[
            Divider(height: 1, color: BlinkColors.darkHover.withValues(alpha: 0.2)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 11,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        FileUtils.formatSize(selection.totalBytes),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _SendButton(onTap: onConfirm),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FileCard extends StatefulWidget {
  final SelectedFile file;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onRemove;

  const _FileCard({
    required this.file,
    required this.icon,
    required this.iconColor,
    required this.onRemove,
  });

  @override
  State<_FileCard> createState() => _FileCardState();
}

class _FileCardState extends State<_FileCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: _isHovered
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: widget.iconColor.withValues(alpha: 0.12),
              ),
              child: Icon(widget.icon, color: widget.iconColor, size: 20),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.file.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(2),
                  Text(
                    FileUtils.formatSize(widget.file.sizeBytes),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: widget.onRemove,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: BlinkColors.error.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: BlinkColors.error.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatefulWidget {
  final VoidCallback onTap;
  const _SendButton({required this.onTap});

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton> {
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
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [BlinkColors.primary, Color(0xFF8B7BFF)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: BlinkColors.primary.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.send_rounded, color: Colors.white, size: 18),
              Gap(8),
              Text(
                'Send',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
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
