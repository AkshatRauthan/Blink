import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../app.dart';
import '../../../core/theme/app_colors.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/permissions_provider.dart';

class PermissionsScreen extends ConsumerWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(permissionsNotifierProvider);
    final items = permissionItemsForPlatform();

    return Scaffold(
      backgroundColor: BlinkColors.darkBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Permissions',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Gap(8),
                  Text(
                    Platform.isAndroid
                        ? 'Grant access so transfers and QR pairing work seamlessly.'
                        : 'Confirm what Blink can do on this device.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                  ),
                  const Gap(24),

                  for (final item in items)
                    _PermissionTile(
                      item: item,
                      selected: permissions.isSelected(item.id),
                      granted: permissions.isGranted(item.id),
                      onToggle: (value) => ref
                          .read(permissionsNotifierProvider.notifier)
                          .setSelected(item.id, value),
                    ),

                  if (permissions.error != null) ...[
                    const Gap(12),
                    Text(
                      permissions.error!,
                      style: TextStyle(
                        color: BlinkColors.error,
                        fontSize: 13,
                      ),
                    ),
                  ],

                  const Gap(20),
                  ElevatedButton(
                    onPressed: permissions.isRequesting
                        ? null
                        : () async {
                            await ref
                                .read(permissionsNotifierProvider.notifier)
                                .requestSelected();

                            final updated =
                                ref.read(permissionsNotifierProvider);
                            if (updated.allGranted && context.mounted) {
                              await ref
                                  .read(settingsNotifierProvider.notifier)
                                  .setPermissionsGranted(true);
                              if (context.mounted) {
                                context.go(AppRoutes.discovery);
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BlinkColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      Platform.isAndroid ? 'Grant selected' : 'Continue',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  if (!permissions.allGranted) ...[
                    const Gap(8),
                    Text(
                      'You can grant missing permissions later in settings.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final PermissionItem item;
  final bool selected;
  final bool granted;
  final ValueChanged<bool> onToggle;

  const _PermissionTile({
    required this.item,
    required this.selected,
    required this.granted,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final statusText = granted
        ? 'Granted'
        : selected
            ? 'Required'
            : 'Skipped';
    final statusColor = granted
        ? BlinkColors.success
        : selected
            ? BlinkColors.warning
            : Colors.white.withValues(alpha: 0.3);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: BlinkColors.darkSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: BlinkColors.darkHover.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: BlinkColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: BlinkColors.primary),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(4),
                Text(
                  item.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Gap(8),
          Column(
            children: [
              Switch(
                value: selected,
                onChanged: onToggle,
                activeColor: BlinkColors.primary,
              ),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
