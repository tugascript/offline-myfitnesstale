import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'constants/equipment_constants.dart';
import 'constants/exercise_constants.dart';
import 'entitlement_state_model.dart';
import 'enums.dart';
import 'equipment_model.dart';
import 'exercise_equipment_model.dart';
import 'exercise_model.dart';
import 'exercise_record_model.dart';
import 'profile_model.dart';
import 'reminders_config_model.dart';
import 'system_model.dart';
import 'weight_goal_model.dart';
import 'weight_record_model.dart';
import 'workout_model.dart';
import 'workout_plan_day_model.dart';
import 'workout_plan_day_record_model.dart';
import 'workout_plan_model.dart';
import 'workout_plan_record_model.dart';
import 'workout_plan_week_model.dart';
import 'workout_plan_week_record_model.dart';
import 'workout_plan_workout_model.dart';
import 'workout_plan_workout_record_model.dart';
import 'workout_record_model.dart';
import 'workout_set_exercise_model.dart';
import 'workout_set_exercise_option_model.dart';
import 'workout_set_exercise_record_model.dart';
import 'workout_set_model.dart';
import 'workout_set_record_model.dart';

const String _productionDatabaseName = "app.db";
const String _integrationTestDatabaseName = "integration_test.db";
const int _databaseVersion = 3;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();

  factory DatabaseHelper() => _instance;
  static Database? _db;
  String _databaseName = _productionDatabaseName;

  DatabaseHelper._();

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }

    _db = await _initDb();
    return _db!;
  }

  Future<void> initialize() async {
    try {
      await db;
    } catch (e) {
      Logger('Database').severe('Database initialization error: $e');
      rethrow;
    }
  }

  Future<void> resetForTesting() async {
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
    final path = join(
      await getDatabasesPath(),
      _integrationTestDatabaseName,
    );
    await deleteDatabase(path);
  }

  Future<Database> _initDb() async {
    final String path = join(await getDatabasesPath(), _databaseName);
    Logger('Database').info('Database path: $path');

    try {
      final db = await openDatabase(
        path,
        version: _databaseVersion,
        onConfigure: _onConfigure,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
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

  Future<void> _onCreate(Database db, int version) async {
    final List<String> createQueries = [
      Profile.tableCreate,
      System.tableCreate,
      RemindersConfig.tableCreate,
      WeightRecord.tableCreate,
      WeightGoal.tableCreate,
      Equipment.tableCreate,
      Exercise.tableCreate,
      ExerciseEquipment.tableCreate,
      ExerciseRecord.tableCreate,
      Workout.tableCreate,
      WorkoutSet.tableCreate,
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
      EntitlementStateModel.tableCreate,
    ];

    for (final query in createQueries) {
      for (final singleExecutable in query.split(';')) {
        final exec = singleExecutable.trim();
        if (exec.isEmpty) {
          continue;
        }

        await db.execute(exec);
      }
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await _backfillLegacyEquipmentSeed(db);
    }
  }

  Future<void> _backfillLegacyEquipmentSeed(Database db) async {
    final completedSystems = await db.query(
      System.table,
      columns: [SystemColumns.id.value],
      where: '${SystemColumns.initialSetup.value} = ?',
      whereArgs: [SetUpStatus.completed.value],
      limit: 1,
    );
    if (completedSystems.isEmpty) {
      return;
    }

    for (final name in kEquipmentNames) {
      await db.insert(
        Equipment.table,
        Equipment.create(
          name: name,
          createdBy: CreatedBy.system,
        ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    final equipmentRows = await db.query(
      Equipment.table,
      columns: [
        EquipmentColumns.id.value,
        EquipmentColumns.name.value,
      ],
    );
    final equipmentIdByName = <String, int>{
      for (final row in equipmentRows)
        row[EquipmentColumns.name.value]! as String:
            row[EquipmentColumns.id.value]! as int,
    };

    final exerciseRows = await db.query(
      Exercise.table,
      columns: [
        ExerciseColumns.id.value,
        ExerciseColumns.name.value,
      ],
      where: '${ExerciseColumns.createdBy.value} = ?',
      whereArgs: [CreatedBy.system.value],
    );
    final exerciseIdByName = <String, int>{
      for (final row in exerciseRows)
        row[ExerciseColumns.name.value]! as String:
            row[ExerciseColumns.id.value]! as int,
    };

    for (final exercise in kInitialExercises) {
      final exerciseId = exerciseIdByName[exercise.name];
      if (exerciseId == null) {
        continue;
      }
      for (final equipmentName in exercise.equipments) {
        final equipmentId = equipmentIdByName[equipmentName];
        if (equipmentId == null) {
          continue;
        }
        await db.insert(
          ExerciseEquipment.table,
          ExerciseEquipment.create(
            exerciseId: exerciseId,
            equipmentId: equipmentId,
          ).toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }
  }
}
