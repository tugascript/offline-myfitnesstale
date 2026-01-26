import 'package:logging/logging.dart';

import '../models/common.dart';
import '../models/db.dart';
import '../models/enums.dart';
import '../models/exercise_model.dart';
import '../models/repository.dart';
import '../models/utilities.dart';
import '../models/workout_model.dart';
import '../models/workout_set_exercise_model.dart';
import '../models/workout_set_exercise_option_model.dart';
import '../models/workout_set_model.dart';
import '../services/dtos/workout_set_dto.dart';
import 'common/errors.dart';
import 'common/result.dart';
import 'dtos/exercise_dto.dart';
import 'dtos/paginated_dto.dart';
import 'dtos/workout_dto.dart';
import 'dtos/workout_set_exercise_dto.dart';
import 'dtos/workout_set_exercise_option_dto.dart';

class WorkoutSetExerciseInput {
  final int exerciseId;
  final int minReps;
  final int? maxReps;
  final WorkoutSetExerciseDifficulty? difficulty;
  final List<int>? alternativeExerciseIds;

  const WorkoutSetExerciseInput({
    required this.exerciseId,
    required this.minReps,
    this.maxReps,
    this.difficulty,
    this.alternativeExerciseIds,
  });
}

class WorkoutService {
  WorkoutService._();

  static final WorkoutService instance = WorkoutService._();

  factory WorkoutService() => instance;

  final Logger _logger = Logger('Workout Service');

  final Repository<Workout> _repository = Repository(
    databaseHelper: DatabaseHelper(),
    tableName: Workout.table,
    fromMap: Workout.fromMap,
  );

  final Repository<WorkoutSet> _setRepository = Repository(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutSet.table,
    fromMap: WorkoutSet.fromMap,
  );

  final Repository<WorkoutSetExercise> _setExerciseRepository = Repository(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutSetExercise.table,
    fromMap: WorkoutSetExercise.fromMap,
  );

  final Repository<WorkoutSetExerciseOption> _setExerciseOptionRepository =
      Repository(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutSetExerciseOption.table,
    fromMap: WorkoutSetExerciseOption.fromMap,
  );

  final Repository<Exercise> _exerciseRepository = Repository(
    databaseHelper: DatabaseHelper(),
    tableName: Exercise.table,
    fromMap: Exercise.fromMap,
  );

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<
      Result<PaginatedDto<WorkoutDto, Workout>,
          ServiceError<OperationErrorTypes>>> getWorkouts({
    String? name,
    Difficulty? difficulty,
    MuscleGroup? muscleGroup,
    int limit = kDefaultLimit,
    int offset = kDefaultOffset,
  }) async {
    _logger.info('Getting workouts');
    final WhereBuilder query = WhereBuilder();

    if (name != null) {
      query.add('${WorkoutColumns.name.value} LIKE ?', '%$name%');
    }

    if (difficulty != null) {
      query.add('${WorkoutColumns.difficulty.value} = ?', difficulty.value);
    }

    if (muscleGroup != null) {
      query.add(
        '${WorkoutColumns.muscleGroups.value} LIKE ?',
        '%${muscleGroup.value}%',
      );
    }

    try {
      final List<Workout> workouts = await _repository.selectPaginated(
        limit: limit,
        offset: offset,
        where: query.where,
        whereArgs: query.args,
      );
      final int total = await _repository.count(
        where: query.where,
        whereArgs: query.args,
      );
      _logger.info('Got ${workouts.length} workouts');
      return ok(PaginatedDto<WorkoutDto, Workout>.mapData(
        data: workouts,
        mapper: (workout) => WorkoutDto.fromModel(workout),
        total: total,
        limit: limit,
        offset: offset,
      ));
    } catch (e) {
      _logger.severe('Failed to get workouts', e);
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to get workouts',
      ));
    }
  }

  Future<Result<WorkoutDto, ServiceError<SingleErrorTypes>>> getWorkout(
    int id,
  ) async {
    _logger.info('Getting workout with id $id');
    try {
      final Workout? workout = await _repository.selectOne(id);
      if (workout == null) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout not found',
        ));
      }

      final List<WorkoutSet> sets = await _setRepository.selectMany(
        where: '${WorkoutSetColumns.workoutId.value} = ?',
        whereArgs: [id],
        orderBy: '${WorkoutSetColumns.position.value} ASC',
      );
      if (sets.isEmpty) {
        _logger.info('Got workout with id $id');
        return ok(WorkoutDto.fromModel(workout));
      }

      final List<WorkoutSetExercise> setExercises =
          await _setExerciseRepository.selectMany(
        where: '${WorkoutSetExerciseColumns.workoutId.value} = ?',
        whereArgs: [id],
        orderBy:
            '${WorkoutSetExerciseColumns.workoutSetId.value} ASC, ${WorkoutSetExerciseColumns.position.value} ASC',
      );
      if (setExercises.isEmpty) {
        _logger.info('Got workout with id $id');
        return ok(WorkoutDto.fromModel(
          workout,
          sets: sets.map((s) => WorkoutSetDto.fromModel(s)).toList(),
        ));
      }

      final List<WorkoutSetExerciseOption> setExerciseOptions =
          await _setExerciseOptionRepository.selectMany(
        where: '${WorkoutSetExerciseOptionColumns.workoutId.value} = ?',
        whereArgs: [id],
        orderBy:
            '${WorkoutSetExerciseOptionColumns.workoutSetExerciseId.value} ASC, ${WorkoutSetExerciseOptionColumns.position.value} ASC',
      );
      final Set<int> exerciseIds = {
        ...setExercises.map((s) => s.exerciseId),
        ...setExerciseOptions.map((s) => s.exerciseId),
      };
      final List<Exercise> exercises = await _exerciseRepository.selectMany(
        where:
            '${ExerciseColumns.id.value} IN (${List.filled(exerciseIds.length, '?').join(", ")})',
        whereArgs: exerciseIds.toList(),
      );
      if (exerciseIds.length != exercises.length) {
        _logger.severe('Failed to get exercises for workout with id $id');
        return err(const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to get exercises for workout',
        ));
      }
      final Map<int, ExerciseDto> exercisesMap = exercises.fold({}, (map, e) {
        map[e.id!] = ExerciseDto.fromModel(e);
        return map;
      });

      final Map<int, List<WorkoutSetExerciseOptionDto>> optionsMap =
          setExerciseOptions.isEmpty
              ? {}
              : setExerciseOptions.fold(
                  {},
                  (map, s) => map
                    ..update(
                      s.workoutSetExerciseId,
                      (value) => value
                        ..add(
                          WorkoutSetExerciseOptionDto.fromModel(
                            s,
                            exercise: exercisesMap[s.exerciseId],
                          ),
                        ),
                      ifAbsent: () => [
                        WorkoutSetExerciseOptionDto.fromModel(
                          s,
                          exercise: exercisesMap[s.exerciseId],
                        ),
                      ],
                    ),
                );

      final Map<int, List<WorkoutSetExerciseDto>> setExercisesMap =
          setExercises.fold(
        {},
        (map, s) => map
          ..update(
            s.workoutSetId,
            (value) => value
              ..add(
                WorkoutSetExerciseDto.fromModel(
                  s,
                  exercise: exercisesMap[s.exerciseId],
                  options: optionsMap[s.id],
                ),
              ),
            ifAbsent: () => [
              WorkoutSetExerciseDto.fromModel(
                s,
                exercise: exercisesMap[s.exerciseId],
                options: optionsMap[s.id],
              ),
            ],
          ),
      );
      return ok(
        WorkoutDto.fromModel(
          workout,
          sets: sets
              .map(
                (s) => WorkoutSetDto.fromModel(
                  s,
                  exercises: setExercisesMap[s.id!],
                ),
              )
              .toList(),
        ),
      );
    } catch (e) {
      _logger.severe('Failed to get workout with id $id', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to get workout',
      ));
    }
  }

  Future<Result<WorkoutDto, ServiceError<OperationErrorTypes>>> createWorkout({
    required String name,
    required Difficulty difficulty,
    String? description,
    PictureData? picture,
    VideoData? video,
  }) async {
    _logger.info('Creating workout with name $name');
    try {
      final Workout workout = Workout.create(
        name: name,
        difficulty: difficulty,
        muscleGroups: <MuscleGroup>{},
        description: description,
        picture: picture,
        video: video,
      );
      final int id = await _repository.insert(workout);
      _logger.info('Created workout with id $id');
      return ok(WorkoutDto.fromModel(workout.copyWith(id: id)));
    } catch (e) {
      _logger.severe('Failed to create workout with name $name', e);
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to create workout',
      ));
    }
  }

  Future<Result<WorkoutDto, ServiceError<SingleErrorTypes>>> updateWorkout({
    required int id,
    String? name,
    Difficulty? difficulty,
    String? description,
    PictureData? picture,
    VideoData? video,
  }) async {
    _logger.info('Updating workout with id $id');
    try {
      final Workout? workout = await _repository.selectOne(id);
      if (workout == null) {
        _logger.info('Workout with id $id not found');
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout not found',
        ));
      }

      final Workout updatedWorkout = workout.copyWith(
        name: name,
        difficulty: difficulty,
        description: description,
        picture: picture,
        video: video,
        updatedAt: DateUtilities.getNowUtcUnix(),
      );
      await _repository.update(updatedWorkout);
      _logger.info('Updated workout with id $id');
      return ok(WorkoutDto.fromModel(updatedWorkout));
    } catch (e) {
      _logger.severe('Failed to update workout with id $id', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to update workout',
      ));
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>> deleteWorkout(
      int id) async {
    _logger.info('Deleting workout with id $id');
    try {
      final bool deleted = await _repository.deleteOne(id);
      if (!deleted) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout not found',
        ));
      }
      _logger.info('Deleted workout with id $id');
      return ok(null);
    } catch (e) {
      _logger.severe('Failed to delete workout with id $id', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to delete workout',
      ));
    }
  }

  Future<Result<WorkoutSetDto, ServiceError<SingleErrorTypes>>>
      createWorkoutSet({
    required int workoutId,
    required WorkoutSetType setType,
    required int minSets,
    required int recommendedRestSecs,
    required List<WorkoutSetExerciseInput> exercises,
    int? position,
    int? maxSets,
    int? maxRestSecs,
  }) async {
    _logger.info('Creating workout set with workout id $workoutId');
    if (exercises.isEmpty) {
      _logger.info('No exercises provided');
      return err(const ServiceError(
        type: SingleErrorTypes.invalidInput,
        description: 'No exercises provided',
      ));
    }

    final Set<int> exerciseIdSet = <int>{};
    for (final exercise in exercises) {
      exerciseIdSet.add(exercise.exerciseId);

      if (exercise.alternativeExerciseIds != null) {
        for (final alternativeExerciseId in exercise.alternativeExerciseIds!) {
          exerciseIdSet.add(alternativeExerciseId);
        }
      }
    }

    try {
      final workout = await _repository.selectOne(workoutId);
      if (workout == null) {
        _logger.info('Workout with id $workoutId not found');
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout with id $workoutId not found',
        ));
      }

      final List<Exercise> exerciseModels =
          await _exerciseRepository.selectMany(
        where: 'id IN (${List.filled(exerciseIdSet.length, '? ').join(', ')})',
        whereArgs: exerciseIdSet.toList(),
      );
      if (exerciseModels.length != exerciseIdSet.length) {
        _logger.info('Invalid exercise ids');
        return err(const ServiceError(
          type: SingleErrorTypes.invalidInput,
          description: 'Invalid exercise ids',
        ));
      }

      final WhereBuilder setQuery = WhereBuilder();
      setQuery.add('workoutId = ?', workoutId);
      final List<WorkoutSet> workoutSets = await _setRepository.selectMany(
        where: setQuery.where,
        whereArgs: setQuery.args,
        orderBy: 'position ASC',
      );
      final int newPosition = workoutSets.length + 1;
      final int setPosition = position ?? newPosition;

      final (
        WorkoutSet set,
        List<WorkoutSetExercise> setExercises,
        Map<int, List<WorkoutSetExerciseOption>> setExerciseOptions,
      ) = await (await _databaseHelper.db).transaction((txn) async {
        final WorkoutSet workoutSet = WorkoutSet.create(
          position: setPosition,
          workoutId: workoutId,
          setType: setType,
          minSets: minSets,
          maxSets: maxSets,
          recommendedRestSecs: recommendedRestSecs,
          maxRestSecs: maxRestSecs,
        );
        final setId = await _setRepository.insert(workoutSet, txn);

        if (setPosition < newPosition) {
          await txn.rawUpdate("""
            UPDATE ${WorkoutSet.table}
            SET position = position + 1
            WHERE workoutId = ? AND position >= ?;
          """, [workoutId, setPosition]);
        }

        final List<WorkoutSetExercise> setExercises = [];
        final Map<int, List<WorkoutSetExerciseOption>> setExerciseOptions = {};
        for (int i = 0; i < exercises.length; i++) {
          final input = exercises[i];
          final workoutSetExercise = WorkoutSetExercise.create(
            position: i + 1,
            workoutId: workoutId,
            workoutSetId: setId,
            exerciseId: input.exerciseId,
            minReps: input.minReps,
            maxReps: input.maxReps,
            difficulty: input.difficulty,
          );
          final setExerciseId = await _setExerciseRepository.insert(
            workoutSetExercise,
            txn,
          );
          setExercises.add(workoutSetExercise.copyWith(id: setExerciseId));

          if (input.alternativeExerciseIds != null) {
            setExerciseOptions[setExerciseId] = <WorkoutSetExerciseOption>[];

            for (int j = 0; j < input.alternativeExerciseIds!.length; j++) {
              final alternativeExerciseId = input.alternativeExerciseIds![j];
              final workoutSetExerciseOption = WorkoutSetExerciseOption.create(
                workoutId: workoutId,
                workoutSetId: setId,
                workoutSetExerciseId: setExerciseId,
                exerciseId: alternativeExerciseId,
                position: j + 1,
              );
              final setExerciseOptionId =
                  await _setExerciseOptionRepository.insert(
                workoutSetExerciseOption,
                txn,
              );
              setExerciseOptions[setExerciseId]!.add(
                workoutSetExerciseOption.copyWith(id: setExerciseOptionId),
              );
            }
          }
        }

        return (workoutSet, setExercises, setExerciseOptions);
      });

      final exerciseMap = Map.fromEntries(
        exerciseModels.map((e) => MapEntry(e.id!, ExerciseDto.fromModel(e))),
      );

      return ok(
        WorkoutSetDto.fromModel(
          set,
          exercises: setExercises
              .map(
                (se) => WorkoutSetExerciseDto.fromModel(
                  se,
                  exercise: exerciseMap[se.exerciseId],
                  options: setExerciseOptions[se.id]
                      ?.map(
                        (so) => WorkoutSetExerciseOptionDto.fromModel(
                          so,
                          exercise: exerciseMap[so.exerciseId],
                        ),
                      )
                      .toList(),
                ),
              )
              .toList(),
        ),
      );
    } catch (e) {
      _logger.severe(
        'Failed to create workout set with workout id $workoutId',
        e,
      );
      return err(ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: "An error was thrown ${e.toString()}",
      ));
    }
  }

  Future<Result<List<WorkoutSetDto>, ServiceError<OperationErrorTypes>>>
      getWorkoutSets(
    int workoutId,
  ) async {
    final WhereBuilder query = WhereBuilder();
    query.add('workout_id = ?', workoutId);

    try {
      final List<WorkoutSet> workoutSets = await _setRepository.selectMany(
        where: query.where,
        whereArgs: query.args,
        orderBy: 'position ASC',
      );
      final List<WorkoutSetExercise> setExercises =
          await _setExerciseRepository.selectMany(
        where: query.where,
        whereArgs: query.args,
        orderBy: 'workout_set_id ASC, position ASC',
      );
      final List<WorkoutSetExerciseOption> setExerciseOptions =
          await _setExerciseOptionRepository.selectMany(
        where: query.where,
        whereArgs: query.args,
        orderBy: 'workoutSetExerciseId ASC, position ASC',
      );

      final Set<int> exerciseIds = <int>{
        ...setExercises.map((e) => e.exerciseId),
        ...setExerciseOptions.map((e) => e.exerciseId),
      };
      final Map<int, List<WorkoutSetExercise>> setExerciseMap =
          setExercises.fold<Map<int, List<WorkoutSetExercise>>>(
        {},
        (prevVal, se) {
          if (prevVal[se.workoutSetId] != null) {
            prevVal[se.workoutSetId]!.add(se);
            return prevVal;
          }

          prevVal[se.workoutSetId] = [se];
          return prevVal;
        },
      );

      final Map<int, List<WorkoutSetExerciseOption>> setExerciseOptionsMap =
          setExerciseOptions.fold<Map<int, List<WorkoutSetExerciseOption>>>(
        {},
        (prevVal, seo) {
          if (prevVal[seo.workoutSetExerciseId] != null) {
            prevVal[seo.workoutSetExerciseId]!.add(seo);
            return prevVal;
          }

          prevVal[seo.workoutSetExerciseId] = [seo];
          return prevVal;
        },
      );
      final List<Exercise> exercises = await _exerciseRepository.selectMany(
        where: 'id IN (${List.filled(exerciseIds.length, '?').join(", ")})',
        whereArgs: exerciseIds.toList(),
      );
      final Map<int, ExerciseDto> exerciseMap = Map.fromEntries(
        exercises.map((e) => MapEntry(e.id!, ExerciseDto.fromModel(e))),
      );

      return ok(
        workoutSets
            .map(
              (ws) => WorkoutSetDto.fromModel(
                ws,
                exercises: setExerciseMap[ws.id!]
                    ?.map(
                      (se) => WorkoutSetExerciseDto.fromModel(
                        se,
                        exercise: exerciseMap[se.exerciseId],
                        options: setExerciseOptionsMap[se.id]
                            ?.map(
                              (so) => WorkoutSetExerciseOptionDto.fromModel(
                                so,
                                exercise: exerciseMap[so.exerciseId],
                              ),
                            )
                            .toList(),
                      ),
                    )
                    .toList(),
              ),
            )
            .toList(),
      );
    } catch (e) {
      _logger.severe('Error getting workout sets', e);
      return err(ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Error getting workout sets: ${e.toString()}',
      ));
    }
  }

  Future<Result<WorkoutSetDto, ServiceError<SingleErrorTypes>>> getWorkoutSet(
    int workoutSetId,
  ) async {
    try {
      final WorkoutSet? workoutSet =
          await _setRepository.selectOne(workoutSetId);
      if (workoutSet == null) {
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Workout set with id: $workoutSetId not found',
          ),
        );
      }

      final List<WorkoutSetExercise> setExercises =
          await _setExerciseRepository.selectMany(
        where: 'workout_set_id = ?',
        whereArgs: [workoutSetId],
      );

      final Set<int> exerciseIds = <int>{};
      final Map<int, List<WorkoutSetExercise>> setExerciseMap = {};
      for (final setExercise in setExercises) {
        if (setExerciseMap[setExercise.workoutSetId] != null) {
          setExerciseMap[setExercise.workoutSetId]!.add(setExercise);
        } else {
          setExerciseMap[setExercise.workoutSetId] = [setExercise];
        }

        exerciseIds.add(setExercise.exerciseId);
      }

      final List<WorkoutSetExerciseOption> setExerciseOptions =
          await _setExerciseOptionRepository.selectMany(
        where: 'workout_set_id = ?',
        whereArgs: [workoutSetId],
      );

      final Map<int, List<WorkoutSetExerciseOption>> setExerciseOptionsMap = {};
      for (final setExerciseOption in setExerciseOptions) {
        if (setExerciseOptionsMap[setExerciseOption.workoutSetExerciseId] !=
            null) {
          setExerciseOptionsMap[setExerciseOption.workoutSetExerciseId]!
              .add(setExerciseOption);
        } else {
          setExerciseOptionsMap[setExerciseOption.workoutSetExerciseId] = [
            setExerciseOption
          ];
        }

        exerciseIds.add(setExerciseOption.exerciseId);
      }

      final List<Exercise> exercises = await _exerciseRepository.selectMany(
        where: 'id IN (${List.filled(exerciseIds.length, '?').join(", ")})',
        whereArgs: exerciseIds.toList(),
      );
      final Map<int, ExerciseDto> exerciseMap = Map.fromEntries(
        exercises.map((e) => MapEntry(e.id!, ExerciseDto.fromModel(e))),
      );

      return ok(
        WorkoutSetDto.fromModel(
          workoutSet,
          exercises: setExerciseMap[workoutSet.id!]
              ?.map(
                (se) => WorkoutSetExerciseDto.fromModel(
                  se,
                  exercise: exerciseMap[se.exerciseId],
                  options: setExerciseOptionsMap[se.id]
                      ?.map(
                        (so) => WorkoutSetExerciseOptionDto.fromModel(
                          so,
                          exercise: exerciseMap[so.exerciseId],
                        ),
                      )
                      .toList(),
                ),
              )
              .toList(),
        ),
      );
    } catch (e) {
      _logger.severe('Error getting workout set', e);
      return err(
        ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Error getting workout set: ${e.toString()}',
        ),
      );
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>> deleteWorkoutSet(
    int workoutSetId,
  ) async {
    try {
      final workoutSet = await _setRepository.selectOne(workoutSetId);
      if (workoutSet == null) {
        _logger.info('Workout set with id $workoutSetId not found');
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout set with id $workoutSetId not found',
        ));
      }

      final position = workoutSet.position;
      final setCount = await _setRepository.count(
        where: 'workout_id = ?',
        whereArgs: [workoutSet.workoutId],
      );

      if (position == setCount) {
        final deleted = await _setRepository.deleteOne(workoutSetId);
        if (!deleted) {
          return err(ServiceError(
            type: SingleErrorTypes.operationFailure,
            description: 'Error deleting workout set: $workoutSetId',
          ));
        }

        return ok(null);
      }

      final deleted = await (await _databaseHelper.db).transaction(
        (txn) async {
          final deleted = await _setRepository.deleteOne(workoutSetId, txn);
          if (!deleted) {
            return false;
          }

          await txn.rawQuery(
            "UPDATE ${WorkoutSet.table} SET position = position - 1 WHERE workout_id = ? AND position > ?",
            [workoutSet.workoutId, position],
          );
          return true;
        },
      );
      if (!deleted) {
        _logger.warning('Workout set with id $workoutSetId not deleted');
        return err(ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Error deleting workout set: $workoutSetId',
        ));
      }

      _logger.info('Workout set with id $workoutSetId deleted successfully');
      return ok(null);
    } catch (e) {
      _logger.severe('Error deleting workout set', e);
      return err(
        ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Error deleting workout set: ${e.toString()}',
        ),
      );
    }
  }

  Future<Result<WorkoutSetDto, ServiceError<SingleErrorTypes>>>
      updateWorkoutSet({
    required int workoutSetId,
    WorkoutSetType? setType,
    int? minSets,
    int? recommendedRestSecs,
    int? position,
    int? maxSets,
    int? maxRestSecs,
  }) async {
    try {
      final workoutSet = await _setRepository.selectOne(workoutSetId);
      if (workoutSet == null) {
        _logger.info('Workout set with id $workoutSetId not found');
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout set with id $workoutSetId not found',
        ));
      }

      final updatedWorkoutSet = workoutSet.copyWith(
        setType: setType,
        minSets: minSets,
        recommendedRestSecs: recommendedRestSecs,
        position: position,
        maxSets: maxSets,
        maxRestSecs: maxRestSecs,
      );

      final updated = await _setRepository.update(updatedWorkoutSet);
      if (!updated) {
        _logger.warning('Workout set with id $workoutSetId not updated');
        return err(ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Error updating workout set: $workoutSetId',
        ));
      }

      _logger.info('Workout set with id $workoutSetId updated successfully');
      return ok(WorkoutSetDto.fromModel(updatedWorkoutSet));
    } catch (e) {
      _logger.severe('Error updating workout set', e);
      return err(
        ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Error updating workout set: ${e.toString()}',
        ),
      );
    }
  }

  Future<Result<WorkoutSetDto, ServiceError<SingleErrorTypes>>>
      updateWorkoutSetPosition({
    required int workoutSetId,
    required int position,
  }) async {
    _logger.info("Updating workout set with id: $workoutSetId position");
    try {
      final set = await _setRepository.selectOne(workoutSetId);
      if (set == null) {
        _logger.warning('Workout set with id $workoutSetId not found');
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout set with id $workoutSetId not found',
        ));
      }

      if (position == set.position) {
        _logger.info('Position already set');
        return ok(WorkoutSetDto.fromModel(set));
      }

      final count = await _setRepository.count(
        where: 'workout_id = ?',
        whereArgs: [set.workoutId],
      );
      if (position < 1 || position > count) {
        _logger.warning('Invalid position');
        return err(const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Position out of bounds',
        ));
      }

      final oldPosition = set.position;
      final updatedSet = set.copyWith(position: position);
      await (await _databaseHelper.db).transaction((txn) async {
        if (oldPosition < position) {
          await txn.rawUpdate(
            """
            UPDATE ${WorkoutSet.table} SET position = position - 1
            WHERE workout_id = ? AND position > ? AND position <= ?;
            """,
            [set.workoutId, oldPosition, position],
          );
        } else {
          await txn.rawUpdate(
            """
            UPDATE ${WorkoutSet.table} SET position = position + 1
            WHERE workout_id = ? AND position >= ? AND position < ?;
            """,
            [set.workoutId, position, oldPosition],
          );
        }
        await _setRepository.update(updatedSet, txn);
      });

      _logger.info('Workout set with id $workoutSetId updated successfully');
      return ok(WorkoutSetDto.fromModel(updatedSet));
    } catch (e) {
      _logger.severe('Error updating workout set', e);
      return err(
        ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Error updating workout set: ${e.toString()}',
        ),
      );
    }
  }

  Future<Result<List<WorkoutSetExerciseDto>, ServiceError<SingleErrorTypes>>>
      getWorkoutSetExercises(
    int workoutSetId,
  ) async {
    _logger.info("Getting workout set exercises with id: $workoutSetId");
    try {
      final workoutSetExercises = await _setExerciseRepository.selectMany(
        where: 'workout_set_id = ?',
        whereArgs: [workoutSetId],
        orderBy: 'position ASC',
      );
      if (workoutSetExercises.isEmpty) {
        return ok([]);
      }

      final exerciseOptions = await _setExerciseOptionRepository.selectMany(
        where: '${WorkoutSetExerciseOptionColumns.workoutSetId.name} = ?',
        whereArgs: [workoutSetId],
        orderBy:
            '${WorkoutSetExerciseOptionColumns.workoutSetExerciseId.name} ASC, ${WorkoutSetExerciseOptionColumns.position.name} ASC',
      );

      final exerciseIds = {
        ...workoutSetExercises.map((e) => e.exerciseId),
        ...exerciseOptions.map((e) => e.exerciseId),
      };
      final exercises = await _exerciseRepository.selectMany(
        where: 'id IN (${List.filled(exerciseIds.length, '?').join(", ")})',
        whereArgs: exerciseIds.toList(),
      );
      if (exercises.length != exerciseIds.length) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Some exercises with not found',
        ));
      }

      final exerciseMap = Map.fromEntries(
        exercises.map(
          (exercise) => MapEntry(
            exercise.id!,
            ExerciseDto.fromModel(exercise),
          ),
        ),
      );
      if (exerciseOptions.isEmpty) {
        return ok(
          workoutSetExercises
              .map(
                (e) => WorkoutSetExerciseDto.fromModel(
                  e,
                  exercise: exerciseMap[e.exerciseId]!,
                ),
              )
              .toList(),
        );
      }

      final Map<int, List<WorkoutSetExerciseOptionDto>> optionsMap = {};
      for (final o in exerciseOptions) {
        if (optionsMap.containsKey(o.workoutSetExerciseId)) {
          optionsMap[o.workoutSetExerciseId]!.add(
            WorkoutSetExerciseOptionDto.fromModel(
              o,
              exercise: exerciseMap[o.exerciseId],
            ),
          );
        } else {
          optionsMap[o.workoutSetExerciseId] = [
            WorkoutSetExerciseOptionDto.fromModel(
              o,
              exercise: exerciseMap[o.exerciseId],
            ),
          ];
        }
      }

      return ok(
        workoutSetExercises
            .map(
              (e) => WorkoutSetExerciseDto.fromModel(
                e,
                exercise: exerciseMap[e.exerciseId],
                options: optionsMap[e.id],
              ),
            )
            .toList(),
      );
    } catch (e) {
      _logger.severe('Error getting workout set exercises', e);
      return err(
        ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Error getting workout set exercises: ${e.toString()}',
        ),
      );
    }
  }

  Future<Result<WorkoutSetExerciseDto, ServiceError<SingleErrorTypes>>>
      getWorkoutSetExercise(
    int workoutSetExerciseId,
  ) async {
    try {
      final workoutSetExercise = await _setExerciseRepository.selectOne(
        workoutSetExerciseId,
      );
      if (workoutSetExercise == null) {
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description:
                'Workout set exercise with id: $workoutSetExerciseId not found',
          ),
        );
      }

      final exerciseOptions = await _setExerciseOptionRepository.selectMany(
        where: 'workout_set_exercise_id = ?',
        whereArgs: [workoutSetExerciseId],
        orderBy: 'position ASC',
      );
      if (exerciseOptions.isEmpty) {
        final exercise = await _exerciseRepository.selectOne(
          workoutSetExercise.exerciseId,
        );
        if (exercise == null) {
          return err(
            ServiceError(
              type: SingleErrorTypes.notFound,
              description:
                  'Exercise with id: ${workoutSetExercise.exerciseId} not found',
            ),
          );
        }

        return ok(WorkoutSetExerciseDto.fromModel(
          workoutSetExercise,
          exercise: ExerciseDto.fromModel(exercise),
        ));
      }

      final exerciseIds = {
        workoutSetExercise.exerciseId,
        ...exerciseOptions.map((e) => e.exerciseId)
      };
      final exercises = await _exerciseRepository.selectMany(
        where: 'id IN (${List.filled(exerciseIds.length, '? ').join(", ")})',
        whereArgs: exerciseIds.toList(),
      );
      if (exercises.length != exerciseIds.length) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Some exercises with not found',
        ));
      }

      final exerciseMap = Map.fromEntries(
        exercises.map(
          (exercise) => MapEntry(
            exercise.id!,
            ExerciseDto.fromModel(exercise),
          ),
        ),
      );
      _logger.info(
          'Workout set exercise with id $workoutSetExerciseId retrieved successfully');
      return ok(WorkoutSetExerciseDto.fromModel(
        workoutSetExercise,
        exercise: exerciseMap[workoutSetExercise.exerciseId],
        options: exerciseOptions
            .map(
              (exerciseOption) => WorkoutSetExerciseOptionDto.fromModel(
                exerciseOption,
                exercise: exerciseMap[exerciseOption.exerciseId],
              ),
            )
            .toList(),
      ));
    } catch (e) {
      _logger.severe('Error getting workout set exercise', e);
      return err(
        ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Error getting workout set exercise: ${e.toString()}',
        ),
      );
    }
  }

  Future<Result<WorkoutSetExerciseDto, ServiceError<SingleErrorTypes>>>
      addWorkoutSetExercise({
    required int workoutSetId,
    required int exerciseId,
    required int minReps,
    int? position,
    int? maxReps,
    WorkoutSetExerciseDifficulty? difficulty,
    List<int>? alternativeExerciseIds,
  }) async {
    try {
      final workoutSet = await _setRepository.selectOne(workoutSetId);
      if (workoutSet == null) {
        _logger.info('Workout set with id $workoutSetId not found');
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout set with id $workoutSetId not found',
        ));
      }

      final exerciseIds = {exerciseId, ...?alternativeExerciseIds};
      final exercises = await _exerciseRepository.selectMany(
        where: exerciseIds.length == 1
            ? 'id = ?'
            : 'id IN (${List.filled(exerciseIds.length, '?').join(", ")})',
        whereArgs: exerciseIds.toList(),
      );
      if (exercises.length != exerciseIds.length) {
        _logger.info('Some exercises not found');
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Some exercises not found',
        ));
      }

      final count = await _setExerciseRepository.count(
        where: 'workout_set_id = ?',
        whereArgs: [workoutSetId],
      );
      final newPosition = count + 1;
      final setExercisePosition = position ?? newPosition;
      final workoutSetExercise = WorkoutSetExercise.create(
        position: setExercisePosition,
        workoutId: workoutSet.workoutId,
        workoutSetId: workoutSetId,
        exerciseId: exerciseId,
        minReps: minReps,
        maxReps: maxReps,
        difficulty: difficulty,
      );

      if (newPosition > setExercisePosition || alternativeExerciseIds != null) {
        final (int setExerciseId, List<WorkoutSetExerciseOptionDto>? options) =
            await (await _databaseHelper.db).transaction((txn) async {
          if (newPosition > setExercisePosition) {
            await txn.rawQuery(
              "UPDATE ${WorkoutSetExercise.table} SET position = position + 1 WHERE workout_set_id = ? AND position >= ?",
              [workoutSetId, setExercisePosition],
            );
          }

          final setExerciseId = await _setExerciseRepository.insert(
            workoutSetExercise,
          );
          if (alternativeExerciseIds == null) {
            return (setExerciseId, null);
          }

          final exerciseMaps = Map.fromEntries(
            exercises.map((e) => MapEntry(e.id!, ExerciseDto.fromModel(e))),
          );
          final options = <WorkoutSetExerciseOptionDto>[];
          for (int i = 0; i < alternativeExerciseIds.length; i++) {
            final alternativeExerciseId = alternativeExerciseIds[i];
            final option = WorkoutSetExerciseOption.create(
              workoutId: workoutSet.workoutId,
              workoutSetId: workoutSetId,
              workoutSetExerciseId: setExerciseId,
              exerciseId: alternativeExerciseId,
              position: i + 1,
            );
            final optionId = await _setExerciseOptionRepository.insert(option);
            options.add(WorkoutSetExerciseOptionDto.fromModel(
              option.copyWith(id: optionId),
              exercise: exerciseMaps[alternativeExerciseId],
            ));
          }
          return (setExerciseId, options);
        });
        return ok(WorkoutSetExerciseDto.fromModel(
          workoutSetExercise,
          exercise: ExerciseDto.fromModel(exercises.first),
          options: options,
        ));
      }

      final workoutSetExerciseId = await _setExerciseRepository.insert(
        workoutSetExercise,
      );
      _logger.info(
        'Workout set exercise with id $workoutSetExerciseId added successfully',
      );
      return ok(WorkoutSetExerciseDto.fromModel(
        workoutSetExercise,
        exercise: ExerciseDto.fromModel(exercises.first),
      ));
    } catch (e) {
      _logger.severe('Error adding workout set exercise', e);
      return err(
        ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Error adding workout set exercise: ${e.toString()}',
        ),
      );
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>>
      deleteWorkoutSetExercise({
    required int workoutSetExerciseId,
  }) async {
    _logger.info('Deleting workout set exercise with id $workoutSetExerciseId');
    try {
      final setExercise = await _setExerciseRepository.selectOne(
        workoutSetExerciseId,
      );
      if (setExercise == null) {
        _logger.warning(
          'Workout set exercise with id $workoutSetExerciseId not found',
        );
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description:
              'Workout set exercise with id $workoutSetExerciseId not found',
        ));
      }

      final position = setExercise.position;
      final count = await _setExerciseRepository.count(
        where: 'workout_set_id = ?',
        whereArgs: [setExercise.workoutSetId],
      );
      if (count == 1) {
        _logger.info("At least one exercise is required per set");
        return err(const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'At least one exercise is required per set',
        ));
      }
      if (position == count) {
        final deleted =
            await _setExerciseRepository.deleteOne(workoutSetExerciseId);
        if (!deleted) {
          _logger.warning(
            'Workout set exercise with id $workoutSetExerciseId failed to delete',
          );
          return err(const ServiceError(
            type: SingleErrorTypes.operationFailure,
            description: 'Workout set exercise failed to delete',
          ));
        }

        _logger.info(
          'Workout set exercise with id $workoutSetExerciseId deleted successfully',
        );
        return ok(null);
      }

      final bool deleted =
          await (await _databaseHelper.db).transaction((txn) async {
        final deleted =
            await _setExerciseRepository.deleteOne(workoutSetExerciseId, txn);
        if (!deleted) {
          _logger.warning(
            'Workout set exercise with id $workoutSetExerciseId failed to delete',
          );
          return false;
        }

        await txn.rawUpdate(
          """
          UPDATE ${WorkoutSetExercise.table} SET position = position - 1 
          WHERE workout_set_id = ? AND position > ?;
          """,
          [setExercise.workoutSetId, position],
        );
        return true;
      });
      if (!deleted) {
        _logger.warning(
          'Workout set exercise with id $workoutSetExerciseId failed to delete',
        );
        return err(const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Workout set exercise failed to delete',
        ));
      }

      _logger.info(
        'Workout set exercise with id $workoutSetExerciseId deleted successfully',
      );
      return ok(null);
    } catch (e) {
      _logger.severe('Error deleting workout set exercise', e);
      return err(
        ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Error deleting workout set exercise: ${e.toString()}',
        ),
      );
    }
  }

  Future<Result<WorkoutSetExerciseDto, ServiceError<SingleErrorTypes>>>
      updateWorkoutSetExercise({
    required int workoutSetExerciseId,
    int? minReps,
    int? maxReps,
    WorkoutSetExerciseDifficulty? difficulty,
  }) async {
    _logger.info('Updating workout set exercise with id $workoutSetExerciseId');
    try {
      final WorkoutSetExercise? workoutSetExercise =
          await _setExerciseRepository.selectOne(workoutSetExerciseId);
      if (workoutSetExercise == null) {
        _logger.info(
          'Workout set exercise with id $workoutSetExerciseId not found',
        );
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description:
              'Workout set exercise with id: $workoutSetExerciseId not found',
        ));
      }

      final WorkoutSetExercise updatedWorkoutSetExercise =
          workoutSetExercise.copyWith(
        minReps: minReps,
        maxReps: maxReps,
        difficulty: difficulty,
        updatedAt: DateUtilities.getNowUtcUnix(),
      );
      await _setExerciseRepository.update(updatedWorkoutSetExercise);
      _logger.info(
        'Updated workout set exercise with id $workoutSetExerciseId',
      );
      return ok(WorkoutSetExerciseDto.fromModel(updatedWorkoutSetExercise));
    } catch (e) {
      _logger.severe(
        'Error updating workout set exercise with id $workoutSetExerciseId',
        e,
      );
      return err(
        ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Error updating workout set exercise: ${e.toString()}',
        ),
      );
    }
  }

  Future<Result<WorkoutSetExerciseDto, ServiceError<SingleErrorTypes>>>
      updateWorkoutSetExercisePosition({
    required int workoutSetExerciseId,
    required int position,
  }) async {
    _logger.info(
        "Updating workout set exercise with id: $workoutSetExerciseId position");
    try {
      final setExercise =
          await _setExerciseRepository.selectOne(workoutSetExerciseId);
      if (setExercise == null) {
        _logger.warning(
            'Workout set exercise with id $workoutSetExerciseId not found');
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description:
              'Workout set exercise with id $workoutSetExerciseId not found',
        ));
      }

      if (position == setExercise.position) {
        _logger.info('Position already set');
        return ok(WorkoutSetExerciseDto.fromModel(setExercise));
      }

      final count = await _setExerciseRepository.count(
        where: 'workout_set_id = ?',
        whereArgs: [setExercise.workoutSetId],
      );
      if (position < 1 || position > count) {
        _logger.warning('Invalid position');
        return err(const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Position out of bounds',
        ));
      }

      final oldPosition = setExercise.position;
      final updatedSetExercise = setExercise.copyWith(
        position: position,
        updatedAt: DateUtilities.getNowUtcUnix(),
      );
      await (await _databaseHelper.db).transaction((txn) async {
        if (oldPosition < position) {
          await txn.rawUpdate(
            """
            UPDATE ${WorkoutSetExercise.table} SET position = position - 1
            WHERE workout_set_id = ? AND position > ? AND position <= ?;
            """,
            [setExercise.workoutSetId, oldPosition, position],
          );
        } else {
          await txn.rawUpdate(
            """
            UPDATE ${WorkoutSetExercise.table} SET position = position + 1
            WHERE workout_set_id = ? AND position >= ? AND position < ?;
            """,
            [setExercise.workoutSetId, position, oldPosition],
          );
        }
        await _setExerciseRepository.update(updatedSetExercise, txn);
      });

      _logger.info(
          'Workout set exercise with id $workoutSetExerciseId updated successfully');
      return ok(WorkoutSetExerciseDto.fromModel(updatedSetExercise));
    } catch (e) {
      _logger.severe('Error updating workout set exercise', e);
      return err(
        ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Error updating workout set exercise: ${e.toString()}',
        ),
      );
    }
  }

  Future<
      Result<List<WorkoutSetExerciseOptionDto>,
          ServiceError<SingleErrorTypes>>> getWorkoutSetExerciseOptions(
    int workoutSetExerciseId,
  ) async {
    _logger.info(
        "Getting workout set exercise options with id: $workoutSetExerciseId");
    try {
      final exerciseOptions = await _setExerciseOptionRepository.selectMany(
        where: 'workout_set_exercise_id = ?',
        whereArgs: [workoutSetExerciseId],
        orderBy: 'position ASC',
      );

      if (exerciseOptions.isEmpty) {
        return ok([]);
      }

      final exerciseIds = exerciseOptions.map((e) => e.exerciseId).toSet();
      final exercises = await _exerciseRepository.selectMany(
        where: 'id IN (${List.filled(exerciseIds.length, '?').join(", ")})',
        whereArgs: exerciseIds.toList(),
      );

      final exerciseMap = Map.fromEntries(
        exercises.map(
          (exercise) => MapEntry(
            exercise.id!,
            ExerciseDto.fromModel(exercise),
          ),
        ),
      );

      return ok(
        exerciseOptions
            .map(
              (o) => WorkoutSetExerciseOptionDto.fromModel(
                o,
                exercise: exerciseMap[o.exerciseId],
              ),
            )
            .toList(),
      );
    } catch (e) {
      _logger.severe('Error getting workout set exercise options', e);
      return err(
        ServiceError(
          type: SingleErrorTypes.operationFailure,
          description:
              'Error getting workout set exercise options: ${e.toString()}',
        ),
      );
    }
  }

  Future<Result<WorkoutSetExerciseOptionDto, ServiceError<SingleErrorTypes>>>
      getWorkoutSetExerciseOption(
    int workoutSetExerciseOptionId,
  ) async {
    _logger.info(
        "Getting workout set exercise option with id: $workoutSetExerciseOptionId");
    try {
      final option = await _setExerciseOptionRepository.selectOne(
        workoutSetExerciseOptionId,
      );
      if (option == null) {
        _logger.warning(
            'Workout set exercise option with id $workoutSetExerciseOptionId not found');
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description:
              'Workout set exercise option with id $workoutSetExerciseOptionId not found',
        ));
      }

      final exercise = await _exerciseRepository.selectOne(option.exerciseId);
      if (exercise == null) {
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Exercise with id ${option.exerciseId} not found',
        ));
      }

      return ok(WorkoutSetExerciseOptionDto.fromModel(
        option,
        exercise: ExerciseDto.fromModel(exercise),
      ));
    } catch (e) {
      _logger.severe('Error getting workout set exercise option', e);
      return err(
        ServiceError(
          type: SingleErrorTypes.operationFailure,
          description:
              'Error getting workout set exercise option: ${e.toString()}',
        ),
      );
    }
  }

  Future<Result<WorkoutSetExerciseOptionDto, ServiceError<SingleErrorTypes>>>
      addWorkoutSetExerciseOption({
    required int workoutSetExerciseId,
    required int exerciseId,
    int? position,
  }) async {
    _logger.info(
        'Adding workout set exercise option for set exercise $workoutSetExerciseId');
    try {
      final workoutSetExercise =
          await _setExerciseRepository.selectOne(workoutSetExerciseId);
      if (workoutSetExercise == null) {
        _logger.warning(
            'Workout set exercise with id $workoutSetExerciseId not found');
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description:
              'Workout set exercise with id $workoutSetExerciseId not found',
        ));
      }

      final exercise = await _exerciseRepository.selectOne(exerciseId);
      if (exercise == null) {
        _logger.warning('Exercise with id $exerciseId not found');
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Exercise with id $exerciseId not found',
        ));
      }

      final count = await _setExerciseOptionRepository.count(
        where: 'workout_set_exercise_id = ?',
        whereArgs: [workoutSetExerciseId],
      );
      final newPosition = count + 1;
      final int optionPosition = position ?? newPosition;

      final option = WorkoutSetExerciseOption.create(
        workoutId: workoutSetExercise.workoutId,
        workoutSetId: workoutSetExercise.workoutSetId,
        workoutSetExerciseId: workoutSetExerciseId,
        exerciseId: exerciseId,
        position: optionPosition,
      );

      if (newPosition > optionPosition) {
        final id = await (await _databaseHelper.db).transaction((txn) async {
          await txn.rawUpdate(
            "UPDATE ${WorkoutSetExerciseOption.table} SET position = position + 1 WHERE workout_set_exercise_id = ? AND position >= ?",
            [workoutSetExerciseId, optionPosition],
          );
          return await _setExerciseOptionRepository.insert(option, txn);
        });
        _logger.info('Workout set exercise option added successfully');
        return ok(WorkoutSetExerciseOptionDto.fromModel(
          option.copyWith(id: id),
          exercise: ExerciseDto.fromModel(exercise),
        ));
      }

      final id = await _setExerciseOptionRepository.insert(option);
      _logger.info('Workout set exercise option added successfully');
      return ok(WorkoutSetExerciseOptionDto.fromModel(
        option.copyWith(id: id),
        exercise: ExerciseDto.fromModel(exercise),
      ));
    } catch (e) {
      _logger.severe('Error adding workout set exercise option', e);
      return err(ServiceError(
        type: SingleErrorTypes.operationFailure,
        description:
            'Error adding workout set exercise option: ${e.toString()}',
      ));
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>>
      deleteWorkoutSetExerciseOption({
    required int workoutSetExerciseOptionId,
  }) async {
    _logger.info(
        'Deleting workout set exercise option with id $workoutSetExerciseOptionId');
    try {
      final option = await _setExerciseOptionRepository.selectOne(
        workoutSetExerciseOptionId,
      );
      if (option == null) {
        _logger.warning(
            'Workout set exercise option with id $workoutSetExerciseOptionId not found');
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description:
              'Workout set exercise option with id $workoutSetExerciseOptionId not found',
        ));
      }

      final position = option.position;
      final count = await _setExerciseOptionRepository.count(
        where: 'workout_set_exercise_id = ?',
        whereArgs: [option.workoutSetExerciseId],
      );

      if (position == count) {
        final deleted = await _setExerciseOptionRepository
            .deleteOne(workoutSetExerciseOptionId);
        if (!deleted) {
          _logger.warning(
              'Workout set exercise option with id $workoutSetExerciseOptionId failed to delete');
          return err(const ServiceError(
            type: SingleErrorTypes.operationFailure,
            description: 'Workout set exercise option failed to delete',
          ));
        }

        _logger.info(
            'Workout set exercise option with id $workoutSetExerciseOptionId deleted successfully');
        return ok(null);
      }

      final deleted = await (await _databaseHelper.db).transaction((txn) async {
        final deleted = await _setExerciseOptionRepository.deleteOne(
            workoutSetExerciseOptionId, txn);
        if (!deleted) {
          return false;
        }

        await txn.rawUpdate(
          """
          UPDATE ${WorkoutSetExerciseOption.table} SET position = position - 1 
          WHERE workout_set_exercise_id = ? AND position > ?;
          """,
          [option.workoutSetExerciseId, position],
        );
        return true;
      });

      if (!deleted) {
        _logger.warning(
            'Workout set exercise option with id $workoutSetExerciseOptionId failed to delete');
        return err(const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Workout set exercise option failed to delete',
        ));
      }

      _logger.info(
          'Workout set exercise option with id $workoutSetExerciseOptionId deleted successfully');
      return ok(null);
    } catch (e) {
      _logger.severe('Error deleting workout set exercise option', e);
      return err(
        ServiceError(
          type: SingleErrorTypes.operationFailure,
          description:
              'Error deleting workout set exercise option: ${e.toString()}',
        ),
      );
    }
  }

  Future<Result<WorkoutSetExerciseOptionDto, ServiceError<SingleErrorTypes>>>
      updateWorkoutSetExerciseOption({
    required int workouSetExerciseOptionId,
    int? exerciseId,
  }) async {
    _logger.info(
        'Updating workout set exercise option with id $workouSetExerciseOptionId');
    try {
      final option = await _setExerciseOptionRepository.selectOne(
        workouSetExerciseOptionId,
      );
      if (option == null) {
        _logger.warning(
            'Workout set exercise option with id $workouSetExerciseOptionId not found');
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description:
              'Workout set exercise option with id $workouSetExerciseOptionId not found',
        ));
      }

      final updatedOption = option.copyWith(
        exerciseId: exerciseId,
        updatedAt: DateUtilities.getNowUtcUnix(),
      );
      await _setExerciseOptionRepository.update(updatedOption);

      final exercise = await _exerciseRepository.selectOne(
        updatedOption.exerciseId,
      );

      _logger.info(
          'Updated workout set exercise option with id $workouSetExerciseOptionId');
      return ok(WorkoutSetExerciseOptionDto.fromModel(
        updatedOption,
        exercise: exercise != null ? ExerciseDto.fromModel(exercise) : null,
      ));
    } catch (e) {
      _logger.severe(
          'Error updating workout set exercise option with id $workouSetExerciseOptionId',
          e);
      return err(
        ServiceError(
          type: SingleErrorTypes.operationFailure,
          description:
              'Error updating workout set exercise option: ${e.toString()}',
        ),
      );
    }
  }

  Future<Result<WorkoutSetExerciseOptionDto, ServiceError<SingleErrorTypes>>>
      updateWorkoutSetExerciseOptionPosition({
    required int workoutSetExerciseOptionId,
    required int position,
  }) async {
    _logger.info(
        "Updating workout set exercise option with id: $workoutSetExerciseOptionId position");
    try {
      final option = await _setExerciseOptionRepository
          .selectOne(workoutSetExerciseOptionId);
      if (option == null) {
        _logger.warning(
            'Workout set exercise option with id $workoutSetExerciseOptionId not found');
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description:
              'Workout set exercise option with id $workoutSetExerciseOptionId not found',
        ));
      }

      if (position == option.position) {
        _logger.info('Position already set');
        return ok(WorkoutSetExerciseOptionDto.fromModel(option));
      }

      final count = await _setExerciseOptionRepository.count(
        where: 'workout_set_exercise_id = ?',
        whereArgs: [option.workoutSetExerciseId],
      );
      if (position < 1 || position > count) {
        _logger.warning('Invalid position');
        return err(const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Position out of bounds',
        ));
      }

      final oldPosition = option.position;
      final updatedOption = option.copyWith(
        position: position,
        updatedAt: DateUtilities.getNowUtcUnix(),
      );
      await (await _databaseHelper.db).transaction((txn) async {
        if (oldPosition < position) {
          await txn.rawUpdate(
            """
            UPDATE ${WorkoutSetExerciseOption.table} SET position = position - 1
            WHERE workout_set_exercise_id = ? AND position > ? AND position <= ?;
            """,
            [option.workoutSetExerciseId, oldPosition, position],
          );
        } else {
          await txn.rawUpdate(
            """
            UPDATE ${WorkoutSetExerciseOption.table} SET position = position + 1
            WHERE workout_set_exercise_id = ? AND position >= ? AND position < ?;
            """,
            [option.workoutSetExerciseId, position, oldPosition],
          );
        }
        await _setExerciseOptionRepository.update(updatedOption, txn);
      });

      _logger.info(
          'Workout set exercise option with id $workoutSetExerciseOptionId updated successfully');
      return ok(WorkoutSetExerciseOptionDto.fromModel(updatedOption));
    } catch (e) {
      _logger.severe('Error updating workout set exercise option', e);
      return err(
        ServiceError(
          type: SingleErrorTypes.operationFailure,
          description:
              'Error updating workout set exercise option: ${e.toString()}',
        ),
      );
    }
  }
}
