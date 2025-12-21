import 'package:sqflite/sqflite.dart';

import '../models/db.dart';
import '../models/exercise_model.dart';
import '../models/repository.dart';
import '../models/utilities.dart';
import '../models/workout_set_exercise_model.dart';
import '../models/workout_set_exercise_option_model.dart';

class WorkoutSetExerciseOptionService {
  WorkoutSetExerciseOptionService._();

  static final WorkoutSetExerciseOptionService _instance =
      WorkoutSetExerciseOptionService._();

  factory WorkoutSetExerciseOptionService() => _instance;

  final _repository = Repository<WorkoutSetExerciseOption>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutSetExerciseOption.table,
    fromMap: (map) => WorkoutSetExerciseOption.fromMap(map),
  );

  final _workoutSetExerciseRepository = Repository<WorkoutSetExercise>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutSetExercise.table,
    fromMap: (map) => WorkoutSetExercise.fromMap(map),
  );

  final _exerciseRepository = Repository<Exercise>(
    databaseHelper: DatabaseHelper(),
    tableName: Exercise.table,
    fromMap: (map) => Exercise.fromMap(map),
  );

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<WorkoutSetExerciseOption>> getWorkoutSetExerciseOptions(
    int workoutSetExerciseId,
  ) async {
    return await _repository.selectMany(
      where: 'workout_set_exercise_id = ?',
      whereArgs: [workoutSetExerciseId],
      orderBy: 'position ASC',
    );
  }

  Future<WorkoutSetExerciseOption?> getWorkoutSetExerciseOption(int id) async {
    return await _repository.selectOne(id);
  }

  Future<Map<int, List<WorkoutSetExerciseOption>>>
      getWorkoutSetExerciseOptionsByWorkoutIdLoader(int workoutId) async {
    final Database db = await _databaseHelper.db;
    final List<Map<String, Object?>> results = await db.rawQuery('''
      SELECT wseo.* 
      FROM ${WorkoutSetExerciseOption.table} wseo
      INNER JOIN ${WorkoutSetExercise.table} wse ON wseo.workout_set_exercise_id = wse.id
      WHERE wse.workout_id = ?
      ORDER BY wseo.position ASC
    ''', [workoutId]);

    final List<WorkoutSetExerciseOption> options =
        results.map((map) => WorkoutSetExerciseOption.fromMap(map)).toList();

    final Map<int, List<WorkoutSetExerciseOption>> optionsMap = {};

    for (final option in options) {
      final List<WorkoutSetExerciseOption> optionsList =
          optionsMap[option.workoutSetExerciseId] ?? [];
      optionsList.add(option);
      optionsMap[option.workoutSetExerciseId] = optionsList;
    }

    return optionsMap;
  }

  Future<WorkoutSetExerciseOption> createWorkoutSetExerciseOption({
    required int workoutSetExerciseId,
    required int exerciseId,
    required int position,
  }) async {
    final WorkoutSetExercise? workoutSetExercise =
        await _workoutSetExerciseRepository.selectOne(workoutSetExerciseId);
    if (workoutSetExercise == null) {
      throw Exception('Workout set exercise not found');
    }

    final Exercise? exercise = await _exerciseRepository.selectOne(exerciseId);
    if (exercise == null) {
      throw Exception('Exercise not found');
    }

    // Validate position is between 1 and 3
    if (position < 1 || position > 3) {
      throw Exception('Position must be between 1 and 3');
    }

    // Check if we already have 3 options
    final Database db = await _databaseHelper.db;
    final int count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(id) FROM ${WorkoutSetExerciseOption.table} WHERE workout_set_exercise_id = ?',
      [workoutSetExerciseId],
    ))!;

    if (count >= 3) {
      throw Exception(
          'Maximum of 3 exercise options allowed per workout set exercise');
    }

    // Check if position is already taken
    final int? existingAtPosition = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(id) FROM ${WorkoutSetExerciseOption.table} WHERE workout_set_exercise_id = ? AND position = ?',
      [workoutSetExerciseId, position],
    ));

    if (existingAtPosition != null && existingAtPosition > 0) {
      throw Exception('Position $position is already taken');
    }

    final WorkoutSetExerciseOption option = WorkoutSetExerciseOption.create(
      workoutSetExerciseId,
      exerciseId,
      position,
    );

    final int id = await _repository.insert(option);
    return option.copyWith(id: id);
  }

  Future<WorkoutSetExerciseOption> updateWorkoutSetExerciseOptionPosition(
    int id,
    int position,
  ) async {
    final WorkoutSetExerciseOption? option = await _repository.selectOne(id);
    if (option == null) {
      throw Exception('Workout set exercise option not found');
    }

    // Validate position is between 1 and 3
    if (position < 1 || position > 3) {
      throw Exception('Position must be between 1 and 3');
    }

    if (option.position == position) {
      return option;
    }

    final Database db = await _databaseHelper.db;

    // Check if position is already taken
    final int? existingAtPosition = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(id) FROM ${WorkoutSetExerciseOption.table} WHERE workout_set_exercise_id = ? AND position = ? AND id != ?',
      [option.workoutSetExerciseId, position, id],
    ));

    if (existingAtPosition != null && existingAtPosition > 0) {
      throw Exception('Position $position is already taken');
    }

    final WorkoutSetExerciseOption updatedOption = option.copyWith(
      position: position,
      updatedAt: DateUtilities.getNowUtcUnix(),
    );

    await _repository.update(updatedOption);
    return updatedOption;
  }

  Future<bool> deleteWorkoutSetExerciseOption(int id) async {
    return await _repository.deleteOne(id);
  }
}
