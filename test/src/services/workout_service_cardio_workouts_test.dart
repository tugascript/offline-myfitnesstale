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
import 'package:myfitnesstale/src/data/models/sqlite/workout_cardio_set_exercise_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_cardio_set_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_record_model.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/inputs/week_workout_input.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/inputs/workout_plan_day_batch_create_input.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/inputs/workout_plan_input.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/inputs/workout_plan_week_batch_create_input.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/inputs/workout_plan_workout_batch_create_input.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/inputs/workout_plan_workout_input.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/inputs/workout_cardio_set_exercise_upsert_input.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/inputs/workout_cardio_set_upsert_input.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/inputs/workout_input.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/inputs/workout_set_exercise_upsert_input.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/inputs/workout_set_upsert_input.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/workout_repository.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/utils/exercise_details.dart';
import 'package:myfitnesstale/src/data/utils/json_data.dart';
import 'package:myfitnesstale/src/ui/workouts/view_models/workout_cubit.dart';
import 'package:myfitnesstale/src/utils/errors.dart';
import 'package:myfitnesstale/src/utils/nullable.dart';

import '../../support/test_database.dart';

void main() {
  final testDatabase = TestDatabase();
  final workoutRepository = WorkoutRepository.create();
  final workoutPlanRepository = WorkoutPlanRepository.create();
  int seedCounter = 0;

  String uniqueName(String prefix) => '$prefix-${seedCounter++}';

  Future<int> createCardioExercise(
    Database db, {
    String? name,
    CardioBaseMode defaultMode = CardioBaseMode.time,
    CardioUnitType unitType = CardioUnitType.distance,
    String unit = 'km',
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

  group('WorkoutRepository cardio workout CRUD', () {
    test(
      'creates, reads, updates, favorites, and cascade deletes cardio workouts',
      () async {
        final db = await testDatabase.db;
        final runId = await createCardioExercise(db, name: 'Running');
        final bikeId = await createCardioExercise(
          db,
          name: 'Cycling',
          defaultMode: CardioBaseMode.units,
          unit: 'km',
        );

        final createdResult = await workoutRepository.createWorkout(
          const WorkoutInput(
            name: 'Morning Cardio',
            description: Nullable('Zone 2 + intervals'),
            difficulty: Difficulty.intermediate,
            isFavorite: false,
            editorType: EditorType.cardio,
          ),
        );
        expect(createdResult.isOk(), isTrue);
        final created = createdResult.value;
        expect(created.editorType, EditorType.cardio);
        expect(created.isCardio, isTrue);

        final upsertResult = await workoutRepository
            .batchUpsertCardioWorkoutSets(
              workoutId: created.id,
              inputs: [
                WorkoutCardioSetUpsertInput(
                  setType: CardioSetType.constant,
                  position: 1,
                  restSecs: 60,
                  rounds: 1,
                  exercises: [
                    WorkoutCardioSetExerciseUpsertInput(
                      position: 1,
                      exerciseId: runId,
                      restSecs: 45,
                      mode: CardioBaseMode.time,
                      quantity: 1200,
                    ),
                  ],
                ),
                WorkoutCardioSetUpsertInput(
                  setType: CardioSetType.interval,
                  position: 2,
                  restSecs: 90,
                  rounds: 4,
                  exercises: [
                    WorkoutCardioSetExerciseUpsertInput(
                      position: 1,
                      exerciseId: runId,
                      restSecs: 30,
                      mode: CardioBaseMode.time,
                      quantity: 60,
                    ),
                    WorkoutCardioSetExerciseUpsertInput(
                      position: 2,
                      exerciseId: bikeId,
                      restSecs: 15,
                      mode: CardioBaseMode.units,
                      quantity: 5,
                    ),
                  ],
                ),
              ],
            );
        expect(upsertResult.isOk(), isTrue);
        expect(upsertResult.value.totalSets, 5);
        expect(upsertResult.value.cardioSets, hasLength(2));

        final loadedResult = await workoutRepository.getWorkout(created.id);
        expect(loadedResult.isOk(), isTrue);
        final loaded = loadedResult.value;
        expect(upsertResult.value, loaded);
        expect(loaded.totalSets, 5);
        expect(loaded.totalReps, 0);
        expect(loaded.muscleGroups, isEmpty);
        expect(loaded.sets, isNull);
        expect(loaded.cardioSets, isNotNull);
        expect(loaded.cardioSets!.length, 2);

        final constantSet = loaded.cardioSets![0];
        expect(constantSet.setType, CardioSetType.constant);
        expect(constantSet.rounds, 1);
        expect(constantSet.restSecs, 60);
        expect(constantSet.exercises!.length, 1);
        // Constant set exercises always normalize restSecs to 0.
        expect(constantSet.exercises!.first.restSecs, 0);
        expect(constantSet.exercises!.first.quantity, 1200);
        expect(constantSet.exercises!.first.exercise?.name, 'Running');

        final intervalSet = loaded.cardioSets![1];
        expect(intervalSet.setType, CardioSetType.interval);
        expect(intervalSet.rounds, 4);
        expect(intervalSet.restSecs, 90);
        expect(intervalSet.exercises!.length, 2);
        expect(intervalSet.exercises![0].restSecs, 30);
        expect(intervalSet.exercises![1].mode, CardioBaseMode.units);
        expect(intervalSet.exercises![1].quantity, 5);
        expect(intervalSet.exercises![1].exercise?.name, 'Cycling');

        final favResult = await workoutRepository.updateWorkoutFavorite(
          created.id,
          true,
        );
        expect(favResult.isOk(), isTrue);
        expect(favResult.value.isFavorite, isTrue);

        final updateResult = await workoutRepository.updateWorkout(
          created.id,
          const WorkoutInput(
            name: 'Updated Cardio',
            description: Nullable('Updated'),
            difficulty: Difficulty.advanced,
            isFavorite: true,
            editorType: EditorType.cardio,
          ),
        );
        expect(updateResult.isOk(), isTrue);
        expect(updateResult.value.name, 'Updated Cardio');

        final deleteResult = await workoutRepository.deleteWorkout(created.id);
        expect(deleteResult.isOk(), isTrue);

        final remainingSets = await db.query(WorkoutCardioSet.table);
        final remainingExercises = await db.query(
          WorkoutCardioSetExercise.table,
        );
        expect(remainingSets, isEmpty);
        expect(remainingExercises, isEmpty);
      },
    );

    test('enforces editorType transition guards on updateWorkout', () async {
      final basic = (await workoutRepository.createWorkout(
        const WorkoutInput(
          name: 'Basic Strength',
          difficulty: Difficulty.beginner,
          editorType: EditorType.basic,
        ),
      )).value;
      final advanced = (await workoutRepository.createWorkout(
        const WorkoutInput(
          name: 'Advanced Strength',
          difficulty: Difficulty.intermediate,
          editorType: EditorType.advanced,
        ),
      )).value;
      final cardio = (await workoutRepository.createWorkout(
        const WorkoutInput(
          name: 'Cardio Run',
          difficulty: Difficulty.beginner,
          editorType: EditorType.cardio,
        ),
      )).value;

      // Allowed: basic -> advanced
      final upgrade = await workoutRepository.updateWorkout(
        basic.id,
        const WorkoutInput(
          name: 'Upgraded Strength',
          difficulty: Difficulty.beginner,
          editorType: EditorType.advanced,
        ),
      );
      expect(upgrade.isOk(), isTrue);
      expect(upgrade.value.editorType, EditorType.advanced);

      // Rejected: advanced -> basic
      final downgrade = await workoutRepository.updateWorkout(
        advanced.id,
        const WorkoutInput(
          name: 'Downgrade Attempt',
          difficulty: Difficulty.intermediate,
          editorType: EditorType.basic,
        ),
      );
      expect(downgrade.isErr(), isTrue);
      expect(downgrade.error.type, SingleErrorTypes.invalidInput);

      // Rejected: strength -> cardio
      final toCardio = await workoutRepository.updateWorkout(
        advanced.id,
        const WorkoutInput(
          name: 'Switch to Cardio',
          difficulty: Difficulty.intermediate,
          editorType: EditorType.cardio,
        ),
      );
      expect(toCardio.isErr(), isTrue);
      expect(toCardio.error.type, SingleErrorTypes.invalidInput);

      // Rejected: cardio -> basic & cardio -> advanced
      for (final target in [EditorType.basic, EditorType.advanced]) {
        final fromCardio = await workoutRepository.updateWorkout(
          cardio.id,
          WorkoutInput(
            name: 'Switch to Strength',
            difficulty: Difficulty.beginner,
            editorType: target,
          ),
        );
        expect(fromCardio.isErr(), isTrue);
        expect(fromCardio.error.type, SingleErrorTypes.invalidInput);
      }
    });

    test(
      'filters getWorkouts and getAllWorkouts cleanly by Strength vs Cardio',
      () async {
        await workoutRepository.createWorkout(
          const WorkoutInput(
            name: 'Basic Push',
            difficulty: Difficulty.beginner,
            editorType: EditorType.basic,
          ),
        );
        await workoutRepository.createWorkout(
          const WorkoutInput(
            name: 'Advanced Pull',
            difficulty: Difficulty.advanced,
            editorType: EditorType.advanced,
          ),
        );
        await workoutRepository.createWorkout(
          const WorkoutInput(
            name: 'HIIT Sprints',
            difficulty: Difficulty.advanced,
            isFavorite: true,
            editorType: EditorType.cardio,
          ),
        );

        final strengthPage = await workoutRepository.getWorkouts(
          type: ExerciseType.strength,
        );
        expect(strengthPage.isOk(), isTrue);
        expect(strengthPage.value.data.map((w) => w.name).toSet(), {
          'Basic Push',
          'Advanced Pull',
        });

        final cardioPage = await workoutRepository.getWorkouts(
          type: ExerciseType.cardio,
          muscleGroup: MuscleGroup.legs, // ignored for cardio
        );
        expect(cardioPage.isOk(), isTrue);
        expect(cardioPage.value.data.map((w) => w.name).toList(), [
          'HIIT Sprints',
        ]);

        final allCardio = await workoutRepository.getAllWorkouts(
          type: ExerciseType.cardio,
          isFavorite: true,
        );
        expect(allCardio.isOk(), isTrue);
        expect(allCardio.value.map((w) => w.name).toList(), ['HIIT Sprints']);

        final allUnfiltered = await workoutRepository.getAllWorkouts();
        expect(allUnfiltered.isOk(), isTrue);
        expect(allUnfiltered.value.length, 3);
      },
    );

    test('updates, reorders, deletes cardio sets in-place and bumps version when records exist', () async {
      final db = await testDatabase.db;
      final runId = await createCardioExercise(db, name: 'Run');
      final rowId = await createCardioExercise(db, name: 'Row');
      final jumpId = await createCardioExercise(db, name: 'Jump Rope');

      final workout = (await workoutRepository.createWorkout(
        const WorkoutInput(
          name: 'Hybrid Cardio',
          difficulty: Difficulty.intermediate,
          editorType: EditorType.cardio,
        ),
      )).value;

      final initialSave = await workoutRepository.batchUpsertCardioWorkoutSets(
        workoutId: workout.id,
        inputs: [
          WorkoutCardioSetUpsertInput(
            setType: CardioSetType.constant,
            position: 1,
            restSecs: 30,
            rounds: 1,
            exercises: [
              WorkoutCardioSetExerciseUpsertInput(
                position: 1,
                exerciseId: runId,
                mode: CardioBaseMode.time,
                quantity: 300,
              ),
            ],
          ),
          WorkoutCardioSetUpsertInput(
            setType: CardioSetType.interval,
            position: 2,
            restSecs: 60,
            rounds: 3,
            exercises: [
              WorkoutCardioSetExerciseUpsertInput(
                position: 1,
                exerciseId: rowId,
                restSecs: 20,
                mode: CardioBaseMode.units,
                quantity: 500,
              ),
              WorkoutCardioSetExerciseUpsertInput(
                position: 2,
                exerciseId: jumpId,
                restSecs: 10,
                mode: CardioBaseMode.time,
                quantity: 45,
              ),
            ],
          ),
        ],
      );
      expect(initialSave.isOk(), isTrue);

      final v1Sets = (await workoutRepository.getWorkoutCardioSets(workout.id))
          .value;
      expect(v1Sets.length, 2);

      // Reorder sets, edit exercises, remove one exercise, add a new set
      final updateSave = await workoutRepository.batchUpsertCardioWorkoutSets(
        workoutId: workout.id,
        inputs: [
          WorkoutCardioSetUpsertInput(
            id: v1Sets[1].id,
            setType: CardioSetType.interval,
            position: 1,
            restSecs: 45,
            rounds: 5,
            exercises: [
              WorkoutCardioSetExerciseUpsertInput(
                id: v1Sets[1].exercises![1].id,
                position: 1,
                exerciseId: jumpId,
                restSecs: 15,
                mode: CardioBaseMode.time,
                quantity: 60,
              ),
            ],
          ),
          WorkoutCardioSetUpsertInput(
            setType: CardioSetType.constant,
            position: 2,
            restSecs: 0,
            rounds: 1,
            exercises: [
              WorkoutCardioSetExerciseUpsertInput(
                position: 1,
                exerciseId: rowId,
                mode: CardioBaseMode.units,
                quantity: 1000,
              ),
            ],
          ),
        ],
      );
      expect(updateSave.isOk(), isTrue);

      final updatedWorkout = (await workoutRepository.getWorkout(workout.id))
          .value;
      expect(updatedWorkout.version, 1);
      expect(updatedWorkout.totalSets, 6);
      expect(updatedWorkout.cardioSets!.length, 2);
      expect(updatedWorkout.cardioSets![0].id, v1Sets[1].id);
      expect(updatedWorkout.cardioSets![0].position, 1);
      expect(updatedWorkout.cardioSets![0].rounds, 5);
      expect(updatedWorkout.cardioSets![0].exercises!.length, 1);
      expect(updatedWorkout.cardioSets![0].exercises!.first.exerciseId, jumpId);
      expect(updatedWorkout.cardioSets![1].position, 2);
      expect(updatedWorkout.cardioSets![1].exercises!.first.quantity, 1000);

      // Insert a historical WorkoutRecord so the next save bumps version to 2
      await db.insert(
        WorkoutRecord.table,
        WorkoutRecord.create(
          workoutId: workout.id,
          version: 1,
          startedAt: 1700000000,
        ).toMap(),
      );

      final v2Save = await workoutRepository.batchUpsertCardioWorkoutSets(
        workoutId: workout.id,
        inputs: [
          WorkoutCardioSetUpsertInput(
            id: updatedWorkout.cardioSets![0].id,
            setType: CardioSetType.constant,
            position: 1,
            restSecs: 15,
            rounds: 1,
            exercises: [
              WorkoutCardioSetExerciseUpsertInput(
                position: 1,
                exerciseId: runId,
                mode: CardioBaseMode.time,
                quantity: 900,
              ),
            ],
          ),
        ],
      );
      expect(v2Save.isOk(), isTrue);

      final v2Workout = (await workoutRepository.getWorkout(workout.id)).value;
      expect(v2Workout.version, 2);
      expect(v2Workout.totalSets, 1);
      expect(v2Workout.cardioSets!.length, 1);
      expect(v2Workout.cardioSets!.first.exercises!.first.quantity, 900);

      // Version 1 sets remain intact
      final preservedV1 = (await workoutRepository.getWorkoutCardioSets(
        workout.id,
        version: 1,
      )).value;
      expect(preservedV1.length, 2);
    });

    test(
      'validates cardio set inputs and rejects cross-domain upserts',
      () async {
        final db = await testDatabase.db;
        final cardioExId = await createCardioExercise(db);
        final strengthExId = await createStrengthExercise(db);

        final cardioWorkout = (await workoutRepository.createWorkout(
          const WorkoutInput(
            name: 'Cardio Guard',
            difficulty: Difficulty.beginner,
            editorType: EditorType.cardio,
          ),
        )).value;
        final strengthWorkout = (await workoutRepository.createWorkout(
          const WorkoutInput(
            name: 'Strength Guard',
            difficulty: Difficulty.beginner,
            editorType: EditorType.basic,
          ),
        )).value;

        // Strength upsert rejected on cardio workout
        final strengthOnCardio = await workoutRepository.batchUpsertWorkoutSets(
          workoutId: cardioWorkout.id,
          inputs: [
            WorkoutSetUpsertInput(
              setType: WorkoutSetType.standard,
              minSets: 3,
              recommendedRestSecs: 60,
              position: 1,
              exercises: [
                WorkoutSetExerciseUpsertInput(
                  position: 1,
                  exerciseId: strengthExId,
                  minReps: 10,
                ),
              ],
            ),
          ],
        );
        expect(strengthOnCardio.isErr(), isTrue);
        expect(strengthOnCardio.error.type, SingleErrorTypes.invalidInput);

        // Cardio upsert rejected on strength workout
        final cardioOnStrength = await workoutRepository
            .batchUpsertCardioWorkoutSets(
              workoutId: strengthWorkout.id,
              inputs: [
                WorkoutCardioSetUpsertInput(
                  setType: CardioSetType.constant,
                  position: 1,
                  exercises: [
                    WorkoutCardioSetExerciseUpsertInput(
                      position: 1,
                      exerciseId: cardioExId,
                      mode: CardioBaseMode.time,
                      quantity: 60,
                    ),
                  ],
                ),
              ],
            );
        expect(cardioOnStrength.isErr(), isTrue);
        expect(cardioOnStrength.error.type, SingleErrorTypes.invalidInput);

        // Non-cardio exercise rejected in cardio workout
        final strengthExerciseInCardio = await workoutRepository
            .batchUpsertCardioWorkoutSets(
              workoutId: cardioWorkout.id,
              inputs: [
                WorkoutCardioSetUpsertInput(
                  setType: CardioSetType.constant,
                  position: 1,
                  exercises: [
                    WorkoutCardioSetExerciseUpsertInput(
                      position: 1,
                      exerciseId: strengthExId,
                      mode: CardioBaseMode.time,
                      quantity: 60,
                    ),
                  ],
                ),
              ],
            );
        expect(strengthExerciseInCardio.isErr(), isTrue);
        expect(
          strengthExerciseInCardio.error.type,
          SingleErrorTypes.invalidInput,
        );

        // Constant set with >1 round rejected
        final invalidConstantRounds = await workoutRepository
            .batchUpsertCardioWorkoutSets(
              workoutId: cardioWorkout.id,
              inputs: [
                WorkoutCardioSetUpsertInput(
                  setType: CardioSetType.constant,
                  position: 1,
                  rounds: 2,
                  exercises: [
                    WorkoutCardioSetExerciseUpsertInput(
                      position: 1,
                      exerciseId: cardioExId,
                      mode: CardioBaseMode.time,
                      quantity: 60,
                    ),
                  ],
                ),
              ],
            );
        expect(invalidConstantRounds.isErr(), isTrue);
        expect(invalidConstantRounds.error.type, SingleErrorTypes.invalidInput);

        // Quantity <= 0 rejected
        final invalidQty = await workoutRepository.batchUpsertCardioWorkoutSets(
          workoutId: cardioWorkout.id,
          inputs: [
            WorkoutCardioSetUpsertInput(
              setType: CardioSetType.constant,
              position: 1,
              exercises: [
                WorkoutCardioSetExerciseUpsertInput(
                  position: 1,
                  exerciseId: cardioExId,
                  mode: CardioBaseMode.units,
                  quantity: 0,
                ),
              ],
            ),
          ],
        );
        expect(invalidQty.isErr(), isTrue);
        expect(invalidQty.error.type, SingleErrorTypes.invalidInput);

        // Unknown exercise -> notFound
        final missingExercise = await workoutRepository
            .batchUpsertCardioWorkoutSets(
              workoutId: cardioWorkout.id,
              inputs: [
                WorkoutCardioSetUpsertInput(
                  setType: CardioSetType.constant,
                  position: 1,
                  exercises: [
                    const WorkoutCardioSetExerciseUpsertInput(
                      position: 1,
                      exerciseId: 99999,
                      mode: CardioBaseMode.time,
                      quantity: 60,
                    ),
                  ],
                ),
              ],
            );
        expect(missingExercise.isErr(), isTrue);
        expect(missingExercise.error.type, SingleErrorTypes.notFound);

        // Seed a valid cardio set, then verify empty upsert is rejected and
        // does not wipe existing cardio sets.
        final seeded = await workoutRepository.batchUpsertCardioWorkoutSets(
          workoutId: cardioWorkout.id,
          inputs: [
            WorkoutCardioSetUpsertInput(
              setType: CardioSetType.constant,
              position: 1,
              exercises: [
                WorkoutCardioSetExerciseUpsertInput(
                  position: 1,
                  exerciseId: cardioExId,
                  mode: CardioBaseMode.time,
                  quantity: 300,
                ),
              ],
            ),
          ],
        );
        expect(seeded.isOk(), isTrue);

        final emptyInputs = await workoutRepository
            .batchUpsertCardioWorkoutSets(
              workoutId: cardioWorkout.id,
              inputs: const [],
            );
        expect(emptyInputs.isErr(), isTrue);
        expect(emptyInputs.error.type, SingleErrorTypes.invalidInput);

        final remaining = await workoutRepository.getWorkout(cardioWorkout.id);
        expect(remaining.isOk(), isTrue);
        expect(remaining.value.cardioSets, hasLength(1));
        expect(
          remaining.value.cardioSets!.first.exercises!.first.quantity,
          300,
        );
      },
    );
  });

  group('WorkoutCubit cardio state management', () {
    test('filters cardio workouts, preserves cardioSets on updates, and saves cardio sets', () async {
      final db = await testDatabase.db;
      final runId = await createCardioExercise(db, name: 'Trail Run');

      final cubit = WorkoutCubit(workoutRepository: workoutRepository);
      addTearDown(cubit.close);

      await cubit.createWorkout(
        const WorkoutInput(
          name: 'Trail Intervals',
          difficulty: Difficulty.intermediate,
          editorType: EditorType.cardio,
        ),
      );
      final workoutId = cubit.state.selectedWorkout!.id;

      await cubit.getWorkouts(
        type: ExerciseType.cardio,
        muscleGroup: MuscleGroup.push,
      );
      expect(cubit.state.pagination.type, ExerciseType.cardio);
      expect(cubit.state.pagination.muscleGroup, isNull);
      expect(cubit.state.workouts.map((w) => w.id), [workoutId]);
      final workoutsRequestIdBeforeSave = cubit.state.workoutsRequestId;

      await cubit.batchUpsertCardioWorkoutSets(
        workoutId: workoutId,
        sets: [
          WorkoutCardioSetUpsertInput(
            setType: CardioSetType.interval,
            position: 1,
            restSecs: 60,
            rounds: 3,
            exercises: [
              WorkoutCardioSetExerciseUpsertInput(
                position: 1,
                exerciseId: runId,
                restSecs: 20,
                mode: CardioBaseMode.time,
                quantity: 120,
              ),
            ],
          ),
        ],
      );
      expect(cubit.state.error, isNull);
      expect(cubit.state.workoutsRequestId, workoutsRequestIdBeforeSave);
      expect(cubit.state.selectedWorkout?.cardioSets?.length, 1);
      expect(cubit.state.selectedWorkout?.totalSets, 3);
      expect(cubit.state.workouts.first.totalSets, 3);
      expect(cubit.state.workouts.first.cardioSets, isNull);

      await cubit.updateWorkoutFavorite(workoutId, true);
      expect(cubit.state.selectedWorkout?.isFavorite, isTrue);
      expect(cubit.state.selectedWorkout?.cardioSets?.length, 1);

      await cubit.updateWorkout(
        workoutId,
        const WorkoutInput(
          name: 'Trail Intervals Renamed',
          difficulty: Difficulty.advanced,
          isFavorite: true,
          editorType: EditorType.cardio,
        ),
      );
      expect(cubit.state.selectedWorkout?.name, 'Trail Intervals Renamed');
      expect(cubit.state.selectedWorkout?.cardioSets?.length, 1);

      await cubit.refreshWorkoutSets(workoutId);
      expect(cubit.state.selectedWorkout?.cardioSets?.length, 1);
    });

    test('getSelectionWorkouts defaults to strength workouts and excludes cardio workouts', () async {
      final strengthWorkout = (await workoutRepository.createWorkout(
        const WorkoutInput(
          name: 'Push Strength',
          difficulty: Difficulty.beginner,
          isFavorite: false,
          editorType: EditorType.basic,
        ),
      )).value;
      await workoutRepository.createWorkout(
        const WorkoutInput(
          name: 'Zone 2 Run',
          difficulty: Difficulty.beginner,
          isFavorite: false,
          editorType: EditorType.cardio,
        ),
      );

      final cubit = WorkoutCubit(workoutRepository: workoutRepository);
      addTearDown(cubit.close);

      await cubit.getSelectionWorkouts();
      expect(cubit.state.error, isNull);
      expect(cubit.state.workoutSelection.map((w) => w.id), [
        strengthWorkout.id,
      ]);
    });
  });

  group('WorkoutPlanRepository cardio workout guards', () {
    test(
      'rejects cardio workouts across plan version, day, and workout mutations',
      () async {
        final strengthWorkout = (await workoutRepository.createWorkout(
          const WorkoutInput(
            name: 'Full Body Strength',
            difficulty: Difficulty.intermediate,
            isFavorite: false,
            editorType: EditorType.basic,
          ),
        )).value;
        final cardioWorkout = (await workoutRepository.createWorkout(
          const WorkoutInput(
            name: 'Tempo Cardio',
            difficulty: Difficulty.intermediate,
            isFavorite: false,
            editorType: EditorType.cardio,
          ),
        )).value;

        final plan = (await workoutPlanRepository.createWorkoutPlan(
          const WorkoutPlanInput(
            name: 'Strength Plan',
            difficulty: Difficulty.intermediate,
          ),
        )).value;

        // 1. Batch plan version creation rejects cardio workouts
        final batchCardioResult = await workoutPlanRepository
            .createWorkoutPlanVersionWithWeeks(
              workoutPlanId: plan.id,
              weeks: [
                WorkoutPlanWeekBatchCreateInput(
                  startWeek: 1,
                  endWeek: 1,
                  days: [
                    WorkoutPlanDayBatchCreateInput(
                      day: 1,
                      workouts: [
                        WorkoutPlanWorkoutBatchCreateInput(
                          workoutId: cardioWorkout.id,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
        expect(batchCardioResult.isErr(), isTrue);
        expect(batchCardioResult.error.type, SingleErrorTypes.invalidInput);

        // Seed a valid strength version so day/workout endpoints can be tested
        final validVersion =
            (await workoutPlanRepository.createWorkoutPlanVersionWithWeeks(
              workoutPlanId: plan.id,
              weeks: [
                WorkoutPlanWeekBatchCreateInput(
                  startWeek: 1,
                  endWeek: 1,
                  days: [
                    WorkoutPlanDayBatchCreateInput(
                      day: 1,
                      workouts: [
                        WorkoutPlanWorkoutBatchCreateInput(
                          workoutId: strengthWorkout.id,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            )).value;
        final weekId = validVersion.weeks!.first.id;
        final dayId = validVersion.weeks!.first.days.first.id;
        final planWorkoutId =
            validVersion.weeks!.first.days.first.planWorkouts!.first.id;

        // 2. createWorkoutPlanDay rejects cardio workouts
        final createDayResult = await workoutPlanRepository
            .createWorkoutPlanDay(
              workoutPlanWeekId: weekId,
              day: 2,
              workouts: [WeekWorkoutInput(workoutId: cardioWorkout.id)],
            );
        expect(createDayResult.isErr(), isTrue);
        expect(createDayResult.error.type, SingleErrorTypes.invalidInput);

        // 3. createWorkoutPlanWorkout rejects cardio workouts
        final createPlanWorkoutResult = await workoutPlanRepository
            .createWorkoutPlanWorkout(
              dayId,
              WorkoutPlanWorkoutInput(workoutId: cardioWorkout.id),
            );
        expect(createPlanWorkoutResult.isErr(), isTrue);
        expect(
          createPlanWorkoutResult.error.type,
          SingleErrorTypes.invalidInput,
        );

        // 4. updateWorkoutPlanWorkout rejects cardio workouts
        final updatePlanWorkoutResult = await workoutPlanRepository
            .updateWorkoutPlanWorkout(
              planWorkoutId,
              WorkoutPlanWorkoutInput(workoutId: cardioWorkout.id),
            );
        expect(updatePlanWorkoutResult.isErr(), isTrue);
        expect(
          updatePlanWorkoutResult.error.type,
          SingleErrorTypes.invalidInput,
        );
      },
    );
  });
}
