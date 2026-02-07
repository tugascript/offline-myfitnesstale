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
        _logger.warning('Workout with id $id not found');
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout not found',
        ));
      }

      final List<WorkoutSet> sets = await _setRepository.selectMany(
        where: WorkoutSetColumns.workoutId.equal,
        whereArgs: [id],
        orderBy: WorkoutSetColumns.position.orderAsc,
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
          WorkoutSetExerciseColumns.position.orderAsc
        ].join(", "),
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
          WorkoutSetExerciseOptionColumns.position.orderAsc
        ].join(", "),
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
          final Set<Muscle> muscles = {};

          for (final set in workoutInput.sets) {
            final int setNum = (set.maxSets ?? set.minSets);
            totalSets += setNum;
            for (final exercise in set.exercises) {
              totalReps += setNum * (exercise.maxReps ?? exercise.minReps);
              muscleGroups.add(exercise.exercise.muscleGroup);
              muscles.addAll(exercise.exercise.muscles.primaryMuscles);
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
        where: ExerciseColumns.id.inList(exerciseIdSet.length),
        whereArgs: exerciseIdSet.toList(),
      );
      if (exerciseModels.length != exerciseIdSet.length) {
        _logger.info('Invalid exercise ids');
        return err(const ServiceError(
          type: SingleErrorTypes.invalidInput,
          description: 'Invalid exercise ids',
        ));
      }

      final List<WorkoutSet> workoutSets = await _setRepository.selectMany(
        where: WorkoutSetColumns.workoutId.equal,
        whereArgs: [workoutId],
        orderBy: [
          WorkoutSetColumns.workoutId.orderAsc,
          WorkoutSetColumns.position.orderAsc
        ].join(", "),
      );
      final int newPosition = workoutSets.length + 1;
      final int setPosition = position ?? newPosition;
      final int extraSets = maxSets ?? minSets;
      final int totalReps = exercises.fold(
        0,
        (acc, exercise) => acc + (exercise.maxReps ?? exercise.minReps),
      );
      final (
        WorkoutSet set,
        List<WorkoutSetExercise> setExercises,
        Map<int, List<WorkoutSetExerciseOption>> setExerciseOptions,
      ) = await _setRepository.startTransaction((txn) async {
        final WorkoutSet workoutSet = WorkoutSet.create(
          position: setPosition,
          workoutId: workoutId,
          setType: setType,
          minSets: minSets,
          maxSets: maxSets,
          recommendedRestSecs: recommendedRestSecs,
          maxRestSecs: maxRestSecs,
          totalExercises: exercises.length,
          totalReps: totalReps,
        );
        final setId = await _setRepository.insert(workoutSet, txn);

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

        final updatedWorkout = workout.copyWith(
          totalSets: workout.totalSets + extraSets,
          totalReps: workout.totalReps + totalReps,
          updatedAt: DateUtilities.getNowUtcUnix(),
        );
        await _repository.update(updatedWorkout, txn);
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
    _logger.info('Getting workout sets with workout id $workoutId');
    try {
      final List<WorkoutSet> workoutSets = await _setRepository.selectMany(
        where: WorkoutSetColumns.workoutId.equal,
        whereArgs: [workoutId],
        orderBy: [
          WorkoutSetColumns.workoutId.orderAsc,
          WorkoutSetColumns.position.orderAsc
        ].join(", "),
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
          WorkoutSetExerciseColumns.position.orderAsc
        ].join(", "),
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
          WorkoutSetExerciseOptionColumns.position.orderAsc
        ].join(", "),
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

  Future<Result<WorkoutSetDto, ServiceError<SingleErrorTypes>>> getWorkoutSet(
    int workoutSetId,
  ) async {
    try {
      final WorkoutSet? workoutSet = await _setRepository.selectOne(
        workoutSetId,
      );
      if (workoutSet == null) {
        _logger.info('Workout set with id $workoutSetId not found');
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Workout set with id: $workoutSetId not found',
          ),
        );
      }

      final List<WorkoutSetExercise> setExercises =
          await _setExerciseRepository.selectMany(
        where: WorkoutSetExerciseColumns.workoutSetId.equal,
        whereArgs: [workoutSetId],
      );
      if (setExercises.isEmpty) {
        _logger.info(
          'No workout set exercises found for workout set id $workoutSetId',
        );
        return ok(WorkoutSetDto.fromModel(workoutSet));
      }

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
        where: WorkoutSetExerciseOptionColumns.workoutSetId.equal,
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
        where: ExerciseColumns.id.inList(exerciseIds.length),
        whereArgs: exerciseIds.toList(),
      );
      final Map<int, ExerciseDto> exerciseMap = exercises.fold(
        {},
        (map, e) {
          map[e.id!] = ExerciseDto.fromModel(e);
          return map;
        },
      );

      _logger.info('Workout set with id $workoutSetId found successfully');
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

      final workout = await _repository.selectOne(workoutSet.workoutId);
      if (workout == null) {
        _logger.info('Workout with id ${workoutSet.workoutId} not found');
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout with id ${workoutSet.workoutId} not found',
        ));
      }

      final int totalSets = (workoutSet.maxSets ?? workoutSet.minSets);
      final List<WorkoutSetExercise> setExercises =
          await _setExerciseRepository.selectMany(
        where: WorkoutSetExerciseColumns.workoutSetId.equal,
        whereArgs: [workoutSetId],
      );
      final int totalReps = setExercises.fold(
        0,
        (acc, e) => acc + totalSets * (e.maxReps ?? e.minReps),
      );

      final position = workoutSet.position;
      final setCount = await _setRepository.count(
        where: WorkoutSetColumns.workoutId.equal,
        whereArgs: [workoutSet.workoutId],
      );

      await _setRepository.startTransaction((txn) async {
        final deleted = await _setRepository.deleteOne(workoutSetId, txn);
        if (!deleted) {
          throw Exception('Workout set failed to delete');
        }

        if (position != setCount) {
          await txn.rawQuery(
            "UPDATE ${WorkoutSet.table} SET position = position - 1 WHERE workout_id = ? AND position > ?",
            [workoutSet.workoutId, position],
          );
        }

        final updatedWorkout = workout.copyWith(
          totalSets: workout.totalSets - totalSets,
          totalReps: workout.totalReps - totalReps,
        );
        final updated = await _repository.update(updatedWorkout, txn);
        if (!updated) {
          throw Exception('Workout failed to update');
        }
      });

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

      final int? oldMaxSets = workoutSet.maxSets;
      final int oldMinSets = workoutSet.minSets;
      final updatedWorkoutSet = workoutSet.copyWith(
        setType: setType,
        minSets: minSets,
        recommendedRestSecs: recommendedRestSecs,
        maxSets: maxSets,
        maxRestSecs: maxRestSecs,
      );

      if (oldMaxSets == updatedWorkoutSet.maxSets &&
          oldMinSets == updatedWorkoutSet.minSets) {
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
      }

      final int addTotalSets =
          (updatedWorkoutSet.maxSets ?? updatedWorkoutSet.minSets) -
              (oldMaxSets ?? oldMinSets);
      if (addTotalSets == 0) {
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
      }

      final workout = await _repository.selectOne(updatedWorkoutSet.workoutId);
      if (workout == null) {
        _logger.warning(
          'Workout with id ${updatedWorkoutSet.workoutId} not found',
        );
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description:
              'Workout with id ${updatedWorkoutSet.workoutId} not found',
        ));
      }

      final List<WorkoutSetExercise> setExercises =
          await _setExerciseRepository.selectMany(
        where: WorkoutSetExerciseColumns.workoutSetId.equal,
        whereArgs: [workoutSetId],
      );
      final int addTotalReps = setExercises.fold(
        0,
        (acc, e) => acc + addTotalSets * (e.maxReps ?? e.minReps),
      );

      await _setRepository.startTransaction((txn) async {
        final updated = await _setRepository.update(updatedWorkoutSet, txn);
        if (!updated) {
          throw Exception('Error updating workout set: $workoutSetId');
        }

        final updateWorkout = workout.copyWith(
          totalSets: workout.totalSets + addTotalSets,
          totalReps: workout.totalReps + addTotalReps,
        );
        final updatedWorkout = await _repository.update(updateWorkout, txn);
        if (!updatedWorkout) {
          throw Exception('Error updating workout: ${workout.id}');
        }
      });

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
      await _setRepository.startTransaction((txn) async {
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
        where: WorkoutSetExerciseColumns.workoutSetId.equal,
        whereArgs: [workoutSetId],
        orderBy: WorkoutSetExerciseColumns.position.orderAsc,
      );
      if (workoutSetExercises.isEmpty) {
        return ok([]);
      }

      final exerciseOptions = await _setExerciseOptionRepository.selectMany(
        where: WorkoutSetExerciseOptionColumns.workoutSetExerciseId.equal,
        whereArgs: [workoutSetId],
        orderBy: WorkoutSetExerciseOptionColumns.position.orderAsc,
      );

      final exerciseIds = {
        ...workoutSetExercises.map((e) => e.exerciseId),
        ...exerciseOptions.map((e) => e.exerciseId),
      };
      final exercises = await _exerciseRepository.selectMany(
        where: ExerciseColumns.id.inList(exerciseIds.length),
        whereArgs: exerciseIds.toList(),
      );
      if (exercises.length != exerciseIds.length) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Some exercises with not found',
        ));
      }

      final Map<int, ExerciseDto> exerciseMap = exercises.fold(
        {},
        (map, e) {
          map[e.id!] = ExerciseDto.fromModel(e);
          return map;
        },
      );
      if (exerciseOptions.isEmpty) {
        return ok(
          workoutSetExercises
              .map(
                (e) => WorkoutSetExerciseDto.fromModel(
                  e,
                  exercise: exerciseMap[e.exerciseId],
                ),
              )
              .toList(),
        );
      }

      final Map<int, List<WorkoutSetExerciseOptionDto>> optionsMap =
          exerciseOptions.fold(
        {},
        (map, o) => map
          ..update(
            o.workoutSetExerciseId,
            (l) => l
              ..add(
                WorkoutSetExerciseOptionDto.fromModel(
                  o,
                  exercise: exerciseMap[o.exerciseId],
                ),
              ),
            ifAbsent: () => [
              WorkoutSetExerciseOptionDto.fromModel(
                o,
                exercise: exerciseMap[o.exerciseId],
              ),
            ],
          ),
      );

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
        where: WorkoutSetExerciseOptionColumns.workoutSetExerciseId.equal,
        whereArgs: [workoutSetExerciseId],
        orderBy: WorkoutSetExerciseOptionColumns.position.orderAsc,
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
        where: ExerciseColumns.id.inList(exerciseIds.length),
        whereArgs: exerciseIds.toList(),
      );
      if (exercises.length != exerciseIds.length) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Some exercises with not found',
        ));
      }

      final Map<int, ExerciseDto> exerciseMap = exercises.fold(
        {},
        (map, e) {
          map[e.id!] = ExerciseDto.fromModel(e);
          return map;
        },
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

      final workout = await _repository.selectOne(workoutSet.workoutId);
      if (workout == null) {
        _logger.info('Workout with id ${workoutSet.workoutId} not found');
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout with id ${workoutSet.workoutId} not found',
        ));
      }

      final exerciseIds = {exerciseId, ...?alternativeExerciseIds};
      final exercises = await _exerciseRepository.selectMany(
        where: exerciseIds.length == 1
            ? ExerciseColumns.id.equal
            : ExerciseColumns.id.inList(exerciseIds.length),
        whereArgs: exerciseIds.toList(),
      );
      if (exercises.length != exerciseIds.length) {
        _logger.info('Some exercises not found');
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Some exercises not found',
        ));
      }
      final Map<int, ExerciseDto> exerciseMap = exercises.fold(
        {},
        (map, e) {
          map[e.id!] = ExerciseDto.fromModel(e);
          return map;
        },
      );

      final count = await _setExerciseRepository.count(
        where: WorkoutSetExerciseColumns.workoutSetId.equal,
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
      final int totalReps =
          (workoutSet.maxSets ?? workoutSet.minSets) * (maxReps ?? minReps);
      final (int setExerciseId, List<WorkoutSetExerciseOptionDto>? options) =
          await _setExerciseRepository.startTransaction(
        (txn) async {
          if (newPosition > setExercisePosition) {
            await txn.rawQuery(
              """
              UPDATE ${WorkoutSetExercise.table} SET ${WorkoutSetExerciseColumns.position.value} = ${WorkoutSetExerciseColumns.position.value} + 1
              WHERE ${WorkoutSetExerciseColumns.workoutSetId.equal} AND ${WorkoutSetExerciseColumns.position.greaterThanOrEqual};
              """,
              [workoutSetId, setExercisePosition],
            );
          }

          final setExerciseId = await _setExerciseRepository.insert(
            workoutSetExercise,
            txn,
          );

          final updatedWorkoutSet = workoutSet.copyWith(
            totalReps: workoutSet.totalReps + totalReps,
          );
          await _setRepository.update(updatedWorkoutSet, txn);

          final updatedWorkout = workout.copyWith(
            totalReps: workout.totalReps + totalReps,
          );
          await _repository.update(updatedWorkout, txn);

          if (alternativeExerciseIds == null) {
            return (setExerciseId, null);
          }

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
            final optionId = await _setExerciseOptionRepository.insert(
              option,
              txn,
            );
            options.add(WorkoutSetExerciseOptionDto.fromModel(
              option.copyWith(id: optionId),
              exercise: exerciseMap[alternativeExerciseId],
            ));
          }

          return (setExerciseId, options);
        },
      );

      return ok(WorkoutSetExerciseDto.fromModel(
        workoutSetExercise,
        exercise: exerciseMap[exerciseId]!,
        options: options,
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
        where: WorkoutSetExerciseColumns.workoutSetId.equal,
        whereArgs: [setExercise.workoutSetId],
      );
      if (count == 1) {
        _logger.info("At least one exercise is required per set");
        return err(const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'At least one exercise is required per set',
        ));
      }

      final set = await _setRepository.selectOne(setExercise.workoutSetId);
      if (set == null) {
        _logger.warning(
          'Workout set with id ${setExercise.workoutSetId} not found',
        );
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description:
              'Workout set with id ${setExercise.workoutSetId} not found',
        ));
      }

      final workout = await _repository.selectOne(set.workoutId);
      if (workout == null) {
        _logger.warning(
          'Workout with id ${set.workoutId} not found',
        );
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout with id ${set.workoutId} not found',
        ));
      }

      final int totalReps = (set.maxSets ?? set.minSets) *
          (setExercise.maxReps ?? setExercise.minReps);
      await _setExerciseRepository.startTransaction((txn) async {
        _logger.info("Txn delete set exercise");
        final deleted = await _setExerciseRepository.deleteOne(
          workoutSetExerciseId,
          txn,
        );
        if (!deleted) {
          throw Exception(
            "Failed to delete set exercise with id $workoutSetExerciseId",
          );
        }

        if (position != count) {
          _logger.info("Txn updating existing positions");
          await txn.rawUpdate(
            """
          UPDATE ${WorkoutSetExercise.table} SET ${WorkoutSetExerciseColumns.position.value} = ${WorkoutSetExerciseColumns.position.value} - 1 
          WHERE ${WorkoutSetExerciseColumns.workoutSetId.equal} AND ${WorkoutSetExerciseColumns.position.greaterThan};
          """,
            [setExercise.workoutSetId, position],
          );
        }

        _logger.info("Txn updating set total reps");
        final updatedSet = set.copyWith(
          totalReps: set.totalReps - totalReps,
        );
        await _setRepository.update(updatedSet, txn);

        _logger.info("Txn updating workout total reps");
        final updatedWorkout = workout.copyWith(
          totalReps: workout.totalReps - totalReps,
        );
        await _repository.update(updatedWorkout, txn);
      });

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

      final int oldBaseReps =
          (workoutSetExercise.maxReps ?? workoutSetExercise.minReps);
      final WorkoutSetExercise updatedWorkoutSetExercise =
          workoutSetExercise.copyWith(
        minReps: minReps,
        maxReps: maxReps,
        difficulty: difficulty,
        updatedAt: DateUtilities.getNowUtcUnix(),
      );
      final int newBaseReps = (updatedWorkoutSetExercise.maxReps ??
          updatedWorkoutSetExercise.minReps);
      if (newBaseReps == oldBaseReps) {
        await _setExerciseRepository.update(updatedWorkoutSetExercise);
        _logger.info(
          'Updated workout set exercise with id $workoutSetExerciseId',
        );
        return ok(WorkoutSetExerciseDto.fromModel(updatedWorkoutSetExercise));
      }

      final WorkoutSet? workoutSet = await _setRepository.selectOne(
        workoutSetExercise.workoutSetId,
      );
      if (workoutSet == null) {
        _logger.warning(
          'Workout set with id ${workoutSetExercise.workoutSetId} not found',
        );
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description:
              'Workout set with id ${workoutSetExercise.workoutSetId} not found',
        ));
      }

      final workout = await _repository.selectOne(workoutSet.workoutId);
      if (workout == null) {
        _logger.warning(
          'Workout with id ${workoutSet.workoutId} not found',
        );
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Workout with id ${workoutSet.workoutId} not found',
        ));
      }

      final int baseSets = workoutSet.maxSets ?? workoutSet.minSets;
      final int oldTotalReps = baseSets * oldBaseReps;
      final int newTotalReps = baseSets * newBaseReps;
      await _setExerciseRepository.startTransaction((txn) async {
        _logger.info("Txn updating set exercise");
        final updated =
            await _setExerciseRepository.update(updatedWorkoutSetExercise, txn);
        if (!updated) {
          throw Exception(
            'Error updating workout set exercise: $workoutSetExerciseId',
          );
        }

        final addTotalReps = newTotalReps - oldTotalReps;
        _logger.info("Txn updating set total reps");
        final updatedWorkoutSet = workoutSet.copyWith(
          totalReps: workoutSet.totalReps + addTotalReps,
        );
        final setUpdated = await _setRepository.update(updatedWorkoutSet, txn);
        if (!setUpdated) {
          throw Exception(
            'Error updating workout set: ${workoutSet.id}',
          );
        }

        _logger.info("Txn updating workout total reps");
        final updatedWorkout = workout.copyWith(
          totalReps: workout.totalReps + addTotalReps,
        );
        final workoutUpdated = await _repository.update(updatedWorkout, txn);
        if (!workoutUpdated) {
          throw Exception(
            'Error updating workout: ${workout.id}',
          );
        }
      });

      _logger.info(
        'Updated workout set with id ${workoutSetExercise.workoutSetId}',
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
        where: WorkoutSetExerciseColumns.workoutSetId.equal,
        whereArgs: [setExercise.workoutSetId],
      );
      if (position < 1 || position > count) {
        _logger.warning('Invalid position');
        return err(const ServiceError(
          type: SingleErrorTypes.invalidInput,
          description: 'Position out of bounds',
        ));
      }

      final oldPosition = setExercise.position;
      final updatedSetExercise = setExercise.copyWith(
        position: position,
        updatedAt: DateUtilities.getNowUtcUnix(),
      );
      await _setExerciseRepository.startTransaction((txn) async {
        if (oldPosition < position) {
          await txn.rawUpdate(
            """
            UPDATE ${WorkoutSetExercise.table} SET ${WorkoutSetExerciseColumns.position.value} = ${WorkoutSetExerciseColumns.position.value} - 1
            WHERE ${WorkoutSetExerciseColumns.workoutSetId.equal} AND ${WorkoutSetExerciseColumns.position.greaterThan} AND ${WorkoutSetExerciseColumns.position.lessThanOrEqual};
            """,
            [setExercise.workoutSetId, oldPosition, position],
          );
        } else {
          await txn.rawUpdate(
            """
            UPDATE ${WorkoutSetExercise.table} SET ${WorkoutSetExerciseColumns.position.value} = ${WorkoutSetExerciseColumns.position.value} + 1
            WHERE ${WorkoutSetExerciseColumns.workoutSetId.equal} AND ${WorkoutSetExerciseColumns.position.greaterThanOrEqual} AND ${WorkoutSetExerciseColumns.position.lessThan};
            """,
            [setExercise.workoutSetId, position, oldPosition],
          );
        }
        await _setExerciseRepository.update(updatedSetExercise, txn);
      });

      _logger.info(
        'Workout set exercise with id $workoutSetExerciseId updated successfully',
      );
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
        where: WorkoutSetExerciseOptionColumns.workoutSetExerciseId.equal,
        whereArgs: [workoutSetExerciseId],
        orderBy: WorkoutSetExerciseOptionColumns.position.orderAsc,
      );

      if (exerciseOptions.isEmpty) {
        return ok([]);
      }

      final exerciseIds = exerciseOptions.map((e) => e.exerciseId).toSet();
      final exercises = await _exerciseRepository.selectMany(
        where: ExerciseColumns.id.inList(exerciseIds.length),
        whereArgs: exerciseIds.toList(),
      );

      final Map<int, ExerciseDto> exerciseMap = exercises.fold(
        {},
        (map, e) {
          map[e.id!] = ExerciseDto.fromModel(e);
          return map;
        },
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
          'Workout set exercise option with id $workoutSetExerciseOptionId not found',
        );
        return err(ServiceError(
          type: SingleErrorTypes.notFound,
          description:
              'Workout set exercise option with id $workoutSetExerciseOptionId not found',
        ));
      }

      final exercise = await _exerciseRepository.selectOne(option.exerciseId);
      if (exercise == null) {
        _logger.warning('Exercise with id ${option.exerciseId} not found');
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Exercise with id ${option.exerciseId} not found',
          ),
        );
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
      'Adding workout set exercise option for set exercise $workoutSetExerciseId',
    );
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
        where: WorkoutSetExerciseOptionColumns.workoutSetExerciseId.equal,
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
        final id = await _setExerciseOptionRepository.startTransaction(
          (txn) async {
            await txn.rawUpdate(
              "UPDATE ${WorkoutSetExerciseOption.table} SET position = position + 1 WHERE ${WorkoutSetExerciseOptionColumns.workoutSetExerciseId.equal} AND ${WorkoutSetExerciseOptionColumns.position.greaterThanOrEqual}",
              [workoutSetExerciseId, optionPosition],
            );
            return await _setExerciseOptionRepository.insert(option, txn);
          },
        );
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
        final deleted = await _setExerciseOptionRepository.deleteOne(
          workoutSetExerciseOptionId,
        );
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

      await _setExerciseOptionRepository.startTransaction(
        (txn) async {
          final deleted = await _setExerciseOptionRepository.deleteOne(
            workoutSetExerciseOptionId,
            txn,
          );
          if (!deleted) {
            throw Exception('Workout set exercise option failed to delete');
          }

          await txn.rawUpdate(
            """
          UPDATE ${WorkoutSetExerciseOption.table} SET ${WorkoutSetExerciseOptionColumns.position.value} = ${WorkoutSetExerciseOptionColumns.position.value} - 1 
          WHERE ${WorkoutSetExerciseOptionColumns.workoutSetExerciseId.equal} AND ${WorkoutSetExerciseOptionColumns.position.greaterThan};
          """,
            [option.workoutSetExerciseId, position],
          );
        },
      );

      _logger.info(
        'Workout set exercise option with id $workoutSetExerciseOptionId deleted successfully',
      );
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
      updateWorkoutSetExerciseOptionPosition({
    required int workoutSetExerciseOptionId,
    required int position,
  }) async {
    _logger.info(
        "Updating workout set exercise option with id: $workoutSetExerciseOptionId position");
    try {
      final option = await _setExerciseOptionRepository.selectOne(
        workoutSetExerciseOptionId,
      );
      if (option == null) {
        _logger.warning(
          'Workout set exercise option with id $workoutSetExerciseOptionId not found',
        );
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description:
                'Workout set exercise option with id $workoutSetExerciseOptionId not found',
          ),
        );
      }

      if (position == option.position) {
        _logger.info('Position already set');
        return ok(WorkoutSetExerciseOptionDto.fromModel(option));
      }

      final count = await _setExerciseOptionRepository.count(
        where: WorkoutSetExerciseOptionColumns.workoutSetExerciseId.equal,
        whereArgs: [option.workoutSetExerciseId],
      );
      if (position < 1 || position > count) {
        _logger.warning('Invalid position');
        return err(
          const ServiceError(
            type: SingleErrorTypes.operationFailure,
            description: 'Position out of bounds',
          ),
        );
      }

      final oldPosition = option.position;
      final updatedOption = option.copyWith(
        position: position,
        updatedAt: DateUtilities.getNowUtcUnix(),
      );
      await _setExerciseOptionRepository.startTransaction((txn) async {
        if (oldPosition < position) {
          await txn.rawUpdate(
            """
            UPDATE ${WorkoutSetExerciseOption.table} SET ${WorkoutSetExerciseOptionColumns.position.value} = ${WorkoutSetExerciseOptionColumns.position.value} - 1
            WHERE ${WorkoutSetExerciseOptionColumns.workoutSetExerciseId.equal} AND ${WorkoutSetExerciseOptionColumns.position.greaterThan} AND ${WorkoutSetExerciseOptionColumns.position.lessThanOrEqual};
            """,
            [option.workoutSetExerciseId, oldPosition, position],
          );
        } else {
          await txn.rawUpdate(
            """
            UPDATE ${WorkoutSetExerciseOption.table} SET ${WorkoutSetExerciseOptionColumns.position.value} = ${WorkoutSetExerciseOptionColumns.position.value} + 1
            WHERE ${WorkoutSetExerciseOptionColumns.workoutSetExerciseId.equal} AND ${WorkoutSetExerciseOptionColumns.position.greaterThanOrEqual} AND ${WorkoutSetExerciseOptionColumns.position.lessThan};
            """,
            [option.workoutSetExerciseId, position, oldPosition],
          );
        }
        await _setExerciseOptionRepository.update(updatedOption, txn);
      });

      _logger.info(
        'Workout set exercise option with id $workoutSetExerciseOptionId updated successfully',
      );
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
