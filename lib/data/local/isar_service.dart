import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../core/utils/logger.dart';

/// Singleton that manages the SQLite database lifecycle via sqflite.
///
/// - Android: uses the native sqflite plugin directly
/// - Linux / Windows: uses sqflite_common_ffi (sqlite3 shared library)
///
/// Call [init] once from [main] before the widget tree mounts.
/// The class is still named IsarService for minimal code disruption;
/// internals are SQLite — swappable to Drift/Isar later via the repository layer.
class IsarService {
  IsarService._();
  static final instance = IsarService._();

  Database? _db;
  bool _initialised = false;

  Future<void> init() async {
    if (_initialised) return;
    _db = await _open();
    _initialised = true;
  }

  Future<Database> get db async {
    if (!_initialised) await init();
    return _db!;
  }

  Future<Database> _open() async {
    if (!kIsWeb && (Platform.isLinux || Platform.isWindows)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'blink.db');

    final database = await openDatabase(
      dbPath,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    Log.i(
      'SQLite opened at $dbPath',
      source: LogSource.storage,
      component: 'SQLite',
    );
    return database;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE devices (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        device_id       TEXT    NOT NULL UNIQUE,
        name            TEXT    NOT NULL,
        public_key      TEXT    NOT NULL DEFAULT '',
        platform        TEXT    NOT NULL DEFAULT 'unknown',
        last_known_ip   TEXT,
        last_known_port INTEGER,
        is_favourite    INTEGER NOT NULL DEFAULT 0,
        last_seen_at    TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE transfer_sessions (
        id                  INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id          TEXT    NOT NULL UNIQUE,
        remote_device_id    TEXT    NOT NULL,
        direction           TEXT    NOT NULL,
        status              TEXT    NOT NULL DEFAULT 'pending',
        total_bytes         INTEGER NOT NULL DEFAULT 0,
        transferred_bytes   INTEGER NOT NULL DEFAULT 0,
        started_at          TEXT,
        completed_at        TEXT,
        failure_reason      TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE transfer_files (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        file_id           TEXT    NOT NULL UNIQUE,
        session_id        TEXT    NOT NULL,
        file_name         TEXT    NOT NULL,
        mime_type         TEXT    NOT NULL DEFAULT '',
        size_bytes        INTEGER NOT NULL DEFAULT 0,
        transferred_bytes INTEGER NOT NULL DEFAULT 0,
        completed         INTEGER NOT NULL DEFAULT 0,
        local_path        TEXT,
        blake3_checksum   TEXT,
        failure_reason    TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE chat_messages (
        id               INTEGER PRIMARY KEY AUTOINCREMENT,
        message_id       TEXT    NOT NULL UNIQUE,
        session_id       TEXT    NOT NULL,
        sender_device_id TEXT    NOT NULL,
        text             TEXT    NOT NULL,
        sent_at          TEXT    NOT NULL,
        is_read          INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE contact_groups (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        group_id   TEXT    NOT NULL UNIQUE,
        name       TEXT    NOT NULL,
        member_ids TEXT    NOT NULL DEFAULT '[]',
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE app_settings (
        key   TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    Log.i(
      'Schema created v$version',
      source: LogSource.storage,
      component: 'SQLite',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS app_settings (
          key   TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');
    }
    Log.i(
      'Schema upgraded $oldVersion -> $newVersion',
      source: LogSource.storage,
      component: 'SQLite',
    );
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
    _initialised = false;
  }
}
