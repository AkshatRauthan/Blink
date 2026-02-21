import 'dart:io';

/// Runtime platform detection helpers.
abstract class PlatformUtils {
  static bool get isAndroid => Platform.isAndroid;
  static bool get isLinux => Platform.isLinux;
  static bool get isWindows => Platform.isWindows;
  static bool get isMacOS => Platform.isMacOS;

  static bool get isDesktop =>
      Platform.isLinux || Platform.isWindows || Platform.isMacOS;

  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  /// Returns true if BLE advertising/scanning is supported on this platform.
  /// Full BLE support on Android only; desktop has partial/unreliable support.
  static bool get bleSupported => Platform.isAndroid;

  /// Returns true if Wi-Fi hotspot creation is supported.
  /// Android only via platform channels.
  static bool get hotspotSupported => Platform.isAndroid;

  /// Platform label for display (e.g., "Android", "Linux").
  static String get platformName {
    if (Platform.isAndroid) return 'Android';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    return 'Unknown';
  }
}
