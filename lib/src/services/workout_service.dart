import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';

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
  final bool toMaxReps;
  final WorkoutSetExerciseDifficulty? difficulty;
  final List<int>? alternativeExerciseIds;

  const WorkoutSetExerciseInput({
    required this.exerciseId,
    required this.minReps,
    this.maxReps,
    this.toMaxReps = false,
    this.difficulty,
    this.alternativeExerciseIds,
  });
}

final class WorkoutSetExerciseUpsertInput {
  final int? id;
  final int exerciseId;
  final int position;
  final int minReps;
  final int? maxReps;
  final bool toMaxReps;
  final WorkoutSetExerciseDifficulty? difficulty;
  final List<int>? alternativeExerciseIds;

  const WorkoutSetExerciseUpsertInput({
    this.id,
    required this.exerciseId,
    required this.position,
    required this.minReps,
    this.maxReps,
    this.toMaxReps = false,
    this.difficulty,
    this.alternativeExerciseIds,
  });
}

final class WorkoutSetUpsertInput {
  final int? id;
  final WorkoutSetType setType;
  final int minSets;
  final int recommendedRestSecs;
  final List<WorkoutSetExerciseUpsertInput> exercises;
  final int position;
  final int? maxSets;
  final int? maxRestSecs;

  const WorkoutSetUpsertInput({
    this.id,
    required this.setType,
    required this.minSets,
    required this.recommendedRestSecs,
    required this.exercises,
    required this.position,
    this.maxSets,
    this.maxRestSecs,
  });
}

class WorkoutSetExerciseRegistrationInput {
  final ExerciseDto exercise;
  final int minReps;
  final int? maxReps;
  final WorkoutSetExerciseDifficulty? difficulty;
  final List<ExerciseDto> alternativeExercises;

  const WorkoutSetExerciseRegistrationInput({
    required this.exercise,
    required this.minReps,
    this.maxReps,
    this.difficulty,
    this.alternativeExercises = const [],
  });
}

class WorkoutSetRegistrationInput {
  final WorkoutSetType setType;
  final int minSets;
  final int? maxSets;
  final int recommendedRestSecs;
  final int? maxRestSecs;
  final List<WorkoutSetExerciseRegistrationInput> exercises;

  const WorkoutSetRegistrationInput({
    required this.setType,
    required this.minSets,
    this.maxSets,
    required this.recommendedRestSecs,
    this.maxRestSecs,
    required this.exercises,
  });
}

class WorkoutRegistrationInput {
  final String name;
  final String description;
  final PictureData? picture;
  final VideoData? video;
  final Difficulty difficulty;
  final WorkoutPhase? phase;
  final List<WorkoutSetRegistrationInput> sets;

  const WorkoutRegistrationInput({
    required this.name,
    required this.description,
    this.picture,
    this.video,
    required this.difficulty,
    this.phase,
    required this.sets,
  });
}

// TODO: Add version to workout service
class WorkoutService {
  WorkoutService._();

  static final WorkoutService instance = WorkoutService._();

  factory WorkoutService() => instance;

  final Logger _logger = Logger('Workout Service');

  final _repository = Repository<Workout>(
    databaseHelper: DatabaseHelper(),
    tableName: Workout.table,
    fromMap: Workout.fromMap,
  );

  final _setRepository = Repository<WorkoutSet>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutSet.table,
    fromMap: WorkoutSet.fromMap,
  );

  final _setExerciseRepository = Repository<WorkoutSetExercise>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutSetExercise.table,
    fromMap: WorkoutSetExercise.fromMap,
  );

  final _setExerciseOptionRepository = Repository<WorkoutSetExerciseOption>(
    databaseHelper: DatabaseHelper(),
    tableName: WorkoutSetExerciseOption.table,
    fromMap: WorkoutSetExerciseOption.fromMap,
  );

  final _exerciseRepository = Repository<Exercise>(
    databaseHelper: DatabaseHelper(),
    tableName: Exercise.table,
    fromMap: Exercise.fromMap,
  );

  Future<
      Result<PaginatedDto<WorkoutDto, Workout>,
          ServiceError<OperationErrorTypes>>> getWorkouts({
    String? name,
    Difficulty? difficulty,
    MuscleGroup? muscleGroup,
    bool isFavorite = false,
    int limit = kDefaultLimit,
    int offset = kDefaultOffset,
  }) async {
    _logger.info('Getting workouts');
    final WhereBuilder query = WhereBuilder();

    if (name != null && name.isNotEmpty) {
      query.and(WorkoutColumns.name.like, '%$name%');
    }

    if (difficulty != null) {
      query.and(WorkoutColumns.difficulty.equal, difficulty.value);
    }

    if (muscleGroup != null) {
      query.and(WorkoutColumns.muscleGroups.like, '%${muscleGroup.value}%');
    }

    if (isFavorite) {
      query.and(WorkoutColumns.isFavorite.equal, 1);
    }

    try {
      final List<Workout> workouts = await _repository.selectPaginated(
        limit: limit,
        offset: offset,
        where: query.where,
        whereArgs: query.args,
        orderBy: [WorkoutColumns.name.orderCaseInsensitiveAsc],
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

  Future<Result<List<WorkoutDto>, ServiceError<OperationErrorTypes>>>
      getAllWorkouts({
    MuscleGroup? muscleGroup,
    String name = "",
    bool isFavorite = false,
  }) async {
    _logger.info('Getting all workouts');
    final WhereBuilder query = WhereBuilder();

    if (name.isNotEmpty) {
      query.and(WorkoutColumns.name.like, '%$name%');
    }

    if (muscleGroup != null) {
      query.and(WorkoutColumns.muscleGroups.like, '%${muscleGroup.value}%');
    }

    if (isFavorite) {
      query.and(WorkoutColumns.isFavorite.equal, 1);
    }

    try {
      final List<Workout> workouts = await _repository.selectMany(
        where: query.where,
        whereArgs: query.args,
        orderBy: [WorkoutColumns.name.orderCaseInsensitiveAsc],
      );
      _logger.info('Got ${workouts.length} workouts');
      return ok(
        workouts.map((workout) => WorkoutDto.fromModel(workout)).toList(),
      );
    } catch (e) {
      _logger.severe('Failed to get all workouts', e);
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to get all workouts',
      ));
    }
  }

  Future<Result<WorkoutDto, ServiceError<SingleErrorTypes>>> getWorkout(
    int id, {
    int? version,
  }) async {
    _logger.info('Getting workout with id $id');
    try {
      late final Workout? workout;
      if (version == null) {
        workout = await _repository.selectOne(id);
      } else {
        final queryBuilder = WhereBuilder();
        queryBuilder.and(WorkoutColumns.id.equal, id);
        queryBuilder.and(WorkoutColumns.version.equal, version);
        final workouts = await _repository.selectMany(
          where: queryBuilder.where,
          whereArgs: queryBuilder.args,
          limit: 1,
        );
        workout = workouts.firstOrNull;
      }

      if (workout == null) {
        _logger.warning('Workout with id $id not found');
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout not found',
        ));
      }

      final List<WorkoutSet> sets = await _setRepository.selectMany(
        where: WorkoutSetColumns.workoutId.equal,
        whereArgs: [id],
        orderBy: [WorkoutSetColumns.position.orderAsc],
      );
      if (sets.isEmpty) {
        _logger.info('Got workout with id $id');
        return ok(WorkoutDto.fromModel(workout));
      }

      final List<WorkoutSetExercise> setExercises =
          await _setExerciseRepository.selectMany(
        where: WorkoutSetExerciseColumns.workoutId.equal,
        whereArgs: [id],
        orderBy: [
          WorkoutSetExerciseColumns.workoutSetId.orderAsc,
          WorkoutSetExerciseColumns.position.orderAsc,
        ],
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
        where: WorkoutSetExerciseOptionColumns.workoutId.equal,
        whereArgs: [id],
        orderBy: [
          WorkoutSetExerciseOptionColumns.workoutSetExerciseId.orderAsc,
          WorkoutSetExerciseOptionColumns.position.orderAsc,
        ],
      );
      final Set<int> exerciseIds = <int>{
        ...setExercises.map((s) => s.exerciseId),
        ...setExerciseOptions.map((s) => s.exerciseId),
      };
      final List<Exercise> exercises = await _exerciseRepository.selectMany(
        where: ExerciseColumns.id.inList(exerciseIds.length),
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
      return err(ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to get workout with error: ${e.toString()}',
      ));
    }
  }

  Future<Result<WorkoutDto, ServiceError<OperationErrorTypes>>> createWorkout({
    required String name,
    required Difficulty difficulty,
    EditorType editorType = EditorType.basic,
    bool isFavorite = false,
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
        isFavorite: isFavorite,
        picture: picture,
        video: video,
        editorType: editorType,
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

  Future<Result<List<WorkoutDto>, ServiceError<OperationErrorTypes>>>
      createWorkouts(
    List<WorkoutRegistrationInput> workouts, {
    CreatedBy createdBy = CreatedBy.user,
  }) async {
    _logger.info("Creating ${workouts.length} workouts...");
    try {
      final List<WorkoutDto> createdWorkouts =
          await _repository.startTransaction((txn) async {
        final List<WorkoutDto> createdWorkouts = [];

        for (final workoutInput in workouts) {
          int totalSets = 0;
          int totalReps = 0;
          final Set<MuscleGroup> muscleGroups = {};
          final TargetMuscles muscles = TargetMuscles(
            primary: <Muscle>{},
            secondary: <Muscle>{},
          );

          for (final set in workoutInput.sets) {
            final int setNum = (set.maxSets ?? set.minSets);
            totalSets += setNum;
            for (final exercise in set.exercises) {
              totalReps += setNum * (exercise.maxReps ?? exercise.minReps);
              muscleGroups.add(exercise.exercise.muscleGroup);

              muscles.primary.addAll(exercise.exercise.muscles.primary);
              muscles.secondary.addAll(exercise.exercise.muscles.secondary);
              muscles.secondary.removeAll(muscles.primary);
            }
          }

          final workout = Workout.create(
            name: workoutInput.name,
            description: workoutInput.description,
            picture: workoutInput.picture,
            video: workoutInput.video,
            difficulty: workoutInput.difficulty,
            phase: workoutInput.phase,
            muscleGroups: muscleGroups,
            muscles: muscles,
            createdBy: createdBy,
            totalSets: totalSets,
            totalReps: totalReps,
          );

          final int workoutId = await _repository.insert(workout, txn);
          final List<WorkoutSetDto> createdSets = [];

          for (int i = 0; i < workoutInput.sets.length; i++) {
            final setInput = workoutInput.sets[i];
            final set = WorkoutSet.create(
              workoutVersion: workout.version,
              position: i + 1,
              workoutId: workoutId,
              setType: setInput.setType,
              minSets: setInput.minSets,
              maxSets: setInput.maxSets,
              recommendedRestSecs: setInput.recommendedRestSecs,
              maxRestSecs: setInput.maxRestSecs,
              createdBy: createdBy,
            );

            final int setId = await _setRepository.insert(set, txn);
            final List<WorkoutSetExerciseDto> createdSetExercises = [];

            for (int j = 0; j < setInput.exercises.length; j++) {
              final exerciseInput = setInput.exercises[j];

              final setExercise = WorkoutSetExercise.create(
                workoutVersion: workout.version,
                position: j + 1,
                workoutId: workoutId,
                workoutSetId: setId,
                exerciseId: exerciseInput.exercise.id,
                minReps: exerciseInput.minReps,
                maxReps: exerciseInput.maxReps,
                difficulty: exerciseInput.difficulty,
                createdBy: createdBy,
              );

              final int setExerciseId = await _setExerciseRepository.insert(
                setExercise,
                txn,
              );

              final List<WorkoutSetExerciseOptionDto> createdOptions = [];
              for (int k = 0;
                  k < exerciseInput.alternativeExercises.length;
                  k++) {
                final optionDto = exerciseInput.alternativeExercises[k];

                final option = WorkoutSetExerciseOption.create(
                  workoutVersion: workout.version,
                  workoutId: workoutId,
                  workoutSetId: setId,
                  workoutSetExerciseId: setExerciseId,
                  exerciseId: optionDto.id,
                  position: k + 1,
                  createdBy: createdBy,
                );

                final int optionKey = await _setExerciseOptionRepository.insert(
                  option,
                  txn,
                );

                createdOptions.add(WorkoutSetExerciseOptionDto.fromModel(
                  option.copyWith(id: optionKey),
                  exercise: optionDto,
                ));
              }

              createdSetExercises.add(WorkoutSetExerciseDto.fromModel(
                setExercise.copyWith(id: setExerciseId),
                exercise: exerciseInput.exercise,
                options: createdOptions,
              ));
            }

            createdSets.add(WorkoutSetDto.fromModel(
              set.copyWith(id: setId),
              exercises: createdSetExercises,
            ));
          }

          createdWorkouts.add(WorkoutDto.fromModel(
            workout.copyWith(id: workoutId),
            sets: createdSets,
          ));
        }

        return createdWorkouts;
      });

      _logger.info("Created ${createdWorkouts.length} workouts");
      return ok(createdWorkouts);
    } catch (e) {
      _logger.severe("Failed to create workouts", e);
      return err(ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to create workouts with error: ${e.toString()}',
      ));
    }
  }

  Future<Result<WorkoutDto, ServiceError<SingleErrorTypes>>> updateWorkout({
    required int id,
    String? name,
    Difficulty? difficulty,
    EditorType? editorType,
    String? description,
    PictureData? picture,
    VideoData? video,
    bool? isFavorite,
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
        isFavorite: isFavorite,
        editorType: editorType,
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

  Future<Result<List<WorkoutSetDto>, ServiceError<OperationErrorTypes>>>
      getWorkoutSets(
    int workoutId,
  ) async {
    _logger.info('Getting workout sets with workout id $workoutId');
    try {
      final List<WorkoutSet> workoutSets = await _setRepository.selectMany(
        where: WorkoutSetColumns.workoutId.equal,
        whereArgs: [workoutId],
        orderBy: [
          WorkoutSetColumns.workoutId.orderAsc,
          WorkoutSetColumns.position.orderAsc,
        ],
      );
      if (workoutSets.isEmpty) {
        _logger.info('No workout sets found for workout id $workoutId');
        return ok([]);
      }

      final List<WorkoutSetExercise> setExercises =
          await _setExerciseRepository.selectMany(
        where: WorkoutSetExerciseColumns.workoutId.equal,
        whereArgs: [workoutId],
        orderBy: [
          WorkoutSetExerciseColumns.workoutSetId.orderAsc,
          WorkoutSetExerciseColumns.position.orderAsc,
        ],
      );
      if (setExercises.isEmpty) {
        _logger
            .info('No workout set exercises found for workout id $workoutId');
        return ok(
          workoutSets.map((ws) => WorkoutSetDto.fromModel(ws)).toList(),
        );
      }

      final List<WorkoutSetExerciseOption> setExerciseOptions =
          await _setExerciseOptionRepository.selectMany(
        where: WorkoutSetExerciseOptionColumns.workoutId.equal,
        whereArgs: [workoutId],
        orderBy: [
          WorkoutSetExerciseOptionColumns.workoutSetExerciseId.orderAsc,
          WorkoutSetExerciseOptionColumns.position.orderAsc,
        ],
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
        where: ExerciseColumns.id.inList(exerciseIds.length),
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

  Future<Result<void, ServiceError<SingleErrorTypes>>> batchUpsertWorkoutSets({
    required int workoutId,
    required List<WorkoutSetUpsertInput> inputs,
  }) async {
    _logger.info('Batch upserting workout sets');
    final exerciseIds = inputs.fold(<int>{}, (previousValue, element) {
      for (final exercise in element.exercises) {
        previousValue.add(exercise.exerciseId);
        if (exercise.alternativeExerciseIds != null) {
          previousValue.addAll(exercise.alternativeExerciseIds!);
        }
      }
      return previousValue;
    });
    try {
      final workout = await _repository.selectOne(workoutId);
      if (workout == null) {
        _logger.warning('Workout with id $workoutId not found');
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Workout not found',
          ),
        );
      }

      final exercises = exerciseIds.isEmpty
          ? <Exercise>[]
          : await _exerciseRepository.selectMany(
              where: ExerciseColumns.id.inList(exerciseIds.length),
              whereArgs: exerciseIds.toList(),
            );
      if (exercises.length != exerciseIds.length) {
        _logger.warning(
          'Not all exercises found, ${exercises.length} found, ${exerciseIds.length} expected',
        );
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Not all exercises found',
          ),
        );
      }

      final exerciseMap = exercises.fold(
        <int, ExerciseDto>{},
        (previousValue, element) {
          previousValue[element.id!] = ExerciseDto.fromModel(element);
          return previousValue;
        },
      );

      final List<WorkoutSet> existingSets = await _setRepository.selectMany(
        where: WorkoutSetColumns.workoutId.equal,
        whereArgs: [workoutId],
      );
      final Set<int> existingSetIds = existingSets
          .map(
            (set) => set.id!,
          )
          .toSet();

      final (
        List<WorkoutSetUpsertInput> setsToCreate,
        List<WorkoutSetUpsertInput> setsToUpdate,
      ) = inputs.fold(([], []), (previousValue, element) {
        if (element.id == null) {
          previousValue.$1.add(element);
          return previousValue;
        }

        if (existingSetIds.contains(element.id)) {
          previousValue.$2.add(element);
          return previousValue;
        }

        return previousValue;
      });

      final idsToDelete = existingSetIds.difference(
        setsToUpdate.map((e) => e.id!).toSet(),
      );

      await _setRepository.startTransaction((txn) async {
        for (final id in idsToDelete) {
          await _doBatchSetDelete(id, txn);
        }

        for (final input in setsToCreate) {
          await _doBatchSetCreate(
            workoutVersion: workout.version,
            input: input,
            txn: txn,
            workoutId: workoutId,
            exerciseMap: exerciseMap,
          );
        }

        for (final input in setsToUpdate) {
          final workoutSet = await _setRepository.selectOne(input.id!, txn);
          if (workoutSet == null) {
            _logger.warning('Workout set not found');
            continue;
          }

          final int oldPosition = workoutSet.position;
          final updatedWorkoutSet = workoutSet.copyWith(
            setType: input.setType,
            minSets: input.minSets,
            recommendedRestSecs: input.recommendedRestSecs,
            maxSets: input.maxSets,
            maxRestSecs: input.maxRestSecs,
            totalExercises: input.exercises.length,
            totalReps: (input.maxSets ?? input.minSets) *
                input.exercises.fold<int>(0, (previousValue, element) {
                  return previousValue + (element.maxReps ?? element.minReps);
                }),
            position: input.position,
          );

          if (oldPosition != input.position) {
            if (oldPosition < input.position) {
              await txn.rawUpdate(
                """
                UPDATE ${WorkoutSet.table} SET position = position - 1
                WHERE workout_id = ? AND position > ? AND position <= ?;
                """,
                [workoutId, oldPosition, input.position],
              );
            } else {
              await txn.rawUpdate(
                """
                UPDATE ${WorkoutSet.table} SET position = position + 1
                WHERE workout_id = ? AND position >= ? AND position < ?;
                """,
                [workoutId, input.position, oldPosition],
              );
            }
          }

          await _setRepository.update(updatedWorkoutSet, txn);

          final (
            List<WorkoutSetExerciseUpsertInput> createSetExercises,
            List<WorkoutSetExerciseUpsertInput> updateSetExercises
          ) = input.exercises.fold(([], []), (arrs, ex) {
            if (ex.id == null) {
              arrs.$1.add(ex);
            } else {
              arrs.$2.add(ex);
            }
            return arrs;
          });

          final List<WorkoutSetExercise> existingSetExercises =
              await _setExerciseRepository.selectMany(
            where: WorkoutSetExerciseColumns.workoutSetId.equal,
            whereArgs: [workoutSet.id!],
            trx: txn,
          );
          final Set<int> setExerciseIdsToKeep =
              updateSetExercises.map((setExercise) => setExercise.id!).toSet();
          final List<int> setExerciseIdsToDelete = existingSetExercises
              .where((setExercise) =>
                  !setExerciseIdsToKeep.contains(setExercise.id))
              .map((setExercise) => setExercise.id!)
              .toList();

          for (final setExerciseId in setExerciseIdsToDelete) {
            await txn.delete(
              WorkoutSetExerciseOption.table,
              where: WorkoutSetExerciseOptionColumns.workoutSetExerciseId.equal,
              whereArgs: [setExerciseId],
            );
            await _setExerciseRepository.deleteOne(setExerciseId, txn);
          }

          final int setCount = await _setExerciseRepository.count(
            where: WorkoutSetExerciseColumns.workoutSetId.equal,
            whereArgs: [workoutSet.id!],
            trx: txn,
          );

          if (createSetExercises.isNotEmpty) {
            for (int i = 0; i < createSetExercises.length; i++) {
              final exerciseInput = createSetExercises[i];
              if (!exerciseMap.containsKey(exerciseInput.exerciseId)) {
                _logger.warning('Exercise not found');
                throw Exception('Exercise not found');
              }

              await _batchCreateSetExercise(
                exerciseInput: exerciseInput,
                index: i,
                setCount: setCount,
                workoutId: workoutId,
                workoutSet: workoutSet,
                txn: txn,
                updatedWorkoutSet: updatedWorkoutSet,
              );
            }
          }

          if (updateSetExercises.isNotEmpty) {
            for (int i = 0; i < updateSetExercises.length; i++) {
              final exerciseInput = updateSetExercises[i];
              if (!exerciseMap.containsKey(exerciseInput.exerciseId)) {
                _logger.warning('Exercise not found');
                throw Exception('Exercise not found');
              }

              await _batchUpdateSetExercise(
                exerciseInput: exerciseInput,
                txn: txn,
                workoutSet: workoutSet,
              );
            }
          }
        }

        final List<WorkoutSet> updatedSets = await _setRepository.selectMany(
          where: WorkoutSetColumns.workoutId.equal,
          whereArgs: [workoutId],
          trx: txn,
        );
        final int updatedTotalSets = updatedSets.fold(
          0,
          (acc, set) => acc + (set.maxSets ?? set.minSets),
        );
        final int updatedTotalReps = updatedSets.fold(
          0,
          (acc, set) => acc + set.totalReps,
        );

        final List<WorkoutSetExercise> updatedSetExercises =
            await _setExerciseRepository.selectMany(
          where: WorkoutSetExerciseColumns.workoutId.equal,
          whereArgs: [workoutId],
          trx: txn,
        );
        final Set<MuscleGroup> updatedMuscleGroups = {};
        final TargetMuscles updatedMuscles = TargetMuscles(
          primary: <Muscle>{},
          secondary: <Muscle>{},
        );
        if (updatedSetExercises.isNotEmpty) {
          for (final setExercise in updatedSetExercises) {
            final exercise = exerciseMap[setExercise.exerciseId];
            if (exercise == null) {
              continue;
            }

            updatedMuscleGroups.add(exercise.muscleGroup);
            updatedMuscles.primary.addAll(exercise.muscles.primary);
            updatedMuscles.secondary.addAll(exercise.muscles.secondary);
            updatedMuscles.secondary.removeAll(updatedMuscles.primary);
          }
        }

        final updatedWorkout = workout.copyWith(
          muscleGroups: updatedMuscleGroups,
          muscles: updatedMuscles,
          totalSets: updatedTotalSets,
          totalReps: updatedTotalReps,
          updatedAt: DateUtilities.getNowUtcUnix(),
        );
        await _repository.update(updatedWorkout, txn);
      });
      _logger.info('Batch upserting workout sets completed successfully');
      return ok(null);
    } catch (e) {
      _logger.severe('Error batch upserting workout sets', e);
      return err(
        ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Error batch upserting workout sets: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _doBatchSetDelete(int id, Transaction txn) async {
    final workoutSet = await _setRepository.selectOne(id, txn);
    if (workoutSet == null) {
      _logger.warning('Workout set with id $id not found');
      return;
    }

    final int oldPosition = workoutSet.position;
    await txn.delete(
      WorkoutSetExerciseOption.table,
      where: WorkoutSetExerciseOptionColumns.workoutSetId.equal,
      whereArgs: [id],
    );
    await txn.delete(
      WorkoutSetExercise.table,
      where: WorkoutSetExerciseColumns.workoutSetId.equal,
      whereArgs: [id],
    );
    await _setRepository.deleteOne(id, txn);
    await txn.rawUpdate(
      """
      UPDATE ${WorkoutSet.table}
      SET ${WorkoutSetColumns.position.value} = ${WorkoutSetColumns.position.value} - 1
      WHERE ${WorkoutSetColumns.workoutId.equal} AND ${WorkoutSetColumns.position.greaterThan};
      """,
      [workoutSet.workoutId, oldPosition],
    );
  }

  Future<void> _batchUpdateSetExercise({
    required WorkoutSetExerciseUpsertInput exerciseInput,
    required Transaction txn,
    required WorkoutSet workoutSet,
  }) async {
    final setExercise = await _setExerciseRepository.selectOne(
      exerciseInput.id!,
      txn,
    );
    if (setExercise == null) {
      _logger.warning('Set exercise not found');
      throw Exception('Set exercise not found');
    }
    if (setExercise.workoutSetId != workoutSet.id) {
      _logger.warning('Set exercise does not belong to workout set');
      throw Exception('Set exercise does not belong to workout set');
    }

    final int oldPosition = setExercise.position;
    final updatedSetExercise = setExercise.copyWith(
      exerciseId: exerciseInput.exerciseId,
      position: exerciseInput.position,
      minReps: exerciseInput.minReps,
      maxReps: exerciseInput.maxReps,
      toMaxReps: exerciseInput.toMaxReps,
      difficulty: exerciseInput.difficulty,
    );

    if (oldPosition != exerciseInput.position) {
      if (oldPosition < exerciseInput.position) {
        await txn.rawUpdate(
          """
          UPDATE ${WorkoutSetExercise.table} SET position = position - 1
          WHERE workout_set_id = ? AND position > ? AND position <= ?;
          """,
          [workoutSet.id!, oldPosition, exerciseInput.position],
        );
      } else {
        await txn.rawUpdate(
          """
          UPDATE ${WorkoutSetExercise.table} SET position = position + 1
          WHERE workout_set_id = ? AND position >= ? AND position < ?;
          """,
          [workoutSet.id!, exerciseInput.position, oldPosition],
        );
      }
    }

    if (exerciseInput.alternativeExerciseIds == null) {
      await txn.rawDelete(
        """
        DELETE FROM ${WorkoutSetExerciseOption.table}
        WHERE ${WorkoutSetExerciseOptionColumns.workoutSetExerciseId.equal};
        """,
        [setExercise.id!],
      );
    } else {
      await txn.rawDelete(
        """
        DELETE FROM ${WorkoutSetExerciseOption.table}
        WHERE ${WorkoutSetExerciseOptionColumns.workoutSetExerciseId.equal};
        """,
        [setExercise.id!],
      );
      for (int j = 0; j < exerciseInput.alternativeExerciseIds!.length; j++) {
        final alternativeExerciseId = exerciseInput.alternativeExerciseIds![j];
        final workoutSetExerciseOption = WorkoutSetExerciseOption.create(
          workoutVersion: workoutSet.workoutVersion,
          workoutId: workoutSet.workoutId,
          workoutSetId: workoutSet.id!,
          workoutSetExerciseId: setExercise.id!,
          exerciseId: alternativeExerciseId,
          position: j + 1,
        );
        await _setExerciseOptionRepository.insert(
          workoutSetExerciseOption,
          txn,
        );
      }
    }

    await _setExerciseRepository.update(updatedSetExercise, txn);
  }

  Future<void> _batchCreateSetExercise({
    required WorkoutSetExerciseUpsertInput exerciseInput,
    required int index,
    required int setCount,
    required int workoutId,
    required WorkoutSet workoutSet,
    required Transaction txn,
    required WorkoutSet updatedWorkoutSet,
  }) async {
    final newPosition = setCount + 1 + index;
    final setExercisePosition = exerciseInput.position;
    final workoutSetExercise = WorkoutSetExercise.create(
      workoutVersion: workoutSet.workoutVersion,
      position: setExercisePosition,
      workoutId: workoutId,
      workoutSetId: workoutSet.id!,
      exerciseId: exerciseInput.exerciseId,
      minReps: exerciseInput.minReps,
      maxReps: exerciseInput.maxReps,
      toMaxReps: exerciseInput.toMaxReps,
      difficulty: exerciseInput.difficulty,
    );

    if (newPosition > setExercisePosition) {
      await txn.rawUpdate(
        """
        UPDATE ${WorkoutSetExercise.table} SET ${WorkoutSetExerciseColumns.position.value} = ${WorkoutSetExerciseColumns.position.value} + 1
        WHERE ${WorkoutSetExerciseColumns.workoutSetId.equal} AND ${WorkoutSetExerciseColumns.position.greaterThanOrEqual};
        """,
        [updatedWorkoutSet.id!, setExercisePosition],
      );
    }
    final setExerciseId =
        await _setExerciseRepository.insert(workoutSetExercise, txn);

    if (exerciseInput.alternativeExerciseIds != null) {
      for (int j = 0; j < exerciseInput.alternativeExerciseIds!.length; j++) {
        final alternativeExerciseId = exerciseInput.alternativeExerciseIds![j];
        final option = WorkoutSetExerciseOption.create(
          workoutVersion: workoutSet.workoutVersion,
          workoutId: workoutId,
          workoutSetId: workoutSet.id!,
          workoutSetExerciseId: setExerciseId,
          exerciseId: alternativeExerciseId,
          position: j + 1,
        );
        await _setExerciseOptionRepository.insert(
          option,
          txn,
        );
      }
    }
  }

  Future<void> _doBatchSetCreate({
    required WorkoutSetUpsertInput input,
    required Transaction txn,
    required int workoutId,
    required int workoutVersion,
    required Map<int, ExerciseDto> exerciseMap,
  }) async {
    final int workoutSetsCount = await _setRepository.count(
      where: WorkoutSetColumns.workoutId.equal,
      whereArgs: [workoutId],
      trx: txn,
    );
    final int extraSets = input.maxSets ?? input.minSets;
    final int perSetReps = input.exercises.fold(
      0,
      (acc, exercise) => acc + (exercise.maxReps ?? exercise.minReps),
    );
    final int setTotalReps = extraSets * perSetReps;
    final int newPosition = workoutSetsCount + 1;
    final int setPosition = input.position;

    if (setPosition < newPosition) {
      await txn.rawUpdate(
        """
        UPDATE ${WorkoutSet.table}
        SET ${WorkoutSetColumns.position.value} = ${WorkoutSetColumns.position.value} + 1
        WHERE ${WorkoutSetColumns.workoutId.equal} AND ${WorkoutSetColumns.position.greaterThanOrEqual};
        """,
        [workoutId, setPosition],
      );
    }

    final WorkoutSet workoutSet = WorkoutSet.create(
      workoutVersion: workoutVersion,
      position: setPosition,
      workoutId: workoutId,
      setType: input.setType,
      minSets: input.minSets,
      maxSets: input.maxSets,
      recommendedRestSecs: input.recommendedRestSecs,
      maxRestSecs: input.maxRestSecs,
      totalExercises: input.exercises.length,
      totalReps: setTotalReps,
    );
    final int setId = await _setRepository.insert(workoutSet, txn);

    for (int i = 0; i < input.exercises.length; i++) {
      final exerciseInput = input.exercises[i];
      final workoutSetExercise = WorkoutSetExercise.create(
        workoutVersion: workoutVersion,
        position: i + 1,
        workoutId: workoutId,
        workoutSetId: setId,
        exerciseId: exerciseInput.exerciseId,
        minReps: exerciseInput.minReps,
        maxReps: exerciseInput.maxReps,
        toMaxReps: exerciseInput.toMaxReps,
        difficulty: exerciseInput.difficulty,
      );
      final setExerciseId = await _setExerciseRepository.insert(
        workoutSetExercise,
        txn,
      );
      if (!exerciseMap.containsKey(exerciseInput.exerciseId)) {
        throw Exception('Exercise not found');
      }

      if (exerciseInput.alternativeExerciseIds != null) {
        for (int j = 0; j < exerciseInput.alternativeExerciseIds!.length; j++) {
          final alternativeExerciseId =
              exerciseInput.alternativeExerciseIds![j];
          final workoutSetExerciseOption = WorkoutSetExerciseOption.create(
            workoutVersion: workoutVersion,
            workoutId: workoutId,
            workoutSetId: setId,
            workoutSetExerciseId: setExerciseId,
            exerciseId: alternativeExerciseId,
            position: j + 1,
          );
          await _setExerciseOptionRepository.insert(
            workoutSetExerciseOption,
            txn,
          );
        }
      }
    }
  }
}
