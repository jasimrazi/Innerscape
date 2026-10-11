import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/foundation.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service responsible for client-side encryption of all sensitive data.
///
/// ### Algorithm: AES-256-CBC
/// - 256-bit key derived from userId + pepper via SHA-256 (domain-separated).
/// - Each encrypt() call generates a fresh random 16-byte IV, so identical
///   plaintexts always produce different ciphertexts.
/// - Output format: `enc:v1:<base64(IV || ciphertext)>`
///
/// ### Backward compatibility
/// Any field that does NOT start with `enc:v1:` is treated as legacy plaintext
/// and returned as-is by decrypt(), ensuring old data keeps working.
class EncryptionService {
  static const String prefix = 'enc:v1:';

  // Pepper from .env keeps the secret out of the repository and database.
  static String? get _pepper => dotenv.env['ENCRYPTION_PEPPER'];

  // ── Key Derivation ────────────────────────────────────────────────────────

  /// Derives a deterministic 256-bit AES key from the user's Supabase User ID.
  ///
  /// A domain-separation context string (`innerscape-journal-v1`) is mixed in
  /// so this key cannot be confused with keys derived for other purposes.
  /// Works identically on any device where the same user is signed in.
  static enc.Key deriveKey(String userId) {
    // Domain-separated: context + userId + pepper
    const context = 'innerscape-journal-v1';
    final bytes = utf8.encode('$context:$userId:$_pepper');
    final hash = sha256.convert(bytes);
    return enc.Key(Uint8List.fromList(hash.bytes));
  }

  // ── String Encryption ─────────────────────────────────────────────────────

  /// Encrypts [plainText] using AES-256-CBC with a random 16-byte IV.
  /// Returns empty string for empty input; returns already-encrypted text as-is.
  static String encrypt(String plainText, enc.Key key) {
    if (plainText.isEmpty) return plainText;

    // Idempotent: don't double-encrypt
    if (plainText.startsWith(prefix)) return plainText;

    try {
      final iv = enc.IV.fromSecureRandom(16);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      final encrypted = encrypter.encrypt(plainText, iv: iv);

      // Payload: [16 bytes IV] || [ciphertext bytes]
      final combined = Uint8List(iv.bytes.length + encrypted.bytes.length);
      combined.setRange(0, iv.bytes.length, iv.bytes);
      combined.setRange(iv.bytes.length, combined.length, encrypted.bytes);

      return '$prefix${base64Encode(combined)}';
    } catch (e) {
      debugPrint('[EncryptionService] Encryption error: $e');
      return plainText;
    }
  }

  /// Decrypts a ciphertext prefixed with `enc:v1:`.
  /// Falls back to returning the raw string for legacy plaintext values.
  static String decrypt(String cipherText, enc.Key key) {
    if (cipherText.isEmpty) return cipherText;

    // Legacy / unencrypted: pass through unchanged
    if (!cipherText.startsWith(prefix)) return cipherText;

    try {
      final rawBase64 = cipherText.substring(prefix.length);
      final combined = base64Decode(rawBase64);

      if (combined.length < 16) {
        debugPrint('[EncryptionService] Corrupted payload (too short)');
        return cipherText;
      }

      final iv = enc.IV(combined.sublist(0, 16));
      final encryptedBytes = combined.sublist(16);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      return encrypter.decrypt(enc.Encrypted(encryptedBytes), iv: iv);
    } catch (e) {
      debugPrint('[EncryptionService] Decryption error: $e');
      return cipherText;
    }
  }

  // ── Numeric Helpers ───────────────────────────────────────────────────────

  /// Encrypts a numeric value by converting it to a string first.
  /// Stored as TEXT in Supabase to keep numeric metadata opaque.
  static String encryptNum(num value, enc.Key key) =>
      encrypt(value.toString(), key);

  /// Decrypts a field that was stored as an encrypted numeric string.
  ///
  /// Handles three cases for backward compatibility:
  /// 1. `enc:v1:...` — decrypt and parse.
  /// 2. A raw numeric string (e.g., `"0.85"`) — parse directly.
  /// 3. A native num (SQLite returned an unencrypted number) — cast directly.
  static double decryptDouble(
    dynamic raw,
    enc.Key key, {
    double fallback = 0.0,
  }) {
    if (raw == null) return fallback;
    if (raw is num) return raw.toDouble(); // backward compat: unencrypted numeric
    final plain = decrypt(raw.toString(), key);
    return double.tryParse(plain) ?? fallback;
  }

  /// Like [decryptDouble] but returns an [int].
  static int decryptInt(dynamic raw, enc.Key key, {int fallback = 0}) {
    if (raw == null) return fallback;
    if (raw is num) return raw.toInt(); // backward compat: unencrypted numeric
    final plain = decrypt(raw.toString(), key);
    return int.tryParse(plain) ?? fallback;
  }
}

