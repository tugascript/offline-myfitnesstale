import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'current_workout_plan_record_model.dart';
import 'equipment_model.dart';
import 'exercise_equipment_model.dart';
import 'exercise_model.dart';
import 'exercise_record_model.dart';
import 'profile_model.dart';
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
const int _databaseVersion = 4;

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
    await db.execute(Profile.tableCreate);
    await db.execute(System.tableCreate);
    await db.execute(WeightRecord.tableCreate);
    await db.execute(WeightGoal.tableCreate);
    await db.execute(Equipment.tableCreate);
    await db.execute(Exercise.tableCreate);
    await db.execute(ExerciseEquipment.tableCreate);
    await db.execute(ExerciseRecord.tableCreate);
    await db.execute(Workout.tableCreate);
    await db.execute(WorkoutSet.tableCreate);
    await db.execute(WorkoutSetExercise.tableCreate);
    await db.execute(WorkoutSetExerciseOption.tableCreate);
    await db.execute(WorkoutRecord.tableCreate);
    await db.execute(WorkoutSetRecord.tableCreate);
    await db.execute(WorkoutSetExerciseRecord.tableCreate);
    await db.execute(WorkoutPlan.tableCreate);
    await db.execute(WorkoutPlanWeek.tableCreate);
    await db.execute(WorkoutPlanDay.tableCreate);
    await db.execute(WorkoutPlanWorkout.tableCreate);
    await db.execute(WorkoutPlanRecord.tableCreate);
    await db.execute(WorkoutPlanWeekRecord.tableCreate);
    await db.execute(WorkoutPlanDayRecord.tableCreate);
    await db.execute(WorkoutPlanWorkoutRecord.tableCreate);
    await db.execute(CurrentWorkoutPlanRecord.tableCreate);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    return;
  }
}
