import 'dart:async';

import 'package:bonsoir/bonsoir.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/platform_utils.dart';
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
  final _lostController = StreamController<String>.broadcast();

  /// Stream of devices announced via mDNS.
  Stream<Device> get onDeviceDiscovered => _discoveredController.stream;

  /// Stream of device IDs that have gone offline.
  Stream<String> get onDeviceLost => _lostController.stream;

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
        attributes: {
          'id': deviceId,
          'platform': PlatformUtils.platformName.toLowerCase(),
        },
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
      switch (event) {
        case BonsoirDiscoveryServiceResolvedEvent():
          final device = _serviceToDevice(event.service);
          if (device != null) {
            _discoveredController.add(device);
            Log.d(
              'Resolved: ${device.name} @ ${device.lastKnownIp}:${device.lastKnownPort}',
              source: LogSource.network,
              component: 'MdnsService',
            );
          }
        case BonsoirDiscoveryServiceLostEvent():
          final deviceId = event.service.attributes['id'];
          if (deviceId != null) {
            _lostController.add(deviceId);
            Log.d(
              'Lost: ${event.service.name} (id=$deviceId)',
              source: LogSource.network,
              component: 'MdnsService',
            );
          }
        case BonsoirDiscoveryServiceFoundEvent():
          Log.t(
            'Found (pending resolve): ${event.service.name}',
            source: LogSource.network,
            component: 'MdnsService',
          );
        default:
          break;
      }
    });

    await _discovery!.start();
    Log.i(
      'Discovery started',
      source: LogSource.network,
      component: 'MdnsService',
    );
  }

  Device? _serviceToDevice(BonsoirService service) {
    final deviceId = service.attributes['id'];
    if (deviceId == null || deviceId.isEmpty) return null;

    final host = service.host;
    if (host == null || host.isEmpty) return null;

    final platformStr = service.attributes['platform'] ?? '';
    final platform = _parsePlatform(platformStr);

    return Device(
      deviceId: deviceId,
      name: service.name,
      platform: platform,
      lastKnownIp: host,
      lastKnownPort: service.port,
      lastSeenAt: DateTime.now(),
    );
  }

  DevicePlatform _parsePlatform(String value) {
    return switch (value.toLowerCase()) {
      'android' => DevicePlatform.android,
      'linux' => DevicePlatform.linux,
      'windows' => DevicePlatform.windows,
      _ => DevicePlatform.unknown,
    };
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
    await _lostController.close();
  }
}
