import 'package:sqflite/sqflite.dart';

import '../models/db.dart';
import '../models/enums.dart';
import '../models/exercise_model.dart';
import '../models/exercise_muscle_model.dart';
import '../models/muscle_group_model.dart';
import '../models/muscle_model.dart';
import '../models/repository.dart';
import '../models/utilities.dart';
import '../models/workout_model.dart';
import '../models/workout_muscle_group_model.dart';
import '../models/workout_muscle_model.dart';
import '../models/workout_set_exercise_model.dart';
import '../models/workout_set_model.dart';
import 'workout_set_exercise_option_service.dart';

class WorkoutSetExerciseInput {
  final int exerciseId;
  final int minReps;
  final int? maxReps;
  final (int, WorkoutSetExerciseDifficulty)? difficulty;
  final List<int>? alternativeExerciseIds;

  const WorkoutSetExerciseInput({
    required this.exerciseId,
    required this.minReps,
    this.maxReps,
    this.difficulty,
    this.alternativeExerciseIds,
  });
}

class WorkoutSetService {
  WorkoutSetService._();

  static final WorkoutSetService _instance = WorkoutSetService._();

  factory WorkoutSetService() => _instance;

  final Repository<WorkoutSet> _repository = Repository<WorkoutSet>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutSet.table,
    fromMap: (map) => WorkoutSet.fromMap(map),
  );

  final Repository<Workout> _workoutRepository = Repository<Workout>(
    databaseHelper: DatabaseHelper(),
    tableName: Workout.table,
    fromMap: (map) => Workout.fromMap(map),
  );

  final Repository<WorkoutSetExercise> _workoutSetExerciseRepository =
      Repository<WorkoutSetExercise>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutSetExercise.table,
    fromMap: (map) => WorkoutSetExercise.fromMap(map),
  );

  final JoinRepository<WorkoutMuscleGroup, MuscleGroup>
      _workoutMuscleGroupRepository =
      JoinRepository<WorkoutMuscleGroup, MuscleGroup>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutMuscleGroup.table,
    joinTableName: WorkoutMuscleGroup.table,
    fromMap: (map) => WorkoutMuscleGroup.fromMap(map),
    primaryKeys: WorkoutMuscleGroup.primaryKeys,
    joinFromMap: (map) => MuscleGroup.fromMap(map),
  );

  final JoinRepository<WorkoutMuscle, Muscle> _workoutMuscleRepository =
      JoinRepository<WorkoutMuscle, Muscle>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutMuscle.table,
    joinTableName: Muscle.table,
    fromMap: (map) => WorkoutMuscle.fromMap(map),
    primaryKeys: WorkoutMuscle.primaryKeys,
    joinFromMap: (map) => Muscle.fromMap(map),
  );

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<WorkoutSet>> getWorkoutSets(int workoutId) async {
    final WhereBuilder query = WhereBuilder();
    query.add('workoutId = ?', workoutId);

    return await _repository.selectMany(
      where: query.where,
      whereArgs: query.args,
      orderBy: 'position ASC',
    );
  }

  Future<WorkoutSet?> getWorkoutSet(int id) async {
    return await _repository.selectOne(id);
  }

  Future<WorkoutSet> createWorkoutSet({
    required int workoutId,
    required int minSets,
    required int recommendedRestSecs,
    required List<WorkoutSetExerciseInput> exercises,
    int? maxSets,
    int? maxRestSecs,
  }) async {
    final Workout? workout = await _workoutRepository.selectOne(workoutId);
    if (workout == null) {
      throw Exception('Workout not found');
    }

    final Database db = await _databaseHelper.db;

    final List<int> exerciseIds = exercises.map((e) => e.exerciseId).toList();
    final List<Map<String, Object?>> exerciseModels = await db.rawQuery(
      'SELECT * FROM ${Exercise.table} WHERE id IN (${"?, " * (exercises.length - 1)}?)',
      exerciseIds,
    );
    if (exerciseModels.length != exercises.length) {
      throw Exception('Invalid exercises');
    }

    final List<Map<String, Object?>> exerciseMuscleModels = await db.rawQuery(
      'SELECT * FROM ${ExerciseMuscle.table} WHERE exercise_id IN (${"?, " * (exerciseIds.length - 1)}?)',
      exerciseIds,
    );

    final int count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(id) FROM ${WorkoutSet.table} WHERE workout_id = ?',
      [workoutId],
    ))!;
    final int position = count + 1;
    final WorkoutSet workoutSet = WorkoutSet.create(
      position,
      workoutId,
      minSets,
      recommendedRestSecs,
      maxSets,
      maxRestSecs,
    );

    final WorkoutSetExerciseOptionService optionService =
        WorkoutSetExerciseOptionService();

    // Create exercises individually to get their IDs for options
    final List<int> exerciseIdsCreated = [];

    final int id = await db.transaction((trx) async {
      final int id = await _repository.insert(workoutSet, trx);

      for (int i = 0; i < exercises.length; i++) {
        final WorkoutSetExerciseInput input = exercises[i];
        final WorkoutSetExercise workoutSetExercise = WorkoutSetExercise.create(
          workoutId,
          id,
          i + 1,
          input.exerciseId,
          input.minReps,
          input.maxReps,
          input.difficulty != null
              ? (input.difficulty!.$2, input.difficulty!.$1)
              : null,
        );
        final int exerciseId = await _workoutSetExerciseRepository.insert(
          workoutSetExercise,
          trx,
        );
        exerciseIdsCreated.add(exerciseId);
      }

      final List<WorkoutMuscleGroup> workoutMuscleGroups = exerciseModels.map(
        (map) {
          final Exercise exercise = Exercise.fromMap(map);
          return WorkoutMuscleGroup.create(id, exercise.muscleGroupId);
        },
      ).toList();
      await _workoutMuscleGroupRepository.insertMany(workoutMuscleGroups, trx);

      final List<WorkoutMuscle> workoutMuscles = exerciseMuscleModels.map(
        (map) {
          final ExerciseMuscle exerciseMuscle = ExerciseMuscle.fromMap(map);
          return WorkoutMuscle.create(id, exerciseMuscle.muscleId);
        },
      ).toList();
      await _workoutMuscleRepository.insertMany(workoutMuscles, trx);

      return id;
    });

    // Create alternative exercise options after transaction
    for (int i = 0; i < exercises.length; i++) {
      final WorkoutSetExerciseInput input = exercises[i];
      if (input.alternativeExerciseIds != null &&
          input.alternativeExerciseIds!.isNotEmpty) {
        if (input.alternativeExerciseIds!.length > 3) {
          throw Exception('Maximum of 3 alternative exercises allowed');
        }
        final int workoutSetExerciseId = exerciseIdsCreated[i];
        for (int j = 0; j < input.alternativeExerciseIds!.length; j++) {
          await optionService.createWorkoutSetExerciseOption(
            workoutSetExerciseId: workoutSetExerciseId,
            exerciseId: input.alternativeExerciseIds![j],
            position: j + 1,
          );
        }
      }
    }

    return workoutSet.copyWith(id: id);
  }

  Future<WorkoutSet?> updateWorkoutSet(
    int id, {
    int? minSets,
    int? maxSets,
    int? recommendedRestSecs,
    int? maxRestSecs,
  }) async {
    final WorkoutSet? workoutSet = await _repository.selectOne(id);
    if (workoutSet == null) {
      return null;
    }

    final WorkoutSet updatedWorkoutSet = workoutSet.copyWith(
      minSets: minSets,
      maxSets: maxSets,
      recommendedRestSecs: recommendedRestSecs,
      maxRestSecs: maxRestSecs,
      updatedAt: DateUtilities.getNowUtcUnix(),
    );
    await _repository.update(updatedWorkoutSet);

    return updatedWorkoutSet;
  }

  Future<WorkoutSet?> updateWorkoutSetPosition(int id, int position) async {
    final WorkoutSet? workoutSet = await _repository.selectOne(id);
    if (workoutSet == null) {
      return null;
    }

    final Database db = await _databaseHelper.db;
    final int count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(id) FROM ${WorkoutSet.table} WHERE workout_id = ?',
      [workoutSet.workoutId],
    ))!;
    if (position < 1 || position > count) {
      throw Exception('Invalid position');
    }
    if (workoutSet.position == position) {
      return workoutSet;
    }

    final WorkoutSet updatedWorkoutSet = workoutSet.copyWith(
      position: position,
      updatedAt: DateUtilities.getNowUtcUnix(),
    );

    await db.transaction((trx) async {
      if (position > workoutSet.position) {
        await trx.rawUpdate(
          'UPDATE ${WorkoutSet.table} SET position = position - 1 WHERE workout_id = ? AND position > ? AND position <= ?',
          [workoutSet.workoutId, workoutSet.position, position],
        );
      } else {
        await trx.rawUpdate(
          'UPDATE ${WorkoutSet.table} SET position = position + 1 WHERE workout_id = ? AND position >= ? AND position < ?',
          [workoutSet.workoutId, position, workoutSet.position],
        );
      }

      await _repository.update(updatedWorkoutSet, trx);
    });

    return updatedWorkoutSet;
  }

  Future<bool> deleteWorkoutSet(int id) async {
    return await _repository.deleteOne(id);
  }
}
