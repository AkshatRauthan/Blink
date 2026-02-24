import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/device.dart';

/// A circular bubble representing a discovered nearby device.
///
/// Shows device initial, name, platform icon, with a subtle cyan glow.
class DeviceBubble extends StatelessWidget {
  final Device device;
  final VoidCallback onTap;

  const DeviceBubble({
    super.key,
    required this.device,
    required this.onTap,
  });

  IconData _platformIcon(DevicePlatform platform) => switch (platform) {
        DevicePlatform.android => Icons.phone_android_rounded,
        DevicePlatform.linux => Icons.computer_rounded,
        DevicePlatform.windows => Icons.desktop_windows_rounded,
        DevicePlatform.unknown => Icons.devices_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: BlinkColors.darkSurfaceVariant,
              border: Border.all(
                color: BlinkColors.accent.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: BlinkColors.accent.withValues(alpha: 0.25),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                device.name.isNotEmpty
                    ? device.name[0].toUpperCase()
                    : '?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: BlinkColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
          const SizedBox(height: BlinkSpacing.xs),
          Text(
            device.name,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: BlinkColors.darkTextPrimary,
                  fontWeight: FontWeight.w500,
                ),
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_platformIcon(device.platform),
                  size: 10, color: BlinkColors.darkTextTertiary),
              const SizedBox(width: 2),
              Text(
                device.platform.name,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: BlinkColors.darkTextTertiary,
                      fontSize: 9,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
