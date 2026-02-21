import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Display Name'),
            subtitle: Text(settings.displayName.isNotEmpty
                ? settings.displayName
                : 'Not set'),
            onTap: () {/* TODO: Rename dialog */},
          ),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.bluetooth),
            title: const Text('BLE Discovery'),
            subtitle: const Text('Use Bluetooth for device presence'),
            value: settings.bleEnabled,
            onChanged: (v) =>
                ref.read(settingsNotifierProvider.notifier).setBleEnabled(v),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.compress),
            title: const Text('LZ4 Compression'),
            subtitle: const Text('Compress non-media files before sending'),
            value: settings.compressionEnabled,
            onChanged: (v) => ref
                .read(settingsNotifierProvider.notifier)
                .setCompressionEnabled(v),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            value: settings.darkMode,
            onChanged: (v) =>
                ref.read(settingsNotifierProvider.notifier).setDarkMode(v),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Blink'),
            subtitle: const Text('v0.1.0 — Privacy-first file sharing'),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Blink',
              applicationVersion: '0.1.0',
            ),
          ),
        ],
      ),
    );
  }
}
