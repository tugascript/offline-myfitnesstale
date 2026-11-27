// Copyright (C) 2026 Afonso Barracha
//
// This file is part of My Fitness Tale.
//
// My Fitness Tale is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// My Fitness Tale is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with My Fitness Tale.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';

import 'package:myfitnesstale/src/data/models/sqlite/exercise_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_cardio_set_exercise_record_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_cardio_set_record_model.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/dtos/workout_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/inputs/workout_cardio_set_exercise_record_batch_input.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/inputs/workout_cardio_set_exercise_record_input.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/inputs/workout_cardio_set_exercise_upsert_input.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/inputs/workout_cardio_set_record_batch_input.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/inputs/workout_cardio_set_record_input.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/inputs/workout_cardio_set_upsert_input.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/inputs/workout_input.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/inputs/workout_record_batch_input.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/inputs/workout_record_input.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/inputs/workout_set_exercise_record_batch_input.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/inputs/workout_set_record_batch_input.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/workout_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/workout_repository.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/utils/exercise_details.dart';
import 'package:myfitnesstale/src/data/utils/json_data.dart';
import 'package:myfitnesstale/src/ui/workouts/view_models/active_workout_cubit.dart';
import 'package:myfitnesstale/src/utils/errors.dart';
import 'package:myfitnesstale/src/utils/nullable.dart';

import '../../support/test_database.dart';

void main() {
  final testDatabase = TestDatabase();
  final workoutRepository = WorkoutRepository.create();
  final workoutRecordRepository = WorkoutRecordRepository.create();
  final workoutPlanRecordRepository = WorkoutPlanRecordRepository.create();
  int seedCounter = 0;

  String uniqueName(String prefix) => '$prefix-${seedCounter++}';

  Future<int> createCardioExercise(
    Database db, {
    String? name,
    CardioBaseMode defaultMode = CardioBaseMode.time,
    CardioUnitType unitType = CardioUnitType.distance,
    String unit = 'm',
  }) async {
    final exercise = Exercise.create(
      name: name ?? uniqueName('cardio-ex'),
      details: CardioExerciseDetails(
        defaultMode: defaultMode,
        unitType: unitType,
        unit: unit,
      ),
      difficulty: Difficulty.beginner,
    );
    return db.insert(Exercise.table, exercise.toMap());
  }

  Future<int> createStrengthExercise(Database db) async {
    final exercise = Exercise.create(
      name: uniqueName('strength-ex'),
      details: const StrengthExerciseDetails(
        muscleGroup: MuscleGroup.push,
        muscles: TargetMuscles(primary: {Muscle.chest}, secondary: {}),
        weightProgress: ExerciseWeightProgress.positive,
      ),
      difficulty: Difficulty.beginner,
    );
    return db.insert(Exercise.table, exercise.toMap());
  }

  Future<WorkoutDto> createSampleCardioWorkout(Database db) async {
    final runId = await createCardioExercise(
      db,
      name: uniqueName('Outdoor Running'),
      defaultMode: CardioBaseMode.time,
      unit: 'km',
    );
    final rowId = await createCardioExercise(
      db,
      name: uniqueName('Rowing'),
      defaultMode: CardioBaseMode.units,
      unit: 'm',
    );

    final created = await workoutRepository.createWorkout(
      WorkoutInput(
        name: uniqueName('Hybrid Cardio'),
        description: const Nullable('Warmup + intervals'),
        difficulty: Difficulty.intermediate,
        isFavorite: false,
        editorType: EditorType.cardio,
      ),
    );
    expect(created.isOk(), isTrue);

    final setsResult = await workoutRepository.batchUpsertCardioWorkoutSets(
      workoutId: created.value.id,
      inputs: [
        WorkoutCardioSetUpsertInput(
          position: 1,
          setType: CardioSetType.constant,
          restSecs: 60,
          rounds: 1,
          exercises: [
            WorkoutCardioSetExerciseUpsertInput(
              position: 1,
              exerciseId: runId,
              restSecs: 0,
              mode: CardioBaseMode.time,
              quantity: 600,
            ),
          ],
        ),
        WorkoutCardioSetUpsertInput(
          position: 2,
          setType: CardioSetType.interval,
          restSecs: 90,
          rounds: 2,
          exercises: [
            WorkoutCardioSetExerciseUpsertInput(
              position: 1,
              exerciseId: runId,
              restSecs: 30,
              mode: CardioBaseMode.time,
              quantity: 120,
            ),
            WorkoutCardioSetExerciseUpsertInput(
              position: 2,
              exerciseId: rowId,
              restSecs: 0,
              mode: CardioBaseMode.units,
              quantity: 500,
            ),
          ],
        ),
      ],
    );
    expect(setsResult.isOk(), isTrue);

    final fullWorkout = await workoutRepository.getWorkout(created.value.id);
    expect(fullWorkout.isOk(), isTrue);
    return fullWorkout.value;
  }

  setUpAll(() async {
    await testDatabase.initialize();
  });

  tearDown(() async {
    await testDatabase.clearWorkoutPlanTables();
    await testDatabase.clearWorkoutTables();
  });

  tearDownAll(() async {
    await testDatabase.destroy();
  });

  group('Cardio workout record SQLite models', () {
    test('WorkoutCardioSetRecord round-trips map and Nullable copyWith', () {
      final model = WorkoutCardioSetRecord.create(
        workoutCardioSetId: 10,
        workoutRecordId: 20,
        roundNumber: 1,
        startedAt: 1000,
        totalRestSecs: 60,
        completedAt: 1300,
      );
      final mapped = WorkoutCardioSetRecord.fromMap({
        ...model.toMap(),
        'id': 99,
      });
      expect(mapped.id, 99);
      expect(mapped.totalRestSecs, 60);
      expect(mapped.completedAt, 1300);

      final cleared = mapped.copyWith(
        totalRestSecs: const Nullable(null),
        completedAt: const Nullable(null),
      );
      expect(cleared.totalRestSecs, isNull);
      expect(cleared.completedAt, isNull);
    });

    test('WorkoutCardioSetExerciseRecord round-trips map and rpe', () {
      final model = WorkoutCardioSetExerciseRecord.create(
        workoutCardioSetExerciseId: 11,
        workoutRecordId: 20,
        workoutCardioSetRecordId: 30,
        exerciseId: 40,
        position: 1,
        mode: CardioBaseMode.units,
        quantity: 500,
        durationSecs: 145,
        restSecs: 30,
        rpe: 9,
      );
      final mapped = WorkoutCardioSetExerciseRecord.fromMap({
        ...model.toMap(),
        'id': 77,
      });
      expect(mapped.id, 77);
      expect(mapped.mode, CardioBaseMode.units);
      expect(mapped.quantity, 500);
      expect(mapped.durationSecs, 145);
      expect(mapped.restSecs, 30);
      expect(mapped.rpe, 9);
    });
  });

  group('WorkoutRecordRepository cardio records', () {
    test('live upserts persist cardio rounds, exercise records, rest deltas, hydration, and cascade delete', () async {
      final db = await testDatabase.db;
      final workout = await createSampleCardioWorkout(db);
      final block1 = workout.cardioSets![0];
      final block1Ex = block1.exercises![0];
      final block2 = workout.cardioSets![1];
      final block2Ex1 = block2.exercises![0];
      final block2Ex2 = block2.exercises![1];

      final startedAt = DateTime(2026, 6, 1, 9, 0);
      final recordRes = await workoutRecordRepository.getOrCreateWorkoutRecord(
        WorkoutRecordInput(workoutId: workout.id, startedAt: startedAt),
      );
      expect(recordRes.isOk(), isTrue);
      final recordId = recordRes.value.id;

      // Round 1 of block 1 (time-based)
      final set1Res = await workoutRecordRepository
          .upsertWorkoutCardioSetRecord(
            WorkoutCardioSetRecordInput(
              workoutCardioSetId: block1.id,
              workoutRecordId: recordId,
              roundNumber: 1,
              startedAt: startedAt,
              completedAt: Nullable(startedAt.add(const Duration(minutes: 10))),
            ),
          );
      expect(set1Res.isOk(), isTrue);

      final ex1Res = await workoutRecordRepository
          .upsertWorkoutCardioSetExerciseRecord(
            WorkoutCardioSetExerciseRecordInput(
              workoutCardioSetExerciseId: block1Ex.id,
              workoutRecordId: recordId,
              workoutCardioSetRecordId: set1Res.value.id,
              exerciseId: block1Ex.exerciseId,
              position: block1Ex.position,
              mode: CardioBaseMode.time,
              quantity: 615,
              durationSecs: 615,
              restSecs: 0,
              rpe: 7,
            ),
          );
      expect(ex1Res.isOk(), isTrue);

      // Update block 1 round rest to 55s -> workoutRecord.totalRestSecs updates
      final set1RestUpdate = await workoutRecordRepository
          .upsertWorkoutCardioSetRecord(
            WorkoutCardioSetRecordInput(
              workoutCardioSetId: block1.id,
              workoutRecordId: recordId,
              roundNumber: 1,
              startedAt: startedAt,
              totalRestSecs: const Nullable(55),
              completedAt: Nullable(startedAt.add(const Duration(minutes: 10))),
            ),
          );
      expect(set1RestUpdate.isOk(), isTrue);

      // Round 1 of block 2 (interval: time + exercise rest + units)
      final set2Res = await workoutRecordRepository
          .upsertWorkoutCardioSetRecord(
            WorkoutCardioSetRecordInput(
              workoutCardioSetId: block2.id,
              workoutRecordId: recordId,
              roundNumber: 1,
              startedAt: startedAt.add(const Duration(minutes: 11)),
              totalRestSecs: const Nullable(80),
              completedAt: Nullable(startedAt.add(const Duration(minutes: 15))),
            ),
          );
      expect(set2Res.isOk(), isTrue);

      final ex2aRes = await workoutRecordRepository
          .upsertWorkoutCardioSetExerciseRecord(
            WorkoutCardioSetExerciseRecordInput(
              workoutCardioSetExerciseId: block2Ex1.id,
              workoutRecordId: recordId,
              workoutCardioSetRecordId: set2Res.value.id,
              exerciseId: block2Ex1.exerciseId,
              position: block2Ex1.position,
              mode: CardioBaseMode.time,
              quantity: 120,
              durationSecs: 120,
              restSecs: 25,
              rpe: 8,
            ),
          );
      expect(ex2aRes.isOk(), isTrue);

      final ex2bRes = await workoutRecordRepository
          .upsertWorkoutCardioSetExerciseRecord(
            WorkoutCardioSetExerciseRecordInput(
              workoutCardioSetExerciseId: block2Ex2.id,
              workoutRecordId: recordId,
              workoutCardioSetRecordId: set2Res.value.id,
              exerciseId: block2Ex2.exerciseId,
              position: block2Ex2.position,
              mode: CardioBaseMode.units,
              quantity: 520,
              durationSecs: 105,
              restSecs: 0,
              rpe: 9,
            ),
          );
      expect(ex2bRes.isOk(), isTrue);

      final hydratedRes = await workoutRecordRepository.getWorkoutRecord(
        recordId,
      );
      expect(hydratedRes.isOk(), isTrue);
      final hydrated = hydratedRes.value;
      expect(hydrated.totalSets, 2);
      expect(hydrated.totalRestSecs, 55 + 80 + 25);
      expect(hydrated.cardioSetRecords, hasLength(2));
      expect(hydrated.cardioSetRecords![0].exerciseRecords, hasLength(1));
      expect(hydrated.cardioSetRecords![0].exerciseRecords![0].rpe, 7);
      expect(
        hydrated.cardioSetRecords![0].exerciseRecords![0].exercise,
        isNotNull,
      );
      expect(hydrated.cardioSetRecords![1].exerciseRecords, hasLength(2));
      expect(hydrated.cardioSetRecords![1].exerciseRecords![1].quantity, 520);
      expect(
        hydrated.cardioSetRecords![1].exerciseRecords![1].durationSecs,
        105,
      );
      expect(hydrated.cardioSetRecords![1].exerciseRecords![1].rpe, 9);

      // Cascade delete parent workout record
      final deletedRes = await workoutRecordRepository.deleteWorkoutRecord(
        recordId,
      );
      expect(deletedRes.isOk(), isTrue);

      final remainingSetRows = await db.query(WorkoutCardioSetRecord.table);
      final remainingExRows = await db.query(
        WorkoutCardioSetExerciseRecord.table,
      );
      expect(remainingSetRows, isEmpty);
      expect(remainingExRows, isEmpty);
    });

    test('rejects invalid RPE, zero units quantity, and strength exercises in cardio records', () async {
      final db = await testDatabase.db;
      final workout = await createSampleCardioWorkout(db);
      final strengthExId = await createStrengthExercise(db);
      final block2 = workout.cardioSets![1];
      final unitsEx = block2.exercises![1];

      final startedAt = DateTime(2026, 6, 1, 9, 0);
      final rec = await workoutRecordRepository.getOrCreateWorkoutRecord(
        WorkoutRecordInput(workoutId: workout.id, startedAt: startedAt),
      );
      final setRec = await workoutRecordRepository.upsertWorkoutCardioSetRecord(
        WorkoutCardioSetRecordInput(
          workoutCardioSetId: block2.id,
          workoutRecordId: rec.value.id,
          roundNumber: 1,
          startedAt: startedAt,
        ),
      );
      expect(setRec.isOk(), isTrue);

      final invalidRpe = await workoutRecordRepository
          .upsertWorkoutCardioSetExerciseRecord(
            WorkoutCardioSetExerciseRecordInput(
              workoutCardioSetExerciseId: unitsEx.id,
              workoutRecordId: rec.value.id,
              workoutCardioSetRecordId: setRec.value.id,
              exerciseId: unitsEx.exerciseId,
              position: 2,
              mode: CardioBaseMode.units,
              quantity: 500,
              durationSecs: 100,
              rpe: 11,
            ),
          );
      expect(invalidRpe.isErr(), isTrue);
      expect(invalidRpe.error.type, OperationErrorTypes.invalidInput);

      final zeroUnits = await workoutRecordRepository
          .upsertWorkoutCardioSetExerciseRecord(
            WorkoutCardioSetExerciseRecordInput(
              workoutCardioSetExerciseId: unitsEx.id,
              workoutRecordId: rec.value.id,
              workoutCardioSetRecordId: setRec.value.id,
              exerciseId: unitsEx.exerciseId,
              position: 2,
              mode: CardioBaseMode.units,
              quantity: 0,
              durationSecs: 100,
              rpe: 8,
            ),
          );
      expect(zeroUnits.isErr(), isTrue);
      expect(zeroUnits.error.type, OperationErrorTypes.invalidInput);

      final wrongType = await workoutRecordRepository
          .upsertWorkoutCardioSetExerciseRecord(
            WorkoutCardioSetExerciseRecordInput(
              workoutCardioSetExerciseId: unitsEx.id,
              workoutRecordId: rec.value.id,
              workoutCardioSetRecordId: setRec.value.id,
              exerciseId: strengthExId,
              position: 2,
              mode: CardioBaseMode.units,
              quantity: 500,
              durationSecs: 100,
              rpe: 8,
            ),
          );
      expect(wrongType.isErr(), isTrue);
      expect(wrongType.error.type, OperationErrorTypes.invalidInput);
    });

    test('batchCreateWorkoutRecord and batchUpdateWorkoutRecord persist and replace cardio records atomically', () async {
      final db = await testDatabase.db;
      final workout = await createSampleCardioWorkout(db);
      final block1 = workout.cardioSets![0];
      final block1Ex = block1.exercises![0];
      final block2 = workout.cardioSets![1];
      final block2Ex1 = block2.exercises![0];
      final block2Ex2 = block2.exercises![1];

      final start = DateTime(2026, 6, 2, 8, 0);
      final end = DateTime(2026, 6, 2, 8, 30);

      // Reject strength payload on cardio workout
      final mismatch = await workoutRecordRepository.batchCreateWorkoutRecord(
        WorkoutRecordBatchInput(
          workoutId: workout.id,
          version: workout.version,
          startedAt: start,
          completedAt: end,
          sets: [
            WorkoutSetRecordBatchInput(
              workoutSetId: 1,
              setNumber: 1,
              startedAt: start,
              completedAt: end,
              totalRestSecs: 60,
              exercises: const [
                WorkoutSetExerciseRecordBatchInput(
                  workoutSetExerciseId: 1,
                  exerciseId: 1,
                  position: 1,
                  reps: 10,
                  weight: 10000,
                  difficulty: WorkoutSetExerciseDifficulty(
                    value: 8,
                    type: WorkoutSetExerciseDifficultyType.rpe,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
      expect(mismatch.isErr(), isTrue);
      expect(mismatch.error.type, OperationErrorTypes.invalidInput);

      final created = await workoutRecordRepository.batchCreateWorkoutRecord(
        WorkoutRecordBatchInput(
          workoutId: workout.id,
          version: workout.version,
          startedAt: start,
          completedAt: end,
          cardioSets: [
            WorkoutCardioSetRecordBatchInput(
              workoutCardioSetId: block1.id,
              roundNumber: 1,
              startedAt: start,
              completedAt: end,
              totalRestSecs: 60,
              exercises: [
                WorkoutCardioSetExerciseRecordBatchInput(
                  workoutCardioSetExerciseId: block1Ex.id,
                  exerciseId: block1Ex.exerciseId,
                  position: 1,
                  mode: CardioBaseMode.time,
                  quantity: 600,
                  durationSecs: 600,
                  restSecs: 0,
                  rpe: 7,
                ),
              ],
            ),
            WorkoutCardioSetRecordBatchInput(
              workoutCardioSetId: block2.id,
              roundNumber: 1,
              startedAt: start,
              completedAt: end,
              totalRestSecs: 90,
              exercises: [
                WorkoutCardioSetExerciseRecordBatchInput(
                  workoutCardioSetExerciseId: block2Ex1.id,
                  exerciseId: block2Ex1.exerciseId,
                  position: 1,
                  mode: CardioBaseMode.time,
                  quantity: 120,
                  durationSecs: 120,
                  restSecs: 30,
                  rpe: 8,
                ),
                WorkoutCardioSetExerciseRecordBatchInput(
                  workoutCardioSetExerciseId: block2Ex2.id,
                  exerciseId: block2Ex2.exerciseId,
                  position: 2,
                  mode: CardioBaseMode.units,
                  quantity: 500,
                  durationSecs: 110,
                  restSecs: 0,
                  rpe: 9,
                ),
              ],
            ),
          ],
        ),
      );
      expect(created.isOk(), isTrue);
      expect(created.value.totalSets, 2);
      expect(created.value.totalRestSecs, 60 + 90 + 30);

      final updated = await workoutRecordRepository.batchUpdateWorkoutRecord(
        created.value.id,
        WorkoutRecordBatchInput(
          workoutId: workout.id,
          version: workout.version,
          startedAt: start,
          completedAt: end.add(const Duration(minutes: 5)),
          cardioSets: [
            WorkoutCardioSetRecordBatchInput(
              workoutCardioSetId: block1.id,
              roundNumber: 1,
              startedAt: start,
              completedAt: end.add(const Duration(minutes: 5)),
              totalRestSecs: 45,
              exercises: [
                WorkoutCardioSetExerciseRecordBatchInput(
                  workoutCardioSetExerciseId: block1Ex.id,
                  exerciseId: block1Ex.exerciseId,
                  position: 1,
                  mode: CardioBaseMode.time,
                  quantity: 630,
                  durationSecs: 630,
                  restSecs: 0,
                  rpe: 10,
                ),
              ],
            ),
          ],
        ),
      );
      expect(updated.isOk(), isTrue);
      expect(updated.value.totalSets, 1);
      expect(updated.value.totalRestSecs, 45);
      expect(updated.value.cardioSetRecords, hasLength(1));
      expect(
        updated.value.cardioSetRecords![0].exerciseRecords![0].durationSecs,
        630,
      );
      expect(updated.value.cardioSetRecords![0].exerciseRecords![0].rpe, 10);
    });
  });

  group('ActiveWorkoutCubit cardio progression', () {
    test('walks through constant and multi-round interval blocks, logs RPE/rest, and auto-completes', () async {
      final db = await testDatabase.db;
      final workout = await createSampleCardioWorkout(db);
      final cubit = ActiveWorkoutCubit(
        workoutRepository: workoutRepository,
        workoutRecordRepository: workoutRecordRepository,
        workoutPlanRecordRepository: workoutPlanRecordRepository,
      );
      addTearDown(cubit.close);

      await cubit.startWorkout(workout.id);
      expect(cubit.state.isCardio, isTrue);
      expect(cubit.state.totalSets, 3); // 1 constant + 2 interval rounds
      expect(cubit.state.totalCurrentSet, 1);
      expect(cubit.state.currentCardioSet?.id, workout.cardioSets![0].id);

      // Log block 1 round 1 -> start round rest -> advance to block 2 round 1 ex 1
      await cubit.logCardioExerciseSet(
        position: 1,
        mode: CardioBaseMode.time,
        quantity: 600,
        durationSecs: 600,
        roundNumber: 1,
        rpe: 7,
        markRoundCompleted: true,
      );
      cubit.startRest(recommendedSecs: 60, isRoundRest: true);
      expect(cubit.state.isResting, isTrue);
      expect(cubit.state.pendingRestSecs, 60);
      expect(cubit.state.isRoundRest, isTrue);

      cubit.nextExercise();
      expect(cubit.state.isResting, isFalse);
      expect(cubit.state.pendingRestSecs, isNull);
      expect(cubit.state.currentSetPosition, 1);
      expect(cubit.state.currentSetNumber, 1);
      expect(cubit.state.currentExercisePosition, 0);
      expect(cubit.state.totalCurrentSet, 2);

      // Log block 2 round 1 ex 1 -> exercise rest -> ex 2
      await cubit.logCardioExerciseSet(
        position: 1,
        mode: CardioBaseMode.time,
        quantity: 120,
        durationSecs: 120,
        roundNumber: 1,
        rpe: 8,
        exerciseRestSecs: 30,
      );
      cubit.startRest(recommendedSecs: 30, isRoundRest: false);
      expect(cubit.state.isRoundRest, isFalse);
      cubit.nextExercise();
      expect(cubit.state.currentSetPosition, 1);
      expect(cubit.state.currentSetNumber, 1);
      expect(cubit.state.currentExercisePosition, 1);

      // Log block 2 round 1 ex 2 -> advance to block 2 round 2 ex 1
      await cubit.logCardioExerciseSet(
        position: 2,
        mode: CardioBaseMode.units,
        quantity: 525,
        durationSecs: 100,
        roundNumber: 1,
        rpe: 9,
        roundRestSecs: 85,
        markRoundCompleted: true,
      );
      cubit.nextExercise();
      expect(cubit.state.currentSetPosition, 1);
      expect(cubit.state.currentSetNumber, 2);
      expect(cubit.state.currentExercisePosition, 0);
      expect(cubit.state.totalCurrentSet, 3);
      // Latest matching cardio exercise record carries previous round's RPE
      expect(cubit.state.latestMatchingCardioExerciseRecord?.rpe, 8);

      // Advance to round 2 ex 2 -> check units carry-over
      cubit.nextExercise();
      expect(cubit.state.currentExercisePosition, 1);
      expect(cubit.state.latestMatchingCardioExerciseRecord?.quantity, 525);
      expect(cubit.state.latestMatchingCardioExerciseRecord?.rpe, 9);

      // Final nextExercise auto-completes the workout
      cubit.nextExercise();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(cubit.state.isCompleted, isTrue);
      expect(cubit.state.workoutRecord?.completedAt, isNotNull);
    });
  });
}
