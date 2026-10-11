import 'package:encrypt/encrypt.dart' as enc;
import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../../services/encryption_service.dart';

/// Data access object for user settings.
///
/// Setting values are encrypted at rest when a key is set via [setKey].
/// Keys (e.g., `light_mode`) are stored in plaintext since they are not
/// sensitive — only the values carry personal preference data.
class SettingsDao {
  final DatabaseHelper _helper;
  enc.Key? _key;

  SettingsDao(this._helper);

  /// Sets the encryption key to use for all subsequent reads and writes.
  void setKey(enc.Key key) => _key = key;

  Future<String?> get(String settingKey) async {
    final db = await _helper.database;
    final rows = await db.query(
      'user_settings',
      where: 'key = ?',
      whereArgs: [settingKey],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    final raw = rows.first['value'] as String;
    final encKey = _key;
    return encKey != null ? EncryptionService.decrypt(raw, encKey) : raw;
  }

  Future<void> set(String settingKey, String value) async {
    final db = await _helper.database;
    final encKey = _key;
    final storedValue =
        encKey != null ? EncryptionService.encrypt(value, encKey) : value;

    await db.insert(
      'user_settings',
      {'key': settingKey, 'value': storedValue},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, String>> getAll() async {
    final db = await _helper.database;
    final rows = await db.query('user_settings');
    final encKey = _key;

    return {
      for (final r in rows)
        r['key'] as String: encKey != null
            ? EncryptionService.decrypt(r['value'] as String, encKey)
            : r['value'] as String,
    };
  }
}
