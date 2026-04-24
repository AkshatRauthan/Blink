import 'dart:io';

import '../../core/utils/logger.dart';

/// Detects the device's local IP address on the current Wi-Fi interface.
class NetworkInfoService {
  NetworkInfoService._();
  static final instance = NetworkInfoService._();

  /// Returns the IPv4 address of the first non-loopback Wi-Fi interface.
  /// Returns null if no suitable address is found.
  Future<String?> getLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );

      for (final interface in interfaces) {
        // Prefer wlan/wifi interfaces
        final name = interface.name.toLowerCase();
        if (name.contains('wlan') ||
            name.contains('wifi') ||
            name.contains('en') ||
            name.contains('eth')) {
          for (final addr in interface.addresses) {
            if (!addr.isLoopback) {
              Log.d(
                'Local IP: ${addr.address} (${interface.name})',
                source: LogSource.network,
                component: 'NetworkInfoService',
              );
              return addr.address;
            }
          }
        }
      }

      // Fallback: first non-loopback address on any interface
      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (!addr.isLoopback) return addr.address;
        }
      }
    } catch (e, s) {
      Log.e(
        'getLocalIp failed',
        source: LogSource.network,
        component: 'NetworkInfoService',
        error: e,
        stackTrace: s,
      );
    }
    return null;
  }
}
