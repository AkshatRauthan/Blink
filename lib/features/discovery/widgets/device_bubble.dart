import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/device.dart';

class DeviceBubble extends StatefulWidget {
  final Device device;
  final VoidCallback onTap;

  const DeviceBubble({
    super.key,
    required this.device,
    required this.onTap,
  });

  @override
  State<DeviceBubble> createState() => _DeviceBubbleState();
}

class _DeviceBubbleState extends State<DeviceBubble> {
  bool _isPressed = false;

  IconData _platformIcon(DevicePlatform platform) => switch (platform) {
        DevicePlatform.android => Icons.phone_android_rounded,
        DevicePlatform.linux => Icons.laptop_rounded,
        DevicePlatform.windows => Icons.desktop_windows_rounded,
        DevicePlatform.unknown => Icons.devices_rounded,
      };

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
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: BlinkColors.accent.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: BlinkColors.primary.withValues(alpha: 0.1),
                    blurRadius: 30,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.12),
                          Colors.white.withValues(alpha: 0.04),
                        ],
                      ),
                      border: Border.all(
                        color: BlinkColors.accent.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          widget.device.name.isNotEmpty
                              ? widget.device.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: BlinkColors.darkSurface,
                              border: Border.all(
                                color: BlinkColors.accent.withValues(alpha: 0.4),
                                width: 0.5,
                              ),
                            ),
                            child: Icon(
                              _platformIcon(widget.device.platform),
                              size: 10,
                              color: BlinkColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Gap(6),
            Text(
              widget.device.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
