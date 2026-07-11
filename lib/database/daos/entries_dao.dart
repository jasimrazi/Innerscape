import 'package:sqflite/sqflite.dart';
import '../../models/journal_entry.dart';
import '../database_helper.dart';

class EntriesDao {
  final DatabaseHelper _helper;
  EntriesDao(this._helper);

  Future<List<JournalEntry>> getAll() async {
    final db = await _helper.database;
    final rows = await db.query(
      'journal_entries',
      orderBy: 'timestamp DESC',
    );
    return rows.map(JournalEntry.fromMap).toList();
  }

  Future<void> insert(JournalEntry entry) async {
    final db = await _helper.database;
    await db.insert(
      'journal_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(String id) async {
    final db = await _helper.database;
    await db.delete('journal_entries', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAll() async {
    final db = await _helper.database;
    await db.delete('journal_entries');
  }
}
