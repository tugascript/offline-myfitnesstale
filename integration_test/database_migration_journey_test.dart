import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:myfitnesstale/src/data/models/sqlite/migration_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/profile_model.dart';
import 'package:myfitnesstale/src/data/services/sqlite/database_helper.dart';
import 'package:myfitnesstale/src/data/services/sqlite/database_migration.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

const _phase = String.fromEnvironment('MIGRATION_PHASE', defaultValue: 'all');
const _fixture = String.fromEnvironment(
  'MIGRATION_FIXTURE',
  defaultValue: 'native migration fixture',
);
const _probe = 'integration_migration_probe';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final helper = DatabaseHelper();

  setUp(() async {
    // Use the real sqflite platform plugin, never the FFI factory or app.db.
    await helper.useIntegrationTestDatabaseForTesting();
  });
  tearDown(() async {
    if (_phase == 'all' || _phase == 'cleanup') {
      await helper.deleteIntegrationTestDatabaseForTesting();
    }
    await helper.useProductionDatabaseForTesting();
  });

  if (_phase != 'all') {
    testWidgets('Android migration process recovery ($_phase)', (tester) async {
      expect(Platform.isAndroid, isTrue);
      expect(
        _phase,
        isIn([
          'interrupt-create',
          'recover-create',
          'interrupt-upgrade',
          'recover-upgrade',
          'interrupt-rollback',
          'recover-rollback',
          'cleanup',
        ]),
      );
      if (_phase == 'cleanup') return;
      expect(const bool.hasEnvironment('MIGRATION_FIXTURE'), isTrue);
      await _processRecovery(helper);
    }, timeout: const Timeout(Duration(minutes: 10)));
    return;
  }

  testWidgets('concurrent cold opens create one native schema and reopen it', (
    tester,
  ) async {
    await helper.deleteIntegrationTestDatabaseForTesting();
    final connections = await Future.wait(List.generate(20, (_) => helper.db));
    final db = connections.first;
    expect(
      connections.every((connection) => identical(connection, db)),
      isTrue,
    );
    expect(await db.getVersion(), 1);
    expect(await _history(db), [(1, 'applied', 'up')]);
    await _seedProfile(db);
    await _checkIntegrity(db);

    await helper.resetForTesting();
    final reopened = await helper.db;
    expect(identical(reopened, db), isFalse);
    await _expectProfile(reopened);
    expect(await _history(reopened), [(1, 'applied', 'up')]);
    await _checkIntegrity(reopened);
  });

  testWidgets('adopts legacy v1 without losing data or duplicating baseline', (
    tester,
  ) async {
    await helper.deleteIntegrationTestDatabaseForTesting();
    final db = await helper.db;
    await _seedProfile(db);
    // Reproduce the pre-PR v1 format: domain schema and user_version, no ledger.
    await db.execute('DROP TABLE ${Migration.table}');
    await helper.resetForTesting();

    for (var reopen = 0; reopen < 2; reopen++) {
      final reopened = await helper.db;
      expect(await reopened.getVersion(), 1);
      await _expectProfile(reopened);
      expect(await _history(reopened), [(1, 'applied', 'up')]);
      await _checkIntegrity(reopened);
      await helper.resetForTesting();
    }
  });

  testWidgets(
    'failed creation leaves only ledger and retries on native reopen',
    (tester) async {
      await helper.deleteIntegrationTestDatabaseForTesting();
      helper.configureMigrationsForTesting(
        onCreateExtraStep: (txn) async {
          await _seedProfile(txn);
          throw StateError('native create failure');
        },
      );
      await expectLater(helper.initialize(), throwsStateError);
      await _inspectClosedDatabase((db) async {
        expect(await db.getVersion(), 0);
        expect(await _hasTable(db, Profile.table), isFalse);
        expect(await _history(db), [(1, 'failed', 'up')]);
      });

      helper.configureMigrationsForTesting();
      await helper.initialize();
      final reopened = await helper.db;
      expect(await reopened.getVersion(), 1);
      expect(await reopened.query(Profile.table), isEmpty);
      expect(await _history(reopened), [
        (1, 'failed', 'up'),
        (1, 'applied', 'up'),
      ]);
      await _checkIntegrity(reopened);
    },
  );

  testWidgets(
    'upgrade failure preserves committed step and retries after reopen',
    (tester) async {
      await helper.deleteIntegrationTestDatabaseForTesting();
      await _seedProfile(await helper.db);
      await helper.resetForTesting();
      helper.configureMigrationsForTesting(
        targetVersion: 3,
        migrations: _migrations(failUpgrade: true),
      );
      await expectLater(helper.initialize(), throwsStateError);
      await _inspectClosedDatabase((db) async {
        expect(await db.getVersion(), 2);
        await _expectProfile(db);
        expect(await _hasTable(db, '${_probe}_v3'), isFalse);
        expect(await db.query(_probe), hasLength(1));
        expect(await _history(db), [
          (1, 'applied', 'up'),
          (2, 'applied', 'up'),
          (3, 'failed', 'up'),
        ]);
        await _checkIntegrity(db);
      });

      helper.configureMigrationsForTesting(migrations: _migrations());
      final db = await helper.db;
      expect(await db.getVersion(), 3);
      await _expectProfile(db);
      expect(await _hasTable(db, '${_probe}_v3'), isTrue);
      expect((await _history(db)).last, (3, 'applied', 'up'));
      // FK enforcement must survive failed open/retry, not just PRAGMA inspection.
      await expectLater(
        db.insert(_probe, {'id': 2, 'profile_id': -1, 'label': 'invalid'}),
        throwsA(isA<DatabaseException>()),
      );
      await _checkIntegrity(db);
    },
  );

  testWidgets('rollback failure is atomic and lower target reopens safely', (
    tester,
  ) async {
    await helper.deleteIntegrationTestDatabaseForTesting();
    await _seedProfile(await helper.db);
    await helper.resetForTesting();
    helper.configureMigrationsForTesting(
      targetVersion: 2,
      migrations: _migrations(failDowngrade: true),
    );
    final db = await helper.db;
    await expectLater(helper.rollbackTo(1), throwsStateError);
    expect(await db.getVersion(), 2);
    await _expectProfile(db);
    expect(await db.query(_probe), hasLength(1));
    expect((await _history(db)).last, (2, 'failed', 'down'));

    await helper.resetForTesting();
    helper.configureMigrationsForTesting(migrations: _migrations());
    final downgraded = await helper.db;
    expect(await downgraded.getVersion(), 1);
    expect(await _hasTable(downgraded, _probe), isFalse);
    await _expectProfile(downgraded);
    expect((await _history(downgraded)).last, (2, 'rolled_back', 'down'));

    await helper.resetForTesting();
    helper.configureMigrationsForTesting(
      targetVersion: 2,
      migrations: _migrations(),
    );
    final upgraded = await helper.db;
    expect(await upgraded.getVersion(), 2);
    expect(await upgraded.query(_probe), hasLength(1));
    await _expectProfile(upgraded);
    await _checkIntegrity(upgraded);
  });
}

List<DatabaseMigration> _migrations({
  bool failUpgrade = false,
  bool failDowngrade = false,
  bool interruptUpgrade = false,
  bool interruptRollback = false,
}) => [
  DatabaseMigration(
    version: 2,
    name: 'native_probe',
    up: (txn) async {
      await txn.execute('''
        CREATE TABLE $_probe (
          id INTEGER PRIMARY KEY,
          profile_id INTEGER NOT NULL REFERENCES ${Profile.table}(id)
            ON DELETE CASCADE,
          label TEXT NOT NULL
        )
      ''');
      await txn.insert(_probe, {'id': 1, 'profile_id': 1, 'label': _fixture});
      if (interruptUpgrade) {
        await _dirtyProfile(txn);
        await _waitForForceStop();
      }
    },
    down: (txn) async {
      await txn.execute('DROP TABLE $_probe');
      if (failDowngrade || interruptRollback) {
        await _dirtyProfile(txn);
        if (failDowngrade) throw StateError('native rollback failure');
        await _waitForForceStop();
      }
    },
  ),
  DatabaseMigration(
    version: 3,
    name: 'native_probe_v3',
    up: (txn) async {
      await txn.execute('CREATE TABLE ${_probe}_v3 (id INTEGER PRIMARY KEY)');
      if (failUpgrade) {
        await _dirtyProfile(txn);
        throw StateError('native upgrade failure');
      }
    },
    down: (txn) => txn.execute('DROP TABLE ${_probe}_v3'),
  ),
];

Future<void> _processRecovery(DatabaseHelper helper) async {
  if (_phase.startsWith('interrupt-')) {
    await helper.deleteIntegrationTestDatabaseForTesting();
    if (_phase == 'interrupt-create') {
      helper.configureMigrationsForTesting(
        onCreateExtraStep: (txn) async {
          await _seedProfile(txn);
          await _waitForForceStop();
        },
      );
      await helper.initialize();
    } else {
      await _seedProfile(await helper.db);
      await helper.resetForTesting();
      helper.configureMigrationsForTesting(
        targetVersion: 2,
        migrations: _migrations(
          interruptUpgrade: _phase == 'interrupt-upgrade',
          interruptRollback: _phase == 'interrupt-rollback',
        ),
      );
      await helper.initialize();
      if (_phase == 'interrupt-rollback') await helper.rollbackTo(1);
    }
    fail('The process should have been force-stopped inside a transaction');
  }

  // Inspect before DatabaseHelper can apply migrations, proving SQLite itself
  // recovered the interrupted transaction and its previous user_version.
  await _inspectClosedDatabase((db) async {
    final wasCreate = _phase == 'recover-create';
    final wasRollback = _phase == 'recover-rollback';
    expect(await db.getVersion(), wasCreate ? 0 : (wasRollback ? 2 : 1));
    expect(await _hasTable(db, Profile.table), !wasCreate);
    expect(await _hasTable(db, _probe), wasRollback);
    expect(await _history(db), [
      if (!wasCreate) (1, 'applied', 'up'),
      if (wasRollback) (2, 'applied', 'up'),
    ], reason: 'A killed transaction cannot commit a success or failure row');
    if (!wasCreate) await _expectProfile(db);
    if (wasRollback) {
      expect((await db.query(_probe)).single['label'], _fixture);
    }
    await _checkIntegrity(db);
  });

  helper.configureMigrationsForTesting(
    targetVersion: _phase == 'recover-upgrade' ? 2 : 1,
    migrations: _migrations(),
  );
  final db = await helper.db;
  expect(await db.getVersion(), _phase == 'recover-upgrade' ? 2 : 1);
  if (_phase == 'recover-create') {
    expect(await db.query(Profile.table), isEmpty);
    await _seedProfile(db);
  }
  await _expectProfile(db);
  expect(await _history(db), [
    (1, 'applied', 'up'),
    if (_phase != 'recover-create') (2, 'applied', 'up'),
    if (_phase == 'recover-rollback') (2, 'rolled_back', 'down'),
  ]);
  await _checkIntegrity(db);
}

Future<void> _waitForForceStop() async {
  // The host runner waits for this unique marker before adb force-stop. All SQL
  // above has completed, but the migration callback/transaction cannot commit.
  debugPrint('MIGRATION_INTERRUPT_READY:$_phase:$_fixture');
  await Completer<void>().future;
}

Future<void> _inspectClosedDatabase(
  Future<void> Function(Database db) inspect,
) async {
  final databasePath = path.join(
    await getDatabasesPath(),
    'integration_test.db',
  );
  expect(await databaseExists(databasePath), isTrue);
  final db = await openDatabase(
    databasePath,
    onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
  );
  try {
    await inspect(db);
  } finally {
    await db.close();
  }
}

Future<void> _seedProfile(DatabaseExecutor db) => db.insert(
  Profile.table,
  const Profile(
    id: 1,
    name: _fixture,
    height: 170,
    gender: Gender.other,
    birthdate: 19900101,
    createdAt: 1700000000,
    updatedAt: 1700000000,
  ).toMap(),
);

Future<void> _dirtyProfile(DatabaseExecutor db) =>
    db.update(Profile.table, {ProfileColumns.name.value: 'uncommitted'});

Future<void> _expectProfile(Database db) async {
  final rows = await db.query(Profile.table);
  expect(rows, [
    {
      'id': 1,
      'name': _fixture,
      'height': 170,
      'gender': Gender.other.value,
      'birthdate': 19900101,
      'created_at': 1700000000,
      'updated_at': 1700000000,
    },
  ]);
}

Future<bool> _hasTable(Database db, String table) async => (await db.rawQuery(
  "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
  [table],
)).isNotEmpty;

Future<List<(int, String, String)>> _history(Database db) async =>
    (await db.query(Migration.table, orderBy: MigrationColumns.id.orderAsc))
        .map((row) => Migration.fromMap(row))
        .map((row) => (row.version, row.status.value, row.direction.value))
        .toList();

Future<void> _checkIntegrity(Database db) async {
  expect(await db.rawQuery('PRAGMA foreign_keys'), [
    {'foreign_keys': 1},
  ]);
  expect(await db.rawQuery('PRAGMA foreign_key_check'), isEmpty);
  expect(await db.rawQuery('PRAGMA integrity_check'), [
    {'integrity_check': 'ok'},
  ]);
}
