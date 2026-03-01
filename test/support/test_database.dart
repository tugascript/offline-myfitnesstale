import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:myfitnesstale/src/models/db.dart';
import 'package:myfitnesstale/src/models/current_workout_plan_record_model.dart';
import 'package:myfitnesstale/src/models/exercise_model.dart';
import 'package:myfitnesstale/src/models/workout_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_day_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_day_record_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_record_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_week_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_week_record_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_workout_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_workout_record_model.dart';
import 'package:myfitnesstale/src/models/workout_set_exercise_model.dart';
import 'package:myfitnesstale/src/models/workout_set_exercise_option_model.dart';
import 'package:myfitnesstale/src/models/workout_set_model.dart';

class TestDatabase {
  String? _originalDatabasesPath;
  String? _dbPath;
  Directory? _tempDir;

  Future<void> initialize() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    await DatabaseHelper().resetForTesting();

    _originalDatabasesPath = await databaseFactory.getDatabasesPath();
    _tempDir = await Directory.systemTemp.createTemp(
      'myfitnesstale_test_db_',
    );
    await databaseFactory.setDatabasesPath(_tempDir!.path);

    _dbPath = join(_tempDir!.path, 'app.db');
    await DatabaseHelper().initialize();
  }

  Future<Database> get db async => DatabaseHelper().db;

  Future<void> clearWorkoutTables() async {
    final database = await db;
    await database.transaction((txn) async {
      await txn.delete(WorkoutSetExerciseOption.table);
      await txn.delete(WorkoutSetExercise.table);
      await txn.delete(WorkoutSet.table);
      await txn.delete(Workout.table);
      await txn.delete(Exercise.table);
    });
  }

  Future<void> clearWorkoutPlanTables() async {
    final database = await db;
    await database.transaction((txn) async {
      await txn.delete(WorkoutPlanWorkoutRecord.table);
      await txn.delete(WorkoutPlanDayRecord.table);
      await txn.delete(WorkoutPlanWeekRecord.table);
      await txn.delete(WorkoutPlanRecord.table);
      await txn.delete(CurrentWorkoutPlanRecord.table);
      await txn.delete(WorkoutPlanWorkout.table);
      await txn.delete(WorkoutPlanDay.table);
      await txn.delete(WorkoutPlanWeek.table);
      await txn.delete(WorkoutPlan.table);
      await txn.delete(Workout.table);
      await txn.delete(Exercise.table);
    });
  }

  Future<void> destroy() async {
    await DatabaseHelper().resetForTesting();

    if (_dbPath != null) {
      await deleteDatabase(_dbPath!);
    }

    if (_originalDatabasesPath != null) {
      await databaseFactory.setDatabasesPath(_originalDatabasesPath!);
    }

    if (_tempDir != null && await _tempDir!.exists()) {
      await _tempDir!.delete(recursive: true);
    }
  }
}
