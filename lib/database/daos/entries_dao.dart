import 'package:encrypt/encrypt.dart' as enc;
import 'package:sqflite/sqflite.dart';
import '../../models/journal_entry.dart';
import '../database_helper.dart';

/// Data access object for journal entries.
///
/// When an AES key has been set via [setKey], all text fields are transparently
/// encrypted before writing to SQLite and decrypted after reading. Numeric
/// fields (timestamp, hue_shift, mood_value) are stored as native types so
/// SQLite can use them for efficient ordering without decryption.
///
/// If no key is set (fallback), entries are stored/read as plain text for
/// backward compatibility during the key-initialization window at app startup.
class EntriesDao {
  final DatabaseHelper _helper;
  enc.Key? _key;

  EntriesDao(this._helper);

  /// Sets the encryption key to use for all subsequent reads and writes.
  void setKey(enc.Key key) => _key = key;

  Future<List<JournalEntry>> getAll() async {
    final db = await _helper.database;
    final rows = await db.query(
      'journal_entries',
      orderBy: 'timestamp DESC',
    );

    final key = _key;
    if (key == null) {
      // No key yet — read as plaintext (startup / migration window)
      return rows.map(JournalEntry.fromMap).toList();
    }
    return rows
        .map((r) => JournalEntry.fromEncryptedLocalMap(r, key))
        .toList();
  }

  Future<void> insert(JournalEntry entry) async {
    final db = await _helper.database;
    final key = _key;
    final map = key != null
        ? entry.toEncryptedLocalMap(key)
        : entry.toMap();

    await db.insert(
      'journal_entries',
      map,
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
