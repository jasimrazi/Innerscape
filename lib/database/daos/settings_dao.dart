import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';

class SettingsDao {
  final DatabaseHelper _helper;
  SettingsDao(this._helper);

  Future<String?> get(String key) async {
    final db = await _helper.database;
    final rows = await db.query(
      'user_settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['value'] as String;
  }

  Future<void> set(String key, String value) async {
    final db = await _helper.database;
    await db.insert(
      'user_settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, String>> getAll() async {
    final db = await _helper.database;
    final rows = await db.query('user_settings');
    return {for (final r in rows) r['key'] as String: r['value'] as String};
  }
}
