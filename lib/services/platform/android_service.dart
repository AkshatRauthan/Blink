import '../../core/utils/logger.dart';
import '../../core/utils/platform_utils.dart';
import 'platform_channel_service.dart';

class AndroidService {
  AndroidService._();
  static final instance = AndroidService._();

  final _channel = PlatformChannelService.instance;

  Future<void> startForegroundService({required String notificationText}) async {
    if (!PlatformUtils.isAndroid) return;
    await _channel.startForeground('Blink Transfer', notificationText);
    Log.i(
      'Foreground service started: $notificationText',
      source: LogSource.system,
      component: 'AndroidService',
    );
  }

  Future<void> stopForegroundService() async {
    if (!PlatformUtils.isAndroid) return;
    await _channel.stopForeground();
    Log.i(
      'Foreground service stopped',
      source: LogSource.system,
      component: 'AndroidService',
    );
  }

  Future<String?> enableHotspot() async {
    if (!PlatformUtils.isAndroid) return null;
    final result = await _channel.enableHotspot();
    if (result != null) {
      Log.i(
        'Hotspot enabled: SSID=${result['ssid']}',
        source: LogSource.system,
        component: 'AndroidService',
      );
      return result['ssid'];
    }
    return null;
  }

  Future<void> disableHotspot() async {
    if (!PlatformUtils.isAndroid) return;
    await _channel.disableHotspot();
  }
}
