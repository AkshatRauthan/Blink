import 'dart:async';

import 'package:bonsoir/bonsoir.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../../data/models/device.dart';

/// Advertises this device and discovers other Blink devices via mDNS/Bonjour.
///
/// Uses the [bonsoir] package on all three platforms (Android, Linux, Windows).
class MdnsService {
  MdnsService._();
  static final instance = MdnsService._();

  BonsoirBroadcast? _broadcast;
  BonsoirDiscovery? _discovery;

  final _discoveredController = StreamController<Device>.broadcast();

  /// Stream of devices announced via mDNS.
  Stream<Device> get onDeviceDiscovered => _discoveredController.stream;

  /// Start advertising this device on the local network.
  Future<void> startAdvertising({
    required String deviceId,
    required String deviceName,
    required int port,
  }) async {
    await stopAdvertising();
    _broadcast = BonsoirBroadcast(
      service: BonsoirService(
        name: deviceName,
        type: AppConstants.mdnsServiceType,
        port: port,
        attributes: {'id': deviceId},
      ),
    );
    await _broadcast!.initialize();
    await _broadcast!.start();
    Log.i(
      'Advertising "$deviceName" on port $port',
      source: LogSource.network,
      component: 'MdnsService',
    );
  }

  /// Start scanning for other Blink devices.
  Future<void> startDiscovery() async {
    await stopDiscovery();
    _discovery = BonsoirDiscovery(type: AppConstants.mdnsServiceType);
    await _discovery!.initialize();

    _discovery!.eventStream?.listen((event) {
      if (event is BonsoirDiscoveryServiceFoundEvent) {
        Log.d(
          'Found: ${event.service.name}',
          source: LogSource.network,
          component: 'MdnsService',
        );
        // TODO: Resolve service and emit parsed Device
      }
    });

    await _discovery!.start();
    Log.i(
      'Discovery started',
      source: LogSource.network,
      component: 'MdnsService',
    );
  }

  Future<void> stopAdvertising() async {
    await _broadcast?.stop();
    _broadcast = null;
  }

  Future<void> stopDiscovery() async {
    await _discovery?.stop();
    _discovery = null;
  }

  Future<void> dispose() async {
    await stopAdvertising();
    await stopDiscovery();
    await _discoveredController.close();
  }
}
