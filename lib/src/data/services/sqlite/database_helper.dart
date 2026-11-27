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

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/sqlite/backup_config_model.dart';
import '../../models/sqlite/backup_model.dart';
import '../../models/sqlite/backup_passkeys_model.dart';
import '../../models/sqlite/daily_nutrition_log_model.dart';
import '../../models/sqlite/day_macro_goal_model.dart';
import '../../models/sqlite/equipment_model.dart';
import '../../models/sqlite/exercise_equipment_model.dart';
import '../../models/sqlite/exercise_model.dart';
import '../../models/sqlite/exercise_record_model.dart';
import '../../models/sqlite/food_model.dart';
import '../../models/sqlite/food_portion_model.dart';
import '../../models/sqlite/meal_log_item_model.dart';
import '../../models/sqlite/meal_log_model.dart';
import '../../models/sqlite/migration_model.dart';
import '../../models/sqlite/profile_model.dart';
import '../../models/sqlite/recipe_item_model.dart';
import '../../models/sqlite/recipe_model.dart';
import '../../models/sqlite/reminders_config_model.dart';
import '../../models/sqlite/strength_goal_model.dart';
import '../../models/sqlite/system_model.dart';
import '../../models/sqlite/week_macro_goal_model.dart';
import '../../models/sqlite/weight_goal_model.dart';
import '../../models/sqlite/weight_record_model.dart';
import '../../models/sqlite/workout_cardio_set_exercise_model.dart';
import '../../models/sqlite/workout_cardio_set_model.dart';
import '../../models/sqlite/workout_model.dart';
import '../../models/sqlite/workout_plan_day_model.dart';
import '../../models/sqlite/workout_plan_day_record_model.dart';
import '../../models/sqlite/workout_plan_model.dart';
import '../../models/sqlite/workout_plan_record_model.dart';
import '../../models/sqlite/workout_plan_week_model.dart';
import '../../models/sqlite/workout_plan_week_record_model.dart';
import '../../models/sqlite/workout_plan_workout_model.dart';
import '../../models/sqlite/workout_plan_workout_record_model.dart';
import '../../models/sqlite/workout_record_model.dart';
import '../../models/sqlite/workout_set_exercise_model.dart';
import '../../models/sqlite/workout_set_exercise_option_model.dart';
import '../../models/sqlite/workout_set_exercise_record_model.dart';
import '../../models/sqlite/workout_set_model.dart';
import '../../models/sqlite/workout_set_record_model.dart';
import '../../utils/dates.dart';
import '../../utils/enums.dart';
import 'database_migration.dart';

const String _productionDatabaseName = "app.db";
const String _integrationTestDatabaseName = "integration_test.db";
const int _databaseVersion = 1;
const String _initialSchemaMigrationName = "initial_schema";
const List<DatabaseMigration> _defaultMigrations = [];

final class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();

  factory DatabaseHelper() => _instance;
  static Database? _db;
  static Future<Database>? _initFuture;
  String _databaseName = _productionDatabaseName;
  int _targetVersion = _databaseVersion;
  List<DatabaseMigration> _registeredMigrations = _defaultMigrations;
  MigrationStepCallback? _onCreateExtraStepForTesting;

  DatabaseHelper._();

  Future<Database> get db {
    if (_db != null) {
      return Future.value(_db!);
    }

    if (_initFuture != null) {
      return _initFuture!;
    }

    final future = _initDb()
        .then((database) {
          _db = database;
          return database;
        })
        .whenComplete(() {
          _initFuture = null;
        });
    _initFuture = future;
    return future;
  }

  Future<void> initialize() async {
    try {
      await db;
    } catch (e) {
      Logger('Database').severe('Database initialization error: $e');
      rethrow;
    }
  }

  Future<List<Migration>> getMigrations() async {
    final database = await db;
    final rows = await database.query(
      Migration.table,
      orderBy: MigrationColumns.id.orderAsc,
    );
    return rows.map(Migration.fromMap).toList();
  }

  Future<void> rollbackTo(int targetVersion) async {
    final database = await db;
    final int currentVersion = await database.getVersion();
    if (targetVersion < 1 || targetVersion >= currentVersion) {
      throw ArgumentError.value(
        targetVersion,
        'targetVersion',
        'Target rollback version must be between 1 and ${currentVersion - 1} '
            '(current version is $currentVersion).',
      );
    }

    await _onDowngrade(database, currentVersion, targetVersion);
  }

  Future<void> resetForTesting({bool resetMigrations = true}) async {
    final pendingInit = _initFuture;
    if (pendingInit != null) {
      try {
        await pendingInit;
      } catch (_) {}
      _initFuture = null;
    }

    if (resetMigrations) {
      _targetVersion = _databaseVersion;
      _registeredMigrations = _defaultMigrations;
      _onCreateExtraStepForTesting = null;
    }

    if (_db == null) {
      return;
    }

    try {
      await _db!.close();
    } finally {
      _db = null;
    }
  }

  @visibleForTesting
  void configureMigrationsForTesting({
    int? targetVersion,
    List<DatabaseMigration>? migrations,
    MigrationStepCallback? onCreateExtraStep,
  }) {
    if (targetVersion != null) {
      if (targetVersion < 1) {
        throw ArgumentError.value(
          targetVersion,
          'targetVersion',
          'Database targetVersion must be >= 1.',
        );
      }
      _targetVersion = targetVersion;
    }
    if (migrations != null) {
      _registeredMigrations = List<DatabaseMigration>.unmodifiable(migrations);
    }
    _onCreateExtraStepForTesting = onCreateExtraStep;
  }

  @visibleForTesting
  Future<void> useIntegrationTestDatabaseForTesting() async {
    await resetForTesting();
    _databaseName = _integrationTestDatabaseName;
  }

  @visibleForTesting
  Future<void> useProductionDatabaseForTesting() async {
    await resetForTesting();
    _databaseName = _productionDatabaseName;
  }

  @visibleForTesting
  Future<void> deleteIntegrationTestDatabaseForTesting() async {
    if (_databaseName != _integrationTestDatabaseName) {
      throw StateError(
        'Refusing to delete a database unless the integration-test database '
        'is selected.',
      );
    }
    await resetForTesting();
    final path = join(await getDatabasesPath(), _integrationTestDatabaseName);
    await deleteDatabase(path);
  }

  Future<Database> _initDb() async {
    final String path = join(await getDatabasesPath(), _databaseName);
    Logger('Database').info('Database path: $path');

    try {
      final db = await openDatabase(
        path,
        onConfigure: _onConfigure,
        onOpen: _onOpen,
      );
      Logger('Database').info('Database opened successfully');
      return db;
    } catch (e) {
      Logger('Database').severe('Failed to open database: $e');
      rethrow;
    }
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onOpen(Database db) async {
    await _ensureMigrationsTable(db);
    final int currentVersion = await db.getVersion();

    if (currentVersion == 0) {
      await _onCreate(db, 1);
      if (_targetVersion > 1) {
        await _onUpgrade(db, 1, _targetVersion);
      }
      return;
    }

    await _ensureBaselineMigrationRecord(db, currentVersion);

    if (currentVersion < _targetVersion) {
      await _onUpgrade(db, currentVersion, _targetVersion);
    } else if (currentVersion > _targetVersion) {
      await _onDowngrade(db, currentVersion, _targetVersion);
    }
  }

  Future<void> _ensureMigrationsTable(Database db) async {
    await _executeStatements(db, Migration.tableCreate);
  }

  Future<void> _ensureBaselineMigrationRecord(
    Database db,
    int currentVersion,
  ) async {
    if (currentVersion != 1) {
      return;
    }

    final existing = await db.query(
      Migration.table,
      columns: [MigrationColumns.id.value],
      where: MigrationColumns.version.equal,
      whereArgs: [1],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      return;
    }

    final int now = DateUtilities.getNowUtcUnix();
    final baseline = Migration.create(
      version: 1,
      name: _initialSchemaMigrationName,
      status: MigrationStatus.applied,
      direction: MigrationDirection.up,
      appliedAt: now,
    );
    await db.insert(Migration.table, baseline.toMap());
  }

  Future<void> _onCreate(Database db, int version) async {
    final List<String> createQueries = [
      Profile.tableCreate,
      System.tableCreate,
      RemindersConfig.tableCreate,
      BackupConfig.tableCreate,
      BackupPasskeys.tableCreate,
      Backup.tableCreate,
      WeightRecord.tableCreate,
      WeightGoal.tableCreate,
      Equipment.tableCreate,
      Exercise.tableCreate,
      ExerciseEquipment.tableCreate,
      ExerciseRecord.tableCreate,
      Workout.tableCreate,
      WorkoutSet.tableCreate,
      WorkoutCardioSet.tableCreate,
      WorkoutCardioSetExercise.tableCreate,
      WorkoutSetExercise.tableCreate,
      WorkoutSetExerciseOption.tableCreate,
      WorkoutRecord.tableCreate,
      WorkoutSetRecord.tableCreate,
      WorkoutSetExerciseRecord.tableCreate,
      WorkoutPlan.tableCreate,
      WorkoutPlanWeek.tableCreate,
      WorkoutPlanDay.tableCreate,
      WorkoutPlanWorkout.tableCreate,
      WorkoutPlanRecord.tableCreate,
      WorkoutPlanWeekRecord.tableCreate,
      WorkoutPlanDayRecord.tableCreate,
      WorkoutPlanWorkoutRecord.tableCreate,
      Food.tableCreate,
      FoodPortion.tableCreate,
      Recipe.tableCreate,
      RecipeItem.tableCreate,
      WeekMacroGoal.tableCreate,
      DayMacroGoal.tableCreate,
      StrengthGoal.tableCreate,
      DailyNutritionLog.tableCreate,
      MealLog.tableCreate,
      MealLogItem.tableCreate,
    ];

    final int startedAt = DateUtilities.getNowUtcUnix();

    try {
      await db.transaction((txn) async {
        for (final query in createQueries) {
          await _executeStatements(txn, query);
        }

        if (_onCreateExtraStepForTesting != null) {
          await _onCreateExtraStepForTesting!(txn);
        }

        final int finishedAt = DateUtilities.getNowUtcUnix();
        final appliedMigration = Migration(
          version: version,
          name: _initialSchemaMigrationName,
          status: MigrationStatus.applied,
          direction: MigrationDirection.up,
          appliedAt: finishedAt,
          createdAt: startedAt,
          updatedAt: finishedAt,
        );
        await txn.insert(Migration.table, appliedMigration.toMap());
        await txn.execute('PRAGMA user_version = $version');
      });
    } catch (error, stackTrace) {
      await _recordMigrationFailure(
        db: db,
        version: version,
        name: _initialSchemaMigrationName,
        direction: MigrationDirection.up,
        startedAt: startedAt,
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    final List<DatabaseMigration> steps = [
      for (int v = oldVersion + 1; v <= newVersion; v++) _requireMigration(v),
    ];

    for (final migration in steps) {
      final int startedAt = DateUtilities.getNowUtcUnix();

      try {
        await db.transaction((txn) async {
          await migration.up(txn);

          final int finishedAt = DateUtilities.getNowUtcUnix();
          final appliedMigration = Migration(
            version: migration.version,
            name: migration.name,
            status: MigrationStatus.applied,
            direction: MigrationDirection.up,
            appliedAt: finishedAt,
            createdAt: startedAt,
            updatedAt: finishedAt,
          );
          await txn.insert(Migration.table, appliedMigration.toMap());
          await txn.execute('PRAGMA user_version = ${migration.version}');
        });
      } catch (error, stackTrace) {
        await _recordMigrationFailure(
          db: db,
          version: migration.version,
          name: migration.name,
          direction: MigrationDirection.up,
          startedAt: startedAt,
          error: error,
          stackTrace: stackTrace,
        );
        rethrow;
      }
    }
  }

  Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    if (newVersion < 1) {
      throw ArgumentError.value(
        newVersion,
        'newVersion',
        'Cannot downgrade database below version 1.',
      );
    }

    final List<DatabaseMigration> steps = [
      for (int v = oldVersion; v > newVersion; v--) _requireMigration(v),
    ];

    for (final migration in steps) {
      final int startedAt = DateUtilities.getNowUtcUnix();

      try {
        await db.transaction((txn) async {
          await migration.down(txn);

          final int finishedAt = DateUtilities.getNowUtcUnix();
          final rolledBackMigration = Migration(
            version: migration.version,
            name: migration.name,
            status: MigrationStatus.rolledBack,
            direction: MigrationDirection.down,
            rolledBackAt: finishedAt,
            createdAt: startedAt,
            updatedAt: finishedAt,
          );
          await txn.insert(Migration.table, rolledBackMigration.toMap());
          await txn.execute('PRAGMA user_version = ${migration.version - 1}');
        });
      } catch (error, stackTrace) {
        await _recordMigrationFailure(
          db: db,
          version: migration.version,
          name: migration.name,
          direction: MigrationDirection.down,
          startedAt: startedAt,
          error: error,
          stackTrace: stackTrace,
        );
        rethrow;
      }
    }
  }

  DatabaseMigration _requireMigration(int version) {
    for (final migration in _registeredMigrations) {
      if (migration.version == version) {
        return migration;
      }
    }
    throw StateError('No DatabaseMigration registered for version $version.');
  }

  Future<void> _recordMigrationFailure({
    required Database db,
    required int version,
    required String name,
    required MigrationDirection direction,
    required int startedAt,
    required Object error,
    required StackTrace stackTrace,
  }) async {
    Logger('Database').severe(
      'Migration v$version ($name, ${direction.value}) failed',
      error,
      stackTrace,
    );
    final int failedAt = DateUtilities.getNowUtcUnix();
    final failedMigration = Migration(
      version: version,
      name: name,
      status: MigrationStatus.failed,
      direction: direction,
      failedAt: failedAt,
      failure: error.toString(),
      createdAt: startedAt,
      updatedAt: failedAt,
    );
    try {
      await db.insert(Migration.table, failedMigration.toMap());
    } catch (recordError, recordStackTrace) {
      Logger('Database').severe(
        'Failed to persist migration failure record for v$version ($name, ${direction.value})',
        recordError,
        recordStackTrace,
      );
    }
  }

  Future<void> _executeStatements(DatabaseExecutor executor, String sql) async {
    for (final singleExecutable in sql.split(';')) {
      final exec = singleExecutable.trim();
      if (exec.isEmpty) {
        continue;
      }

      await executor.execute(exec);
    }
  }
}
