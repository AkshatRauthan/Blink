import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;

    return Scaffold(
      backgroundColor: BlinkColors.darkBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isDesktop ? 560 : double.infinity),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: const Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: _ProfileCard(
                      displayName: settings.displayName,
                      onTap: () => _showRenameSheet(context, ref, settings.displayName),
                    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.03, end: 0),
                  ),
                ),
                SliverToBoxAdapter(child: const Gap(24)),
                ..._buildSection(
                  context,
                  label: 'GENERAL',
                  delay: 100,
                  children: [
                    _ToggleTile(
                      icon: Icons.dark_mode_rounded,
                      iconColor: BlinkColors.primary,
                      title: 'Dark Mode',
                      subtitle: 'Always-on dark theme',
                      value: settings.darkMode,
                      onChanged: notifier.setDarkMode,
                    ),
                  ],
                ),
                ..._buildSection(
                  context,
                  label: 'TRANSFER',
                  delay: 200,
                  children: [
                    _ToggleTile(
                      icon: Icons.compress_rounded,
                      iconColor: BlinkColors.accent,
                      title: 'LZ4 Compression',
                      subtitle: 'Compress non-media files',
                      value: settings.compressionEnabled,
                      onChanged: notifier.setCompressionEnabled,
                    ),
                  ],
                ),
                ..._buildSection(
                  context,
                  label: 'DISCOVERY',
                  delay: 300,
                  children: [
                    _ToggleTile(
                      icon: Icons.bluetooth_rounded,
                      iconColor: const Color(0xFF5B8DEF),
                      title: 'BLE Discovery',
                      subtitle: 'Bluetooth device presence',
                      value: settings.bleEnabled,
                      onChanged: notifier.setBleEnabled,
                    ),
                  ],
                ),
                ..._buildSection(
                  context,
                  label: 'SECURITY',
                  delay: 400,
                  children: [
                    _InfoTile(
                      icon: Icons.shield_rounded,
                      iconColor: BlinkColors.success,
                      title: 'Encryption',
                      subtitle: 'XChaCha20-Poly1305 · Ed25519',
                    ),
                    _InfoTile(
                      icon: Icons.tag_rounded,
                      iconColor: BlinkColors.success,
                      title: 'File Integrity',
                      subtitle: 'BLAKE3 checksum verification',
                    ),
                  ],
                ),
                ..._buildSection(
                  context,
                  label: 'ABOUT',
                  delay: 500,
                  children: [
                    _InfoTile(
                      icon: Icons.info_outline_rounded,
                      iconColor: BlinkColors.primary,
                      title: 'Version',
                      subtitle: '0.1.0',
                      trailing: const _VersionBadge(),
                    ),
                  ],
                ),
                SliverToBoxAdapter(child: const Gap(40)),
                SliverToBoxAdapter(
                  child: Center(
                    child: Column(
                      children: [
                        SvgPicture.asset(
                          'assets/svg/logo/blink_logo_small.svg',
                          width: 20,
                          height: 20,
                          colorFilter: ColorFilter.mode(
                            Colors.white.withValues(alpha: 0.12),
                            BlendMode.srcIn,
                          ),
                        ),
                        const Gap(6),
                        Text(
                          'Blink · Privacy First',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.15),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: const Gap(32)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSection(
    BuildContext context, {
    required String label,
    required int delay,
    required List<Widget> children,
  }) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 20, 8),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: BlinkColors.darkSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: BlinkColors.darkHover.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1)
                    Divider(
                      height: 0.5,
                      indent: 56,
                      color: BlinkColors.darkHover.withValues(alpha: 0.3),
                    ),
                ],
              ],
            ),
          ).animate().fadeIn(
                duration: 400.ms,
                delay: Duration(milliseconds: delay),
              ),
        ),
      ),
      SliverToBoxAdapter(child: const Gap(20)),
    ];
  }

  void _showRenameSheet(BuildContext context, WidgetRef ref, String current) {
    final controller = TextEditingController(text: current);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
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
                'Display Name',
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
                    color: BlinkColors.darkHover.withValues(alpha: 0.5),
                  ),
                ),
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const Gap(16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 15,
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
                        final name = controller.text.trim();
                        if (name.isNotEmpty) {
                          ref
                              .read(settingsNotifierProvider.notifier)
                              .setDisplayName(name);
                        }
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [BlinkColors.primary, Color(0xFF8B7BFF)],
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
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
      ),
    );
  }
}

class _ProfileCard extends StatefulWidget {
  final String displayName;
  final VoidCallback onTap;

  const _ProfileCard({required this.displayName, required this.onTap});

  @override
  State<_ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<_ProfileCard> {
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
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                BlinkColors.primary.withValues(alpha: 0.1),
                BlinkColors.accent.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: BlinkColors.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [BlinkColors.primary, Color(0xFF8B7BFF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: BlinkColors.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.displayName.isEmpty
                        ? '?'
                        : widget.displayName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.displayName.isEmpty
                          ? 'Set your name'
                          : widget.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      'Tap to edit display name',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.2),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 17),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeTrackColor: BlinkColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 17),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _VersionBadge extends StatelessWidget {
  const _VersionBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: BlinkColors.primary.withValues(alpha: 0.12),
      ),
      child: const Text(
        'Beta',
        style: TextStyle(
          color: BlinkColors.primaryLight,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
