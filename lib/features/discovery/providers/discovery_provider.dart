import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/device.dart';
import '../../../services/discovery/discovery_manager.dart';

/// Manages the list of currently visible nearby devices.
///
/// Subscribes to [DiscoveryManager.onDeviceFound] and deduplicates by [deviceId].
class DiscoveryNotifier extends Notifier<AsyncValue<List<Device>>> {
  @override
  AsyncValue<List<Device>> build() {
    _startDiscovery();
    return const AsyncData([]);
  }

  void _startDiscovery() {
    DiscoveryManager.instance.onDeviceFound.listen(
      (device) {
        final current = state.value ?? [];
        final idx = current.indexWhere((d) => d.deviceId == device.deviceId);
        if (idx == -1) {
          state = AsyncData([...current, device]);
        } else {
          final updated = [...current];
          updated[idx] = device;
          state = AsyncData(updated);
        }
      },
      onError: (e) => state = AsyncError(e, StackTrace.current),
    );
  }

  /// Manually removes a device that has gone offline.
  void removeDevice(String deviceId) {
    final current = state.value ?? [];
    state = AsyncData(current.where((d) => d.deviceId != deviceId).toList());
  }
}

final discoveryNotifierProvider =
    NotifierProvider<DiscoveryNotifier, AsyncValue<List<Device>>>(
  DiscoveryNotifier.new,
);
