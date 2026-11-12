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

import 'package:myfitnesstale/src/data/models/sqlite/food_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/food_portion_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/weight_goal_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/weight_record_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_plan_week_model.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/exercise_repository.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/inputs/equipment_input.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/inputs/exercise_input.dart';
import 'package:myfitnesstale/src/data/repositories/foods/food_repository.dart';
import 'package:myfitnesstale/src/data/repositories/foods/inputs/food_input.dart';
import 'package:myfitnesstale/src/data/repositories/onboarding/onboarding_repository.dart';
import 'package:myfitnesstale/src/data/repositories/profile/profile_repository.dart';
import 'package:myfitnesstale/src/data/repositories/weight/inputs/weight_goal_input.dart';
import 'package:myfitnesstale/src/data/repositories/weight/weight_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/workout_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/dtos/workout_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/dtos/workout_record_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/dtos/workout_set_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/dtos/workout_set_exercise_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/dtos/workout_set_exercise_record_dto.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/dtos/workout_set_record_dto.dart';
import 'package:myfitnesstale/src/data/services/common.dart';
import 'package:myfitnesstale/src/data/services/sqlite/dao.dart';
import 'package:myfitnesstale/src/data/services/sqlite/database_helper.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/utils/json_data.dart';
import 'package:myfitnesstale/src/ui/core/view_models/states/common_state.dart';
import 'package:myfitnesstale/src/ui/exercises/view_models/exercise_cubit.dart';
import 'package:myfitnesstale/src/ui/foods/view_models/food_cubit.dart';
import 'package:myfitnesstale/src/ui/foods/view_models/states/food_state.dart';
import 'package:myfitnesstale/src/ui/home/view_models/profile_cubit.dart';
import 'package:myfitnesstale/src/ui/home/view_models/states/profile_state.dart';
import 'package:myfitnesstale/src/ui/weight/view_models/states/weight_record_state.dart';
import 'package:myfitnesstale/src/ui/weight/view_models/weight_record_cubit.dart';
import 'package:myfitnesstale/src/ui/workout_plans/view_models/states/workout_plan_state.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/inputs/workout_plan_day_batch_create_input.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/inputs/workout_plan_input.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/inputs/workout_plan_week_batch_create_input.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/inputs/workout_plan_workout_batch_create_input.dart';
import 'package:myfitnesstale/src/ui/workout_plans/view_models/workout_plan_cubit.dart';
import 'package:myfitnesstale/src/ui/workout_plans/view_models/workout_plan_record_cubit.dart';
import 'package:myfitnesstale/src/ui/workouts/view_models/states/active_workout_state.dart';
import 'package:myfitnesstale/src/ui/workouts/view_models/states/workout_state.dart';
import 'package:myfitnesstale/src/utils/nullable.dart';

import '../../support/test_database.dart';

class _TestProfileCubit extends ProfileCubit {
  _TestProfileCubit({
    required super.profileRepository,
    required super.onboardingService,
  });

  void seedError([String description = 'stale error']) {
    emit(
      state.copyWith(
        error: Nullable(
          ErrorState(type: 'TestError', description: description),
        ),
      ),
    );
  }
}

void main() {
  const difficulty = WorkoutSetExerciseDifficulty(
    value: 2,
    type: WorkoutSetExerciseDifficultyType.rir,
  );
  const supersetFirst = WorkoutSetExerciseDto(
    id: 11,
    position: 0,
    minReps: 8,
    exerciseId: 100,
    toMaxReps: false,
  );
  const supersetSecond = WorkoutSetExerciseDto(
    id: 12,
    position: 1,
    minReps: 10,
    exerciseId: 100,
    toMaxReps: false,
  );
  const firstSet = WorkoutSetDto(
    id: 10,
    position: 0,
    setType: WorkoutSetType.superSet,
    minSets: 3,
    recommendedRestSecs: 60,
    totalExercises: 2,
    totalReps: 54,
    exercises: [supersetFirst, supersetSecond],
  );
  const secondSet = WorkoutSetDto(
    id: 20,
    position: 1,
    setType: WorkoutSetType.standard,
    minSets: 4,
    recommendedRestSecs: 90,
    totalExercises: 1,
    totalReps: 32,
    exercises: [supersetFirst],
  );
  const baseWorkout = WorkoutDto(
    id: 1,
    name: 'Upper Body',
    muscleGroups: {MuscleGroup.push},
    muscles: TargetMuscles(primary: {Muscle.chest}, secondary: {}),
    difficulty: Difficulty.beginner,
    version: 1,
    isFavorite: false,
    totalSets: 7,
    totalReps: 86,
    editorType: EditorType.advanced,
    createdBy: CreatedBy.user,
    sets: [firstSet, secondSet],
  );

  WorkoutRecordDto buildRecord(List<WorkoutSetRecordDto> setRecords) {
    return WorkoutRecordDto(
      id: 50,
      workoutId: baseWorkout.id,
      currentSetPosition: 0,
      currentSetNumber: 2,
      currentExercisePosition: 1,
      totalSets: 2,
      totalReps: 18,
      totalRestSecs: 60,
      totalVolume: 1200000,
      muscles: baseWorkout.muscles,
      startedAt: DateTime(2026),
      setRecords: setRecords,
    );
  }

  WorkoutSetExerciseRecordDto buildExerciseRecord({
    required int id,
    required int workoutSetExerciseId,
    required int reps,
    required int weightGrams,
  }) {
    return WorkoutSetExerciseRecordDto(
      id: id,
      workoutSetExerciseId: workoutSetExerciseId,
      exerciseId: 100,
      reps: reps,
      weightGrams: weightGrams,
      difficulty: difficulty,
    );
  }

  group('Pure state equality and O(N) getters', () {
    test('WorkoutState compares workout lists and WorkoutPagination fields by value', () {
      final renamedWorkout = baseWorkout.copyWith(name: 'Upper Body v2');
      final stateA = WorkoutState.initial().copyWith(
        workouts: [baseWorkout],
        workoutSelection: [baseWorkout],
      );
      final stateB = WorkoutState.initial().copyWith(
        workouts: [renamedWorkout],
        workoutSelection: [baseWorkout],
      );
      final stateC = WorkoutState.initial().copyWith(
        workouts: [baseWorkout],
        workoutSelection: [renamedWorkout],
      );

      expect(stateA == stateB, isFalse);
      expect(stateA == stateC, isFalse);

      const basePagination = WorkoutPagination(
        name: 'Push',
        muscleGroup: MuscleGroup.push,
        difficulty: Difficulty.beginner,
        isFavorite: false,
        limit: 20,
        offset: 0,
        total: 5,
      );
      const diffMuscleGroup = WorkoutPagination(
        name: 'Push',
        muscleGroup: MuscleGroup.pull,
        difficulty: Difficulty.beginner,
        isFavorite: false,
        limit: 20,
        offset: 0,
        total: 5,
      );
      const diffDifficulty = WorkoutPagination(
        name: 'Push',
        muscleGroup: MuscleGroup.push,
        difficulty: Difficulty.advanced,
        isFavorite: false,
        limit: 20,
        offset: 0,
        total: 5,
      );
      const diffTotal = WorkoutPagination(
        name: 'Push',
        muscleGroup: MuscleGroup.push,
        difficulty: Difficulty.beginner,
        isFavorite: false,
        limit: 20,
        offset: 0,
        total: 6,
      );

      expect(basePagination == diffMuscleGroup, isFalse);
      expect(basePagination == diffDifficulty, isFalse);
      expect(basePagination == diffTotal, isFalse);
    });

    test('ActiveWorkoutState compares workout and record contents even with same id', () {
      final recordA = buildRecord(const []);
      final recordB = buildRecord([
        WorkoutSetRecordDto(
          id: 61,
          workoutSetId: firstSet.id,
          setNumber: 1,
          startedAt: DateTime(2026),
          setExerciseRecords: [
            buildExerciseRecord(
              id: 71,
              workoutSetExerciseId: supersetFirst.id,
              reps: 8,
              weightGrams: 50000,
            ),
          ],
        ),
      ]);

      final stateA = ActiveWorkoutState.initial().copyWith(
        workout: const Nullable(baseWorkout),
        workoutRecord: Nullable(recordA),
      );
      final stateRenamedWorkout = stateA.copyWith(
        workout: Nullable(baseWorkout.copyWith(name: 'Upper Body Edited')),
      );
      final stateUpdatedRecord = stateA.copyWith(
        workoutRecord: Nullable(recordB),
      );

      expect(stateA == stateRenamedWorkout, isFalse);
      expect(stateA == stateUpdatedRecord, isFalse);
    });

    test('ActiveWorkoutState.latestMatchingExerciseRecord picks exact entry and latest prior set from unsorted records without O(N log N) sorting', () {
      final unsortedExactMatch = ActiveWorkoutState.initial().copyWith(
        workout: const Nullable(baseWorkout),
        currentSetPosition: 0,
        currentSetNumber: 2,
        currentExercisePosition: 1,
        workoutRecord: Nullable(
          buildRecord([
            // Future set should be ignored
            WorkoutSetRecordDto(
              id: 99,
              workoutSetId: firstSet.id,
              setNumber: 3,
              startedAt: DateTime(2026),
              setExerciseRecords: [
                buildExerciseRecord(
                  id: 903,
                  workoutSetExerciseId: supersetSecond.id,
                  reps: 99,
                  weightGrams: 999000,
                ),
              ],
            ),
            // Matching currentSetNumber with both duplicate exerciseId entries
            WorkoutSetRecordDto(
              id: 62,
              workoutSetId: firstSet.id,
              setNumber: 2,
              startedAt: DateTime(2026),
              setExerciseRecords: [
                buildExerciseRecord(
                  id: 72,
                  workoutSetExerciseId: supersetFirst.id,
                  reps: 8,
                  weightGrams: 40000,
                ),
                buildExerciseRecord(
                  id: 73,
                  workoutSetExerciseId: supersetSecond.id,
                  reps: 10,
                  weightGrams: 60000,
                ),
              ],
            ),
            WorkoutSetRecordDto(
              id: 61,
              workoutSetId: firstSet.id,
              setNumber: 1,
              startedAt: DateTime(2026),
              setExerciseRecords: [
                buildExerciseRecord(
                  id: 71,
                  workoutSetExerciseId: supersetSecond.id,
                  reps: 12,
                  weightGrams: 55000,
                ),
              ],
            ),
          ]),
        ),
      );

      final exact = unsortedExactMatch.latestMatchingExerciseRecord;
      expect(exact?.id, 73);
      expect(exact?.weightGrams, 60000);

      final fallbackLatestPrior = ActiveWorkoutState.initial().copyWith(
        workout: const Nullable(baseWorkout),
        currentSetPosition: 0,
        currentSetNumber: 3,
        currentExercisePosition: 1,
        workoutRecord: Nullable(
          buildRecord([
            // Unrelated set group should be ignored
            WorkoutSetRecordDto(
              id: 88,
              workoutSetId: secondSet.id,
              setNumber: 3,
              startedAt: DateTime(2026),
              setExerciseRecords: [
                buildExerciseRecord(
                  id: 801,
                  workoutSetExerciseId: supersetSecond.id,
                  reps: 15,
                  weightGrams: 90000,
                ),
              ],
            ),
            // Set 2 comes before set 1 in the list (unsorted)
            WorkoutSetRecordDto(
              id: 62,
              workoutSetId: firstSet.id,
              setNumber: 2,
              startedAt: DateTime(2026),
              setExerciseRecords: [
                buildExerciseRecord(
                  id: 72,
                  workoutSetExerciseId: supersetFirst.id,
                  reps: 9,
                  weightGrams: 65000,
                ),
              ],
            ),
            WorkoutSetRecordDto(
              id: 61,
              workoutSetId: firstSet.id,
              setNumber: 1,
              startedAt: DateTime(2026),
              setExerciseRecords: [
                buildExerciseRecord(
                  id: 71,
                  workoutSetExerciseId: supersetSecond.id,
                  reps: 12,
                  weightGrams: 50000,
                ),
              ],
            ),
            // Empty set records are skipped
            WorkoutSetRecordDto(
              id: 63,
              workoutSetId: firstSet.id,
              setNumber: 3,
              startedAt: DateTime(2026),
              setExerciseRecords: const [],
            ),
          ]),
        ),
      );

      final latestPrior = fallbackLatestPrior.latestMatchingExerciseRecord;
      expect(latestPrior?.id, 72);
      expect(latestPrior?.weightGrams, 65000);

      final secondSetState = fallbackLatestPrior.copyWith(
        currentSetPosition: 1,
      );
      expect(fallbackLatestPrior.totalCurrentSet, 3);
      expect(secondSetState.totalCurrentSet, 6);
    });

    test('Weight pagination defaults to kDefaultLimit and ProfileState clears errors', () {
      expect(WeightRecordPaginationState.initial().limit, kDefaultLimit);
      expect(WeightGoalPaginationState.initial().limit, kDefaultLimit);

      final withError = ProfileState.initial().copyWith(
        error: const Nullable(
          ErrorState(type: 'Err', description: 'something failed'),
        ),
      );
      expect(withError.error, isNotNull);

      final cleared = withError.copyWith(error: const Nullable(null));
      expect(cleared.error, isNull);
    });
  });

  group('SQLite-backed Cubit consistency and performance', () {
    final testDatabase = TestDatabase();

    setUpAll(testDatabase.initialize);

    tearDown(() async {
      final db = await testDatabase.db;
      await testDatabase.clearWorkoutPlanTables();
      await testDatabase.clearOnboardingTables();
      await db.delete(FoodPortion.table);
      await db.delete(Food.table);
      await db.delete(WeightRecord.table);
      await db.delete(WeightGoal.table);
    });

    tearDownAll(testDatabase.destroy);

    test('ExerciseCubit appends paginated equipments and updates favorite-filtered exercises', () async {
      final cubit = ExerciseCubit(
        exerciseRepository: ExerciseRepository.create(),
      );
      addTearDown(cubit.close);

      await cubit.createEquipment(const EquipmentInput(name: 'A Barbell'));
      final barbellId = cubit.state.selectedEquipment!.equipment.id;
      await cubit.createEquipment(const EquipmentInput(name: 'B Dumbbell'));
      await cubit.createEquipment(const EquipmentInput(name: 'C Kettlebell'));

      await cubit.getEquipments(limit: 2, offset: 0);
      expect(cubit.state.equipments.map((e) => e.name).toList(), [
        'A Barbell',
        'B Dumbbell',
      ]);
      expect(cubit.state.equipmentPagination.total, 3);

      await cubit.getEquipments(limit: 2, offset: 2);
      expect(cubit.state.equipments.map((e) => e.name).toList(), [
        'A Barbell',
        'B Dumbbell',
        'C Kettlebell',
      ]);

      await cubit.createExercise(
        ExerciseInput(
          name: 'Bench Press',
          muscleGroup: MuscleGroup.push,
          muscles: const TargetMuscles(primary: {Muscle.chest}, secondary: {}),
          equipmentIds: {barbellId},
          isFavorite: true,
        ),
      );
      final firstId = cubit.state.selectedExercise!.id;
      await cubit.createExercise(
        ExerciseInput(
          name: 'Overhead Press',
          muscleGroup: MuscleGroup.push,
          muscles: const TargetMuscles(
            primary: {Muscle.shoulders},
            secondary: {},
          ),
          equipmentIds: {barbellId},
          isFavorite: true,
        ),
      );
      final secondId = cubit.state.selectedExercise!.id;

      await cubit.getExercises(isFavourite: true);
      expect(cubit.state.exercises.map((e) => e.id).toSet(), {
        firstId,
        secondId,
      });
      expect(cubit.state.exercisePagination.total, 2);

      await cubit.updateExerciseFavorite(secondId, false);
      expect(cubit.state.exercises.map((e) => e.id).toList(), [firstId]);
      expect(cubit.state.exercisePagination.total, 1);
      expect(cubit.state.selectedExercise?.id, secondId);
      expect(cubit.state.selectedExercise?.isFavorite, isFalse);
    });

    test('WorkoutPlanCubit updates plans in-place, preserves loaded weeks, clears stale errors, and enforces WorkoutPlanState equality', () async {
      final db = await testDatabase.db;
      final workoutId = await db.insert(
        Workout.table,
        Workout.create(
          name: 'Seed Workout',
          difficulty: Difficulty.beginner,
        ).toMap(),
      );

      final cubit = WorkoutPlanCubit(
        workoutPlanRepository: WorkoutPlanRepository.create(),
      );
      addTearDown(cubit.close);

      await cubit.createWorkoutPlan(
        const WorkoutPlanInput(
          name: 'Alpha Plan',
          totalWeeks: 1,
          difficulty: Difficulty.beginner,
          isFavorite: true,
        ),
      );
      final planId = cubit.state.selectedWorkoutPlan!.id;

      await cubit.createWorkoutPlanVersionWithWeeks(
        workoutPlanId: planId,
        weeks: [
          WorkoutPlanWeekBatchCreateInput(
            startWeek: 1,
            endWeek: 1,
            days: [
              WorkoutPlanDayBatchCreateInput(
                day: 1,
                workouts: [
                  WorkoutPlanWorkoutBatchCreateInput(workoutId: workoutId),
                ],
              ),
            ],
          ),
        ],
      );
      expect(cubit.state.error, isNull);
      final withWeeks = cubit.state.selectedWorkoutPlan!;
      expect(withWeeks.weeks, isNotNull);
      expect(withWeeks.weeks, isNotEmpty);

      // Verify WorkoutPlanState compares elements by value rather than length.
      final listStateA = WorkoutPlanState.initial().copyWith(
        workoutPlans: [withWeeks],
      );
      final listStateB = WorkoutPlanState.initial().copyWith(
        workoutPlans: [withWeeks.copyWith(name: 'Renamed In Memory')],
      );
      expect(listStateA == listStateB, isFalse);

      await cubit.getWorkoutPlans(isFavorite: true);
      expect(cubit.state.workoutPlans, hasLength(1));

      // Seed an error by requesting a nonexistent plan.
      await cubit.getWorkoutPlan(999999);
      expect(cubit.state.error, isNotNull);

      await cubit.updateWorkoutPlan(
        planId,
        const WorkoutPlanInput(
          name: 'Alpha Plan Updated',
          totalWeeks: 1,
          difficulty: Difficulty.intermediate,
          isFavorite: true,
        ),
      );
      expect(cubit.state.error, isNull);
      expect(cubit.state.selectedWorkoutPlan?.name, 'Alpha Plan Updated');
      expect(cubit.state.selectedWorkoutPlan?.weeks, isNotEmpty);
      expect(cubit.state.workoutPlans.single.name, 'Alpha Plan Updated');

      await cubit.updateWorkoutPlanFavorite(planId, false);
      expect(cubit.state.error, isNull);
      expect(cubit.state.workoutPlans, isEmpty);
      expect(cubit.state.pagination.total, 0);
      expect(cubit.state.selectedWorkoutPlan?.isFavorite, isFalse);
    });

    test('WorkoutPlanRecordCubit resolves todaysWorkouts from in-memory plan weeks and loads progress concurrently', () async {
      final db = await testDatabase.db;
      final workoutId = await db.insert(
        Workout.table,
        Workout.create(
          name: 'In-Memory Workout',
          difficulty: Difficulty.beginner,
        ).toMap(),
      );

      final planRepo = WorkoutPlanRepository.create();
      final createdPlan = await planRepo.createWorkoutPlan(
        const WorkoutPlanInput(
          name: 'In-Memory Plan',
          totalWeeks: 1,
          difficulty: Difficulty.beginner,
          isFavorite: false,
        ),
      );
      expect(createdPlan.isOk(), isTrue);
      final planId = createdPlan.value.id;

      final withWeeks = await planRepo.createWorkoutPlanVersionWithWeeks(
        workoutPlanId: planId,
        weeks: [
          WorkoutPlanWeekBatchCreateInput(
            startWeek: 1,
            endWeek: 1,
            scheduleMode: WorkoutPlanWeekScheduleMode.manual,
            days: [
              WorkoutPlanDayBatchCreateInput(
                day: 1,
                workouts: [
                  WorkoutPlanWorkoutBatchCreateInput(workoutId: workoutId),
                ],
              ),
            ],
          ),
        ],
      );
      expect(withWeeks.isOk(), isTrue);

      final recordCubit = WorkoutPlanRecordCubit(
        workoutPlanRecordRepository: WorkoutPlanRecordRepository.create(),
        workoutPlanRepository: planRepo,
        workoutRecordRepository: WorkoutRecordRepository.create(),
      );
      addTearDown(recordCubit.close);

      await recordCubit.getOrCreateActivePlanRecord(planId);
      await recordCubit.getLatestActivePlanRecord();

      expect(
        recordCubit.state.currentPlanRecord.workoutPlan?.weeks,
        isNotEmpty,
      );
      expect(recordCubit.state.currentPlanRecord.totalWorkouts, 1);
      expect(recordCubit.state.currentPlanRecord.completedWorkouts, 0);
      expect(recordCubit.state.currentPlanRecord.todaysWorkouts, hasLength(1));

      await recordCubit.refreshProgress();
      expect(recordCubit.state.currentPlanRecord.totalWorkouts, 1);
      expect(recordCubit.state.currentPlanRecord.completedWorkouts, 0);

      // Delete week rows from SQLite: getTodaysWorkout should resolve from the loaded plan without re-querying weeks.
      await db.delete(
        WorkoutPlanWeek.table,
        where: '${WorkoutPlanWeekColumns.workoutPlanId.value} = ?',
        whereArgs: [planId],
      );

      await recordCubit.getTodaysWorkout();
      expect(recordCubit.state.error, isNull);
      expect(recordCubit.state.currentPlanRecord.todaysWorkouts, hasLength(1));
      expect(
        recordCubit.state.currentPlanRecord.todaysWorkouts.single.name,
        'In-Memory Workout',
      );
    });

    test(
      'WeightRecordCubit uses kDefaultLimit and populates created goals',
      () async {
        final cubit = WeightRecordCubit(
          weightRecordRepository: WeightRecordRepository.create(),
        );
        addTearDown(cubit.close);

        expect(cubit.state.goalPagination.limit, kDefaultLimit);
        expect(cubit.state.recordPagination.limit, kDefaultLimit);

        await cubit.createWeightGoal(
          WeightGoalInput(
            targetWeight: 74000,
            startDate: DateTime(2026, 2, 1),
            phase: WeightGoalPhase.cut,
          ),
        );

        expect(cubit.state.error, isNull);
        expect(cubit.state.activeWeightGoal?.targetWeight, 74000);
        expect(cubit.state.weightGoals, hasLength(1));
      },
    );

    test('ProfileCubit loads initial data concurrently and clears stale errors on updates', () async {
      final seedCubit = ProfileCubit(
        profileRepository: ProfileRepository.create(),
        onboardingService: OnboardingRepository.create(),
      );
      addTearDown(seedCubit.close);

      await seedCubit.onboardProfile(
        units: Units.metric,
        theme: ThemeType.light,
        name: 'Concurrent User',
        height: 178,
        gender: Gender.other,
        birthday: DateTime(1992, 5, 10),
        createWorkouts: false,
        notificationsOn: true,
      );

      final cubit = _TestProfileCubit(
        profileRepository: ProfileRepository.create(),
        onboardingService: OnboardingRepository.create(),
      );
      addTearDown(cubit.close);

      await cubit.loadInitialData();
      expect(cubit.state.error, isNull);
      expect(cubit.state.profile?.name, 'Concurrent User');
      expect(cubit.state.system?.theme, ThemeType.light);
      expect(cubit.state.remindersConfig?.workoutsOn, isTrue);

      cubit.seedError();
      expect(cubit.state.error, isNotNull);
      await cubit.updateProfile(name: 'Updated User');
      expect(cubit.state.error, isNull);
      expect(cubit.state.profile?.name, 'Updated User');

      cubit.seedError();
      await cubit.updateSystem(theme: ThemeType.dark);
      expect(cubit.state.error, isNull);
      expect(cubit.state.system?.theme, ThemeType.dark);

      cubit.seedError();
      await cubit.getRemindersConfig();
      expect(cubit.state.error, isNull);
      expect(cubit.state.remindersConfig, isNotNull);
    });

    test('FoodCubit keeps pagination intact on failure and respects active filters on createFood and toggleFavorite', () async {
      final failingFoodRepo = FoodRepository(
        foodDao: Dao<Food>(
          databaseHelper: DatabaseHelper(),
          tableName: 'nonexistent_foods_table',
          fromMap: Food.fromMap,
        ),
        portionDao: Dao<FoodPortion>(
          databaseHelper: DatabaseHelper(),
          tableName: FoodPortion.table,
          fromMap: FoodPortion.fromMap,
        ),
      );
      final failingCubit = FoodCubit(foodRepository: failingFoodRepo);
      addTearDown(failingCubit.close);

      await failingCubit.getFoods(
        search: 'QueryShouldNotStick',
        category: FoodCategory.fruits,
        isFavorite: true,
        limit: 15,
        offset: 5,
      );
      expect(failingCubit.state.error, isNotNull);
      expect(failingCubit.state.isLoading, isFalse);
      expect(
        failingCubit.state.foodPagination,
        FoodState.initial().foodPagination,
      );

      final cubit = FoodCubit(foodRepository: FoodRepository.create());
      addTearDown(cubit.close);

      await cubit.createFood(
        const FoodInput(
          name: 'Chicken Breast',
          category: FoodCategory.meatAndPoultry,
          servingSizeBaseGrams: 100,
          caloriesBase: 165,
          proteinBase: 31,
          carbsBase: 0,
          fatBase: 4,
          isFavorite: true,
          portions: [],
        ),
      );
      final chickenId = cubit.state.selectedFood!.id;

      await cubit.getFoods(
        category: FoodCategory.meatAndPoultry,
        isFavorite: true,
      );
      expect(cubit.state.foods.map((f) => f.id).toList(), [chickenId]);
      expect(cubit.state.foodPagination.total, 1);

      // Non-matching food should not be prepended to the filtered list.
      final createdOther = await cubit.createFood(
        const FoodInput(
          name: 'Brown Rice',
          category: FoodCategory.grainsAndCereals,
          servingSizeBaseGrams: 100,
          caloriesBase: 112,
          proteinBase: 3,
          carbsBase: 24,
          fatBase: 1,
          isFavorite: false,
          portions: [],
        ),
      );
      expect(createdOther, isTrue);
      expect(cubit.state.foods.map((f) => f.id).toList(), [chickenId]);
      expect(cubit.state.foodPagination.total, 1);

      // Matching food should be added to the filtered list and increment total.
      final createdMatch = await cubit.createFood(
        const FoodInput(
          name: 'Turkey Breast',
          category: FoodCategory.meatAndPoultry,
          servingSizeBaseGrams: 100,
          caloriesBase: 135,
          proteinBase: 30,
          carbsBase: 0,
          fatBase: 1,
          isFavorite: true,
          portions: [],
        ),
      );
      expect(createdMatch, isTrue);
      expect(cubit.state.foodPagination.total, 2);
      expect(cubit.state.foods, hasLength(2));

      // Toggling favorite off removes item when isFavorite filter is active.
      final toggled = await cubit.toggleFavorite(chickenId);
      expect(toggled, isTrue);
      expect(cubit.state.foods.any((food) => food.id == chickenId), isFalse);
      expect(cubit.state.foodPagination.total, 1);
    });

    FoodInput foodInput(String name, {bool isFavorite = false}) => FoodInput(
      name: name,
      category: FoodCategory.fruits,
      servingSizeBaseGrams: 100,
      caloriesBase: 60,
      proteinBase: 1,
      carbsBase: 14,
      fatBase: 0,
      isFavorite: isFavorite,
      portions: const [],
    );

    test('Food creation preserves the sorted pagination boundary', () async {
      final repository = FoodRepository.create();
      for (final name in ['Apple', 'Banana', 'Cherry']) {
        expect((await repository.createFood(foodInput(name))).isOk(), isTrue);
      }
      final cubit = FoodCubit(foodRepository: repository);
      addTearDown(cubit.close);

      await cubit.getFoods(limit: 1);
      await cubit.getFoods(limit: 1, offset: cubit.state.foods.length);
      expect(await cubit.createFood(foodInput('Zucchini')), isTrue);
      expect(cubit.state.foods.map((food) => food.name), ['Apple', 'Banana']);
      expect(cubit.state.foodPagination.total, 4);

      await cubit.getFoods(limit: 2, offset: cubit.state.foods.length);
      expect(cubit.state.foods.map((food) => food.name), [
        'Apple',
        'Banana',
        'Cherry',
        'Zucchini',
      ]);
    });

    test(
      'Food search overlapping a favorite write settles the latest query',
      () async {
        final repository = FoodRepository.create();
        final apple = await repository.createFood(
          foodInput('Apple', isFavorite: true),
        );
        await repository.createFood(foodInput('Apricot', isFavorite: true));
        await repository.createFood(foodInput('Banana', isFavorite: true));
        final cubit = FoodCubit(foodRepository: repository);
        addTearDown(cubit.close);
        await cubit.getFoods();

        final toggle = cubit.toggleFavorite(apple.value.id);
        final search = cubit.getFoods(search: 'Ap', isFavorite: true, limit: 1);
        expect(cubit.state.isLoading, isTrue);
        expect(await toggle, isTrue);
        await search;

        expect(cubit.state.isLoading, isFalse);
        expect(cubit.state.foodPagination.name, 'Ap');
        expect(cubit.state.foodPagination.isFavorite, isTrue);
        expect(cubit.state.foodPagination.total, 1);
        expect(cubit.state.foods.map((food) => food.name), ['Apricot']);
      },
    );
  });
}
