import 'package:sqflite/sqflite.dart';

import '../models/device.dart';
import '../local/isar_service.dart';

/// Persistence and query operations for [Device] records.
class DeviceRepository {
  DeviceRepository._();
  static final instance = DeviceRepository._();

  Future<Database> get _db => IsarService.instance.db;

  static const _table = 'devices';

  Map<String, dynamic> _toRow(Device d) => {
    'device_id': d.deviceId,
    'name': d.name,
    'public_key': d.publicKeyBase64,
    'platform': d.platform.name,
    'last_known_ip': d.lastKnownIp,
    'last_known_port': d.lastKnownPort,
    'is_favourite': d.isFavourite ? 1 : 0,
    'last_seen_at': d.lastSeenAt?.toIso8601String(),
  };

  Device _fromRow(Map<String, dynamic> row) => Device(
    id: row['id'] as int?,
    deviceId: row['device_id'] as String,
    name: row['name'] as String,
    publicKeyBase64: row['public_key'] as String? ?? '',
    platform: DevicePlatform.values.firstWhere(
      (e) => e.name == row['platform'],
      orElse: () => DevicePlatform.unknown,
    ),
    lastKnownIp: row['last_known_ip'] as String?,
    lastKnownPort: row['last_known_port'] as int?,
    isFavourite: (row['is_favourite'] as int? ?? 0) == 1,
    lastSeenAt: row['last_seen_at'] != null
        ? DateTime.tryParse(row['last_seen_at'] as String)
        : null,
  );

  /// Upsert a device by [deviceId].
  Future<void> save(Device device) async {
    final db = await _db;
    await db.insert(
      _table,
      _toRow(device),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// All stored devices, most recently seen first.
  Future<List<Device>> getAll() async {
    final db = await _db;
    final rows = await db.query(
      _table,
      orderBy: 'last_seen_at DESC',
    );
    return rows.map(_fromRow).toList();
  }

  /// Find a device by its UUID [deviceId]. Returns null if not found.
  Future<Device?> findById(String deviceId) async {
    final db = await _db;
    final rows = await db.query(
      _table,
      where: 'device_id = ?',
      whereArgs: [deviceId],
      limit: 1,
    );
    return rows.isEmpty ? null : _fromRow(rows.first);
  }

  Future<void> delete(String deviceId) async {
    final db = await _db;
    await db.delete(_table, where: 'device_id = ?', whereArgs: [deviceId]);
  }
}
