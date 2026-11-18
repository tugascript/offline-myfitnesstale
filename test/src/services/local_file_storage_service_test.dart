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

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:myfitnesstale/src/data/services/storage/local_file_storage_service.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tempDir;
  late LocalFileStorageService storage;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('mft_storage_test_');
    storage = LocalFileStorageService.create(
      directoryProvider: () async => tempDir,
    );
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'savePictureBytes saves inside pictures dir and returns relative filename',
    () async {
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final uri = await storage.savePictureBytes(bytes, prefix: 'equip!@#');

      expect(p.isRelative(uri), isTrue);
      expect(uri, startsWith('equip____'));
      expect(uri, endsWith('.jpg'));
      expect(await storage.pictureExists(uri), isTrue);

      final resolved = await storage.resolvePictureFile(uri);
      expect(resolved, isNotNull);
      expect(await resolved!.readAsBytes(), bytes);
    },
  );

  test('resolvePictureFile rejects empty strings and path traversal', () async {
    expect(await storage.resolvePictureFile(''), isNull);
    expect(await storage.resolvePictureFile('   '), isNull);
    expect(await storage.resolvePictureFile('../outside.jpg'), isNull);
    expect(await storage.resolvePictureFile('sub/../../outside.jpg'), isNull);
  });

  test(
    'deletePicture deletes managed file and refuses external files',
    () async {
      final externalFile = File(p.join(tempDir.path, 'outside.jpg'));
      await externalFile.writeAsBytes([9, 9, 9]);

      final savedUri = await storage.savePictureBytes(
        Uint8List.fromList([10, 20, 30]),
        prefix: 'test',
      );
      expect(await storage.pictureExists(savedUri), isTrue);

      expect(await storage.deletePicture(externalFile.path), isFalse);
      expect(await externalFile.exists(), isTrue);

      expect(await storage.deletePicture(savedUri), isTrue);
      expect(await storage.pictureExists(savedUri), isFalse);
      expect(await storage.deletePicture(savedUri), isFalse);
    },
  );
}
