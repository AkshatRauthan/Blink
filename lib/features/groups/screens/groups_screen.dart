import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/contact_group.dart';
import '../../../data/models/device.dart';
import '../../discovery/providers/discovery_provider.dart';
import '../providers/groups_provider.dart';

class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsState = ref.watch(groupsNotifierProvider);
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
                          'Groups',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                      _CreateGroupButton(
                        onTap: () => _showCreateDialog(context, ref),
                      ),
                    ],
                  ),
                ),
                const Gap(16),
                // Content
                Expanded(
                  child: groupsState.groups.isEmpty
                      ? _EmptyState(
                          onCreate: () => _showCreateDialog(context, ref))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: groupsState.groups.length,
                          itemBuilder: (_, i) {
                            final group = groupsState.groups[i];
                            return _GroupCard(
                              group: group,
                              index: i,
                              onTap: () =>
                                  _showGroupDetails(context, ref, group),
                              onSend: () =>
                                  _sendToGroup(context, ref, group),
                              onDelete: () => _confirmDelete(
                                  context, ref, group),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: BlinkColors.darkSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: BlinkColors.darkHover.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Group',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(16),
              Container(
                decoration: BoxDecoration(
                  color: BlinkColors.darkBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: BlinkColors.darkHover.withValues(alpha: 0.3),
                  ),
                ),
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Group name',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (value) {
                    if (value.trim().length >= 2) {
                      ref
                          .read(groupsNotifierProvider.notifier)
                          .createGroup(value.trim());
                      Navigator.pop(ctx);
                    }
                  },
                ),
              ),
              const Gap(16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const Gap(8),
                  GestureDetector(
                    onTap: () {
                      final name = controller.text.trim();
                      if (name.length >= 2) {
                        ref
                            .read(groupsNotifierProvider.notifier)
                            .createGroup(name);
                        Navigator.pop(ctx);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [BlinkColors.primary, Color(0xFF8B7BFF)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Create',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGroupDetails(
      BuildContext context, WidgetRef ref, ContactGroup group) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _GroupDetailsSheet(group: group),
    );
  }

  Future<void> _sendToGroup(
      BuildContext context, WidgetRef ref, ContactGroup group) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );
    if (result == null || result.files.isEmpty) return;

    final paths = result.files
        .where((f) => f.path != null)
        .map((f) => f.path!)
        .toList();
    if (paths.isEmpty) return;

    final devices = ref.read(discoveryNotifierProvider).value ?? [];
    ref.read(groupsNotifierProvider.notifier).sendToGroup(
          groupId: group.groupId,
          filePaths: paths,
          availableDevices: devices,
        );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sending ${paths.length} file${paths.length == 1 ? '' : 's'} to ${group.name}',
          ),
          backgroundColor: BlinkColors.darkSurface,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, ContactGroup group) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: BlinkColors.darkSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: BlinkColors.darkHover.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Delete Group',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap(8),
            Text(
              'Are you sure you want to delete "${group.name}"?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
            const Gap(20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                      child: const Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      ref
                          .read(groupsNotifierProvider.notifier)
                          .deleteGroup(group.groupId);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: BlinkColors.error.withValues(alpha: 0.15),
                      ),
                      child: Center(
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            color: BlinkColors.error,
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
      ),
    );
  }
}

class _CreateGroupButton extends StatefulWidget {
  final VoidCallback onTap;
  const _CreateGroupButton({required this.onTap});

  @override
  State<_CreateGroupButton> createState() => _CreateGroupButtonState();
}

class _CreateGroupButtonState extends State<_CreateGroupButton> {
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
                'New Group',
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
  final VoidCallback onCreate;
  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
                Icons.group_outlined,
                size: 36,
                color: BlinkColors.primary.withValues(alpha: 0.3),
              ),
            ),
            const Gap(20),
            Text(
              'No Groups Yet',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(6),
            Text(
              'Create groups to send files to\nmultiple devices at once.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.25),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const Gap(28),
            _CreateGroupButton(onTap: onCreate),
          ],
        ).animate().fadeIn(duration: 500.ms),
      ),
    );
  }
}

class _GroupCard extends StatefulWidget {
  final ContactGroup group;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onSend;
  final VoidCallback onDelete;

  const _GroupCard({
    required this.group,
    required this.index,
    required this.onTap,
    required this.onSend,
    required this.onDelete,
  });

  @override
  State<_GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<_GroupCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final memberCount = widget.group.memberDeviceIds.length;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [BlinkColors.primary, Color(0xFF8B7BFF)],
                  ),
                ),
                child: const Icon(Icons.group_rounded,
                    color: Colors.white, size: 22),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.group.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(3),
                    Row(
                      children: [
                        _MemberDots(count: memberCount),
                        const Gap(6),
                        Text(
                          '$memberCount member${memberCount == 1 ? '' : 's'}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: widget.onSend,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: BlinkColors.primary.withValues(alpha: 0.12),
                  ),
                  child: const Icon(Icons.send_rounded,
                      color: BlinkColors.primary, size: 16),
                ),
              ),
              const Gap(6),
              GestureDetector(
                onTap: widget.onDelete,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                  child: Icon(Icons.more_vert_rounded,
                      color: Colors.white.withValues(alpha: 0.3), size: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(
          duration: 400.ms,
          delay: Duration(milliseconds: 60 * widget.index),
        );
  }
}

class _MemberDots extends StatelessWidget {
  final int count;
  const _MemberDots({required this.count});

  @override
  Widget build(BuildContext context) {
    final display = count.clamp(0, 3);
    if (display == 0) return const SizedBox.shrink();
    return SizedBox(
      width: 14.0 + (display - 1) * 8.0,
      height: 14,
      child: Stack(
        children: List.generate(display, (i) {
          return Positioned(
            left: i * 8.0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BlinkColors.darkHover,
                border:
                    Border.all(color: BlinkColors.darkSurface, width: 1.5),
              ),
              child: Icon(
                Icons.person_rounded,
                size: 8,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _GroupDetailsSheet extends ConsumerWidget {
  final ContactGroup group;
  const _GroupDetailsSheet({required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentGroup = ref.watch(groupsNotifierProvider).groups.firstWhere(
          (g) => g.groupId == group.groupId,
          orElse: () => group,
        );
    final devicesAsync = ref.watch(discoveryNotifierProvider);
    final nearbyDevices = devicesAsync.value ?? [];

    final nonMembers = nearbyDevices
        .where((d) => !currentGroup.memberDeviceIds.contains(d.deviceId))
        .toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          const Gap(8),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Gap(16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [BlinkColors.primary, Color(0xFF8B7BFF)],
                    ),
                  ),
                  child: const Icon(Icons.group_rounded,
                      color: Colors.white, size: 24),
                ),
                const Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentGroup.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${currentGroup.memberDeviceIds.length} members',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close_rounded,
                      color: Colors.white.withValues(alpha: 0.4), size: 22),
                ),
              ],
            ),
          ),
          const Gap(20),

          // Members section
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                Text(
                  'MEMBERS',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const Gap(10),
                if (currentGroup.memberDeviceIds.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: BlinkColors.darkBackground,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person_add_rounded,
                            color: Colors.white.withValues(alpha: 0.2),
                            size: 20),
                        const Gap(10),
                        Expanded(
                          child: Text(
                            'No members yet. Add nearby devices below.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...currentGroup.memberDeviceIds.map(
                    (deviceId) => _MemberTile(
                      deviceId: deviceId,
                      device: nearbyDevices
                          .where((d) => d.deviceId == deviceId)
                          .firstOrNull,
                      onRemove: () => ref
                          .read(groupsNotifierProvider.notifier)
                          .removeMember(currentGroup.groupId, deviceId),
                    ),
                  ),
                const Gap(20),

                // Add nearby devices
                if (nonMembers.isNotEmpty) ...[
                  Text(
                    'ADD NEARBY DEVICES',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Gap(10),
                  ...nonMembers.map(
                    (device) => _AddDeviceTile(
                      device: device,
                      onAdd: () => ref
                          .read(groupsNotifierProvider.notifier)
                          .addMember(currentGroup.groupId, device.deviceId),
                    ),
                  ),
                ],
                const Gap(16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final String deviceId;
  final Device? device;
  final VoidCallback onRemove;

  const _MemberTile({
    required this.deviceId,
    this.device,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isOnline = device != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: BlinkColors.darkBackground,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline
                  ? BlinkColors.success.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.04),
            ),
            child: Icon(
              Icons.devices_rounded,
              size: 16,
              color: isOnline
                  ? BlinkColors.success
                  : Colors.white.withValues(alpha: 0.3),
            ),
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device?.name ?? 'Device ${deviceId.substring(0, 8)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: isOnline ? BlinkColors.success : Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.remove_circle_outline_rounded,
                size: 18, color: BlinkColors.error.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }
}

class _AddDeviceTile extends StatelessWidget {
  final Device device;
  final VoidCallback onAdd;

  const _AddDeviceTile({required this.device, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: BlinkColors.darkBackground,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BlinkColors.accent.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.devices_rounded,
                size: 16,
                color: BlinkColors.accent.withValues(alpha: 0.7),
              ),
            ),
            const Gap(10),
            Expanded(
              child: Text(
                device.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.add_circle_outline_rounded,
                size: 18, color: BlinkColors.success.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}
