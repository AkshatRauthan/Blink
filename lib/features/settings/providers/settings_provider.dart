import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/settings_repository.dart';

class AppSettings {
  final String displayName;
  final String? avatarPath;
  final bool bleEnabled;
  final bool compressionEnabled;
  final bool darkMode;
  final bool onboarded;
  final bool permissionsGranted;

  const AppSettings({
    this.displayName = '',
    this.avatarPath,
    this.bleEnabled = true,
    this.compressionEnabled = true,
    this.darkMode = true,
    this.onboarded = false,
    this.permissionsGranted = false,
  });

  AppSettings copyWith({
    String? displayName,
    String? avatarPath,
    bool clearAvatar = false,
    bool? bleEnabled,
    bool? compressionEnabled,
    bool? darkMode,
    bool? onboarded,
    bool? permissionsGranted,
  }) =>
      AppSettings(
        displayName: displayName ?? this.displayName,
        avatarPath: clearAvatar ? null : (avatarPath ?? this.avatarPath),
        bleEnabled: bleEnabled ?? this.bleEnabled,
        compressionEnabled: compressionEnabled ?? this.compressionEnabled,
        darkMode: darkMode ?? this.darkMode,
        onboarded: onboarded ?? this.onboarded,
        permissionsGranted: permissionsGranted ?? this.permissionsGranted,
      );
}

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  static const _kDisplayName = 'display_name';
  static const _kAvatarPath = 'avatar_path';
  static const _kBleEnabled = 'ble_enabled';
  static const _kCompressionEnabled = 'compression_enabled';
  static const _kDarkMode = 'dark_mode';
  static const _kOnboarded = 'onboarded';
  static const _kPermissionsGranted = 'permissions_granted';

  SettingsRepository get _repo => SettingsRepository.instance;

  @override
  Future<AppSettings> build() async {
    final all = await _repo.getAll();
    return AppSettings(
      displayName: all[_kDisplayName] ?? '',
      avatarPath: all[_kAvatarPath],
      bleEnabled: (all[_kBleEnabled] ?? '1') == '1',
      compressionEnabled: (all[_kCompressionEnabled] ?? '1') == '1',
      darkMode: (all[_kDarkMode] ?? '1') == '1',
      onboarded: (all[_kOnboarded] ?? '0') == '1',
      permissionsGranted: (all[_kPermissionsGranted] ?? '0') == '1',
    );
  }

  Future<void> setDisplayName(String name) async {
    await _repo.setString(_kDisplayName, name);
    final current = state.value ?? const AppSettings();
    state = AsyncData(current.copyWith(displayName: name));
  }

  Future<void> setAvatarPath(String? path) async {
    if (path != null) {
      await _repo.setString(_kAvatarPath, path);
    }
    final current = state.value ?? const AppSettings();
    state = AsyncData(current.copyWith(avatarPath: path));
  }

  Future<void> setBleEnabled(bool v) async {
    await _repo.setBool(_kBleEnabled, v);
    final current = state.value ?? const AppSettings();
    state = AsyncData(current.copyWith(bleEnabled: v));
  }

  Future<void> setCompressionEnabled(bool v) async {
    await _repo.setBool(_kCompressionEnabled, v);
    final current = state.value ?? const AppSettings();
    state = AsyncData(current.copyWith(compressionEnabled: v));
  }

  Future<void> setDarkMode(bool v) async {
    await _repo.setBool(_kDarkMode, v);
    final current = state.value ?? const AppSettings();
    state = AsyncData(current.copyWith(darkMode: v));
  }

  Future<void> completeOnboarding({
    required String displayName,
    String? avatarPath,
  }) async {
    await _repo.setString(_kDisplayName, displayName);
    if (avatarPath != null) {
      await _repo.setString(_kAvatarPath, avatarPath);
    }
    await _repo.setBool(_kOnboarded, true);
    state = AsyncData(AppSettings(
      displayName: displayName,
      avatarPath: avatarPath,
      bleEnabled: state.value?.bleEnabled ?? true,
      compressionEnabled: state.value?.compressionEnabled ?? true,
      darkMode: state.value?.darkMode ?? true,
      onboarded: true,
      permissionsGranted: state.value?.permissionsGranted ?? false,
    ));
  }

  Future<void> setPermissionsGranted(bool value) async {
    await _repo.setBool(_kPermissionsGranted, value);
    final current = state.value ?? const AppSettings();
    state = AsyncData(current.copyWith(permissionsGranted: value));
  }
}

final settingsNotifierProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
