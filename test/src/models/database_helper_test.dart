import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:myfitnesstale/src/models/db.dart';

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
