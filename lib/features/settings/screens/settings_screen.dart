import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../providers/settings_provider.dart';

/// iOS-style grouped settings screen.
///
/// Stitch screen: "Blink App Settings Screen" (e10e369e6f64495e84f113d51f62d9ab)
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text('Settings', style: theme.textTheme.headlineMedium),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: BlinkSpacing.md,
          vertical: BlinkSpacing.sm,
        ),
        children: [
          // ── Profile card ─────────────────────────
          _ProfileCard(
            displayName: settings.displayName,
            onTap: () => _showRenameDialog(context, ref, settings.displayName),
          ),
          const Gap(BlinkSpacing.lg),

          // ── General ──────────────────────────────
          _SectionLabel('General'),
          const Gap(BlinkSpacing.sm),
          _SettingsGroup(
            children: [
              _ToggleTile(
                icon: Icons.dark_mode_rounded,
                iconColor: BlinkColors.primary,
                title: 'Dark Mode',
                subtitle: 'Switch appearance theme',
                value: settings.darkMode,
                onChanged: notifier.setDarkMode,
              ),
            ],
          ),
          const Gap(BlinkSpacing.lg),

          // ── Transfer ─────────────────────────────
          _SectionLabel('Transfer'),
          const Gap(BlinkSpacing.sm),
          _SettingsGroup(
            children: [
              _ToggleTile(
                icon: Icons.compress_rounded,
                iconColor: BlinkColors.accent,
                title: 'LZ4 Compression',
                subtitle: 'Compress non-media files before sending',
                value: settings.compressionEnabled,
                onChanged: notifier.setCompressionEnabled,
              ),
            ],
          ),
          const Gap(BlinkSpacing.lg),

          // ── Discovery ────────────────────────────
          _SectionLabel('Discovery'),
          const Gap(BlinkSpacing.sm),
          _SettingsGroup(
            children: [
              _ToggleTile(
                icon: Icons.bluetooth_rounded,
                iconColor: Colors.blue,
                title: 'BLE Discovery',
                subtitle: 'Use Bluetooth for device presence',
                value: settings.bleEnabled,
                onChanged: notifier.setBleEnabled,
              ),
            ],
          ),
          const Gap(BlinkSpacing.lg),

          // ── Security ─────────────────────────────
          _SectionLabel('Security'),
          const Gap(BlinkSpacing.sm),
          _SettingsGroup(
            children: [
              _InfoTile(
                icon: Icons.shield_rounded,
                iconColor: BlinkColors.mint,
                title: 'Encryption',
                subtitle: 'XChaCha20-Poly1305 · Ed25519 signing',
              ),
              _InfoTile(
                icon: Icons.tag_rounded,
                iconColor: BlinkColors.mint,
                title: 'File Integrity',
                subtitle: 'BLAKE3 checksum verification',
              ),
            ],
          ),
          const Gap(BlinkSpacing.lg),

          // ── About ────────────────────────────────
          _SectionLabel('About'),
          const Gap(BlinkSpacing.sm),
          _SettingsGroup(
            children: [
              _InfoTile(
                icon: Icons.info_outline_rounded,
                iconColor: BlinkColors.primary,
                title: 'Version',
                subtitle: '0.1.0',
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'Blink',
                  applicationVersion: '0.1.0',
                  applicationLegalese: 'Privacy-first local file sharing',
                ),
              ),
            ],
          ),
          const Gap(BlinkSpacing.xxl),
        ],
      ),
    );
  }

  void _showRenameDialog(
      BuildContext context, WidgetRef ref, String current) {
    final controller = TextEditingController(text: current);
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BlinkRadius.xl),
        ),
        title: const Text('Display Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter your name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BlinkRadius.md),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref
                    .read(settingsNotifierProvider.notifier)
                    .setDisplayName(name);
              }
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
              backgroundColor: BlinkColors.primary,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ── Private widgets ──────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final String displayName;
  final VoidCallback onTap;

  const _ProfileCard({required this.displayName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(BlinkSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              BlinkColors.primary.withValues(alpha: 0.08),
              BlinkColors.accent.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(BlinkRadius.xl),
          border:
              Border.all(color: BlinkColors.primary.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [BlinkColors.primary, BlinkColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  displayName.isEmpty
                      ? '?'
                      : displayName[0].toUpperCase(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const Gap(BlinkSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName.isEmpty ? 'Set your name' : displayName,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Tap to edit display name',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color:
                    theme.colorScheme.onSurface.withValues(alpha: 0.3)),
          ],
        ),
      ),
    ).animate().fadeIn(duration: BlinkDurations.standard);
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: BlinkSpacing.xs),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.4),
            ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(BlinkRadius.lg),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
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
                color: theme.colorScheme.outlineVariant
                    .withValues(alpha: 0.2),
              ),
          ],
        ],
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: BlinkSpacing.md, vertical: BlinkSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(BlinkRadius.sm),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const Gap(BlinkSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500)),
                Text(subtitle,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.45),
                    )),
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
  final VoidCallback? onTap;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: BlinkSpacing.md, vertical: BlinkSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(BlinkRadius.sm),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const Gap(BlinkSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w500)),
                  Text(subtitle,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.45),
                      )),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right_rounded,
                  size: 18,
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}
