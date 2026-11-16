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

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfitnesstale/src/data/services/backup/backup_crypto.dart';
import 'package:myfitnesstale/src/data/services/secure_storage/secure_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BackupCrypto crypto;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    crypto = BackupCrypto.create(SecureStorageService.create());
  });

  group('salt', () {
    test('generateSalt returns 16 bytes', () {
      final salt = crypto.generateSalt();
      expect(salt, hasLength(BackupCrypto.saltLengthBytes));
    });

    test('generateSalt returns different values', () {
      final a = crypto.generateSalt();
      final b = crypto.generateSalt();
      expect(a, isNot(equals(b)));
    });

    test('encodeSalt and decodeSalt round-trip', () {
      final salt = crypto.generateSalt();
      final encoded = crypto.encodeSalt(salt);
      expect(crypto.decodeSalt(encoded), salt);
    });
  });

  group('passkey hashing', () {
    test('hashPasskey does not store the plaintext', () {
      const passkey = 'correct horse battery staple';
      final hash = crypto.hashPasskey(passkey);

      expect(hash, isNot(equals(passkey)));
      expect(hash, startsWith(r'$2'));
    });

    test('verifyPasskey accepts the correct passkey', () {
      const passkey = 'my-backup-passkey';
      final hash = crypto.hashPasskey(passkey);

      expect(crypto.verifyPasskey(passkey, hash), isTrue);
    });

    test('verifyPasskey rejects an incorrect passkey', () {
      final hash = crypto.hashPasskey('right-passkey');

      expect(crypto.verifyPasskey('wrong-passkey', hash), isFalse);
    });
  });

  group('AES key derivation', () {
    test('deriveAesKey is deterministic for the same passkey and salt', () async {
      const passkey = 'derive-me';
      final salt = List<int>.generate(16, (i) => i + 1);

      final first = await crypto.deriveAesKey(passkey: passkey, salt: salt);
      final second = await crypto.deriveAesKey(passkey: passkey, salt: salt);

      expect(await first.extractBytes(), await second.extractBytes());
      expect(await first.extractBytes(), hasLength(32));
    });

    test('deriveAesKey changes when the salt changes', () async {
      const passkey = 'derive-me';
      final saltA = List<int>.filled(16, 1);
      final saltB = List<int>.filled(16, 2);

      final keyA = await crypto.deriveAesKey(passkey: passkey, salt: saltA);
      final keyB = await crypto.deriveAesKey(passkey: passkey, salt: saltB);

      expect(await keyA.extractBytes(), isNot(equals(await keyB.extractBytes())));
    });
  });

  group('AES key cache', () {
    test('readCachedAesKey returns null when nothing is cached', () async {
      expect(await crypto.readCachedAesKey(), isNull);
    });

    test('cacheAesKey then readCachedAesKey round-trips the key', () async {
      final salt = List<int>.generate(16, (i) => i);
      final key = await crypto.deriveAesKey(passkey: 'cache-me', salt: salt);

      await crypto.cacheAesKey(key);
      final cached = await crypto.readCachedAesKey();

      expect(cached, isNotNull);
      expect(await cached!.extractBytes(), await key.extractBytes());
    });

    test('clearCachedAesKey removes the cached key', () async {
      final salt = List<int>.generate(16, (i) => i);
      final key = await crypto.deriveAesKey(passkey: 'clear-me', salt: salt);

      await crypto.cacheAesKey(key);
      await crypto.clearCachedAesKey();

      expect(await crypto.readCachedAesKey(), isNull);
    });
  });
}
