import 'package:sqflite/sqflite.dart';

import '../models/db.dart';
import '../models/enums.dart';
import '../models/exercise_model.dart';
import '../models/exercise_muscle_model.dart';
import '../models/muscle_group_model.dart';
import '../models/muscle_model.dart';
import '../models/repository.dart';
import '../models/utilities.dart';
import '../models/workout_muscle_group_model.dart';
import '../models/workout_muscle_model.dart';
import '../models/workout_set_exercise_model.dart';
import '../models/workout_set_model.dart';
import 'workout_set_exercise_option_service.dart';

class WorkoutSetExerciseService {
  WorkoutSetExerciseService._();

  static final WorkoutSetExerciseService _instance =
      WorkoutSetExerciseService._();

  factory WorkoutSetExerciseService() => _instance;

  final _repository = Repository<WorkoutSetExercise>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutSetExercise.table,
    fromMap: (map) => WorkoutSetExercise.fromMap(map),
  );

  final _workoutSetRepository = Repository<WorkoutSet>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutSet.table,
    fromMap: (map) => WorkoutSet.fromMap(map),
  );

  final _exerciseRepository = Repository<Exercise>(
    databaseHelper: DatabaseHelper(),
    tableName: Exercise.table,
    fromMap: (map) => Exercise.fromMap(map),
  );

  final _exerciseMuscleRepository = JoinRepository<ExerciseMuscle, Muscle>(
    databaseHelper: DatabaseHelper(),
    tableName: ExerciseMuscle.table,
    fromMap: (map) => ExerciseMuscle.fromMap(map),
    primaryKeys: ExerciseMuscle.primaryKeys,
    joinTableName: Muscle.table,
    joinFromMap: (map) => Muscle.fromMap(map),
  );

  final _workoutMuscleRepository = JoinRepository<WorkoutMuscle, Muscle>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutMuscle.table,
    fromMap: (map) => WorkoutMuscle.fromMap(map),
    primaryKeys: WorkoutMuscle.primaryKeys,
    joinTableName: Muscle.table,
    joinFromMap: (map) => Muscle.fromMap(map),
  );

  final _workoutMuscleGroupRepository =
      JoinRepository<WorkoutMuscleGroup, MuscleGroup>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutMuscleGroup.table,
    fromMap: (map) => WorkoutMuscleGroup.fromMap(map),
    primaryKeys: WorkoutMuscleGroup.primaryKeys,
    joinTableName: MuscleGroup.table,
    joinFromMap: (map) => MuscleGroup.fromMap(map),
  );

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<WorkoutSetExercise>> getWorkoutSetExercises(
    int workoutSetId,
  ) async {
    return await _repository.selectMany(
      where: 'workout_set_id = ?',
      whereArgs: [workoutSetId],
      orderBy: 'position ASC',
    );
  }

  Future<WorkoutSetExercise?> getWorkoutSetExercise(int id) async {
    return await _repository.selectOne(id);
  }

  Future<Map<int, List<WorkoutSetExercise>>>
      getWorkoutSetExercisesByWorkoutIdSetLoader(int workoutId) async {
    final List<WorkoutSetExercise> workoutSetExercises =
        await _repository.selectMany(
      where: 'workout_id = ?',
      whereArgs: [workoutId],
      orderBy: 'position ASC',
    );

    final Map<int, List<WorkoutSetExercise>> workoutSetExercisesMap = {};

    for (final workoutSetExercise in workoutSetExercises) {
      final List<WorkoutSetExercise> workoutSetExercisesList =
          workoutSetExercisesMap[workoutSetExercise.workoutSetId] ?? [];
      workoutSetExercisesList.add(workoutSetExercise);
      workoutSetExercisesMap[workoutSetExercise.workoutSetId] =
          workoutSetExercisesList;
    }

    return workoutSetExercisesMap;
  }

  Future<WorkoutSetExercise> createWorkoutSetExercise({
    required int workoutId,
    required int workoutSetId,
    required int exerciseId,
    required int minReps,
    int? maxReps,
    int? difficulty,
    WorkoutSetExerciseDifficulty? difficultyText,
    List<int>? alternativeExerciseIds,
  }) async {
    final WorkoutSet? workoutSet = await _workoutSetRepository.selectOne(
      workoutSetId,
    );
    if (workoutSet == null) {
      throw Exception('Workout set not found');
    }
    if (workoutSet.workoutId != workoutId) {
      throw Exception('Workout set does not belong to workout');
    }

    final Exercise? exercise = await _exerciseRepository.selectOne(exerciseId);
    if (exercise == null) {
      throw Exception('Exercise not found');
    }

    final List<ExerciseMuscle> exerciseMuscles =
        await _exerciseMuscleRepository.selectAllByPk1(exerciseId);

    final Database db = await _databaseHelper.db;
    final int count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(id) FROM ${WorkoutSetExercise.table} WHERE workout_set_id = ?',
      [workoutSetId],
    ))!;

    final int position = count + 1;
    final WorkoutSetExercise workoutSetExercise = WorkoutSetExercise.create(
      workoutId,
      workoutSetId,
      position,
      exerciseId,
      minReps,
      maxReps,
      difficulty != null && difficultyText != null
          ? (difficultyText, difficulty)
          : null,
    );

    final int id = await db.transaction((trx) async {
      final int id = await _repository.insert(workoutSetExercise, trx);
      if (exerciseMuscles.isNotEmpty) {
        await _workoutMuscleRepository.insertMany(
          exerciseMuscles
              .map((exerciseMuscle) => WorkoutMuscle.create(
                    workoutId,
                    exerciseMuscle.muscleId,
                  ))
              .toList(),
          trx,
        );
      }

      await _workoutMuscleGroupRepository.insert(
        WorkoutMuscleGroup.create(workoutId, exercise.muscleGroupId),
        trx,
      );

      return id;
    });

    // Create alternative exercise options if provided (after transaction)
    if (alternativeExerciseIds != null && alternativeExerciseIds.isNotEmpty) {
      if (alternativeExerciseIds.length > 3) {
        throw Exception('Maximum of 3 alternative exercises allowed');
      }
      final WorkoutSetExerciseOptionService optionService =
          WorkoutSetExerciseOptionService();
      for (int i = 0; i < alternativeExerciseIds.length; i++) {
        await optionService.createWorkoutSetExerciseOption(
          workoutSetExerciseId: id,
          exerciseId: alternativeExerciseIds[i],
          position: i + 1,
        );
      }
    }

    return workoutSetExercise.copyWith(id: id);
  }

  Future<WorkoutSetExercise> updateWorkoutSetExercise(
    int id, {
    int? minReps,
    int? maxReps,
    int? difficulty,
    WorkoutSetExerciseDifficulty? difficultyText,
  }) async {
    final WorkoutSetExercise? workoutSetExercise =
        await _repository.selectOne(id);
    if (workoutSetExercise == null) {
      throw Exception('Workout set exercise not found');
    }

    final WorkoutSetExercise updatedWorkoutSetExercise =
        workoutSetExercise.copyWith(
      minReps: minReps,
      maxReps: maxReps,
      difficultyValue: difficulty,
      difficultyType: difficultyText,
    );
    await _repository.update(updatedWorkoutSetExercise);
    return updatedWorkoutSetExercise;
  }

  Future<WorkoutSetExercise> updateWorkoutSetExercisePosition(
    int id,
    int position,
  ) async {
    final WorkoutSetExercise? workoutSetExercise =
        await _repository.selectOne(id);
    if (workoutSetExercise == null) {
      throw Exception('Workout set exercise not found');
    }

    final Database db = await _databaseHelper.db;
    final int count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(id) FROM ${WorkoutSetExercise.table} WHERE workout_set_id = ?',
      [workoutSetExercise.workoutSetId],
    ))!;

    if (position < 1 || position > count) {
      throw Exception('Invalid position');
    }
    if (workoutSetExercise.position == position) {
      return workoutSetExercise;
    }

    final WorkoutSetExercise updatedWorkoutSetExercise =
        workoutSetExercise.copyWith(
      position: position,
      updatedAt: DateUtilities.getNowUtcUnix(),
    );

    await db.transaction((trx) async {
      if (position > workoutSetExercise.position) {
        await trx.rawUpdate(
          'UPDATE ${WorkoutSetExercise.table} SET position = position - 1 WHERE workout_set_id = ? AND position > ? AND position <= ?',
          [
            workoutSetExercise.workoutSetId,
            workoutSetExercise.position,
            position
          ],
        );
      } else {
        await trx.rawUpdate(
          'UPDATE ${WorkoutSetExercise.table} SET position = position + 1 WHERE workout_set_id = ? AND position >= ? AND position < ?',
          [
            workoutSetExercise.workoutSetId,
            position,
            workoutSetExercise.position
          ],
        );
      }

      await _repository.update(updatedWorkoutSetExercise, trx);
    });

    return updatedWorkoutSetExercise;
  }

  Future<bool> deleteWorkoutSetExercise(int id) async {
    return await _repository.deleteOne(id);
  }
}
