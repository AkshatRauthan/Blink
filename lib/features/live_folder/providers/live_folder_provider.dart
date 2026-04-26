import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watcher/watcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import '../../../services/transfer/transfer_manager.dart';

class WatchedFolder {
  final String path;
  final bool isPaused;
  final int pendingChanges;

  const WatchedFolder({
    required this.path,
    this.isPaused = false,
    this.pendingChanges = 0,
  });

  WatchedFolder copyWith({bool? isPaused, int? pendingChanges}) => WatchedFolder(
        path: path,
        isPaused: isPaused ?? this.isPaused,
        pendingChanges: pendingChanges ?? this.pendingChanges,
      );
}

class LiveFolderState {
  final List<WatchedFolder> folders;
  final String? pairedDeviceId;
  final String? pairedDeviceIp;
  final int? pairedDevicePort;

  const LiveFolderState({
    this.folders = const [],
    this.pairedDeviceId,
    this.pairedDeviceIp,
    this.pairedDevicePort,
  });

  LiveFolderState copyWith({
    List<WatchedFolder>? folders,
    String? pairedDeviceId,
    String? pairedDeviceIp,
    int? pairedDevicePort,
  }) =>
      LiveFolderState(
        folders: folders ?? this.folders,
        pairedDeviceId: pairedDeviceId ?? this.pairedDeviceId,
        pairedDeviceIp: pairedDeviceIp ?? this.pairedDeviceIp,
        pairedDevicePort: pairedDevicePort ?? this.pairedDevicePort,
      );
}

class LiveFolderNotifier extends Notifier<LiveFolderState> {
  final _watchers = <String, DirectoryWatcher>{};
  final _subs = <String, StreamSubscription<WatchEvent>>{};
  final _pendingQueue = <String, Set<String>>{};
  Timer? _debounceTimer;

  @override
  LiveFolderState build() {
    ref.onDispose(() {
      for (final sub in _subs.values) {
        sub.cancel();
      }
      _subs.clear();
      _watchers.clear();
      _debounceTimer?.cancel();
    });
    return const LiveFolderState();
  }

  void setPairedDevice({
    required String deviceId,
    required String ip,
    required int port,
  }) {
    state = state.copyWith(
      pairedDeviceId: deviceId,
      pairedDeviceIp: ip,
      pairedDevicePort: port,
    );
  }

  Future<void> addFolder(String path) async {
    if (path.isEmpty) return;
    if (_watchers.containsKey(path)) return;

    final watcher = DirectoryWatcher(path);
    _pendingQueue[path] = {};

    final sub = watcher.events.listen((event) {
      if (event.type == ChangeType.REMOVE) return;
      final folder = state.folders.firstWhere(
        (f) => f.path == path,
        orElse: () => WatchedFolder(path: path),
      );
      if (folder.isPaused) return;

      _pendingQueue[path]?.add(event.path);
      _updatePendingCount(path);
      _scheduleDrainQueue(path);

      Log.d(
        'Change: ${event.type} ${event.path}',
        source: LogSource.ui,
        component: 'LiveFolderNotifier',
      );
    });

    _watchers[path] = watcher;
    _subs[path] = sub;
    state = state.copyWith(
      folders: [...state.folders, WatchedFolder(path: path)],
    );

    Log.i(
      'Watching: $path',
      source: LogSource.ui,
      component: 'LiveFolderNotifier',
    );
  }

  Future<void> removeFolder(String path) async {
    await _subs[path]?.cancel();
    _subs.remove(path);
    _watchers.remove(path);
    _pendingQueue.remove(path);
    state = state.copyWith(
      folders: state.folders.where((f) => f.path != path).toList(),
    );
  }

  void togglePause(String path) {
    state = state.copyWith(
      folders: state.folders.map((f) {
        if (f.path == path) return f.copyWith(isPaused: !f.isPaused);
        return f;
      }).toList(),
    );
  }

  void _updatePendingCount(String folderPath) {
    final count = _pendingQueue[folderPath]?.length ?? 0;
    state = state.copyWith(
      folders: state.folders.map((f) {
        if (f.path == folderPath) return f.copyWith(pendingChanges: count);
        return f;
      }).toList(),
    );
  }

  void _scheduleDrainQueue(String folderPath) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), () {
      _drainQueue(folderPath);
    });
  }

  Future<void> _drainQueue(String folderPath) async {
    final pending = _pendingQueue[folderPath];
    if (pending == null || pending.isEmpty) return;
    if (state.pairedDeviceId == null || state.pairedDeviceIp == null) {
      Log.w(
        'No paired device — skipping sync for $folderPath',
        source: LogSource.process,
        component: 'LiveFolderNotifier',
      );
      return;
    }

    final filePaths = pending.where((p) {
      try {
        return File(p).existsSync();
      } catch (_) {
        return false;
      }
    }).toList();

    pending.clear();
    _updatePendingCount(folderPath);

    if (filePaths.isEmpty) return;

    final files = filePaths.map((p) => File(p)).toList();
    final sessionKey = Uint8List.fromList(
      List.generate(32, (_) => Random.secure().nextInt(256)),
    );

    try {
      await TransferManager.instance.sendFiles(
        files: files,
        remoteDeviceId: state.pairedDeviceId!,
        remoteIp: state.pairedDeviceIp!,
        remotePort: state.pairedDevicePort ?? AppConstants.transferPort,
        sessionKey: sessionKey,
      );

      Log.i(
        'Live sync: ${files.length} files queued to ${state.pairedDeviceId}',
        source: LogSource.process,
        component: 'LiveFolderNotifier',
      );
    } catch (e) {
      Log.e(
        'Live sync failed: $e',
        source: LogSource.process,
        component: 'LiveFolderNotifier',
      );
    }
  }
}

final liveFolderNotifierProvider =
    NotifierProvider<LiveFolderNotifier, LiveFolderState>(
  LiveFolderNotifier.new,
);
