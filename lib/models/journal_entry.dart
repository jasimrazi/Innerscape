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
        tags: (map['tags'] as String?)?.split(',').where((t) => t.isNotEmpty).toList() ?? const [],
      );

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

  factory JournalEntry.fromSupabaseMap(Map<String, dynamic> map) => JournalEntry(
        id: map['id'] as String,
        timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
        date: map['date'] as String,
        win: map['win'] as String,
        goal: map['goal'] as String,
        hueShift: (map['hue_shift'] as num).toDouble(),
        moodValue: (map['mood_value'] as num).toDouble(),
        tags: (map['tags'] as String?)?.split(',').where((t) => t.isNotEmpty).toList() ?? const [],
      );

  /// Encrypts sensitive fields (win, goal, tags) before transmitting to Supabase.
  Map<String, dynamic> toEncryptedSupabaseMap(String userId, enc.Key key) => {
        'id': id,
        'user_id': userId,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'date': date,
        'win': EncryptionService.encrypt(win, key),
        'goal': EncryptionService.encrypt(goal, key),
        'hue_shift': hueShift,
        'mood_value': moodValue,
        'tags': EncryptionService.encrypt(tags.join(','), key),
      };

  /// Decrypts sensitive fields received from Supabase.
  /// Safely falls back to plaintext if the row was stored unencrypted.
  factory JournalEntry.fromEncryptedSupabaseMap(Map<String, dynamic> map, enc.Key key) {
    final rawWin = map['win'] as String? ?? '';
    final rawGoal = map['goal'] as String? ?? '';
    final rawTags = map['tags'] as String? ?? '';

    final decryptedWin = EncryptionService.decrypt(rawWin, key);
    final decryptedGoal = EncryptionService.decrypt(rawGoal, key);
    final decryptedTags = EncryptionService.decrypt(rawTags, key);

    return JournalEntry(
      id: map['id'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      date: map['date'] as String,
      win: decryptedWin,
      goal: decryptedGoal,
      hueShift: (map['hue_shift'] as num).toDouble(),
      moodValue: (map['mood_value'] as num).toDouble(),
      tags: decryptedTags.split(',').where((t) => t.isNotEmpty).toList(),
    );
  }
}
