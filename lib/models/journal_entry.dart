import 'package:encrypt/encrypt.dart' as enc;
import '../services/encryption_service.dart';

/// Journal entry model with support for id, timestamp, mood, and aura ring hue.
class JournalEntry {
  final String id;
  final DateTime timestamp;
  final String date;
  final String win;
  final String goal;
  final double hueShift; // degrees, for AuraRing color variety
  final double moodValue; // 0.0 to 1.0
  final List<String> tags;

  const JournalEntry({
    required this.id,
    required this.timestamp,
    required this.date,
    required this.win,
    required this.goal,
    this.hueShift = 0,
    this.moodValue = 0.5,
    this.tags = const [],
  });

  // ── Local SQLite (unencrypted) ─────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
        'id': id,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'date': date,
        'win': win,
        'goal': goal,
        'hue_shift': hueShift,
        'mood_value': moodValue,
        'tags': tags.join(','),
      };

  factory JournalEntry.fromMap(Map<String, dynamic> map) => JournalEntry(
        id: map['id'] as String,
        timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
        date: map['date'] as String,
        win: map['win'] as String,
        goal: map['goal'] as String,
        hueShift: (map['hue_shift'] as num).toDouble(),
        moodValue: (map['mood_value'] as num).toDouble(),
        tags: (map['tags'] as String?)
                ?.split(',')
                .where((t) => t.isNotEmpty)
                .toList() ??
            const [],
      );

  // ── Local SQLite (encrypted text fields) ──────────────────────────────────

  /// Encrypts text fields (date, win, goal, tags) for local SQLite storage.
  ///
  /// Numeric fields (timestamp, hue_shift, mood_value) are intentionally kept
  /// as native types so SQLite can use them for `ORDER BY` without decryption.
  Map<String, dynamic> toEncryptedLocalMap(enc.Key key) => {
        'id': id,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'date': EncryptionService.encrypt(date, key),
        'win': EncryptionService.encrypt(win, key),
        'goal': EncryptionService.encrypt(goal, key),
        'hue_shift': hueShift,
        'mood_value': moodValue,
        'tags': EncryptionService.encrypt(tags.join(','), key),
      };

  /// Decrypts text fields read from local SQLite.
  /// Falls back to legacy plaintext for unencrypted rows.
  factory JournalEntry.fromEncryptedLocalMap(
    Map<String, dynamic> map,
    enc.Key key,
  ) =>
      JournalEntry(
        id: map['id'] as String,
        timestamp:
            DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
        date: EncryptionService.decrypt(map['date'] as String? ?? '', key),
        win: EncryptionService.decrypt(map['win'] as String? ?? '', key),
        goal: EncryptionService.decrypt(map['goal'] as String? ?? '', key),
        hueShift: (map['hue_shift'] as num).toDouble(),
        moodValue: (map['mood_value'] as num).toDouble(),
        tags: EncryptionService.decrypt(map['tags'] as String? ?? '', key)
            .split(',')
            .where((t) => t.isNotEmpty)
            .toList(),
      );

  // ── Supabase (unencrypted — legacy) ───────────────────────────────────────

  Map<String, dynamic> toSupabaseMap(String userId) => {
        'id': id,
        'user_id': userId,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'date': date,
        'win': win,
        'goal': goal,
        'hue_shift': hueShift,
        'mood_value': moodValue,
        'tags': tags.join(','),
      };

  factory JournalEntry.fromSupabaseMap(Map<String, dynamic> map) =>
      JournalEntry(
        id: map['id'] as String,
        timestamp:
            DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
        date: map['date'] as String,
        win: map['win'] as String,
        goal: map['goal'] as String,
        hueShift: (map['hue_shift'] as num).toDouble(),
        moodValue: (map['mood_value'] as num).toDouble(),
        tags: (map['tags'] as String?)
                ?.split(',')
                .where((t) => t.isNotEmpty)
                .toList() ??
            const [],
      );

  // ── Supabase (fully encrypted) ─────────────────────────────────────────────

  /// Encrypts ALL sensitive fields before uploading to Supabase.
  ///
  /// - Text fields (date, win, goal, tags): AES-256-CBC ciphertext strings.
  /// - Numeric fields (timestamp, moodValue, hueShift): encrypted as strings
  ///   so Supabase cannot infer mood patterns from raw numbers.
  /// - `id` and `user_id` are left plaintext (required for DB lookups & RLS).
  Map<String, dynamic> toEncryptedSupabaseMap(String userId, enc.Key key) => {
        'id': id,
        'user_id': userId,
        'timestamp':
            EncryptionService.encryptNum(timestamp.millisecondsSinceEpoch, key),
        'date': EncryptionService.encrypt(date, key),
        'win': EncryptionService.encrypt(win, key),
        'goal': EncryptionService.encrypt(goal, key),
        'hue_shift': EncryptionService.encryptNum(hueShift, key),
        'mood_value': EncryptionService.encryptNum(moodValue, key),
        'tags': EncryptionService.encrypt(tags.join(','), key),
      };

  /// Decrypts all sensitive fields received from Supabase.
  ///
  /// Handles backward compatibility for rows that were stored before full
  /// encryption was enabled (any non-prefixed value is passed through as-is).
  factory JournalEntry.fromEncryptedSupabaseMap(
    Map<String, dynamic> map,
    enc.Key key,
  ) {
    return JournalEntry(
      id: map['id'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        EncryptionService.decryptInt(
          map['timestamp'],
          key,
          fallback: DateTime.now().millisecondsSinceEpoch,
        ),
      ),
      date: EncryptionService.decrypt(map['date'] as String? ?? '', key),
      win: EncryptionService.decrypt(map['win'] as String? ?? '', key),
      goal: EncryptionService.decrypt(map['goal'] as String? ?? '', key),
      hueShift: EncryptionService.decryptDouble(map['hue_shift'], key),
      moodValue: EncryptionService.decryptDouble(
        map['mood_value'],
        key,
        fallback: 0.5,
      ),
      tags: EncryptionService.decrypt(map['tags'] as String? ?? '', key)
          .split(',')
          .where((t) => t.isNotEmpty)
          .toList(),
    );
  }
}
