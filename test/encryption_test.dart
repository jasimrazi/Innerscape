import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innerscape/models/journal_entry.dart';
import 'package:innerscape/services/encryption_service.dart';

void main() {
  setUpAll(() async {
    // Load .env so EncryptionService can read ENCRYPTION_PEPPER
    await dotenv.load(fileName: '.env');
  });

  // ── EncryptionService Core ───────────────────────────────────────────────
  group('EncryptionService — string encryption', () {
    late enc.Key key;

    setUp(() {
      key = EncryptionService.deriveKey('user-uuid-12345-abcde');
    });

    test('Round-trip encryption and decryption preserves plaintext', () {
      const plain = 'Today I had a breakthrough with my personal project!';
      final cipher = EncryptionService.encrypt(plain, key);

      expect(cipher.startsWith(EncryptionService.prefix), isTrue);
      expect(cipher, isNot(equals(plain)));

      final decrypted = EncryptionService.decrypt(cipher, key);
      expect(decrypted, equals(plain));
    });

    test('Each encryption call produces unique ciphertext (random IV)', () {
      const plain = 'Consistent reflection';
      final cipher1 = EncryptionService.encrypt(plain, key);
      final cipher2 = EncryptionService.encrypt(plain, key);

      expect(cipher1, isNot(equals(cipher2)));
      expect(EncryptionService.decrypt(cipher1, key), equals(plain));
      expect(EncryptionService.decrypt(cipher2, key), equals(plain));
    });

    test('Gracefully handles empty strings', () {
      expect(EncryptionService.encrypt('', key), equals(''));
      expect(EncryptionService.decrypt('', key), equals(''));
    });

    test('Backward compatibility: unencrypted text passes through decrypt safely', () {
      const legacyPlain = 'Legacy entry from before encryption was enabled';
      final decrypted = EncryptionService.decrypt(legacyPlain, key);
      expect(decrypted, equals(legacyPlain));
    });

    test('Idempotent: re-encrypting an already-encrypted string is a no-op', () {
      const plain = 'Already encrypted test';
      final cipher = EncryptionService.encrypt(plain, key);
      final reEncrypted = EncryptionService.encrypt(cipher, key);
      expect(reEncrypted, equals(cipher));
    });

    test('Different user keys produce different derivations', () {
      final key1 = EncryptionService.deriveKey('user-1');
      final key2 = EncryptionService.deriveKey('user-2');
      expect(key1.bytes, isNot(equals(key2.bytes)));
    });

    test('Domain-separated key is 256 bits long', () {
      final domainKey = EncryptionService.deriveKey('user-abc');
      expect(domainKey.bytes.length, equals(32)); // 256 bits
    });
  });

  // ── Numeric Helpers ───────────────────────────────────────────────────────
  group('EncryptionService — numeric helpers', () {
    late enc.Key key;

    setUp(() {
      key = EncryptionService.deriveKey('user-numeric-test');
    });

    test('encryptNum / decryptDouble round-trip', () {
      const moodValue = 0.85;
      final cipher = EncryptionService.encryptNum(moodValue, key);
      expect(cipher.startsWith(EncryptionService.prefix), isTrue);
      final decrypted = EncryptionService.decryptDouble(cipher, key);
      expect(decrypted, closeTo(moodValue, 0.0001));
    });

    test('encryptNum / decryptInt round-trip for timestamp', () {
      final timestamp = DateTime(2026, 9, 23, 11, 0).millisecondsSinceEpoch;
      final cipher = EncryptionService.encryptNum(timestamp, key);
      expect(cipher.startsWith(EncryptionService.prefix), isTrue);
      final decrypted = EncryptionService.decryptInt(cipher, key);
      expect(decrypted, equals(timestamp));
    });

    test('decryptDouble backward compat: raw num returns as double', () {
      const rawNum = 0.72;
      final result = EncryptionService.decryptDouble(rawNum, key);
      expect(result, closeTo(rawNum, 0.0001));
    });

    test('decryptInt backward compat: raw num returns as int', () {
      const rawNum = 1700000000000;
      final result = EncryptionService.decryptInt(rawNum, key);
      expect(result, equals(rawNum));
    });

    test('decryptDouble returns fallback for null', () {
      expect(
        EncryptionService.decryptDouble(null, key, fallback: 0.5),
        equals(0.5),
      );
    });

    test('encryptNum with negative hueShift round-trips correctly', () {
      const hue = -15.5;
      final cipher = EncryptionService.encryptNum(hue, key);
      final decrypted = EncryptionService.decryptDouble(cipher, key);
      expect(decrypted, closeTo(hue, 0.0001));
    });
  });

  // ── Supabase Serialization (full field encryption) ────────────────────────
  group('JournalEntry — Supabase full field encryption', () {
    late enc.Key key;
    late JournalEntry entry;
    const testUserId = 'test-user-999';

    setUp(() {
      key = EncryptionService.deriveKey(testUserId);
      entry = JournalEntry(
        id: '2026-09-23T11:00:00.000',
        timestamp: DateTime(2026, 9, 23, 11, 0),
        date: 'Wednesday, September 23',
        win: 'Shipped confidential features',
        goal: 'Meditate for 20 minutes',
        hueShift: 15.0,
        moodValue: 0.85,
        tags: const ['focus', 'zen'],
      );
    });

    test('toEncryptedSupabaseMap encrypts ALL sensitive fields', () {
      final map = entry.toEncryptedSupabaseMap(testUserId, key);

      // Text fields must be ciphertext
      expect(map['win'], startsWith(EncryptionService.prefix));
      expect(map['goal'], startsWith(EncryptionService.prefix));
      expect(map['tags'], startsWith(EncryptionService.prefix));
      expect(map['date'], startsWith(EncryptionService.prefix));

      // Numeric fields must now be ciphertext strings too
      expect(map['timestamp'], startsWith(EncryptionService.prefix));
      expect(map['mood_value'], startsWith(EncryptionService.prefix));
      expect(map['hue_shift'], startsWith(EncryptionService.prefix));

      // Plaintext must not appear in any encrypted field
      expect(map['win'], isNot(contains('Shipped confidential features')));
      expect(map['date'], isNot(contains('September')));

      // id and user_id remain plaintext (required for DB operations)
      expect(map['id'], equals(entry.id));
      expect(map['user_id'], equals(testUserId));
    });

    test('fromEncryptedSupabaseMap restores all fields correctly', () {
      final map = entry.toEncryptedSupabaseMap(testUserId, key);
      final restored = JournalEntry.fromEncryptedSupabaseMap(map, key);

      expect(restored.win, equals('Shipped confidential features'));
      expect(restored.goal, equals('Meditate for 20 minutes'));
      expect(restored.tags, equals(['focus', 'zen']));
      expect(restored.date, equals('Wednesday, September 23'));
      expect(restored.moodValue, closeTo(0.85, 0.0001));
      expect(restored.hueShift, closeTo(15.0, 0.0001));
      expect(restored.id, equals(entry.id));
      expect(
        restored.timestamp.millisecondsSinceEpoch,
        equals(entry.timestamp.millisecondsSinceEpoch),
      );
    });

    test('fromEncryptedSupabaseMap handles legacy plaintext rows (backward compat)', () {
      final legacyMap = {
        'id': 'legacy-id',
        'timestamp': 1700000000000,
        'date': 'Wednesday, September 23',
        'win': 'Legacy raw win',
        'goal': 'Legacy raw goal',
        'hue_shift': 0.0,
        'mood_value': 0.5,
        'tags': 'legacy,tag',
      };

      final restored = JournalEntry.fromEncryptedSupabaseMap(legacyMap, key);
      expect(restored.win, equals('Legacy raw win'));
      expect(restored.goal, equals('Legacy raw goal'));
      expect(restored.tags, equals(['legacy', 'tag']));
      expect(restored.moodValue, closeTo(0.5, 0.0001));
    });
  });

  // ── Local SQLite Serialization ─────────────────────────────────────────────
  group('JournalEntry — local SQLite encrypted serialization', () {
    late enc.Key key;
    late JournalEntry entry;

    setUp(() {
      key = EncryptionService.deriveKey('local-user-test');
      entry = JournalEntry(
        id: '2026-10-01T08:30:00.000',
        timestamp: DateTime(2026, 10, 1, 8, 30),
        date: 'Thursday, October 1',
        win: 'Completed morning routine',
        goal: 'Read for 30 minutes',
        hueShift: -10.0,
        moodValue: 0.72,
        tags: const ['health', 'routine'],
      );
    });

    test('toEncryptedLocalMap encrypts text fields but keeps numerics native', () {
      final map = entry.toEncryptedLocalMap(key);

      // Text fields encrypted
      expect(map['date'], startsWith(EncryptionService.prefix));
      expect(map['win'], startsWith(EncryptionService.prefix));
      expect(map['goal'], startsWith(EncryptionService.prefix));
      expect(map['tags'], startsWith(EncryptionService.prefix));

      // Numeric fields kept as native types for SQLite efficiency
      expect(map['timestamp'], isA<int>());
      expect(map['hue_shift'], isA<double>());
      expect(map['mood_value'], isA<double>());
      expect(map['id'], equals(entry.id));
    });

    test('fromEncryptedLocalMap round-trips all fields correctly', () {
      final map = entry.toEncryptedLocalMap(key);
      final restored = JournalEntry.fromEncryptedLocalMap(map, key);

      expect(restored.win, equals('Completed morning routine'));
      expect(restored.goal, equals('Read for 30 minutes'));
      expect(restored.date, equals('Thursday, October 1'));
      expect(restored.tags, equals(['health', 'routine']));
      expect(restored.moodValue, closeTo(0.72, 0.0001));
      expect(restored.hueShift, closeTo(-10.0, 0.0001));
      expect(
        restored.timestamp.millisecondsSinceEpoch,
        equals(entry.timestamp.millisecondsSinceEpoch),
      );
    });

    test('fromEncryptedLocalMap handles legacy plaintext SQLite rows', () {
      final legacyMap = {
        'id': 'legacy-local',
        'timestamp': 1700000000000,
        'date': 'Old plaintext date',
        'win': 'Old plaintext win',
        'goal': 'Old plaintext goal',
        'hue_shift': 5.0,
        'mood_value': 0.6,
        'tags': 'old,tag',
      };

      final restored = JournalEntry.fromEncryptedLocalMap(legacyMap, key);
      expect(restored.win, equals('Old plaintext win'));
      expect(restored.date, equals('Old plaintext date'));
      expect(restored.tags, equals(['old', 'tag']));
    });
  });
}
