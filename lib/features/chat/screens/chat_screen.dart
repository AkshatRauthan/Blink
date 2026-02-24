import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/chat_message.dart';
import '../providers/chat_provider.dart';

/// Format a [DateTime] to HH:MM am/pm string without the intl package.
String _formatTime(DateTime dt) {
  final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final minute = dt.minute.toString().padLeft(2, '0');
  final amPm = dt.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $amPm';
}

/// iMessage-style device chat screen.
///
/// Stitch screen: "Blink Device Chat Screen" (f5ceeb07eb27409288c3ff3503ea54c9)
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  /// Placeholder local device ID — replace with real value from device service.
  static const _localDeviceId = 'local';

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    ref.read(chatNotifierProvider.notifier).sendMessage(text);
    _controller.clear();
    _focusNode.requestFocus();
    // Scroll to bottom after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: BlinkDurations.quick,
          curve: BlinkCurves.standard,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatNotifierProvider);
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Text('Device Chat',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            Text(
              'End-to-end encrypted',
              style: theme.textTheme.labelSmall?.copyWith(
                color: BlinkColors.mint,
                fontSize: 10,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert_rounded,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Messages ────────────────────────────────
          Expanded(
            child: messages.isEmpty
                ? _EmptyChat(theme: theme)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: BlinkSpacing.md,
                      vertical: BlinkSpacing.sm,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (_, i) {
                      final msg = messages[i];
                      final isMine = msg.senderDeviceId == _localDeviceId;
                      final showTime = i == 0 ||
                          messages[i].sentAt
                                  .difference(messages[i - 1].sentAt)
                                  .inMinutes >
                              5;
                      return Column(
                        children: [
                          if (showTime) _TimeLabel(time: msg.sentAt),
                          _ChatBubble(message: msg, isMine: isMine),
                        ],
                      );
                    },
                  ),
          ),
          // ── Input bar ──────────────────────────────
          Container(
            padding: EdgeInsets.only(
              left: BlinkSpacing.md,
              right: BlinkSpacing.sm,
              top: BlinkSpacing.sm,
              bottom: bottomInset + BlinkSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                // Attachment button
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: BlinkColors.primary.withValues(alpha: 0.1),
                  ),
                  child: Icon(Icons.add_rounded,
                      color: BlinkColors.primary, size: 20),
                ),
                const Gap(BlinkSpacing.sm),
                // Text field
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(BlinkRadius.full),
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: 'Message',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.35),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: BlinkSpacing.md,
                          vertical: BlinkSpacing.sm,
                        ),
                        isDense: true,
                      ),
                      style: theme.textTheme.bodyMedium,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                ),
                const Gap(BlinkSpacing.xs),
                // Send button
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [BlinkColors.primary, BlinkColors.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(Icons.arrow_upward_rounded,
                        color: Colors.white, size: 18),
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

class _EmptyChat extends StatelessWidget {
  final ThemeData theme;
  const _EmptyChat({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 48,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
          ),
          const Gap(BlinkSpacing.md),
          Text(
            'No messages yet',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
            ),
          ),
          const Gap(BlinkSpacing.xs),
          Text(
            'Send a quick message alongside your files',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
            ),
          ),
        ],
      ).animate().fadeIn(duration: BlinkDurations.standard),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;

  const _ChatBubble({required this.message, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: BlinkSpacing.xs),
        padding: const EdgeInsets.symmetric(
            horizontal: BlinkSpacing.md, vertical: BlinkSpacing.sm),
        decoration: BoxDecoration(
          gradient: isMine
              ? const LinearGradient(
                  colors: [BlinkColors.primary, Color(0xFF8B80FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isMine
              ? null
              : theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(BlinkRadius.lg),
            topRight: const Radius.circular(BlinkRadius.lg),
            bottomLeft:
                Radius.circular(isMine ? BlinkRadius.lg : BlinkRadius.xs),
            bottomRight:
                Radius.circular(isMine ? BlinkRadius.xs : BlinkRadius.lg),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isMine
                    ? Colors.white
                    : theme.colorScheme.onSurface,
              ),
            ),
            const Gap(2),
            Text(
              _formatTime(message.sentAt),
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 9,
                color: isMine
                    ? Colors.white.withValues(alpha: 0.6)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.35),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: BlinkDurations.quick).slideY(
          begin: 0.1,
          duration: BlinkDurations.quick,
          curve: BlinkCurves.standard,
        );
  }
}

class _TimeLabel extends StatelessWidget {
  final DateTime time;
  const _TimeLabel({required this.time});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: BlinkSpacing.sm),
      child: Text(
        _formatTime(time),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          fontSize: 10,
        ),
      ),
    );
  }
}
