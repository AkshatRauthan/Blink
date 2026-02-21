import 'dart:io';
import 'package:path/path.dart' as p;

/// Utility helpers for file system operations.
abstract class FileUtils {
  /// Returns a human-readable file size string (e.g., "4.2 MB").
  static String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Returns the MIME type for a file based on its extension.
  static String mimeType(String filePath) {
    final ext = p.extension(filePath).toLowerCase().replaceFirst('.', '');
    const map = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'webp': 'image/webp',
      'mp4': 'video/mp4',
      'mkv': 'video/x-matroska',
      'pdf': 'application/pdf',
      'zip': 'application/zip',
      'apk': 'application/vnd.android.package-archive',
      'txt': 'text/plain',
    };
    return map[ext] ?? 'application/octet-stream';
  }

  /// Returns true if the file extension is a known media type.
  static bool isMedia(String filePath) {
    final ext = p.extension(filePath).toLowerCase().replaceFirst('.', '');
    return {'jpg', 'jpeg', 'png', 'gif', 'webp', 'mp4', 'mkv', 'mov', 'avi'}
        .contains(ext);
  }

  /// Safely returns file size; returns 0 on error.
  static int sizeOf(File file) {
    try {
      return file.lengthSync();
    } catch (_) {
      return 0;
    }
  }

  /// Lists all files recursively under [directory].
  static Future<List<File>> listRecursive(Directory directory) async {
    final files = <File>[];
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File) files.add(entity);
    }
    return files;
  }
}
