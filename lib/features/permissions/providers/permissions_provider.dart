import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

enum BlinkPermission {
  storage,
  nearbyDevices,
  camera,
  notifications,
}

class PermissionItem {
  final BlinkPermission id;
  final String title;
  final String description;
  final IconData icon;

  const PermissionItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}

List<PermissionItem> permissionItemsForPlatform() {
  const all = <PermissionItem>[
    PermissionItem(
      id: BlinkPermission.storage,
      title: 'File access',
      description: 'Select files to send and save received files',
      icon: Icons.folder_rounded,
    ),
    PermissionItem(
      id: BlinkPermission.nearbyDevices,
      title: 'Nearby devices',
      description: 'Discover devices on the local network',
      icon: Icons.radar_rounded,
    ),
    PermissionItem(
      id: BlinkPermission.camera,
      title: 'Camera',
      description: 'Scan QR codes for pairing',
      icon: Icons.qr_code_scanner_rounded,
    ),
    PermissionItem(
      id: BlinkPermission.notifications,
      title: 'Notifications',
      description: 'Get transfer alerts and status updates',
      icon: Icons.notifications_rounded,
    ),
  ];

  if (Platform.isAndroid) return all;
  if (Platform.isLinux) {
    return all.where((i) => i.id == BlinkPermission.storage).toList();
  }
  if (Platform.isWindows) {
    return all
        .where((i) =>
            i.id == BlinkPermission.storage ||
            i.id == BlinkPermission.nearbyDevices)
        .toList();
  }

  return all
      .where((i) => i.id != BlinkPermission.notifications)
      .toList();
}

class PermissionsState {
  final Map<BlinkPermission, bool> selected;
  final Map<BlinkPermission, bool> granted;
  final bool isRequesting;
  final String? error;

  const PermissionsState({
    required this.selected,
    required this.granted,
    this.isRequesting = false,
    this.error,
  });

  PermissionsState copyWith({
    Map<BlinkPermission, bool>? selected,
    Map<BlinkPermission, bool>? granted,
    bool? isRequesting,
    String? error,
  }) {
    return PermissionsState(
      selected: selected ?? this.selected,
      granted: granted ?? this.granted,
      isRequesting: isRequesting ?? this.isRequesting,
      error: error,
    );
  }

  bool isSelected(BlinkPermission id) => selected[id] ?? false;
  bool isGranted(BlinkPermission id) => granted[id] ?? false;

  bool get allGranted {
    final selectedEntries = selected.entries.where((e) => e.value);
    if (selectedEntries.isEmpty) return true;
    return selectedEntries.every((e) => granted[e.key] == true);
  }
}

class PermissionsNotifier extends Notifier<PermissionsState> {
  @override
  PermissionsState build() {
    final items = permissionItemsForPlatform();
    final selected = {
      for (final item in items) item.id: true,
    };
    final granted = {
      for (final item in items) item.id: false,
    };

    if (Platform.isAndroid) {
      Future.microtask(refreshStatuses);
    }

    return PermissionsState(selected: selected, granted: granted);
  }

  void setSelected(BlinkPermission id, bool value) {
    final nextSelected = Map<BlinkPermission, bool>.from(state.selected);
    nextSelected[id] = value;

    final nextGranted = Map<BlinkPermission, bool>.from(state.granted);
    if (!value) {
      nextGranted[id] = false;
    }

    state = state.copyWith(selected: nextSelected, granted: nextGranted);
  }

  Future<void> refreshStatuses() async {
    if (!Platform.isAndroid) return;

    final nextGranted = Map<BlinkPermission, bool>.from(state.granted);
    for (final item in permissionItemsForPlatform()) {
      nextGranted[item.id] = await _isGranted(item.id);
    }

    state = state.copyWith(granted: nextGranted, error: null);
  }

  Future<void> requestSelected() async {
    if (state.isRequesting) return;
    state = state.copyWith(isRequesting: true, error: null);

    try {
      if (Platform.isAndroid) {
        final toRequest = <Permission>{};
        if (state.isSelected(BlinkPermission.camera)) {
          toRequest.add(Permission.camera);
        }
        if (state.isSelected(BlinkPermission.notifications)) {
          toRequest.add(Permission.notification);
        }
        if (state.isSelected(BlinkPermission.storage)) {
          toRequest.add(Permission.storage);
          toRequest.add(Permission.photos);
          toRequest.add(Permission.videos);
          toRequest.add(Permission.audio);
        }
        if (state.isSelected(BlinkPermission.nearbyDevices)) {
          toRequest.add(Permission.bluetoothScan);
          toRequest.add(Permission.bluetoothConnect);
          toRequest.add(Permission.bluetoothAdvertise);
          toRequest.add(Permission.nearbyWifiDevices);
        }

        if (toRequest.isNotEmpty) {
          await toRequest.toList().request();
        }
        await refreshStatuses();
      } else {
        final nextGranted = Map<BlinkPermission, bool>.from(state.granted);
        for (final entry in state.selected.entries) {
          if (entry.value) nextGranted[entry.key] = true;
        }
        state = state.copyWith(granted: nextGranted);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to request permissions');
    } finally {
      state = state.copyWith(isRequesting: false);
    }
  }

  Future<bool> _isGranted(BlinkPermission id) async {
    switch (id) {
      case BlinkPermission.camera:
        return (await Permission.camera.status).isGranted;
      case BlinkPermission.notifications:
        return (await Permission.notification.status).isGranted;
      case BlinkPermission.nearbyDevices:
        final scan = await Permission.bluetoothScan.status;
        final connect = await Permission.bluetoothConnect.status;
        final advertise = await Permission.bluetoothAdvertise.status;
        final wifi = await Permission.nearbyWifiDevices.status;
        return scan.isGranted && connect.isGranted && advertise.isGranted && wifi.isGranted;
      case BlinkPermission.storage:
        final storage = await Permission.storage.status;
        if (storage.isGranted) return true;
        final photos = await Permission.photos.status;
        final videos = await Permission.videos.status;
        final audio = await Permission.audio.status;
        return photos.isGranted && videos.isGranted && audio.isGranted;
    }
  }
}

final permissionsNotifierProvider =
    NotifierProvider<PermissionsNotifier, PermissionsState>(
  PermissionsNotifier.new,
);
