import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/blink_avatar.dart';
import '../../../shared/widgets/blink_button.dart';
import '../../../shared/widgets/blink_card.dart';
import '../../../shared/widgets/blink_dialog.dart';
import '../providers/groups_provider.dart';

/// Contact Groups screen for managing device groups.
///
/// Allows creating groups of devices for quick multi-send.
class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(groupsNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: BlinkColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Groups',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: BlinkColors.darkTextPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          BlinkIconButton(
            icon: Icons.add_rounded,
            onPressed: () => _showCreateGroupDialog(context, ref),
            tooltip: 'Create Group',
          ),
          const Gap(BlinkSpacing.sm),
        ],
      ),
      body: state.groups.isEmpty
          ? _EmptyState(onCreateGroup: () => _showCreateGroupDialog(context, ref))
          : ListView.builder(
              padding: const EdgeInsets.all(BlinkSpacing.md),
              itemCount: state.groups.length,
              itemBuilder: (context, index) {
                final group = state.groups[index];
                return _GroupCard(
                  group: group,
                  index: index,
                  onTap: () => _showGroupDetails(context, ref, group),
                  onDelete: () => _confirmDeleteGroup(context, ref, group),
                );
              },
            ),
    );
  }

  void _showCreateGroupDialog(BuildContext context, WidgetRef ref) async {
    final name = await showBlinkInputDialog(
      context: context,
      title: 'Create Group',
      hint: 'Group name',
      confirmText: 'Create',
      validator: (value) {
        if (value.trim().isEmpty) return 'Name required';
        if (value.trim().length < 2) return 'At least 2 characters';
        return null;
      },
    );
    if (name != null && name.trim().isNotEmpty) {
      ref.read(groupsNotifierProvider.notifier).createGroup(name.trim());
    }
  }

  void _showGroupDetails(BuildContext context, WidgetRef ref, ContactGroup group) {
    showModalBottomSheet(
      context: context,
      backgroundColor: BlinkColors.darkElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(BlinkRadius.xl)),
      ),
      builder: (context) => _GroupDetailsSheet(group: group),
    );
  }

  void _confirmDeleteGroup(BuildContext context, WidgetRef ref, ContactGroup group) async {
    final confirmed = await showBlinkConfirm(
      context: context,
      title: 'Delete Group',
      message: 'Are you sure you want to delete "${group.name}"? This cannot be undone.',
      confirmText: 'Delete',
      isDestructive: true,
    );
    if (confirmed == true) {
      ref.read(groupsNotifierProvider.notifier).deleteGroup(group.id);
    }
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreateGroup;
  const _EmptyState({required this.onCreateGroup});

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
                color: BlinkColors.primaryMuted,
              ),
              child: Icon(
                Icons.group_outlined,
                size: 40,
                color: BlinkColors.primary.withValues(alpha: 0.6),
              ),
            ),
            const Gap(BlinkSpacing.lg),
            Text(
              'No Groups Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: BlinkColors.darkTextPrimary,
              ),
            ),
            const Gap(BlinkSpacing.sm),
            Text(
              'Create groups to send files to\nmultiple devices at once',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: BlinkColors.darkTextSecondary,
              ),
            ),
            const Gap(BlinkSpacing.xl),
            BlinkButton(
              label: 'Create Group',
              icon: Icons.add_rounded,
              onPressed: onCreateGroup,
            ),
          ],
        ),
      ).animate().fadeIn(duration: BlinkDurations.standard),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final ContactGroup group;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _GroupCard({
    required this.group,
    required this.index,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BlinkSpacing.sm),
      child: BlinkCard(
        onTap: onTap,
        child: Row(
          children: [
            // Group icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [BlinkColors.primary, BlinkColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(BlinkRadius.md),
              ),
              child: const Icon(
                Icons.group_rounded,
                color: BlinkColors.white,
                size: 24,
              ),
            ),
            const Gap(BlinkSpacing.md),
            // Group info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: BlinkColors.darkTextPrimary,
                    ),
                  ),
                  const Gap(4),
                  Row(
                    children: [
                      // Member count
                      _MemberAvatarStack(memberCount: group.memberDeviceIds.length),
                      const Gap(BlinkSpacing.sm),
                      Text(
                        '${group.memberDeviceIds.length} member${group.memberDeviceIds.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: BlinkColors.darkTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Actions
            BlinkIconButton(
              icon: Icons.send_rounded,
              iconSize: 20,
              size: 40,
              color: BlinkColors.primary,
              onPressed: () {
                // TODO: Send to group
              },
              tooltip: 'Send to group',
            ),
            BlinkIconButton(
              icon: Icons.more_vert_rounded,
              iconSize: 20,
              size: 40,
              color: BlinkColors.darkTextSecondary,
              onPressed: onDelete,
            ),
          ],
        ),
      ).animate().fadeIn(
        duration: BlinkDurations.standard,
        delay: Duration(milliseconds: 50 * index),
      ),
    );
  }
}

class _MemberAvatarStack extends StatelessWidget {
  final int memberCount;
  const _MemberAvatarStack({required this.memberCount});

  @override
  Widget build(BuildContext context) {
    final displayCount = memberCount.clamp(0, 3);
    return SizedBox(
      width: 16.0 + (displayCount - 1) * 12.0,
      height: 20,
      child: Stack(
        children: List.generate(displayCount, (i) {
          return Positioned(
            left: i * 12.0,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BlinkColors.darkElevated,
                border: Border.all(color: BlinkColors.darkSurface, width: 2),
              ),
              child: Icon(
                Icons.person_rounded,
                size: 12,
                color: BlinkColors.darkTextTertiary,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _GroupDetailsSheet extends StatelessWidget {
  final ContactGroup group;
  const _GroupDetailsSheet({required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BlinkSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: BlinkColors.darkHover,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Gap(BlinkSpacing.lg),
          // Header
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [BlinkColors.primary, BlinkColors.accent],
                  ),
                  borderRadius: BorderRadius.circular(BlinkRadius.md),
                ),
                child: const Icon(Icons.group_rounded, color: Colors.white, size: 28),
              ),
              const Gap(BlinkSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: BlinkColors.darkTextPrimary,
                      ),
                    ),
                    Text(
                      '${group.memberDeviceIds.length} members',
                      style: TextStyle(
                        fontSize: 14,
                        color: BlinkColors.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(BlinkSpacing.xl),
          // Members section
          Text(
            'MEMBERS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: BlinkColors.darkTextTertiary,
            ),
          ),
          const Gap(BlinkSpacing.sm),
          if (group.memberDeviceIds.isEmpty)
            Container(
              padding: const EdgeInsets.all(BlinkSpacing.lg),
              decoration: BoxDecoration(
                color: BlinkColors.darkSurface,
                borderRadius: BorderRadius.circular(BlinkRadius.md),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_add_rounded, color: BlinkColors.darkTextTertiary),
                  const Gap(BlinkSpacing.sm),
                  Text(
                    'No members yet. Add devices from Discovery.',
                    style: TextStyle(color: BlinkColors.darkTextSecondary),
                  ),
                ],
              ),
            )
          else
            ...group.memberDeviceIds.take(5).map((deviceId) => Container(
              padding: const EdgeInsets.symmetric(vertical: BlinkSpacing.sm),
              child: Row(
                children: [
                  const BlinkAvatar(
                    size: BlinkAvatarSize.sm,
                    icon: Icons.devices_rounded,
                  ),
                  const Gap(BlinkSpacing.sm),
                  Expanded(
                    child: Text(
                      'Device $deviceId',
                      style: const TextStyle(
                        fontSize: 14,
                        color: BlinkColors.darkTextPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          const Gap(BlinkSpacing.lg),
          // Send to group button
          BlinkButton(
            label: 'Send Files to Group',
            icon: Icons.send_rounded,
            onPressed: () {
              Navigator.pop(context);
              // TODO: Open file picker and send to all members
            },
            isExpanded: true,
          ),
          const Gap(BlinkSpacing.md),
        ],
      ),
    );
  }
}
