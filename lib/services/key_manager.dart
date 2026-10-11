import 'dart:convert';
import 'dart:math';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'encryption_service.dart';

/// Resolves the AES-256 encryption key to use for the current session.
///
/// Two modes:
/// - **Authenticated** (`userId != null`): derives a deterministic key from
///   `userId + pepper` via [EncryptionService.deriveKey]. The same key is
///   reproduced on any device where the user signs in.
/// - **Anonymous** (`userId == null`): generates a random 32-byte key on first
///   launch and persists it in the OS secure storage (iOS Keychain /
///   Android Keystore). The key is stable for the lifetime of the app install.
///
/// Call [resolveKey] at app start and again after any auth-state change.
/// Call [clearCache] on sign-out so the old key is not held in memory.
class KeyManager {
  // Storage key for the anonymous device key
  static const _deviceKeyStorageKey = 'innerscape_device_enc_key_v1';

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // In-memory cache — invalidated on sign-out
  static enc.Key? _cachedKey;
  static String? _cachedUserId; // null = anonymous

  // ── Public API ────────────────────────────────────────────────────────────

  /// Returns the active AES-256 encryption key.
  ///
  /// - If [userId] is provided: derives the user key (cached per userId).
  /// - If [userId] is null: returns/generates the anonymous device key.
  static Future<enc.Key> resolveKey({String? userId}) async {
    if (userId != null) {
      // Re-use cache if same user
      if (_cachedUserId == userId && _cachedKey != null) return _cachedKey!;

      debugPrint('[KeyManager] Deriving user key for userId=${userId.substring(0, 8)}...');
      _cachedKey = EncryptionService.deriveKey(userId);
      _cachedUserId = userId;
      return _cachedKey!;
    }

    // Anonymous mode: use cached device key if already loaded
    if (_cachedUserId == null && _cachedKey != null) return _cachedKey!;

    _cachedKey = await _loadOrCreateDeviceKey();
    _cachedUserId = null;
    return _cachedKey!;
  }

  /// Clears the in-memory key cache.
  /// Call this immediately after the user signs out.
  static void clearCache() {
    debugPrint('[KeyManager] Clearing key cache.');
    _cachedKey = null;
    _cachedUserId = null;
  }

  // ── Private ───────────────────────────────────────────────────────────────

  /// Loads the persisted device key from secure storage, or generates a new
  /// random 32-byte key, persists it, and returns it.
  static Future<enc.Key> _loadOrCreateDeviceKey() async {
    try {
      final existing = await _storage.read(key: _deviceKeyStorageKey);
      if (existing != null) {
        debugPrint('[KeyManager] Loaded existing device key from secure storage.');
        final bytes = base64Decode(existing);
        return enc.Key(Uint8List.fromList(bytes));
      }
    } catch (e) {
      debugPrint('[KeyManager] Failed to read device key from secure storage: $e');
    }

    // Generate a cryptographically secure random 32-byte key
    final random = Random.secure();
    final keyBytes = Uint8List.fromList(
      List.generate(32, (_) => random.nextInt(256)),
    );

    try {
      await _storage.write(
        key: _deviceKeyStorageKey,
        value: base64Encode(keyBytes),
      );
      debugPrint('[KeyManager] Generated and stored new device key.');
    } catch (e) {
      debugPrint('[KeyManager] Failed to persist device key: $e');
    }

    return enc.Key(keyBytes);
  }
}
