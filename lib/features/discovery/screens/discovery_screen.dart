import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/device.dart';
import '../providers/discovery_provider.dart';
import '../widgets/device_bubble.dart';
import '../widgets/radar_painter.dart';

class DiscoveryScreen extends ConsumerWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesAsync = ref.watch(discoveryNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blink'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {/* TODO: navigate to QR scan */},
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {/* TODO: navigate to settings */},
          ),
        ],
      ),
      body: devicesAsync.when(
        loading: () => _buildRadar(context, []),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (devices) => _buildRadar(context, devices),
      ),
    );
  }

  Widget _buildRadar(BuildContext context, List<Device> devices) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Animated radar rings
        CustomPaint(
          painter: RadarPainter(),
          size: Size.infinite,
        ),
        // Device bubbles floating around the radar centre
        ...devices.map(
          (d) => DeviceBubble(device: d, onTap: () {/* TODO: initiate send */}),
        ),
        // Centre: "You" avatar
        const CircleAvatar(
          radius: 32,
          child: Icon(Icons.person, size: 32),
        ),
        // Status label at bottom
        Positioned(
          bottom: 48,
          child: Text(
            devices.isEmpty
                ? 'Looking for nearby devices…'
                : '${devices.length} device${devices.length == 1 ? '' : 's'} nearby',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
