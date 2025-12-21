  import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/equipment_constants.dart';
import '../constants/exercise_constants.dart';
import '../constants/muscle_constants.dart';
import '../constants/muscle_group_constants.dart';
import '../constants/workout_constants.dart';
import 'current_workout_plan_record_model.dart';
import 'equipment_model.dart';
import 'exercise_equipment_model.dart';
import 'exercise_model.dart';
import 'exercise_muscle_model.dart';
import 'exercise_record_model.dart';
import 'muscle_group_model.dart';
import 'muscle_model.dart';
import 'profile_model.dart';
import 'system_model.dart';
import 'weight_goal_model.dart';
import 'weight_record_model.dart';
import 'workout_model.dart';
import 'workout_muscle_group_model.dart';
import 'workout_muscle_model.dart';
import 'workout_plan_day_model.dart';
import 'workout_plan_day_record_model.dart';
import 'workout_plan_model.dart';
import 'workout_plan_record.dart';
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
    await db.execute(MuscleGroup.tableCreate);
    await db.execute(Muscle.tableCreate);
    await db.execute(Equipment.tableCreate);
    await db.execute(Exercise.tableCreate);
    await db.execute(ExerciseMuscle.tableCreate);
    await db.execute(ExerciseEquipment.tableCreate);
    await db.execute(ExerciseRecord.tableCreate);
    await db.execute(Workout.tableCreate);
    await db.execute(WorkoutMuscleGroup.tableCreate);
    await db.execute(WorkoutMuscle.tableCreate);
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
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE ${Exercise.table} ADD COLUMN is_favorite INTEGER NOT NULL DEFAULT 0',
      );
      Logger('Database')
          .info('Migrated database from version $oldVersion to 2');
    }
    if (oldVersion < 3) {
      // Create equipment table
      await db.execute(Equipment.tableCreate);
      // Create exercise_equipment junction table
      await db.execute(ExerciseEquipment.tableCreate);
      // Add difficulty column to exercises table (nullable)
      await db.execute(
        'ALTER TABLE ${Exercise.table} ADD COLUMN difficulty INTEGER',
      );
      Logger('Database')
          .info('Migrated database from version $oldVersion to 3');
    }
    if (oldVersion < 4) {
      await db.execute(ExerciseRecord.tableCreate);
      Logger('Database')
          .info('Migrated database from version $oldVersion to 4');
    }
  }

  Future<void> createDefaultData({
    bool withWorkouts = false,
  }) async {
    final inDb = await db;
    final muscleGroupMap = await MuscleGroupData.createMusclesGroups(
      inDb,
      MuscleGroup.table,
    );
    final muscleMap = await MuscleData.createMuscles(
      inDb,
      Muscle.table,
      MuscleGroup.table,
      muscleGroupMap,
    );

    final equipmentMap = await EquipmentData.createEquipments(
      inDb,
      Equipment.table,
    );
    final exerciseMap = await ExerciseData.createExercises(
      inDb,
      Exercise.table,
      ExerciseMuscle.table,
      Muscle.table,
      MuscleGroup.table,
      ExerciseEquipment.table,
      muscleGroupMap,
      muscleMap,
      equipmentMap,
    );

    if (withWorkouts) {
      await WorkoutData.createWorkouts(
        inDb,
        Workout.table,
        WorkoutSet.table,
        WorkoutSetExercise.table,
        exerciseMap,
      );
    }
  }
}
