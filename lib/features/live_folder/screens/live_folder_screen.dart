import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/live_folder_provider.dart';

class LiveFolderScreen extends ConsumerWidget {
  const LiveFolderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(liveFolderNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Live Folders')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {/* TODO: Pick folder to sync */},
        icon: const Icon(Icons.add),
        label: const Text('Add Folder'),
      ),
      body: state.syncedFolders.isEmpty
          ? const Center(
              child: Text('No live folders yet.\nTap + to add one.'),
            )
          : ListView.builder(
              itemCount: state.syncedFolders.length,
              itemBuilder: (_, i) {
                final folder = state.syncedFolders[i];
                return ListTile(
                  leading: const Icon(Icons.folder_outlined),
                  title: Text(folder),
                  subtitle: const Text('Syncing…'),
                  trailing: IconButton(
                    icon: const Icon(Icons.stop),
                    onPressed: () => ref
                        .read(liveFolderNotifierProvider.notifier)
                        .removeFolder(folder),
                  ),
                );
              },
            ),
    );
  }
}
