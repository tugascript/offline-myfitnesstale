// Copyright (C) 2026 Afonso Barracha
//
// This file is part of My Fitness Tale.
//
// My Fitness Tale is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// My Fitness Tale is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with My Fitness Tale.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:bcrypt/bcrypt.dart';
import 'package:cryptography/cryptography.dart';
import 'package:logging/logging.dart';

import '../secure_storage/secure_storage_service.dart';

/// Crypto helpers for backup passkeys: bcrypt verification + PBKDF2 AES key
/// derivation, with optional caching of the derived key in secure storage.
final class BackupCrypto {
  static const String cachedAesKeyStorageKey = 'backup_aes_key';
  static const int saltLengthBytes = 16;
  static const int _pbkdf2Iterations = 310000;
  static const int _aesKeyBits = 256;

  final SecureStorageService _secureStorage;
  final Logger _logger = Logger('BackupCrypto');
  final Pbkdf2 _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: _pbkdf2Iterations,
    bits: _aesKeyBits,
  );

  BackupCrypto({required this._secureStorage});

  factory BackupCrypto.create([SecureStorageService? secureStorage]) {
    return BackupCrypto(
      secureStorage: secureStorage ?? SecureStorageService.create(),
    );
  }

  /// 16 cryptographically secure random bytes for PBKDF2 salt.
  List<int> generateSalt() {
    final random = Random.secure();
    return List<int>.generate(saltLengthBytes, (_) => random.nextInt(256));
  }

  String encodeSalt(List<int> salt) => base64Encode(salt);

  List<int> decodeSalt(String saltBase64) => base64Decode(saltBase64);

  /// One-way hash for verifying the passkey. Store this in SQLite, not the
  /// plaintext passkey.
  String hashPasskey(String passkey) {
    return BCrypt.hashpw(passkey, BCrypt.gensalt());
  }

  bool verifyPasskey(String passkey, String hash) {
    return BCrypt.checkpw(passkey, hash);
  }

  /// Derives a 256-bit AES key from [passkey] and [salt] via PBKDF2-HMAC-SHA256.
  Future<SecretKey> deriveAesKey({
    required String passkey,
    required List<int> salt,
  }) async {
    _logger.info('deriveAesKey');
    return _pbkdf2.deriveKeyFromPassword(password: passkey, nonce: salt);
  }

  Future<void> cacheAesKey(SecretKey key) async {
    final bytes = await key.extractBytes();
    await _secureStorage.write(
      key: cachedAesKeyStorageKey,
      value: base64Encode(Uint8List.fromList(bytes)),
    );
  }

  Future<SecretKey?> readCachedAesKey() async {
    final encoded = await _secureStorage.read(cachedAesKeyStorageKey);
    if (encoded == null || encoded.isEmpty) {
      return null;
    }
    return SecretKey(base64Decode(encoded));
  }

  Future<void> clearCachedAesKey() async {
    await _secureStorage.delete(cachedAesKeyStorageKey);
  }
}
