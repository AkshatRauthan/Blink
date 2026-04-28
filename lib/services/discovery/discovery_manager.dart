import 'dart:async';

import '../../core/utils/logger.dart';
import '../../data/models/device.dart';
import 'mdns_service.dart';
import 'ble_service.dart';

class DiscoveryManager {
  DiscoveryManager._();
  static final instance = DiscoveryManager._();

  final MdnsService _mdns = MdnsService.instance;
  final BleService _ble = BleService.instance;

  final _devicesController = StreamController<Device>.broadcast();
  final _lostController = StreamController<String>.broadcast();
  StreamSubscription<Device>? _mdnsSub;
  StreamSubscription<String>? _mdnsLostSub;
  StreamSubscription<Device>? _bleSub;
  StreamSubscription<String>? _bleLostSub;
  bool _running = false;

  Stream<Device> get onDeviceFound => _devicesController.stream;
  Stream<String> get onDeviceLost => _lostController.stream;

  Future<void> startAll({
    required String deviceId,
    required String deviceName,
    required int port,
  }) async {
    if (_running) return;
    Log.i(
      'Starting discovery manager',
      source: LogSource.service,
      component: 'DiscoveryManager',
    );

    await _ble.init();

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
    _mdnsLostSub = _mdns.onDeviceLost.listen(_lostController.add);
    _bleSub = _ble.onDeviceDiscovered.listen(_devicesController.add);
    _bleLostSub = _ble.onDeviceLost.listen(_lostController.add);
    _running = true;
  }

  Future<void> stopAll() async {
    if (!_running) return;
    await _mdnsSub?.cancel();
    _mdnsSub = null;
    await _mdnsLostSub?.cancel();
    _mdnsLostSub = null;
    await _bleSub?.cancel();
    _bleSub = null;
    await _bleLostSub?.cancel();
    _bleLostSub = null;

    await Future.wait([
      _mdns.stopAdvertising(),
      _mdns.stopDiscovery(),
      _ble.stopAll(),
    ]);
    _running = false;
    Log.i(
      'Stopped',
      source: LogSource.service,
      component: 'DiscoveryManager',
    );
  }

  Future<void> dispose() async {
    await stopAll();
    await _devicesController.close();
    await _lostController.close();
    await _mdns.dispose();
    await _ble.dispose();
  }
}
