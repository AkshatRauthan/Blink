import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../app.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/device.dart';
import '../providers/discovery_provider.dart';
import '../widgets/device_bubble.dart';
import '../widgets/radar_painter.dart';

class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen>
    with TickerProviderStateMixin {
  late final AnimationController _radarController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _radarController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final devicesAsync = ref.watch(discoveryNotifierProvider);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;

    return Scaffold(
      backgroundColor: BlinkColors.darkBackground,
      body: isDesktop
          ? _buildDesktopLayout(context, devicesAsync)
          : _buildMobileLayout(context, devicesAsync),
    );
  }

  Widget _buildMobileLayout(
      BuildContext context, AsyncValue<List<Device>> devicesAsync) {
    final devices = devicesAsync.value ?? [];

    return Stack(
      children: [
        // Radar
        Positioned.fill(
          child: _buildRadarView(context, devices),
        ),

        // Top header
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _FrostedHeader(
            onQrTap: () => context.push(AppRoutes.qrScan),
            onShowQrTap: () => context.push(AppRoutes.qrShow),
          ),
        ),

        // Bottom status + FAB
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _BottomControls(
            deviceCount: devices.length,
            onSelectFiles: () {
              // TODO: Open file picker
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(
      BuildContext context, AsyncValue<List<Device>> devicesAsync) {
    final devices = devicesAsync.value ?? [];

    return Row(
      children: [
        // Radar area
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              Positioned.fill(
                child: _buildRadarView(context, devices),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _FrostedHeader(
                  onQrTap: () => context.push(AppRoutes.qrScan),
                  onShowQrTap: () => context.push(AppRoutes.qrShow),
                ),
              ),
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Center(
                  child: _SelectFilesButton(
                    onPressed: () {
                      // TODO: Open file picker
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // Device list panel
        Container(
          width: 320,
          decoration: BoxDecoration(
            color: BlinkColors.darkSurface,
            border: Border(
              left: BorderSide(
                color: BlinkColors.darkHover.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: _DeviceListPanel(
            devices: devices,
            onDeviceTap: (device) => context.push(AppRoutes.send),
          ),
        ),
      ],
    );
  }

  Widget _buildRadarView(BuildContext context, List<Device> devices) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;
    final radarSize = isDesktop
        ? min(size.height * 0.85, size.width * 0.5)
        : min(size.width, size.height * 0.65);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Radar rings
        AnimatedBuilder(
          animation: Listenable.merge([_radarController, _pulseController]),
          builder: (context, _) => CustomPaint(
            painter: RadarPainter(
              animationValue: _radarController.value,
              pulseValue: _pulseController.value,
              deviceCount: devices.length,
            ),
            size: Size(radarSize, radarSize),
          ),
        ),

        // Device bubbles
        ...devices.asMap().entries.map((entry) {
          final i = entry.key;
          final device = entry.value;
          final angle = (2 * pi / max(devices.length, 1)) * i - (pi / 2);
          final ringIndex = (i % 3) + 2;
          final radiusFraction = ringIndex / 5;
          final radius = (radarSize / 2) * radiusFraction * 0.9;

          return Positioned(
            left: (size.width / 2) + cos(angle) * radius - 32,
            top: (size.height / 2) + sin(angle) * radius - 40,
            child: DeviceBubble(
              device: device,
              onTap: () => context.push(AppRoutes.send),
            )
                .animate()
                .fadeIn(
                  duration: 500.ms,
                  delay: Duration(milliseconds: 150 * i),
                )
                .scale(
                  begin: const Offset(0.5, 0.5),
                  duration: 500.ms,
                  delay: Duration(milliseconds: 150 * i),
                  curve: Curves.easeOutBack,
                ),
          );
        }),

        // Centre avatar
        _CentreAvatar(controller: _pulseController),
      ],
    );
  }
}

class _FrostedHeader extends StatelessWidget {
  final VoidCallback onQrTap;
  final VoidCallback onShowQrTap;

  const _FrostedHeader({
    required this.onQrTap,
    required this.onShowQrTap,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(
            top: topPadding + 8,
            left: 20,
            right: 12,
            bottom: 12,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                BlinkColors.darkBackground.withValues(alpha: 0.85),
                BlinkColors.darkBackground.withValues(alpha: 0.0),
              ],
            ),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/svg/logo/blink_logo_small.svg',
                width: 24,
                height: 24,
              ),
              const Gap(10),
              const Text(
                'Blink',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
              ),
              const Spacer(),
              _HeaderButton(
                icon: Icons.qr_code_rounded,
                onTap: onShowQrTap,
              ),
              const Gap(4),
              _HeaderButton(
                icon: Icons.qr_code_scanner_rounded,
                onTap: onQrTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.06),
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }
}

class _CentreAvatar extends StatelessWidget {
  final AnimationController controller;
  const _CentreAvatar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final glow = 0.3 + controller.value * 0.2;
        return Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: BlinkColors.primary.withValues(alpha: glow),
                blurRadius: 40,
                spreadRadius: 8,
              ),
              BoxShadow(
                color: BlinkColors.accent.withValues(alpha: glow * 0.3),
                blurRadius: 60,
                spreadRadius: 4,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [BlinkColors.primary, Color(0xFF8B7BFF)],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.person_rounded,
            size: 32,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  final int deviceCount;
  final VoidCallback onSelectFiles;

  const _BottomControls({
    required this.deviceCount,
    required this.onSelectFiles,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.only(
        bottom: bottomPadding + 16,
        left: 24,
        right: 24,
        top: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            BlinkColors.darkBackground.withValues(alpha: 0.95),
            BlinkColors.darkBackground.withValues(alpha: 0.0),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status pill
          _StatusPill(deviceCount: deviceCount),
          const Gap(16),
          // Select files button
          _SelectFilesButton(onPressed: onSelectFiles),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final int deviceCount;
  const _StatusPill({required this.deviceCount});

  @override
  Widget build(BuildContext context) {
    final isSearching = deviceCount == 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSearching)
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: BlinkColors.accent.withValues(alpha: 0.7),
              ),
            )
          else
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BlinkColors.success,
                boxShadow: [
                  BoxShadow(
                    color: BlinkColors.success.withValues(alpha: 0.4),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          const Gap(8),
          Text(
            isSearching
                ? 'Searching for nearby devices...'
                : '$deviceCount device${deviceCount == 1 ? '' : 's'} nearby',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms);
  }
}

class _SelectFilesButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _SelectFilesButton({required this.onPressed});

  @override
  State<_SelectFilesButton> createState() => _SelectFilesButtonState();
}

class _SelectFilesButtonState extends State<_SelectFilesButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 52,
          constraints: const BoxConstraints(maxWidth: 320),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [BlinkColors.primary, Color(0xFF8B7BFF)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: BlinkColors.primary.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_rounded,
                color: Colors.white.withValues(alpha: 0.9),
                size: 22,
              ),
              const Gap(8),
              const Text(
                'Select Files',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeviceListPanel extends StatelessWidget {
  final List<Device> devices;
  final ValueChanged<Device> onDeviceTap;

  const _DeviceListPanel({
    required this.devices,
    required this.onDeviceTap,
  });

  IconData _platformIcon(DevicePlatform platform) => switch (platform) {
        DevicePlatform.android => Icons.phone_android_rounded,
        DevicePlatform.linux => Icons.laptop_rounded,
        DevicePlatform.windows => Icons.desktop_windows_rounded,
        DevicePlatform.unknown => Icons.devices_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(
            children: [
              const Text(
                'Nearby Devices',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: BlinkColors.primary.withValues(alpha: 0.15),
                ),
                child: Text(
                  '${devices.length}',
                  style: const TextStyle(
                    color: BlinkColors.primaryLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(
          color: Color(0xFF1E1E2E),
          height: 1,
        ),
        Expanded(
          child: devices.isEmpty
              ? _EmptyDeviceList()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return _DeviceListTile(
                      device: device,
                      platformIcon: _platformIcon(device.platform),
                      onTap: () => onDeviceTap(device),
                    )
                        .animate()
                        .fadeIn(
                          duration: 400.ms,
                          delay: Duration(milliseconds: 80 * index),
                        )
                        .slideX(
                          begin: 0.05,
                          end: 0,
                          delay: Duration(milliseconds: 80 * index),
                        );
                  },
                ),
        ),
      ],
    );
  }
}

class _EmptyDeviceList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.radar_rounded,
            size: 48,
            color: Colors.white.withValues(alpha: 0.12),
          ),
          const Gap(12),
          Text(
            'Scanning...',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Gap(4),
          Text(
            'Devices will appear here',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.2),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceListTile extends StatefulWidget {
  final Device device;
  final IconData platformIcon;
  final VoidCallback onTap;

  const _DeviceListTile({
    required this.device,
    required this.platformIcon,
    required this.onTap,
  });

  @override
  State<_DeviceListTile> createState() => _DeviceListTileState();
}

class _DeviceListTileState extends State<_DeviceListTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: _isHovered
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      BlinkColors.accent.withValues(alpha: 0.15),
                      BlinkColors.primary.withValues(alpha: 0.08),
                    ],
                  ),
                  border: Border.all(
                    color: BlinkColors.accent.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.device.name.isNotEmpty
                        ? widget.device.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.device.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(2),
                    Row(
                      children: [
                        Icon(
                          widget.platformIcon,
                          size: 12,
                          color: BlinkColors.darkTextTertiary,
                        ),
                        const Gap(4),
                        Text(
                          widget.device.platform.name,
                          style: const TextStyle(
                            color: BlinkColors.darkTextTertiary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
