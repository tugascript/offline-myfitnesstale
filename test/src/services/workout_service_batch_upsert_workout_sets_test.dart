import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';

import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/models/exercise_model.dart';
import 'package:myfitnesstale/src/models/workout_model.dart';
import 'package:myfitnesstale/src/models/workout_set_exercise_model.dart';
import 'package:myfitnesstale/src/models/workout_set_exercise_option_model.dart';
import 'package:myfitnesstale/src/models/workout_set_model.dart';
import 'package:myfitnesstale/src/services/common/errors.dart';
import 'package:myfitnesstale/src/services/workout_service.dart';

import '../../support/test_database.dart';

void main() {
  final testDatabase = TestDatabase();
  final workoutService = WorkoutService();
  int seedCounter = 0;

  String uniqueName(String prefix) => '$prefix-${seedCounter++}';

  Future<int> createWorkout(
    Database db, {
    int totalSets = 0,
    int totalReps = 0,
    Set<MuscleGroup> muscleGroups = const <MuscleGroup>{},
    Set<Muscle> muscles = const <Muscle>{},
  }) async {
    final workout = Workout.create(
      name: uniqueName('workout'),
      difficulty: Difficulty.intermediate,
      totalSets: totalSets,
      totalReps: totalReps,
      muscleGroups: muscleGroups,
      muscles: muscles,
    );
    return db.insert(Workout.table, workout.toMap());
  }

  Future<int> createExercise(
    Database db, {
    required MuscleGroup muscleGroup,
    required Set<Muscle> primaryMuscles,
  }) async {
    final exercise = Exercise.create(
      name: uniqueName('exercise'),
      muscleGroup: muscleGroup,
      muscles: ExerciseMuscles(
        primaryMuscles: primaryMuscles,
        secondaryMuscles: const <Muscle>{},
      ),
      difficulty: Difficulty.beginner,
    );
    return db.insert(Exercise.table, exercise.toMap());
  }

  Future<int> createWorkoutSet(
    Database db, {
    required int workoutId,
    required int position,
    required int minSets,
    required int maxSets,
    required int totalExercises,
    required int totalReps,
    WorkoutSetType setType = WorkoutSetType.standard,
    int recommendedRestSecs = 60,
    int? maxRestSecs,
  }) async {
    final set = WorkoutSet.create(
      workoutId: workoutId,
      position: position,
      setType: setType,
      minSets: minSets,
      maxSets: maxSets,
      recommendedRestSecs: recommendedRestSecs,
      maxRestSecs: maxRestSecs,
      totalExercises: totalExercises,
      totalReps: totalReps,
    );
    return db.insert(WorkoutSet.table, set.toMap());
  }

  Future<int> createWorkoutSetExercise(
    Database db, {
    required int workoutId,
    required int workoutSetId,
    required int exerciseId,
    required int position,
    required int minReps,
    int? maxReps,
    bool toMaxReps = false,
  }) async {
    final setExercise = WorkoutSetExercise.create(
      workoutId: workoutId,
      workoutSetId: workoutSetId,
      exerciseId: exerciseId,
      position: position,
      minReps: minReps,
      maxReps: maxReps,
      toMaxReps: toMaxReps,
    );
    return db.insert(WorkoutSetExercise.table, setExercise.toMap());
  }

  Future<int> createWorkoutSetExerciseOption(
    Database db, {
    required int workoutId,
    required int workoutSetId,
    required int workoutSetExerciseId,
    required int exerciseId,
    required int position,
  }) async {
    final option = WorkoutSetExerciseOption.create(
      workoutId: workoutId,
      workoutSetId: workoutSetId,
      workoutSetExerciseId: workoutSetExerciseId,
      exerciseId: exerciseId,
      position: position,
    );
    return db.insert(WorkoutSetExerciseOption.table, option.toMap());
  }

  setUpAll(() async {
    await testDatabase.initialize();
  });

  tearDown(() async {
    await testDatabase.clearWorkoutTables();
  });

  tearDownAll(() async {
    await testDatabase.destroy();
  });

  test(
    'creates workout sets, set exercises, options and updates workout aggregates',
    () async {
      final db = await testDatabase.db;
      final workoutId = await createWorkout(db);
      final exerciseA = await createExercise(
        db,
        muscleGroup: MuscleGroup.push,
        primaryMuscles: {Muscle.chest},
      );
      final exerciseB = await createExercise(
        db,
        muscleGroup: MuscleGroup.pull,
        primaryMuscles: {Muscle.lats},
      );
      final alternativeExercise = await createExercise(
        db,
        muscleGroup: MuscleGroup.push,
        primaryMuscles: {Muscle.triceps},
      );

      final result = await workoutService.batchUpsertWorkoutSets(
        workoutId: workoutId,
        idsToDelete: <int>{},
        inputs: [
          WorkoutSetUpsertInput(
            setType: WorkoutSetType.standard,
            minSets: 2,
            maxSets: 3,
            recommendedRestSecs: 90,
            maxRestSecs: 120,
            position: 1,
            exercises: [
              WorkoutSetExerciseUpsertInput(
                exerciseId: exerciseA,
                position: 1,
                minReps: 8,
                maxReps: 10,
                alternativeExerciseIds: [alternativeExercise],
              ),
              WorkoutSetExerciseUpsertInput(
                exerciseId: exerciseB,
                position: 2,
                minReps: 6,
                maxReps: 6,
              ),
            ],
          ),
        ],
      );

      expect(result.isOk(), isTrue);

      final workout = Workout.fromMap(
        (await db.query(
          Workout.table,
          where: '${WorkoutColumns.id.value} = ?',
          whereArgs: [workoutId],
          limit: 1,
        ))
            .single,
      );
      expect(workout.totalSets, 3);
      expect(workout.totalReps, 48);
      expect(workout.muscleGroups, {MuscleGroup.push, MuscleGroup.pull});
      expect(workout.muscles, {Muscle.chest, Muscle.lats});

      final createdSets = (await db.query(
        WorkoutSet.table,
        where: '${WorkoutSetColumns.workoutId.value} = ?',
        whereArgs: [workoutId],
        orderBy: WorkoutSetColumns.position.orderAsc,
      ))
          .map(WorkoutSet.fromMap)
          .toList();
      expect(createdSets, hasLength(1));
      expect(createdSets.single.totalExercises, 2);
      expect(createdSets.single.totalReps, 48);

      final createdSetExercises = (await db.query(
        WorkoutSetExercise.table,
        where: '${WorkoutSetExerciseColumns.workoutSetId.value} = ?',
        whereArgs: [createdSets.single.id],
        orderBy: WorkoutSetExerciseColumns.position.orderAsc,
      ))
          .map(WorkoutSetExercise.fromMap)
          .toList();
      expect(createdSetExercises, hasLength(2));
      expect(
          createdSetExercises.map((e) => e.exerciseId), [exerciseA, exerciseB]);
      expect(createdSetExercises.map((e) => e.position), [1, 2]);

      final options = (await db.query(
        WorkoutSetExerciseOption.table,
        where:
            '${WorkoutSetExerciseOptionColumns.workoutSetExerciseId.value} = ?',
        whereArgs: [createdSetExercises.first.id],
        orderBy: WorkoutSetExerciseOptionColumns.position.orderAsc,
      ))
          .map(WorkoutSetExerciseOption.fromMap)
          .toList();
      expect(options, hasLength(1));
      expect(options.single.exerciseId, alternativeExercise);
      expect(options.single.position, 1);
    },
  );

  test('updates existing set exercise and replaces alternative options',
      () async {
    final db = await testDatabase.db;
    final workoutId = await createWorkout(
      db,
      totalSets: 2,
      totalReps: 20,
      muscleGroups: {MuscleGroup.push},
      muscles: {Muscle.chest},
    );
    final originalExercise = await createExercise(
      db,
      muscleGroup: MuscleGroup.push,
      primaryMuscles: {Muscle.chest},
    );
    final oldAlternative = await createExercise(
      db,
      muscleGroup: MuscleGroup.push,
      primaryMuscles: {Muscle.triceps},
    );
    final updatedExercise = await createExercise(
      db,
      muscleGroup: MuscleGroup.legs,
      primaryMuscles: {Muscle.quadriceps},
    );
    final newAlternative = await createExercise(
      db,
      muscleGroup: MuscleGroup.legs,
      primaryMuscles: {Muscle.hamstrings},
    );

    final setId = await createWorkoutSet(
      db,
      workoutId: workoutId,
      position: 1,
      minSets: 2,
      maxSets: 2,
      totalExercises: 1,
      totalReps: 20,
    );
    final setExerciseId = await createWorkoutSetExercise(
      db,
      workoutId: workoutId,
      workoutSetId: setId,
      exerciseId: originalExercise,
      position: 1,
      minReps: 10,
      maxReps: 10,
    );
    await createWorkoutSetExerciseOption(
      db,
      workoutId: workoutId,
      workoutSetId: setId,
      workoutSetExerciseId: setExerciseId,
      exerciseId: oldAlternative,
      position: 1,
    );

    final result = await workoutService.batchUpsertWorkoutSets(
      workoutId: workoutId,
      idsToDelete: <int>{},
      inputs: [
        WorkoutSetUpsertInput(
          id: setId,
          setType: WorkoutSetType.drop,
          minSets: 3,
          maxSets: 4,
          recommendedRestSecs: 120,
          maxRestSecs: 180,
          position: 1,
          exercises: [
            WorkoutSetExerciseUpsertInput(
              id: setExerciseId,
              exerciseId: updatedExercise,
              position: 1,
              minReps: 7,
              maxReps: 9,
              toMaxReps: true,
              alternativeExerciseIds: [newAlternative, oldAlternative],
            ),
          ],
        ),
      ],
    );

    expect(result.isOk(), isTrue);

    final updatedSet = WorkoutSet.fromMap(
      (await db.query(
        WorkoutSet.table,
        where: '${WorkoutSetColumns.id.value} = ?',
        whereArgs: [setId],
        limit: 1,
      ))
          .single,
    );
    expect(updatedSet.setType, WorkoutSetType.drop);
    expect(updatedSet.minSets, 3);
    expect(updatedSet.maxSets, 4);
    expect(updatedSet.totalExercises, 1);
    expect(updatedSet.totalReps, 36);
    expect(updatedSet.recommendedRestSecs, 120);
    expect(updatedSet.maxRestSecs, 180);

    final updatedSetExercise = WorkoutSetExercise.fromMap(
      (await db.query(
        WorkoutSetExercise.table,
        where: '${WorkoutSetExerciseColumns.id.value} = ?',
        whereArgs: [setExerciseId],
        limit: 1,
      ))
          .single,
    );
    expect(updatedSetExercise.exerciseId, updatedExercise);
    expect(updatedSetExercise.minReps, 7);
    expect(updatedSetExercise.maxReps, 9);
    expect(updatedSetExercise.toMaxReps, isTrue);

    final updatedOptions = (await db.query(
      WorkoutSetExerciseOption.table,
      where:
          '${WorkoutSetExerciseOptionColumns.workoutSetExerciseId.value} = ?',
      whereArgs: [setExerciseId],
      orderBy: WorkoutSetExerciseOptionColumns.position.orderAsc,
    ))
        .map(WorkoutSetExerciseOption.fromMap)
        .toList();
    expect(updatedOptions, hasLength(2));
    expect(updatedOptions.map((o) => o.exerciseId),
        [newAlternative, oldAlternative]);
    expect(updatedOptions.map((o) => o.position), [1, 2]);

    final workout = Workout.fromMap(
      (await db.query(
        Workout.table,
        where: '${WorkoutColumns.id.value} = ?',
        whereArgs: [workoutId],
        limit: 1,
      ))
          .single,
    );
    expect(workout.totalSets, 4);
    expect(workout.totalReps, 36);
    expect(workout.muscleGroups, {MuscleGroup.legs});
    expect(workout.muscles, {Muscle.quadriceps});
  });

  test('deletes set ids and compacts remaining set positions', () async {
    final db = await testDatabase.db;
    final workoutId = await createWorkout(db, totalSets: 2, totalReps: 20);
    final exerciseA = await createExercise(
      db,
      muscleGroup: MuscleGroup.push,
      primaryMuscles: {Muscle.chest},
    );
    final exerciseB = await createExercise(
      db,
      muscleGroup: MuscleGroup.pull,
      primaryMuscles: {Muscle.lats},
    );

    final setToDelete = await createWorkoutSet(
      db,
      workoutId: workoutId,
      position: 1,
      minSets: 1,
      maxSets: 1,
      totalExercises: 1,
      totalReps: 10,
    );
    final setToKeep = await createWorkoutSet(
      db,
      workoutId: workoutId,
      position: 2,
      minSets: 1,
      maxSets: 1,
      totalExercises: 1,
      totalReps: 10,
    );
    await createWorkoutSetExercise(
      db,
      workoutId: workoutId,
      workoutSetId: setToDelete,
      exerciseId: exerciseA,
      position: 1,
      minReps: 10,
      maxReps: 10,
    );
    final keptSetExerciseId = await createWorkoutSetExercise(
      db,
      workoutId: workoutId,
      workoutSetId: setToKeep,
      exerciseId: exerciseB,
      position: 1,
      minReps: 10,
      maxReps: 10,
    );

    final result = await workoutService.batchUpsertWorkoutSets(
      workoutId: workoutId,
      idsToDelete: {setToDelete},
      inputs: [
        WorkoutSetUpsertInput(
          id: setToKeep,
          setType: WorkoutSetType.standard,
          minSets: 1,
          maxSets: 1,
          recommendedRestSecs: 60,
          maxRestSecs: null,
          position: 1,
          exercises: [
            WorkoutSetExerciseUpsertInput(
              id: keptSetExerciseId,
              exerciseId: exerciseB,
              position: 1,
              minReps: 10,
              maxReps: 10,
            ),
          ],
        ),
      ],
    );

    expect(result.isOk(), isTrue);

    final sets = (await db.query(
      WorkoutSet.table,
      where: '${WorkoutSetColumns.workoutId.value} = ?',
      whereArgs: [workoutId],
      orderBy: WorkoutSetColumns.position.orderAsc,
    ))
        .map(WorkoutSet.fromMap)
        .toList();
    expect(sets, hasLength(1));
    expect(sets.single.id, setToKeep);
    expect(sets.single.position, 1);

    final deletedSetExercises = await db.query(
      WorkoutSetExercise.table,
      where: '${WorkoutSetExerciseColumns.workoutSetId.value} = ?',
      whereArgs: [setToDelete],
    );
    expect(deletedSetExercises, isEmpty);
  });

  test('deletes all sets when inputs are empty and idsToDelete is not empty',
      () async {
    final db = await testDatabase.db;
    final workoutId = await createWorkout(
      db,
      totalSets: 3,
      totalReps: 24,
      muscleGroups: {MuscleGroup.push},
      muscles: {Muscle.chest},
    );
    final exerciseId = await createExercise(
      db,
      muscleGroup: MuscleGroup.push,
      primaryMuscles: {Muscle.chest},
    );

    final setA = await createWorkoutSet(
      db,
      workoutId: workoutId,
      position: 1,
      minSets: 1,
      maxSets: 1,
      totalExercises: 1,
      totalReps: 8,
    );
    final setB = await createWorkoutSet(
      db,
      workoutId: workoutId,
      position: 2,
      minSets: 2,
      maxSets: 2,
      totalExercises: 1,
      totalReps: 16,
    );
    await createWorkoutSetExercise(
      db,
      workoutId: workoutId,
      workoutSetId: setA,
      exerciseId: exerciseId,
      position: 1,
      minReps: 8,
      maxReps: 8,
    );
    await createWorkoutSetExercise(
      db,
      workoutId: workoutId,
      workoutSetId: setB,
      exerciseId: exerciseId,
      position: 1,
      minReps: 8,
      maxReps: 8,
    );

    final result = await workoutService.batchUpsertWorkoutSets(
      workoutId: workoutId,
      inputs: const [],
      idsToDelete: {setA, setB},
    );

    expect(result.isOk(), isTrue);

    final remainingSets = await db.query(
      WorkoutSet.table,
      where: '${WorkoutSetColumns.workoutId.value} = ?',
      whereArgs: [workoutId],
    );
    expect(remainingSets, isEmpty);

    final remainingSetExercises = await db.query(
      WorkoutSetExercise.table,
      where: '${WorkoutSetExerciseColumns.workoutId.value} = ?',
      whereArgs: [workoutId],
    );
    expect(remainingSetExercises, isEmpty);

    final workout = Workout.fromMap(
      (await db.query(
        Workout.table,
        where: '${WorkoutColumns.id.value} = ?',
        whereArgs: [workoutId],
        limit: 1,
      ))
          .single,
    );
    expect(workout.totalSets, 0);
    expect(workout.totalReps, 0);
    expect(workout.muscleGroups, isEmpty);
    expect(workout.muscles, isEmpty);
  });

  test('returns notFound when workout does not exist', () async {
    final result = await workoutService.batchUpsertWorkoutSets(
      workoutId: -1,
      idsToDelete: <int>{},
      inputs: const <WorkoutSetUpsertInput>[],
    );

    expect(result.isErr(), isTrue);
    expect(result.error.type, SingleErrorTypes.notFound);
  });

  test('returns notFound when at least one exercise id does not exist',
      () async {
    final db = await testDatabase.db;
    final workoutId = await createWorkout(db);

    final result = await workoutService.batchUpsertWorkoutSets(
      workoutId: workoutId,
      idsToDelete: <int>{},
      inputs: const [
        WorkoutSetUpsertInput(
          setType: WorkoutSetType.standard,
          minSets: 1,
          maxSets: 1,
          recommendedRestSecs: 60,
          position: 1,
          exercises: [
            WorkoutSetExerciseUpsertInput(
              exerciseId: 999999,
              position: 1,
              minReps: 8,
              maxReps: 10,
            ),
          ],
        ),
      ],
    );

    expect(result.isErr(), isTrue);
    expect(result.error.type, SingleErrorTypes.notFound);
  });

  test('rolls back transaction when a set exercise update fails', () async {
    final db = await testDatabase.db;
    final workoutId = await createWorkout(
      db,
      totalSets: 1,
      totalReps: 10,
      muscleGroups: {MuscleGroup.push},
      muscles: {Muscle.chest},
    );
    final originalExercise = await createExercise(
      db,
      muscleGroup: MuscleGroup.push,
      primaryMuscles: {Muscle.chest},
    );
    final replacementExercise = await createExercise(
      db,
      muscleGroup: MuscleGroup.pull,
      primaryMuscles: {Muscle.lats},
    );

    final setId = await createWorkoutSet(
      db,
      workoutId: workoutId,
      position: 1,
      minSets: 1,
      maxSets: 1,
      totalExercises: 1,
      totalReps: 10,
    );
    final originalSetExerciseId = await createWorkoutSetExercise(
      db,
      workoutId: workoutId,
      workoutSetId: setId,
      exerciseId: originalExercise,
      position: 1,
      minReps: 10,
      maxReps: 10,
    );

    final result = await workoutService.batchUpsertWorkoutSets(
      workoutId: workoutId,
      idsToDelete: <int>{},
      inputs: [
        WorkoutSetUpsertInput(
          id: setId,
          setType: WorkoutSetType.drop,
          minSets: 5,
          maxSets: 5,
          recommendedRestSecs: 120,
          maxRestSecs: 180,
          position: 1,
          exercises: [
            WorkoutSetExerciseUpsertInput(
              id: 999999,
              exerciseId: replacementExercise,
              position: 1,
              minReps: 6,
              maxReps: 8,
            ),
          ],
        ),
      ],
    );

    expect(result.isErr(), isTrue);
    expect(result.error.type, SingleErrorTypes.operationFailure);

    final setAfterFailure = WorkoutSet.fromMap(
      (await db.query(
        WorkoutSet.table,
        where: '${WorkoutSetColumns.id.value} = ?',
        whereArgs: [setId],
        limit: 1,
      ))
          .single,
    );
    expect(setAfterFailure.setType, WorkoutSetType.standard);
    expect(setAfterFailure.minSets, 1);
    expect(setAfterFailure.maxSets, 1);
    expect(setAfterFailure.totalReps, 10);

    final setExerciseAfterFailure = WorkoutSetExercise.fromMap(
      (await db.query(
        WorkoutSetExercise.table,
        where: '${WorkoutSetExerciseColumns.id.value} = ?',
        whereArgs: [originalSetExerciseId],
        limit: 1,
      ))
          .single,
    );
    expect(setExerciseAfterFailure.exerciseId, originalExercise);
    expect(setExerciseAfterFailure.minReps, 10);
    expect(setExerciseAfterFailure.maxReps, 10);

    final workoutAfterFailure = Workout.fromMap(
      (await db.query(
        Workout.table,
        where: '${WorkoutColumns.id.value} = ?',
        whereArgs: [workoutId],
        limit: 1,
      ))
          .single,
    );
    expect(workoutAfterFailure.totalSets, 1);
    expect(workoutAfterFailure.totalReps, 10);
    expect(workoutAfterFailure.muscleGroups, {MuscleGroup.push});
    expect(workoutAfterFailure.muscles, {Muscle.chest});
  });
}
