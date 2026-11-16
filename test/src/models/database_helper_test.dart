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

import 'package:flutter_test/flutter_test.dart';
import 'package:myfitnesstale/src/data/models/sqlite/backup_config_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/backup_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/backup_passkeys_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/model.dart';
import 'package:myfitnesstale/src/data/services/sqlite/dao.dart';
import 'package:myfitnesstale/src/data/services/sqlite/database_helper.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/utils/nullable.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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

  test('fresh version 1 database creates backup tables and indexes', () async {
    await databaseHelper.useIntegrationTestDatabaseForTesting();
    final db = await databaseHelper.db;
    expect(await db.getVersion(), 1);
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    );
    expect(
      tables.map((row) => row['name']),
      containsAll([Backup.table, BackupConfig.table, BackupPasskeys.table]),
    );

    final backupIndexes = await db.rawQuery('PRAGMA index_list(backups)');
    for (final (name, column) in [
      ('idx_backups_provider', BackupColumns.provider.value),
      ('idx_backups_started_at', BackupColumns.startedAt.value),
      ('idx_backups_backup_config_id', BackupColumns.backupConfigId.value),
      ('idx_backups_backup_passkey_id', BackupColumns.backupPasskeyId.value),
    ]) {
      expect(backupIndexes.map((row) => row['name']), contains(name));
      final info = await db.rawQuery('PRAGMA index_info($name)');
      expect(info.single['name'], column);
    }
    final passkeyIndexes = await db.rawQuery(
      'PRAGMA index_list(backup_passkeys)',
    );
    expect(
      passkeyIndexes.singleWhere(
        (row) => row['name'] == 'uidx_backup_passkeys_passkey',
      )['unique'],
      1,
    );
    final info = await db.rawQuery(
      'PRAGMA index_info(uidx_backup_passkeys_passkey)',
    );
    expect(info.single['name'], BackupPasskeysColumns.passkey.value);
  });

  test('backup models support persisted CRUD and nullable updates', () async {
    await databaseHelper.useIntegrationTestDatabaseForTesting();
    final backup = Backup.create(
      provider: BackupProvider.localFile,
      path: '/backup.zip',
      encrypted: false,
      schemaVersion: 1,
    ).copyWith(finishedAt: const Nullable(42));
    await _expectCrud(
      Dao<Backup>(
        databaseHelper: databaseHelper,
        tableName: Backup.table,
        fromMap: Backup.fromMap,
      ),
      backup,
      (id) => backup.copyWith(id: id),
      (id) => backup.copyWith(
        id: id,
        path: '/updated.zip',
        finishedAt: const Nullable(null),
      ),
    );

    final config = BackupConfig.create(
      provider: BackupProvider.localFile,
      schedule: BackupSchedule.weekly,
      backupsOn: true,
      encrypted: false,
    );
    await _expectCrud(
      Dao<BackupConfig>(
        databaseHelper: databaseHelper,
        tableName: BackupConfig.table,
        fromMap: BackupConfig.fromMap,
      ),
      config,
      (id) => config.copyWith(id: id),
      (id) => config.copyWith(
        id: id,
        schedule: BackupSchedule.monthly,
        encrypted: true,
      ),
    );

    final passkey = BackupPasskeys.create(
      passkey: r'$2b$10$test-hash',
      salt: 'AAECAwQFBgcICQoLDA0ODw==',
    ).copyWith(lastUsedAt: const Nullable(42));
    await _expectCrud(
      Dao<BackupPasskeys>(
        databaseHelper: databaseHelper,
        tableName: BackupPasskeys.table,
        fromMap: BackupPasskeys.fromMap,
      ),
      passkey,
      (id) => passkey.copyWith(id: id),
      (id) => passkey.copyWith(
        id: id,
        salt: 'Dw4NDAsKCQgHBgUEAwIBAA==',
        lastUsedAt: const Nullable(null),
      ),
    );
  });
}

Future<void> _expectCrud<T extends Model>(
  Dao<T> dao,
  T initial,
  T Function(int) inserted,
  T Function(int) updated,
) async {
  final id = await dao.insert(initial);
  expect(id, greaterThan(0));
  expect(await dao.selectOne(id), inserted(id));
  expect(await dao.update(updated(id)), isTrue);
  expect(await dao.selectOne(id), updated(id));
  expect(await dao.deleteOne(id), isTrue);
  expect(await dao.selectOne(id), isNull);
}
