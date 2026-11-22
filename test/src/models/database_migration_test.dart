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
import 'package:myfitnesstale/src/data/models/constants/equipment_constants.dart';
import 'package:myfitnesstale/src/data/models/constants/exercise_constants.dart';
import 'package:myfitnesstale/src/data/models/sqlite/equipment_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/exercise_equipment_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/exercise_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/migration_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/profile_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/system_model.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/exercise_repository.dart';
import 'package:myfitnesstale/src/data/services/sqlite/database_helper.dart';
import 'package:myfitnesstale/src/data/services/sqlite/database_migration.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/utils/json_data.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DatabaseHelper migrations', () {
    final databaseHelper = DatabaseHelper();
    late Directory tempDirectory;
    late String originalDatabasesPath;

    setUp(() async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      await databaseHelper.useProductionDatabaseForTesting();
      originalDatabasesPath = await databaseFactory.getDatabasesPath();
      tempDirectory = await Directory.systemTemp.createTemp(
        'myfitnesstale_migration_engine_test_',
      );
      await databaseFactory.setDatabasesPath(tempDirectory.path);
    });

    tearDown(() async {
      await databaseHelper.useProductionDatabaseForTesting();
      await databaseFactory.setDatabasesPath(originalDatabasesPath);
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    test('creates migrations table first, rolls back failed create transaction, and persists failure before retry', () async {
      databaseHelper.configureMigrationsForTesting(
        onCreateExtraStep: (txn) async {
          throw StateError('Simulated create failure');
        },
      );

      await expectLater(
        databaseHelper.initialize(),
        throwsA(isA<StateError>()),
      );

      final rawDb = await openDatabase(join(tempDirectory.path, 'app.db'));
      try {
        expect(await rawDb.getVersion(), 0);
        final tables = (await rawDb.rawQuery(
          "SELECT name FROM sqlite_master WHERE type = 'table'",
        )).map((row) => row['name'] as String).toSet();
        expect(tables, contains(Migration.table));
        expect(tables, isNot(contains(Profile.table)));

        final rows = (await rawDb.query(
          Migration.table,
          orderBy: MigrationColumns.id.orderAsc,
        )).map(Migration.fromMap).toList();
        expect(rows, hasLength(1));
        expect(rows.single.version, 1);
        expect(rows.single.name, 'initial_schema');
        expect(rows.single.status, MigrationStatus.failed);
        expect(rows.single.direction, MigrationDirection.up);
        expect(rows.single.appliedAt, isNull);
        expect(rows.single.failedAt, isNotNull);
        expect(rows.single.failure, contains('Simulated create failure'));
      } finally {
        await rawDb.close();
      }

      databaseHelper.configureMigrationsForTesting(onCreateExtraStep: null);
      await databaseHelper.initialize();

      final db = await databaseHelper.db;
      expect(await db.getVersion(), 1);
      final tablesAfterRetry = (await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table'",
      )).map((row) => row['name'] as String).toSet();
      expect(tablesAfterRetry, contains(Profile.table));

      final migrations = await databaseHelper.getMigrations();
      expect(migrations, hasLength(2));
      expect(migrations[0].status, MigrationStatus.failed);
      expect(migrations[1].version, 1);
      expect(migrations[1].status, MigrationStatus.applied);
      expect(migrations[1].appliedAt, isNotNull);
      expect(migrations[1].failure, isNull);
    });

    test('supports roll-forward, failure recovery, rollbackTo, and re-applying rolled back versions', () async {
      await databaseHelper.initialize();
      await databaseHelper.resetForTesting(resetMigrations: false);

      final v2Migration = DatabaseMigration(
        version: 2,
        name: 'add_mig_notes',
        up: (txn) async {
          await txn.execute(
            'CREATE TABLE mig_notes (id INTEGER PRIMARY KEY, body TEXT NOT NULL)',
          );
        },
        down: (txn) async {
          await txn.execute('DROP TABLE IF EXISTS mig_notes');
        },
      );
      final v3FailingMigration = DatabaseMigration(
        version: 3,
        name: 'add_mig_tags',
        up: (txn) async {
          await txn.execute(
            'CREATE TABLE mig_tags (id INTEGER PRIMARY KEY, label TEXT NOT NULL)',
          );
          throw StateError('Simulated v3 upgrade failure');
        },
        down: (txn) async {
          await txn.execute('DROP TABLE IF EXISTS mig_tags');
        },
      );

      databaseHelper.configureMigrationsForTesting(
        targetVersion: 3,
        migrations: [v2Migration, v3FailingMigration],
      );

      await expectLater(
        databaseHelper.initialize(),
        throwsA(isA<StateError>()),
      );

      final rawDb = await openDatabase(join(tempDirectory.path, 'app.db'));
      try {
        expect(await rawDb.getVersion(), 2);
        final tables = (await rawDb.rawQuery(
          "SELECT name FROM sqlite_master WHERE type = 'table'",
        )).map((row) => row['name'] as String).toSet();
        expect(tables, contains('mig_notes'));
        expect(tables, isNot(contains('mig_tags')));

        final rows = (await rawDb.query(
          Migration.table,
          orderBy: MigrationColumns.id.orderAsc,
        )).map(Migration.fromMap).toList();
        expect(rows.map((r) => (r.version, r.status, r.direction)), [
          (1, MigrationStatus.applied, MigrationDirection.up),
          (2, MigrationStatus.applied, MigrationDirection.up),
          (3, MigrationStatus.failed, MigrationDirection.up),
        ]);
        expect(rows.last.failedAt, isNotNull);
        expect(rows.last.failure, contains('Simulated v3 upgrade failure'));
      } finally {
        await rawDb.close();
      }

      final v3FixedMigration = DatabaseMigration(
        version: 3,
        name: 'add_mig_tags',
        up: (txn) async {
          await txn.execute(
            'CREATE TABLE mig_tags (id INTEGER PRIMARY KEY, label TEXT NOT NULL)',
          );
        },
        down: (txn) async {
          await txn.execute('DROP TABLE IF EXISTS mig_tags');
        },
      );

      databaseHelper.configureMigrationsForTesting(
        targetVersion: 3,
        migrations: [v2Migration, v3FixedMigration],
      );
      await databaseHelper.initialize();

      final db = await databaseHelper.db;
      expect(await db.getVersion(), 3);
      final tablesAtV3 = (await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table'",
      )).map((row) => row['name'] as String).toSet();
      expect(tablesAtV3, containsAll(['mig_notes', 'mig_tags']));

      // Rollback v3 -> v1 explicitly.
      await databaseHelper.rollbackTo(1);
      expect(await db.getVersion(), 1);
      final tablesAfterRollback = (await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table'",
      )).map((row) => row['name'] as String).toSet();
      expect(tablesAfterRollback, isNot(contains('mig_notes')));
      expect(tablesAfterRollback, isNot(contains('mig_tags')));

      // Re-apply v2 -> v3 after rollback to ensure no unique-version conflict.
      await databaseHelper.resetForTesting(resetMigrations: false);
      databaseHelper.configureMigrationsForTesting(
        targetVersion: 3,
        migrations: [v2Migration, v3FixedMigration],
      );
      await databaseHelper.initialize();

      final reopenedDb = await databaseHelper.db;
      expect(await reopenedDb.getVersion(), 3);
      final tablesAfterReapply = (await reopenedDb.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table'",
      )).map((row) => row['name'] as String).toSet();
      expect(tablesAfterReapply, containsAll(['mig_notes', 'mig_tags']));

      final history = await databaseHelper.getMigrations();
      expect(history.map((r) => (r.version, r.status, r.direction)), [
        (1, MigrationStatus.applied, MigrationDirection.up),
        (2, MigrationStatus.applied, MigrationDirection.up),
        (3, MigrationStatus.failed, MigrationDirection.up),
        (3, MigrationStatus.applied, MigrationDirection.up),
        (3, MigrationStatus.rolledBack, MigrationDirection.down),
        (2, MigrationStatus.rolledBack, MigrationDirection.down),
        (2, MigrationStatus.applied, MigrationDirection.up),
        (3, MigrationStatus.applied, MigrationDirection.up),
      ]);
      expect(history[4].rolledBackAt, isNotNull);
      expect(history[5].rolledBackAt, isNotNull);
    });

    test('automatically downgrades when targetVersion is lower than database version', () async {
      final migrations = [
        DatabaseMigration(
          version: 2,
          name: 'add_mig_notes',
          up: (txn) async {
            await txn.execute(
              'CREATE TABLE mig_notes (id INTEGER PRIMARY KEY)',
            );
          },
          down: (txn) async {
            await txn.execute('DROP TABLE IF EXISTS mig_notes');
          },
        ),
        DatabaseMigration(
          version: 3,
          name: 'add_mig_tags',
          up: (txn) async {
            await txn.execute('CREATE TABLE mig_tags (id INTEGER PRIMARY KEY)');
          },
          down: (txn) async {
            await txn.execute('DROP TABLE IF EXISTS mig_tags');
          },
        ),
      ];

      databaseHelper.configureMigrationsForTesting(
        targetVersion: 3,
        migrations: migrations,
      );
      await databaseHelper.initialize();
      expect(await (await databaseHelper.db).getVersion(), 3);

      await databaseHelper.resetForTesting(resetMigrations: false);
      databaseHelper.configureMigrationsForTesting(
        targetVersion: 2,
        migrations: migrations,
      );
      await databaseHelper.initialize();

      final db = await databaseHelper.db;
      expect(await db.getVersion(), 2);
      final tables = (await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table'",
      )).map((row) => row['name'] as String).toSet();
      expect(tables, contains('mig_notes'));
      expect(tables, isNot(contains('mig_tags')));

      final history = await databaseHelper.getMigrations();
      expect(history.last.version, 3);
      expect(history.last.status, MigrationStatus.rolledBack);
      expect(history.last.direction, MigrationDirection.down);
    });

    test('failed rollback rolls back transaction, preserves version, and records failure on Migration', () async {
      databaseHelper.configureMigrationsForTesting(
        targetVersion: 2,
        migrations: [
          DatabaseMigration(
            version: 2,
            name: 'add_mig_notes',
            up: (txn) async {
              await txn.execute(
                'CREATE TABLE mig_notes (id INTEGER PRIMARY KEY)',
              );
            },
            down: (txn) async {
              await txn.execute('DROP TABLE IF EXISTS mig_notes');
              throw StateError('Simulated rollback failure');
            },
          ),
        ],
      );
      await databaseHelper.initialize();

      await expectLater(
        databaseHelper.rollbackTo(1),
        throwsA(isA<StateError>()),
      );

      final db = await databaseHelper.db;
      expect(await db.getVersion(), 2);
      final tables = (await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table'",
      )).map((row) => row['name'] as String).toSet();
      expect(tables, contains('mig_notes'));

      final history = await databaseHelper.getMigrations();
      expect(history.map((r) => (r.version, r.status, r.direction)), [
        (1, MigrationStatus.applied, MigrationDirection.up),
        (2, MigrationStatus.applied, MigrationDirection.up),
        (2, MigrationStatus.failed, MigrationDirection.down),
      ]);
      expect(history.last.failedAt, isNotNull);
      expect(history.last.rolledBackAt, isNull);
      expect(history.last.failure, contains('Simulated rollback failure'));
    });

    test('backfills baseline v1 migration record for pre-existing version 1 database', () async {
      final legacyDb = await openDatabase(
        join(tempDirectory.path, 'app.db'),
        version: 1,
        onCreate: (db, _) async {
          for (final statement in Profile.tableCreate.split(';')) {
            if (statement.trim().isNotEmpty) {
              await db.execute(statement.trim());
            }
          }
        },
      );
      await legacyDb.close();

      await databaseHelper.initialize();
      final migrations = await databaseHelper.getMigrations();
      expect(migrations, hasLength(1));
      expect(migrations.single.version, 1);
      expect(migrations.single.name, 'initial_schema');
      expect(migrations.single.status, MigrationStatus.applied);
      expect(migrations.single.direction, MigrationDirection.up);
    });

    test(
      'validates rollback target bounds and missing migration steps',
      () async {
        await databaseHelper.initialize();
        await expectLater(
          databaseHelper.rollbackTo(1),
          throwsA(isA<ArgumentError>()),
        );
        await expectLater(
          databaseHelper.rollbackTo(0),
          throwsA(isA<ArgumentError>()),
        );

        await databaseHelper.resetForTesting();
        databaseHelper.configureMigrationsForTesting(
          targetVersion: 2,
          migrations: const [],
        );
        await expectLater(
          databaseHelper.initialize(),
          throwsA(isA<StateError>()),
        );
      },
    );
  });

  test(
    'version 3 repairs equipment for completed legacy onboarding',
    () async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      await DatabaseHelper().resetForTesting();

      final originalDatabasesPath = await databaseFactory.getDatabasesPath();
      final tempDirectory = await Directory.systemTemp.createTemp(
        'myfitnesstale_migration_test_',
      );
      await databaseFactory.setDatabasesPath(tempDirectory.path);

      addTearDown(() async {
        await DatabaseHelper().resetForTesting();
        await databaseFactory.setDatabasesPath(originalDatabasesPath);
        await tempDirectory.delete(recursive: true);
      });

      final legacyDatabase = await openDatabase(
        join(tempDirectory.path, 'app.db'),
        version: 2,
        onCreate: (database, _) async {
          for (final statement in [
            Profile.tableCreate,
            System.tableCreate,
            Equipment.tableCreate,
            Exercise.tableCreate,
            ExerciseEquipment.tableCreate,
          ]) {
            for (final query in statement.split(';')) {
              if (query.trim().isNotEmpty) {
                await database.execute(query.trim());
              }
            }
          }
        },
      );

      final profileId = await legacyDatabase.insert(
        Profile.table,
        Profile.create(
          name: 'Legacy Profile',
          height: 175,
          gender: Gender.other,
          birthdate: DateTime(1990),
        ).toMap(),
      );
      await legacyDatabase.insert(
        System.table,
        System.create(
          theme: ThemeType.system,
          units: Units.metric,
          profileId: profileId,
          notificationsOn: false,
        ).copyWith(initialSetup: SetUpStatus.completed).toMap(),
      );
      final exerciseId = await legacyDatabase.insert(
        Exercise.table,
        Exercise.create(
          name: kBarbellChestPressName,
          muscleGroup: MuscleGroup.push,
          muscles: const TargetMuscles(primary: {}, secondary: {}),
          difficulty: Difficulty.beginner,
          createdBy: CreatedBy.system,
        ).toMap(),
      );
      await legacyDatabase.close();

      await DatabaseHelper().initialize();
      final migratedDatabase = await DatabaseHelper().db;

      expect(await migratedDatabase.getVersion(), 3);
      expect(
        (await migratedDatabase.query(Equipment.table)).length,
        kEquipmentNames.length,
      );

      final relations = await migratedDatabase.query(
        ExerciseEquipment.table,
        columns: [ExerciseEquipmentColumns.equipmentId.value],
        where: '${ExerciseEquipmentColumns.exerciseId.value} = ?',
        whereArgs: [exerciseId],
      );
      final relatedEquipmentIds = relations
          .map((row) => row[ExerciseEquipmentColumns.equipmentId.value]! as int)
          .toSet();
      final expectedEquipmentRows = await migratedDatabase.query(
        Equipment.table,
        columns: [EquipmentColumns.id.value],
        where: '${EquipmentColumns.name.value} IN (?, ?)',
        whereArgs: [kBarbellName, kBenchName],
      );
      expect(
        relatedEquipmentIds,
        expectedEquipmentRows
            .map((row) => row[EquipmentColumns.id.value]! as int)
            .toSet(),
      );
      expect(
        await migratedDatabase.rawQuery('PRAGMA foreign_key_check'),
        isEmpty,
      );

      final equipmentService = ExerciseRepository.create();
      final paginatedEquipment = await equipmentService.getEquipments();
      final equipmentSelection = await equipmentService.getAllEquipments();
      expect(paginatedEquipment.isOk(), isTrue);
      expect(paginatedEquipment.value.total, kEquipmentNames.length);
      expect(paginatedEquipment.value.data, hasLength(kEquipmentNames.length));
      expect(equipmentSelection.isOk(), isTrue);
      expect(equipmentSelection.value, hasLength(kEquipmentNames.length));
    },
    skip: 'Pre-release schema version is 1; migrations deferred until external beta.',
  );
}
