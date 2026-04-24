import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/device.dart';
import '../../../services/discovery/discovery_manager.dart';

/// Manages the list of currently visible nearby devices.
///
/// Subscribes to [DiscoveryManager.onDeviceFound] and deduplicates by [deviceId].
/// Automatically removes devices when they disappear from the network.
class DiscoveryNotifier extends Notifier<AsyncValue<List<Device>>> {
  StreamSubscription<Device>? _foundSub;
  StreamSubscription<String>? _lostSub;

  @override
  AsyncValue<List<Device>> build() {
    _startDiscovery();
    ref.onDispose(() {
      _foundSub?.cancel();
      _lostSub?.cancel();
    });
    return const AsyncData([]);
  }

  void _startDiscovery() {
    _foundSub = DiscoveryManager.instance.onDeviceFound.listen(
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

    _lostSub = DiscoveryManager.instance.onDeviceLost.listen(
      (deviceId) {
        final current = state.value ?? [];
        state =
            AsyncData(current.where((d) => d.deviceId != deviceId).toList());
      },
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
