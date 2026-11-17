import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:myfitnesstale/src/data/models/sqlite/backup_config_model.dart';
import 'package:myfitnesstale/src/data/services/backup/backup_crypto.dart';
import 'package:myfitnesstale/src/data/services/secure_storage/secure_storage_service.dart';
import 'package:myfitnesstale/src/data/services/sqlite/database_helper.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';

// Keep the default Android preference files so platform backup exclusions apply,
// but isolate test values from the application's cached key on both platforms.
BackupCrypto _createCrypto() => BackupCrypto.create(
  SecureStorageService(
    storage: const FlutterSecureStorage(
      aOptions: AndroidOptions(
        preferencesKeyPrefix: 'integration_test_',
        resetOnError: false,
      ),
      iOptions: IOSOptions(accountName: 'myfitnesstale.integration_test'),
    ),
  ),
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const phase = String.fromEnvironment(
    'BACKUP_STORAGE_PHASE',
    defaultValue: 'all',
  );
  const fixture = String.fromEnvironment(
    'BACKUP_STORAGE_FIXTURE',
    defaultValue: 'native storage test fixture',
  );

  testWidgets('native backup cache journey ($phase)', (tester) async {
    expect(phase, isIn(['all', 'seed', 'verify', 'restore', 'cleanup']));
    if (phase == 'restore') {
      expect(Platform.isAndroid, isTrue, reason: 'Android restore only');
      expect(
        const bool.hasEnvironment('BACKUP_STORAGE_FIXTURE'),
        isTrue,
        reason: 'Use the same per-run fixture ID as the seed phase',
      );
    }
    final helper = DatabaseHelper();
    await helper.useIntegrationTestDatabaseForTesting();
    addTearDown(() async {
      if (phase == 'all' || phase == 'cleanup') {
        await _createCrypto().clearCachedAesKey();
        await helper.deleteIntegrationTestDatabaseForTesting();
      }
      await helper.useProductionDatabaseForTesting();
    });

    if (phase == 'cleanup') return;

    var crypto = _createCrypto();
    final expectedKey = await Sha256().hash(fixture.codeUnits);
    final fixtureId = ByteData.sublistView(
      Uint8List.fromList(expectedKey.bytes),
    ).getUint32(0);
    if (phase == 'all' || phase == 'seed') {
      await helper.deleteIntegrationTestDatabaseForTesting();
      await crypto.clearCachedAesKey();
      expect(await crypto.readCachedAesKey(), isNull);
      await crypto.cacheAesKey(SecretKey(expectedKey.bytes));
      final db = await helper.db;
      await db.insert(
        BackupConfig.table,
        BackupConfig.create(
          provider: BackupProvider.localFile,
          schedule: BackupSchedule.weekly,
          backupsOn: true,
          encrypted: true,
        ).copyWith(id: fixtureId).toMap(),
      );
      if (phase == 'seed') return;
    }

    await helper.resetForTesting();
    final db = await helper.db;
    final rows = await db.query(BackupConfig.table);
    expect(rows, hasLength(1), reason: 'Ordinary SQLite data must survive');
    final config = BackupConfig.fromMap(rows.single);
    expect(config.id, fixtureId, reason: 'Check this run’s SQLite fixture');
    expect(config.provider, BackupProvider.localFile);
    expect(config.schedule, BackupSchedule.weekly);
    expect(config.encrypted, isTrue);

    crypto = _createCrypto();
    if (phase == 'restore') {
      // Check before the plugin can initialize or modify its preference files.
      final appData = File(db.path).parent.parent.path;
      for (final name in [
        'FlutterSecureStorage',
        'FlutterSecureKeyStorage',
        'FlutterSecureStorageConfiguration',
        'FlutterSecureStorageConfiguration:FlutterSecureStorage',
      ]) {
        expect(
          await File('$appData/shared_prefs/$name.xml').exists(),
          isFalse,
          reason: '$name preferences must be excluded from Android restore',
        );
      }
      expect(await crypto.readCachedAesKey(), isNull);
      final replacement = await Sha256().hash(
        '$fixture after restore'.codeUnits,
      );
      await crypto.cacheAesKey(SecretKey(replacement.bytes));
      final cached = await _createCrypto().readCachedAesKey();
      expect(await cached?.extractBytes(), replacement.bytes);
      await crypto.clearCachedAesKey();
      expect(await crypto.readCachedAesKey(), isNull);
      return;
    }
    final cached = await crypto.readCachedAesKey();
    expect(cached, isNotNull);
    if (cached == null) return;
    expect(await cached.extractBytes(), expectedKey.bytes);
    if (phase == 'all') {
      await crypto.clearCachedAesKey();
      expect(await crypto.readCachedAesKey(), isNull);
    }
  });
}
