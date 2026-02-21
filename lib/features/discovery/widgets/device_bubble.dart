import 'package:flutter/material.dart';
import '../../../data/models/device.dart';

/// A circular bubble representing a discovered nearby device.
class DeviceBubble extends StatelessWidget {
  final Device device;
  final VoidCallback onTap;

  const DeviceBubble({
    super.key,
    required this.device,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor:
                Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              device.name.isNotEmpty
                  ? device.name[0].toUpperCase()
                  : '?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            device.name,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          Text(
            device.platform.name,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: Theme.of(context).colorScheme.outline),
          ),
        ],
      ),
    );
  }
}
