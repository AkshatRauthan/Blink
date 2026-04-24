import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watcher/watcher.dart';

import '../../../core/utils/logger.dart';

class LiveFolderState {
  final List<String> syncedFolders;
  const LiveFolderState({this.syncedFolders = const []});
  LiveFolderState copyWith({List<String>? syncedFolders}) =>
      LiveFolderState(syncedFolders: syncedFolders ?? this.syncedFolders);
}

class LiveFolderNotifier extends Notifier<LiveFolderState> {
  final _watchers = <String, DirectoryWatcher>{};
  final _subs = <String, StreamSubscription<WatchEvent>>{};

  @override
  LiveFolderState build() {
    // Clean up watchers when the provider is disposed.
    ref.onDispose(() {
      for (final sub in _subs.values) {
        sub.cancel();
      }
      _subs.clear();
      _watchers.clear();
    });
    return const LiveFolderState();
  }

  Future<void> addFolder(String path) async {
    if (_watchers.containsKey(path)) return;
    final watcher = DirectoryWatcher(path);
    final sub = watcher.events.listen((event) {
      Log.d(
        'Change: ${event.type} ${event.path}',
        source: LogSource.ui,
        component: 'LiveFolderNotifier',
      );
      // TODO: Queue changed files for transfer to paired device
    });
    _watchers[path] = watcher;
    _subs[path] = sub;
    state = state.copyWith(syncedFolders: [...state.syncedFolders, path]);
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
    state = state.copyWith(
        syncedFolders: state.syncedFolders.where((f) => f != path).toList());
  }
}

final liveFolderNotifierProvider =
    NotifierProvider<LiveFolderNotifier, LiveFolderState>(
  LiveFolderNotifier.new,
);
