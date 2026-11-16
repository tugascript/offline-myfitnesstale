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
import 'package:myfitnesstale/src/data/services/secure_storage/secure_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SecureStorageService storage;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    storage = SecureStorageService.create();
  });

  test('write then read returns the stored value', () async {
    await storage.write(key: 'token', value: 'secret-value');

    expect(await storage.read('token'), 'secret-value');
  });

  test('read returns null for missing keys', () async {
    expect(await storage.read('missing'), isNull);
  });

  test('delete removes a single key', () async {
    await storage.write(key: 'a', value: '1');
    await storage.write(key: 'b', value: '2');

    await storage.delete('a');

    expect(await storage.read('a'), isNull);
    expect(await storage.read('b'), '2');
  });

  test('deleteAll clears every key', () async {
    await storage.write(key: 'a', value: '1');
    await storage.write(key: 'b', value: '2');

    await storage.deleteAll();

    expect(await storage.read('a'), isNull);
    expect(await storage.read('b'), isNull);
  });

  test('write overwrites an existing value', () async {
    await storage.write(key: 'k', value: 'old');
    await storage.write(key: 'k', value: 'new');

    expect(await storage.read('k'), 'new');
  });
}
