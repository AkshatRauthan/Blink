import 'package:sqflite/sqflite.dart';

import '../models/transfer_session.dart';
import '../models/transfer_file.dart';
import '../local/isar_service.dart';

/// Persistence operations for transfer sessions and their files.
class TransferRepository {
  TransferRepository._();
  static final instance = TransferRepository._();

  Future<Database> get _db => IsarService.instance.db;

  static const _sessionsTable = 'transfer_sessions';
  static const _filesTable = 'transfer_files';

  // ── TransferSession helpers ─────────────────────────────────────────────

  Map<String, dynamic> _sessionToRow(TransferSession s) => {
    'session_id': s.sessionId,
    'remote_device_id': s.remoteDeviceId,
    'direction': s.direction.name,
    'status': s.status.name,
    'total_bytes': s.totalBytes,
    'transferred_bytes': s.transferredBytes,
    'started_at': s.startedAt?.toIso8601String(),
    'completed_at': s.completedAt?.toIso8601String(),
    'failure_reason': s.failureReason,
  };

  TransferSession _sessionFromRow(Map<String, dynamic> row) => TransferSession(
    id: row['id'] as int?,
    sessionId: row['session_id'] as String,
    remoteDeviceId: row['remote_device_id'] as String,
    direction: TransferDirection.values.firstWhere(
      (e) => e.name == row['direction'],
      orElse: () => TransferDirection.send,
    ),
    status: TransferStatus.values.firstWhere(
      (e) => e.name == row['status'],
      orElse: () => TransferStatus.pending,
    ),
    totalBytes: row['total_bytes'] as int? ?? 0,
    transferredBytes: row['transferred_bytes'] as int? ?? 0,
    startedAt: row['started_at'] != null
        ? DateTime.tryParse(row['started_at'] as String)
        : null,
    completedAt: row['completed_at'] != null
        ? DateTime.tryParse(row['completed_at'] as String)
        : null,
    failureReason: row['failure_reason'] as String?,
  );

  Future<void> saveSession(TransferSession session) async {
    final db = await _db;
    await db.insert(
      _sessionsTable,
      _sessionToRow(session),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<TransferSession?> findSession(String sessionId) async {
    final db = await _db;
    final rows = await db.query(
      _sessionsTable,
      where: 'session_id = ?',
      whereArgs: [sessionId],
      limit: 1,
    );
    return rows.isEmpty ? null : _sessionFromRow(rows.first);
  }

  Future<List<TransferSession>> getRecentSessions({int limit = 50}) async {
    final db = await _db;
    final rows = await db.query(
      _sessionsTable,
      orderBy: 'started_at DESC',
      limit: limit,
    );
    return rows.map(_sessionFromRow).toList();
  }

  // ── TransferFile helpers ────────────────────────────────────────────────

  Map<String, dynamic> _fileToRow(TransferFile f) => {
    'file_id': f.fileId,
    'session_id': f.sessionId,
    'file_name': f.fileName,
    'mime_type': f.mimeType,
    'size_bytes': f.sizeBytes,
    'transferred_bytes': f.transferredBytes,
    'completed': f.completed ? 1 : 0,
    'local_path': f.localPath,
    'blake3_checksum': f.blake3Checksum,
    'failure_reason': f.failureReason,
  };

  TransferFile _fileFromRow(Map<String, dynamic> row) => TransferFile(
    id: row['id'] as int?,
    fileId: row['file_id'] as String,
    sessionId: row['session_id'] as String,
    fileName: row['file_name'] as String,
    mimeType: row['mime_type'] as String? ?? '',
    sizeBytes: row['size_bytes'] as int? ?? 0,
    transferredBytes: row['transferred_bytes'] as int? ?? 0,
    completed: (row['completed'] as int? ?? 0) == 1,
    localPath: row['local_path'] as String?,
    blake3Checksum: row['blake3_checksum'] as String?,
    failureReason: row['failure_reason'] as String?,
  );

  Future<void> saveFile(TransferFile file) async {
    final db = await _db;
    await db.insert(
      _filesTable,
      _fileToRow(file),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TransferFile>> filesForSession(String sessionId) async {
    final db = await _db;
    final rows = await db.query(
      _filesTable,
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
    return rows.map(_fileFromRow).toList();
  }
}
