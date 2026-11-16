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
      aOptions: AndroidOptions(preferencesKeyPrefix: 'integration_test_'),
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
  final expectedKey = List<int>.generate(32, (index) => index);

  testWidgets('native backup cache journey ($phase)', (tester) async {
    expect(phase, isIn(['all', 'seed', 'verify', 'restore', 'cleanup']));
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
    if (phase == 'all' || phase == 'seed') {
      await helper.deleteIntegrationTestDatabaseForTesting();
      await crypto.clearCachedAesKey();
      expect(await crypto.readCachedAesKey(), isNull);
      await crypto.cacheAesKey(SecretKey(expectedKey));
      final db = await helper.db;
      await db.insert(
        BackupConfig.table,
        BackupConfig.create(
          provider: BackupProvider.localFile,
          schedule: BackupSchedule.weekly,
          encrypted: true,
        ).toMap(),
      );
      if (phase == 'seed') return;
    }

    await helper.resetForTesting();
    final db = await helper.db;
    final rows = await db.query(BackupConfig.table);
    expect(rows, hasLength(1), reason: 'Ordinary SQLite data must survive');
    final config = BackupConfig.fromMap(rows.single);
    expect(config.provider, BackupProvider.localFile);
    expect(config.schedule, BackupSchedule.weekly);
    expect(config.encrypted, isTrue);

    crypto = _createCrypto();
    if (phase == 'restore') {
      // Run only after an actual Android backup/restore onto a clean install.
      expect(await crypto.readCachedAesKey(), isNull);
      await crypto.cacheAesKey(SecretKey(expectedKey));
    }
    final cached = await crypto.readCachedAesKey();
    expect(cached, isNotNull);
    if (cached == null) return;
    expect(await cached.extractBytes(), expectedKey);
    if (phase == 'all' || phase == 'restore') {
      await crypto.clearCachedAesKey();
      expect(await crypto.readCachedAesKey(), isNull);
    }
  });
}
