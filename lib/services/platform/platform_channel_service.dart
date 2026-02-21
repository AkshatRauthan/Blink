import 'package:flutter/services.dart';

import '../../core/utils/logger.dart';

/// Centralises all MethodChannel calls to native platform code.
class PlatformChannelService {
  PlatformChannelService._();
  static final instance = PlatformChannelService._();

  static const _channel = MethodChannel('com.example.blink/platform');

  Future<T?> invoke<T>(String method, [dynamic arguments]) async {
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } on PlatformException catch (e, s) {
      Log.e('[Platform] invokeMethod($method) failed', error: e, stackTrace: s);
      return null;
    }
  }

  Future<void> startForeground(String title, String text) =>
      invoke('startForeground', {'title': title, 'text': text});

  Future<void> stopForeground() => invoke('stopForeground');

  Future<Map<String, String>?> enableHotspot() async {
    final result = await invoke<Map>('enableHotspot');
    return result?.cast<String, String>();
  }

  Future<void> disableHotspot() => invoke('disableHotspot');
}
