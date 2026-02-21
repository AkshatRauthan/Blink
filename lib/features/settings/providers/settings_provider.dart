import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSettings {
  final String displayName;
  final bool bleEnabled;
  final bool compressionEnabled;
  final bool darkMode;

  const AppSettings({
    this.displayName = '',
    this.bleEnabled = true,
    this.compressionEnabled = true,
    this.darkMode = false,
  });

  AppSettings copyWith({
    String? displayName,
    bool? bleEnabled,
    bool? compressionEnabled,
    bool? darkMode,
  }) =>
      AppSettings(
        displayName: displayName ?? this.displayName,
        bleEnabled: bleEnabled ?? this.bleEnabled,
        compressionEnabled: compressionEnabled ?? this.compressionEnabled,
        darkMode: darkMode ?? this.darkMode,
      );
}

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => const AppSettings();

  void setDisplayName(String name) =>
      state = state.copyWith(displayName: name);

  void setBleEnabled(bool v) => state = state.copyWith(bleEnabled: v);

  void setCompressionEnabled(bool v) =>
      state = state.copyWith(compressionEnabled: v);

  void setDarkMode(bool v) => state = state.copyWith(darkMode: v);
}

final settingsNotifierProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
