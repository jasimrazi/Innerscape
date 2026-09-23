import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/foundation.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service responsible for client-side encryption of sensitive journal entry texts.
/// Uses AES-256 (CBC with random IV) with key derivation from the user account identity.
/// Prefix "enc:v1:" guarantees backward-compatibility with existing unencrypted entries.
class EncryptionService {
  static const String prefix = 'enc:v1:';

  // Retrieve pepper from .env (keeps secret isolated from repository & database)
   static String? get _pepper =>
      dotenv.env['ENCRYPTION_PEPPER'];

  /// Derives a deterministic 256-bit AES Key from the user's Supabase User ID.
  /// Works seamlessly across any device where the user logs into their account.
  static enc.Key deriveKey(String userId) {
    final bytes = utf8.encode('$userId:$_pepper');
    final hash = sha256.convert(bytes);
    return enc.Key(Uint8List.fromList(hash.bytes));
  }

  /// Encrypts plaintext using AES-256-CBC with a randomly generated 16-byte IV.
  /// Result is encoded as Base64 and prefixed with `enc:v1:`.
  /// If the text is empty, returns empty string.
  static String encrypt(String plainText, enc.Key key) {
    if (plainText.isEmpty) return plainText;
    
    // Don't re-encrypt if already encrypted
    if (plainText.startsWith(prefix)) return plainText;

    try {
      final iv = enc.IV.fromSecureRandom(16);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      final encrypted = encrypter.encrypt(plainText, iv: iv);

      // Payload contains: [16 bytes IV] + [encrypted bytes]
      final combinedBytes = Uint8List(iv.bytes.length + encrypted.bytes.length);
      combinedBytes.setRange(0, iv.bytes.length, iv.bytes);
      combinedBytes.setRange(iv.bytes.length, combinedBytes.length, encrypted.bytes);

      return '$prefix${base64Encode(combinedBytes)}';
    } catch (e) {
      debugPrint('[EncryptionService] Encryption error: $e');
      return plainText;
    }
  }

  /// Decrypts a ciphertext string starting with `enc:v1:`.
  /// If the string is unencrypted (legacy plaintext), it safely returns the original text.
  static String decrypt(String cipherText, enc.Key key) {
    if (cipherText.isEmpty) return cipherText;

    // Backward compatibility: If not starting with prefix, return plainText as-is
    if (!cipherText.startsWith(prefix)) {
      return cipherText;
    }

    try {
      final rawBase64 = cipherText.substring(prefix.length);
      final combinedBytes = base64Decode(rawBase64);

      if (combinedBytes.length < 16) {
        // Corrupted payload
        return cipherText;
      }

      final ivBytes = combinedBytes.sublist(0, 16);
      final encryptedBytes = combinedBytes.sublist(16);

      final iv = enc.IV(ivBytes);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      final decrypted = encrypter.decrypt(enc.Encrypted(encryptedBytes), iv: iv);

      return decrypted;
    } catch (e) {
      debugPrint('[EncryptionService] Decryption error: $e');
      // In case of error (e.g., tampered data or wrong key), return raw or placeholder
      return cipherText;
    }
  }
}
