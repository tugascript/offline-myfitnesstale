import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'current_workout_plan_record_model.dart';
import 'entitlement_state_model.dart';
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

const String _databaseName = "app.db";
const int _databaseVersion = 2;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();

  factory DatabaseHelper() => _instance;
  static Database? _db;

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

  Future<Database> _initDb() async {
    final String path = join(await getDatabasesPath(), _databaseName);
    Logger('Database').info('Database path: $path');

    try {
      final db = await openDatabase(
        path,
        version: _databaseVersion,
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
      CurrentWorkoutPlanRecord.tableCreate,
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
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE ${WorkoutPlan.table} ADD COLUMN ${WorkoutPlanColumns.version.value} INTEGER NOT NULL DEFAULT 1',
      );
      await db.execute(
        'ALTER TABLE ${WorkoutPlanWeek.table} ADD COLUMN ${WorkoutPlanWeekColumns.planVersion.value} INTEGER NOT NULL DEFAULT 1',
      );
      await db.execute(
        'ALTER TABLE ${WorkoutPlanDay.table} ADD COLUMN ${WorkoutPlanDayColumns.planVersion.value} INTEGER NOT NULL DEFAULT 1',
      );
      await db.execute(
        'ALTER TABLE ${WorkoutPlanWorkout.table} ADD COLUMN ${WorkoutPlanWorkoutColumns.planVersion.value} INTEGER NOT NULL DEFAULT 1',
      );
      await db.execute(
        'ALTER TABLE ${WorkoutPlanRecord.table} ADD COLUMN ${WorkoutPlanRecordColumns.workoutPlanVersion.value} INTEGER NOT NULL DEFAULT 1',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_workout_plan_weeks_plan_version ON ${WorkoutPlanWeek.table} (${WorkoutPlanWeekColumns.workoutPlanId.value}, ${WorkoutPlanWeekColumns.planVersion.value}, ${WorkoutPlanWeekColumns.startWeek.value})',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_workout_plan_days_plan_version ON ${WorkoutPlanDay.table} (${WorkoutPlanDayColumns.workoutPlanId.value}, ${WorkoutPlanDayColumns.planVersion.value}, ${WorkoutPlanDayColumns.workoutPlanWeekId.value}, ${WorkoutPlanDayColumns.day.value})',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_workout_plan_workouts_plan_version ON ${WorkoutPlanWorkout.table} (${WorkoutPlanWorkoutColumns.workoutPlanId.value}, ${WorkoutPlanWorkoutColumns.planVersion.value}, ${WorkoutPlanWorkoutColumns.workoutPlanDayId.value}, ${WorkoutPlanWorkoutColumns.position.value})',
      );
    }

    return;
  }
}
