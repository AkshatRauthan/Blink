import 'package:sqflite/sqflite.dart';

import '../models/chat_message.dart';
import '../local/isar_service.dart';

/// Persistence operations for in-flight chat messages.
class ChatRepository {
  ChatRepository._();
  static final instance = ChatRepository._();

  Future<Database> get _db => IsarService.instance.db;

  static const _table = 'chat_messages';

  Map<String, dynamic> _toRow(ChatMessage m) => {
    'message_id': m.messageId,
    'session_id': m.sessionId,
    'sender_device_id': m.senderDeviceId,
    'text': m.text,
    'sent_at': m.sentAt.toIso8601String(),
    'is_read': m.isRead ? 1 : 0,
  };

  ChatMessage _fromRow(Map<String, dynamic> row) => ChatMessage(
    id: row['id'] as int?,
    messageId: row['message_id'] as String,
    sessionId: row['session_id'] as String,
    senderDeviceId: row['sender_device_id'] as String,
    text: row['text'] as String,
    sentAt: DateTime.parse(row['sent_at'] as String),
    isRead: (row['is_read'] as int? ?? 0) == 1,
  );

  Future<void> saveMessage(ChatMessage message) async {
    final db = await _db;
    await db.insert(
      _table,
      _toRow(message),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ChatMessage>> messagesForSession(
    String sessionId, {
    int limit = 200,
  }) async {
    final db = await _db;
    final rows = await db.query(
      _table,
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'sent_at ASC',
      limit: limit,
    );
    return rows.map(_fromRow).toList();
  }

  Future<int> unreadCount(String sessionId) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM $_table WHERE session_id = ? AND is_read = 0',
      [sessionId],
    );
    return (result.first['cnt'] as int?) ?? 0;
  }

  Future<void> markAllRead(String sessionId) async {
    final db = await _db;
    await db.update(
      _table,
      {'is_read': 1},
      where: 'session_id = ? AND is_read = 0',
      whereArgs: [sessionId],
    );
  }
}
