import 'package:flutter/foundation.dart';
import '../models/journal_entry.dart';
import 'supabase_service.dart';
import 'encryption_service.dart';

class SyncService {
  static final _client = SupabaseService.client;
  static const _table = 'journal_entries';

  /// Called on login. Encrypts and uploads local entries to Supabase,
  /// then fetches and decrypts all remote entries.
  /// Merges them and returns the complete unique plaintext list.
  static Future<List<JournalEntry>> syncOnLogin(
    String userId,
    List<JournalEntry> localEntries,
  ) async {
    if (!SupabaseService.isInitialized) return localEntries;

    final key = EncryptionService.deriveKey(userId);

    try {
      // 1. Upload local entries encrypted with the user's key
      if (localEntries.isNotEmpty) {
        final encryptedMaps = localEntries
            .map((e) => e.toEncryptedSupabaseMap(userId, key))
            .toList();
        await _client.from(_table).upsert(encryptedMaps);
      }

      // 2. Fetch all remote entries from Supabase
      final List<dynamic> response = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .order('timestamp', ascending: false);

      // 3. Decrypt remote entries (handles both encrypted ciphertext and legacy plaintext)
      final remoteEntries = response
          .map((data) => JournalEntry.fromEncryptedSupabaseMap(
                data as Map<String, dynamic>,
                key,
              ))
          .toList();

      // 4. Merge them locally (using a map keyed by ID to ensure uniqueness)
      final Map<String, JournalEntry> mergedMap = {};
      
      // Load remote entries first
      for (final entry in remoteEntries) {
        mergedMap[entry.id] = entry;
      }
      
      // Overlay local entries (local entries are already in plaintext)
      for (final entry in localEntries) {
        mergedMap[entry.id] = entry;
      }

      final mergedList = mergedMap.values.toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return mergedList;
    } catch (e) {
      debugPrint('Error syncing on login: $e');
      return localEntries;
    }
  }

  /// Uploads (upserts) a single encrypted entry to Supabase.
  static Future<void> upsertEntry(String userId, JournalEntry entry) async {
    if (!SupabaseService.isInitialized) return;

    try {
      final key = EncryptionService.deriveKey(userId);
      await _client.from(_table).upsert(entry.toEncryptedSupabaseMap(userId, key));
    } catch (e) {
      debugPrint('Error upserting entry: $e');
      rethrow;
    }
  }

  /// Fetches and decrypts all remote entries for the current user.
  static Future<List<JournalEntry>> fetchRemote(String userId) async {
    if (!SupabaseService.isInitialized) return [];

    try {
      final key = EncryptionService.deriveKey(userId);
      final List<dynamic> response = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .order('timestamp', ascending: false);

      return response
          .map((data) => JournalEntry.fromEncryptedSupabaseMap(
                data as Map<String, dynamic>,
                key,
              ))
          .toList();
    } catch (e) {
      debugPrint('Error fetching remote entries: $e');
      return [];
    }
  }
}
