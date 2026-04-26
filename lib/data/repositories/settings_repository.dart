import 'package:sqflite/sqflite.dart';

import '../local/isar_service.dart';

class SettingsRepository {
  SettingsRepository._();
  static final instance = SettingsRepository._();

  Future<Database> get _db => IsarService.instance.db;

  static const _table = 'app_settings';

  Future<String?> getString(String key) async {
    final db = await _db;
    final rows = await db.query(
      _table,
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String;
  }

  Future<void> setString(String key, String value) async {
    final db = await _db;
    await db.insert(
      _table,
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final v = await getString(key);
    if (v == null) return defaultValue;
    return v == '1';
  }

  Future<void> setBool(String key, bool value) async {
    await setString(key, value ? '1' : '0');
  }

  Future<Map<String, String>> getAll() async {
    final db = await _db;
    final rows = await db.query(_table);
    return {for (final r in rows) r['key'] as String: r['value'] as String};
  }
}
