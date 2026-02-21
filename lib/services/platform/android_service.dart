import '../../core/utils/logger.dart';
import '../../core/utils/platform_utils.dart';

/// Android-specific features: foreground service and Wi-Fi hotspot.
///
/// All methods are no-ops on non-Android platforms.
class AndroidService {
  AndroidService._();
  static final instance = AndroidService._();

  /// Starts a foreground service notification to keep Blink alive in background.
  Future<void> startForegroundService({required String notificationText}) async {
    if (!PlatformUtils.isAndroid) return;
    // TODO: Invoke platform channel method 'startForeground' on MainActivity
    Log.i('[Android] Foreground service started: $notificationText');
  }

  Future<void> stopForegroundService() async {
    if (!PlatformUtils.isAndroid) return;
    // TODO: Invoke platform channel method 'stopForeground'
    Log.i('[Android] Foreground service stopped');
  }

  /// Enables a Wi-Fi hotspot for the fallback transport.
  Future<String?> enableHotspot() async {
    if (!PlatformUtils.isAndroid) return null;
    // TODO: Invoke platform channel 'enableHotspot', return SSID/password
    Log.i('[Android] Hotspot enabled');
    return null;
  }

  Future<void> disableHotspot() async {
    if (!PlatformUtils.isAndroid) return;
    // TODO: Invoke platform channel 'disableHotspot'
  }
}
