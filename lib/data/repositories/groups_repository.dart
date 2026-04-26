import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../models/contact_group.dart';
import '../local/isar_service.dart';

class GroupsRepository {
  GroupsRepository._();
  static final instance = GroupsRepository._();

  Future<Database> get _db => IsarService.instance.db;

  static const _table = 'contact_groups';

  Map<String, dynamic> _toRow(ContactGroup g) => {
        'group_id': g.groupId,
        'name': g.name,
        'member_ids': jsonEncode(g.memberDeviceIds),
        'created_at': g.createdAt?.toIso8601String(),
      };

  ContactGroup _fromRow(Map<String, dynamic> row) => ContactGroup(
        id: row['id'] as int?,
        groupId: row['group_id'] as String,
        name: row['name'] as String,
        memberDeviceIds: (jsonDecode(row['member_ids'] as String) as List)
            .cast<String>(),
        createdAt: row['created_at'] != null
            ? DateTime.tryParse(row['created_at'] as String)
            : null,
      );

  Future<void> saveGroup(ContactGroup group) async {
    final db = await _db;
    await db.insert(
      _table,
      _toRow(group),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateGroup(ContactGroup group) async {
    final db = await _db;
    await db.update(
      _table,
      _toRow(group),
      where: 'group_id = ?',
      whereArgs: [group.groupId],
    );
  }

  Future<void> deleteGroup(String groupId) async {
    final db = await _db;
    await db.delete(_table, where: 'group_id = ?', whereArgs: [groupId]);
  }

  Future<List<ContactGroup>> allGroups() async {
    final db = await _db;
    final rows = await db.query(_table, orderBy: 'created_at DESC');
    return rows.map(_fromRow).toList();
  }
}
