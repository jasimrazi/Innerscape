import 'package:flutter/foundation.dart';
import '../models/journal_entry.dart';
import 'supabase_service.dart';

class SyncService {
  static final _client = SupabaseService.client;
  static const _table = 'journal_entries';

  /// Called on login. Uploads all local entries to Supabase, then fetches all remote entries.
  /// Merges them and returns the complete unique list.
  static Future<List<JournalEntry>> syncOnLogin(
    String userId,
    List<JournalEntry> localEntries,
  ) async {
    if (!SupabaseService.isInitialized) return localEntries;

    try {
      // 1. Upload all local entries to Supabase using upsert
      if (localEntries.isNotEmpty) {
        final supabaseMaps = localEntries.map((e) => e.toSupabaseMap(userId)).toList();
        await _client.from(_table).upsert(supabaseMaps);
      }

      // 2. Fetch all remote entries from Supabase
      final List<dynamic> response = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .order('timestamp', ascending: false);

      final remoteEntries = response
          .map((data) => JournalEntry.fromSupabaseMap(data as Map<String, dynamic>))
          .toList();

      // 3. Merge them locally (using a map keyed by ID to ensure uniqueness)
      final Map<String, JournalEntry> mergedMap = {};
      
      // Load remote entries first
      for (final entry in remoteEntries) {
        mergedMap[entry.id] = entry;
      }
      
      // Overlay local entries (local wins in case of conflict, though IDs are timestamp-based and usually unique)
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

  /// Uploads (upserts) a single entry to Supabase.
  static Future<void> upsertEntry(String userId, JournalEntry entry) async {
    if (!SupabaseService.isInitialized) return;

    try {
      await _client.from(_table).upsert(entry.toSupabaseMap(userId));
    } catch (e) {
      debugPrint('Error upserting entry: $e');
      rethrow;
    }
  }

  /// Fetches all remote entries for the current user.
  static Future<List<JournalEntry>> fetchRemote(String userId) async {
    if (!SupabaseService.isInitialized) return [];

    try {
      final List<dynamic> response = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .order('timestamp', ascending: false);

      return response
          .map((data) => JournalEntry.fromSupabaseMap(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching remote entries: $e');
      return [];
    }
  }
}
