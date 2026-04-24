import 'dart:async';

import '../../core/utils/logger.dart';
import '../../data/models/device.dart';
import 'mdns_service.dart';
import 'ble_service.dart';

/// Combines mDNS and BLE discovery into a single unified stream.
///
/// mDNS is the primary channel on all platforms.
/// BLE provides a faster initial tap-to-send signal on Android.
class DiscoveryManager {
  DiscoveryManager._();
  static final instance = DiscoveryManager._();

  final MdnsService _mdns = MdnsService.instance;
  final BleService _ble = BleService.instance;

  final _devicesController = StreamController<Device>.broadcast();
  StreamSubscription<Device>? _mdnsSub;

  /// Unified stream of nearby devices from all discovery sources.
  Stream<Device> get onDeviceFound => _devicesController.stream;

  /// Starts both mDNS and BLE discovery.
  Future<void> startAll({
    required String deviceId,
    required String deviceName,
    required int port,
  }) async {
    Log.i(
      'Starting discovery manager',
      source: LogSource.service,
      component: 'DiscoveryManager',
    );
    await Future.wait([
      _mdns.startAdvertising(
        deviceId: deviceId,
        deviceName: deviceName,
        port: port,
      ),
      _mdns.startDiscovery(),
      _ble.startAdvertising(deviceId),
      _ble.startScanning(),
    ]);

    _mdnsSub = _mdns.onDeviceDiscovered.listen(_devicesController.add);
    // BLE beacons are supplementary; devices still need mDNS to resolve IP
  }

  Future<void> stopAll() async {
    await Future.wait([
      _mdns.stopAdvertising(),
      _mdns.stopDiscovery(),
      _ble.stopAll(),
    ]);
    Log.i(
      'Stopped',
      source: LogSource.service,
      component: 'DiscoveryManager',
    );
  }

  Future<void> dispose() async {
    await _mdnsSub?.cancel();
    await stopAll();
    await _devicesController.close();
  }
}
