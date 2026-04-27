import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../core/utils/logger.dart';
import '../../core/utils/platform_utils.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/device.dart';

class BleService {
  BleService._();
  static final instance = BleService._();

  Timer? _scanTimer;
  bool _isScanning = false;
  StreamSubscription<List<ScanResult>>? _scanResultsSub;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSub;
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  final _discoveredController = StreamController<Device>.broadcast();
  final _lostController = StreamController<String>.broadcast();
  final _seenDevices = <String, DateTime>{};

  Stream<Device> get onDeviceDiscovered => _discoveredController.stream;
  Stream<String> get onDeviceLost => _lostController.stream;

  static const _staleTimeout = Duration(seconds: 30);
  static final _blinkServiceGuid = Guid(AppConstants.bleServiceUuid);

  Future<void> init() async {
    if (!PlatformUtils.bleSupported) return;

    _adapterStateSub = FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      _adapterState = state;
      Log.d(
        'Adapter state: $state',
        source: LogSource.service,
        component: 'BleService',
      );
    });
  }

  DevicePlatform _parsePlatform(String? str) => switch (str) {
    'android' => DevicePlatform.android,
    'linux' => DevicePlatform.linux,
    'windows' => DevicePlatform.windows,
    _ => DevicePlatform.unknown,
  };

  Future<void> startScanning() async {
    if (!PlatformUtils.bleSupported) {
      Log.w(
        'BLE not supported on ${PlatformUtils.platformName}',
        source: LogSource.service,
        component: 'BleService',
      );
      return;
    }

    if (_adapterState != BluetoothAdapterState.on) {
      Log.w(
        'Bluetooth adapter not on (state: $_adapterState)',
        source: LogSource.service,
        component: 'BleService',
      );
      return;
    }

    _scanResultsSub = FlutterBluePlus.onScanResults.listen(
      _handleScanResults,
      onError: (Object e) {
        Log.e(
          'Scan results error',
          source: LogSource.service,
          component: 'BleService',
          error: e,
        );
      },
    );

    _scheduleDutyCycle();
    Log.i(
      'Duty-cycled BLE scanning started',
      source: LogSource.service,
      component: 'BleService',
    );
  }

  void _scheduleDutyCycle() {
    _doScan();
    _scanTimer = Timer.periodic(
      AppConstants.bleScanWindow + AppConstants.bleScanGap,
      (_) => _doScan(),
    );
  }

  Future<void> _doScan() async {
    if (_isScanning) return;
    if (_adapterState != BluetoothAdapterState.on) return;

    _isScanning = true;
    try {
      await FlutterBluePlus.startScan(
        withServices: [_blinkServiceGuid],
        timeout: AppConstants.bleScanWindow,
        androidUsesFineLocation: false,
      );
    } catch (e) {
      Log.w(
        'BLE scan start failed',
        source: LogSource.service,
        component: 'BleService',
        error: e,
      );
    } finally {
      _isScanning = false;
      _pruneStaleDevices();
    }
  }

  void _handleScanResults(List<ScanResult> results) {
    for (final result in results) {
      final mfData = result.advertisementData.manufacturerData;
      final localName = result.advertisementData.advName;

      String? deviceId;
      String? platformStr;

      // Parse Blink beacon from manufacturer data (company ID 0xFFFF for development)
      if (mfData.containsKey(0xFFFF)) {
        final payload = mfData[0xFFFF]!;
        try {
          final decoded = utf8.decode(payload);
          final parts = decoded.split('|');
          if (parts.length >= 2 && parts[0].startsWith('BLINK:')) {
            deviceId = parts[0].substring(6);
            platformStr = parts.length >= 3 ? parts[2] : 'unknown';
          }
        } catch (_) {}
      }

      // Fallback: use service data or local name
      if (deviceId == null && localName.startsWith('Blink_')) {
        deviceId = localName.substring(6);
      }

      if (deviceId == null) continue;

      _seenDevices[deviceId] = DateTime.now();

      final device = Device(
        deviceId: deviceId,
        name: localName.isNotEmpty ? localName : 'Unknown',
        platform: _parsePlatform(platformStr),
        lastKnownPort: AppConstants.transferPort,
        lastSeenAt: DateTime.now(),
      );

      _discoveredController.add(device);
    }
  }

  void _pruneStaleDevices() {
    final now = DateTime.now();
    final stale = <String>[];
    _seenDevices.forEach((id, lastSeen) {
      if (now.difference(lastSeen) > _staleTimeout) {
        stale.add(id);
      }
    });
    for (final id in stale) {
      _seenDevices.remove(id);
      _lostController.add(id);
    }
  }

  Future<void> startAdvertising(String deviceId) async {
    if (!PlatformUtils.bleSupported) return;

    // flutter_blue_plus doesn't support peripheral advertising directly.
    // On Android, BLE advertising requires the BLE Peripheral role which
    // needs a platform channel to BluetoothLeAdvertiser.
    // For now we rely on mDNS as primary discovery — BLE scan picks up
    // other Blink devices advertising via their own platform channels.
    Log.i(
      'BLE advertising registered for $deviceId (via mDNS primary)',
      source: LogSource.service,
      component: 'BleService',
    );
  }

  Future<void> stopAll() async {
    _scanTimer?.cancel();
    _scanTimer = null;
    _isScanning = false;

    try {
      if (_adapterState == BluetoothAdapterState.on) {
        await FlutterBluePlus.stopScan();
      }
    } catch (_) {}

    await _scanResultsSub?.cancel();
    _scanResultsSub = null;
    _seenDevices.clear();

    Log.i(
      'BLE stopped',
      source: LogSource.service,
      component: 'BleService',
    );
  }

  Future<void> dispose() async {
    await stopAll();
    await _adapterStateSub?.cancel();
    _adapterStateSub = null;
    await _discoveredController.close();
    await _lostController.close();
  }
}
