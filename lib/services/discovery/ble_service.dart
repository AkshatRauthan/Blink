import 'dart:async';

import '../../core/utils/logger.dart';
import '../../core/utils/platform_utils.dart';
import '../../core/constants/app_constants.dart';

/// Manages BLE advertising and scanning for device presence beacons.
///
/// BLE is used ONLY for discovery — no data is transferred over BLE.
/// Fully supported on Android. Limited / disabled on Linux & Windows.
///
/// Duty-cycle: scan [AppConstants.bleScanWindow] every [AppConstants.bleScanGap]
/// to preserve battery.
class BleService {
  BleService._();
  static final instance = BleService._();

  Timer? _scanTimer;
  bool _isScanning = false;

  final _discoveredController = StreamController<String>.broadcast();

  /// Stream emitting discovered device IDs from BLE advertisements.
  Stream<String> get onDeviceBeaconReceived => _discoveredController.stream;

  /// Starts duty-cycled BLE scanning. No-op on unsupported platforms.
  Future<void> startScanning() async {
    if (!PlatformUtils.bleSupported) {
      Log.w(
        'Scanning not supported on ${PlatformUtils.platformName}',
        source: LogSource.service,
        component: 'BleService',
      );
      return;
    }
    _scheduleScan();
    Log.i(
      'Duty-cycled scanning started',
      source: LogSource.service,
      component: 'BleService',
    );
  }

  void _scheduleScan() {
    _doScan();
    _scanTimer = Timer.periodic(
      AppConstants.bleScanWindow + AppConstants.bleScanGap,
      (_) => _doScan(),
    );
  }

  Future<void> _doScan() async {
    if (_isScanning) return;
    _isScanning = true;
    // TODO: Use flutter_blue_plus to start a scan for AppConstants.bleScanWindow
    // FlutterBluePlus.startScan(
    //   withServices: [Guid(AppConstants.bleServiceUuid)],
    //   duration: AppConstants.bleScanWindow,
    // );
    await Future.delayed(AppConstants.bleScanWindow);
    _isScanning = false;
  }

  /// Starts BLE advertising this device as a Blink presence beacon.
  Future<void> startAdvertising(String deviceId) async {
    if (!PlatformUtils.bleSupported) return;
    // TODO: Implement BLE peripheral advertising via flutter_blue_plus / method channel
    Log.i(
      'Advertising started for $deviceId',
      source: LogSource.service,
      component: 'BleService',
    );
  }

  Future<void> stopAll() async {
    _scanTimer?.cancel();
    _scanTimer = null;
    _isScanning = false;
    Log.i(
      'Stopped',
      source: LogSource.service,
      component: 'BleService',
    );
  }

  Future<void> dispose() async {
    await stopAll();
    await _discoveredController.close();
  }
}
