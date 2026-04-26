import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../core/utils/file_utils.dart';

class SelectedFile {
  final String path;
  final String name;
  final int sizeBytes;
  final String mimeType;
  final bool isMedia;

  SelectedFile({
    required this.path,
    required this.name,
    required this.sizeBytes,
    required this.mimeType,
    required this.isMedia,
  });

  factory SelectedFile.fromPath(String path) {
    final file = File(path);
    return SelectedFile(
      path: path,
      name: p.basename(path),
      sizeBytes: FileUtils.sizeOf(file),
      mimeType: FileUtils.mimeType(path),
      isMedia: FileUtils.isMedia(path),
    );
  }
}

class FileSelectionState {
  final List<SelectedFile> files;

  const FileSelectionState({this.files = const []});

  int get totalBytes => files.fold(0, (sum, f) => sum + f.sizeBytes);
  bool get isEmpty => files.isEmpty;
  bool get isNotEmpty => files.isNotEmpty;

  FileSelectionState copyWith({List<SelectedFile>? files}) =>
      FileSelectionState(files: files ?? this.files);
}

class FileSelectionNotifier extends Notifier<FileSelectionState> {
  @override
  FileSelectionState build() => const FileSelectionState();

  void addFiles(List<String> paths) {
    final existing = state.files.map((f) => f.path).toSet();
    final newFiles = paths
        .where((p) => !existing.contains(p))
        .map((p) => SelectedFile.fromPath(p))
        .toList();
    if (newFiles.isEmpty) return;
    state = state.copyWith(files: [...state.files, ...newFiles]);
  }

  void removeFile(String path) {
    state = state.copyWith(
      files: state.files.where((f) => f.path != path).toList(),
    );
  }

  void clear() {
    state = const FileSelectionState();
  }
}

final fileSelectionProvider =
    NotifierProvider<FileSelectionNotifier, FileSelectionState>(
  FileSelectionNotifier.new,
);
