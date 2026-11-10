// Copyright (C) 2026 afonsobarracha
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

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:myfitnesstale/src/data/services/sqlite/database_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  final databaseHelper = DatabaseHelper();
  late Directory temporaryDirectory;
  late String originalDatabasesPath;

  setUp(() async {
    databaseFactory = databaseFactoryFfi;
    await databaseHelper.useProductionDatabaseForTesting();
    originalDatabasesPath = await databaseFactory.getDatabasesPath();
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'myfitnesstale_database_isolation_',
    );
    await databaseFactory.setDatabasesPath(temporaryDirectory.path);
  });

  tearDown(() async {
    await databaseHelper.useProductionDatabaseForTesting();
    await databaseFactory.setDatabasesPath(originalDatabasesPath);
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('integration reset preserves the production database', () async {
    final productionPath = join(temporaryDirectory.path, 'app.db');
    final productionDatabase = await openDatabase(
      productionPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE sentinel (value TEXT NOT NULL)');
      },
    );
    await productionDatabase.insert('sentinel', {'value': 'keep me'});
    await productionDatabase.close();

    await databaseHelper.useIntegrationTestDatabaseForTesting();
    await databaseHelper.initialize();
    final integrationDatabase = await databaseHelper.db;
    expect(
      integrationDatabase.path,
      join(temporaryDirectory.path, 'integration_test.db'),
    );

    await databaseHelper.deleteIntegrationTestDatabaseForTesting();

    expect(
      await databaseExists(
        join(temporaryDirectory.path, 'integration_test.db'),
      ),
      isFalse,
    );
    expect(await databaseExists(productionPath), isTrue);

    final preservedDatabase = await openDatabase(productionPath);
    final preservedRows = await preservedDatabase.query('sentinel');
    await preservedDatabase.close();
    expect(preservedRows, [
      {'value': 'keep me'},
    ]);
  });

  test('integration deletion refuses to target production', () async {
    await databaseHelper.useProductionDatabaseForTesting();

    expect(
      databaseHelper.deleteIntegrationTestDatabaseForTesting,
      throwsA(isA<StateError>()),
    );
  });
}
