import 'package:flutter_test/flutter_test.dart';
import 'package:innerscape/services/encryption_service.dart';
import 'package:innerscape/models/journal_entry.dart';

void main() {
  group('EncryptionService', () {
    const testUserId = 'user-uuid-12345-abcde';
    final key = EncryptionService.deriveKey(testUserId);

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

    test('Different user keys produce different derivations', () {
      final key1 = EncryptionService.deriveKey('user-1');
      final key2 = EncryptionService.deriveKey('user-2');
      expect(key1.bytes, isNot(equals(key2.bytes)));
    });
  });

  group('JournalEntry Encryption serialization', () {
    const testUserId = 'test-user-999';
    final key = EncryptionService.deriveKey(testUserId);

    test('toEncryptedSupabaseMap encrypts text fields and fromEncryptedSupabaseMap restores them', () {
      final entry = JournalEntry(
        id: '2026-09-23T11:00:00.000',
        timestamp: DateTime(2026, 9, 23, 11, 0),
        date: 'Wednesday, September 23',
        win: 'Shipped confidential features',
        goal: 'Meditate for 20 minutes',
        hueShift: 15.0,
        moodValue: 0.85,
        tags: const ['focus', 'zen'],
      );

      final map = entry.toEncryptedSupabaseMap(testUserId, key);

      expect(map['win'], startsWith(EncryptionService.prefix));
      expect(map['goal'], startsWith(EncryptionService.prefix));
      expect(map['tags'], startsWith(EncryptionService.prefix));
      expect(map['win'], isNot(contains('Shipped confidential features')));

      // Deserialization restores plaintext
      final restored = JournalEntry.fromEncryptedSupabaseMap(map, key);
      expect(restored.win, equals('Shipped confidential features'));
      expect(restored.goal, equals('Meditate for 20 minutes'));
      expect(restored.tags, equals(['focus', 'zen']));
      expect(restored.moodValue, equals(0.85));
      expect(restored.id, equals(entry.id));
    });

    test('fromEncryptedSupabaseMap seamlessly handles legacy plaintext maps', () {
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
    });
  });
}
