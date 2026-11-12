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
import 'package:myfitnesstale/src/data/models/sqlite/daily_nutrition_log_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/day_macro_goal_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/food_portion_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/meal_plan_day_record_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/meal_plan_week_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/recipe_item_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/week_macro_goal_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/weight_goal_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_plan_day_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_plan_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_plan_week_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_record_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_set_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_set_record_model.dart';
import 'package:myfitnesstale/src/data/repositories/core/repository_helpers.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/exercise_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/foods/food_repository.dart';
import 'package:myfitnesstale/src/data/repositories/foods/inputs/food_input.dart';
import 'package:myfitnesstale/src/data/repositories/foods/inputs/food_portion_input.dart';
import 'package:myfitnesstale/src/data/repositories/macros/inputs/week_macro_goal_input.dart';
import 'package:myfitnesstale/src/data/repositories/macros/macro_tracking_repository.dart';
import 'package:myfitnesstale/src/data/repositories/meal_plans/inputs/meal_plan_day_input.dart';
import 'package:myfitnesstale/src/data/repositories/meal_plans/inputs/meal_plan_input.dart';
import 'package:myfitnesstale/src/data/repositories/meal_plans/inputs/meal_plan_week_input.dart';
import 'package:myfitnesstale/src/data/repositories/meal_plans/meal_plan_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/meal_plans/meal_plan_repository.dart';
import 'package:myfitnesstale/src/data/repositories/recipes/inputs/recipe_input.dart';
import 'package:myfitnesstale/src/data/repositories/recipes/inputs/recipe_item_input.dart';
import 'package:myfitnesstale/src/data/repositories/recipes/recipe_repository.dart';
import 'package:myfitnesstale/src/data/repositories/weight/inputs/weight_goal_input.dart';
import 'package:myfitnesstale/src/data/repositories/weight/weight_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/inputs/week_workout_input.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/inputs/workout_plan_day_batch_create_input.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/inputs/workout_plan_record_input.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/inputs/workout_plan_week_batch_create_input.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/inputs/workout_plan_workout_batch_create_input.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/inputs/workout_plan_workout_record_input.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/inputs/workout_record_batch_input.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/inputs/workout_set_record_batch_input.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/workout_record_repository.dart';
import 'package:myfitnesstale/src/data/services/sqlite/dao.dart';
import 'package:myfitnesstale/src/data/services/sqlite/database_helper.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/ui/meal_plans/view_models/meal_plan_cubit.dart';
import 'package:myfitnesstale/src/utils/errors.dart';
import 'package:sqflite/sqflite.dart';

import '../../support/test_database.dart';

void main() {
  final testDatabase = TestDatabase();
  int counter = 0;

  String uniqueName(String prefix) => '$prefix-${counter++}';

  Future<int> insertWorkout(Database db) async {
    return db.insert(
      Workout.table,
      Workout.create(
        name: uniqueName('workout'),
        difficulty: Difficulty.beginner,
      ).toMap(),
    );
  }

  Future<int> insertWorkoutPlan(Database db) async {
    return db.insert(
      WorkoutPlan.table,
      WorkoutPlan.create(
        name: uniqueName('plan'),
        difficulty: Difficulty.beginner,
      ).toMap(),
    );
  }

  Future<int> insertWorkoutRecord(Database db, int workoutId) async {
    return db.insert(
      WorkoutRecord.table,
      WorkoutRecord.create(
        workoutId: workoutId,
        version: 1,
        startedAt: 1700000000 + counter++,
      ).toMap(),
    );
  }

  setUpAll(testDatabase.initialize);
  tearDownAll(testDatabase.destroy);

  test('ExerciseRecordRepository.getExerciseRecords handles empty DB with null exerciseId', () async {
    final result = await ExerciseRecordRepository.create().getExerciseRecords();
    expect(result.isOk(), isTrue);
    expect(result.value.data, isEmpty);
    expect(result.value.total, 0);
  });

  group('WorkoutPlanRepository regressions', () {
    tearDown(testDatabase.clearWorkoutPlanTables);

    test('createWorkoutPlanDay allows duplicate workout IDs and getWorkoutPlanDay loads them', () async {
      final db = await testDatabase.db;
      final workoutId = await insertWorkout(db);
      final planId = await insertWorkoutPlan(db);
      final weekId = await db.insert(
        WorkoutPlanWeek.table,
        WorkoutPlanWeek.create(
          workoutPlanId: planId,
          startWeek: 1,
          endWeek: 1,
          scheduleMode: WorkoutPlanWeekScheduleMode.manual,
        ).toMap(),
      );

      final repo = WorkoutPlanRepository.create();
      final created = await repo.createWorkoutPlanDay(
        workoutPlanWeekId: weekId,
        day: 1,
        workouts: [
          WeekWorkoutInput(
            workoutId: workoutId,
            timeOfDay: WorkoutTimeOfDay.morning,
          ),
          WeekWorkoutInput(
            workoutId: workoutId,
            timeOfDay: WorkoutTimeOfDay.evening,
          ),
        ],
      );

      expect(created.isOk(), isTrue);
      expect(created.value.planWorkouts, hasLength(2));

      final fetched = await repo.getWorkoutPlanDay(created.value.id);
      expect(fetched.isOk(), isTrue);
      expect(fetched.value.planWorkouts, hasLength(2));
      expect(fetched.value.planWorkouts!.map((w) => w.workout?.id).toList(), [
        workoutId,
        workoutId,
      ]);
    });

    test(
      'inserting into a sparse schedule shifts days only up to the next gap',
      () async {
        final db = await testDatabase.db;
        final workoutId = await insertWorkout(db);
        final planId = await insertWorkoutPlan(db);
        final repo = WorkoutPlanRepository.create();
        final plan = (await repo.createWorkoutPlanVersionWithWeeks(
          workoutPlanId: planId,
          weeks: [
            WorkoutPlanWeekBatchCreateInput(
              startWeek: 1,
              endWeek: 1,
              days: [
                for (final day in [1, 2, 3, 4, 5, 7])
                  WorkoutPlanDayBatchCreateInput(
                    day: day,
                    workouts: [
                      WorkoutPlanWorkoutBatchCreateInput(workoutId: workoutId),
                    ],
                  ),
              ],
            ),
          ],
        )).value;
        final week = plan.weeks!.single;
        final inserted = await repo.createWorkoutPlanDay(
          workoutPlanWeekId: week.id,
          day: 5,
          workouts: [WeekWorkoutInput(workoutId: workoutId)],
        );
        expect(inserted.isOk(), isTrue);
        expect(inserted.value.day, 5);

        final saved = (await repo.getWorkoutPlanWeek(week.id)).value;
        expect(saved.days.map((day) => day.day), [1, 2, 3, 4, 5, 6, 7]);
        expect(saved.days.last.id, week.days.last.id);
      },
    );

    test('updateWorkoutPlanDay persists target day and shifts only overlapping siblings', () async {
      final db = await testDatabase.db;
      final workoutId = await insertWorkout(db);
      final planId = await insertWorkoutPlan(db);
      final weekId = await db.insert(
        WorkoutPlanWeek.table,
        WorkoutPlanWeek.create(
          workoutPlanId: planId,
          startWeek: 1,
          endWeek: 1,
          scheduleMode: WorkoutPlanWeekScheduleMode.manual,
        ).toMap(),
      );

      final repo = WorkoutPlanRepository.create();
      final day1 = (await repo.createWorkoutPlanDay(
        workoutPlanWeekId: weekId,
        day: 1,
        workouts: [WeekWorkoutInput(workoutId: workoutId)],
      )).value;
      final day2 = (await repo.createWorkoutPlanDay(
        workoutPlanWeekId: weekId,
        day: 2,
        workouts: [WeekWorkoutInput(workoutId: workoutId)],
      )).value;
      final day3 = (await repo.createWorkoutPlanDay(
        workoutPlanWeekId: weekId,
        day: 3,
        workouts: [WeekWorkoutInput(workoutId: workoutId)],
      )).value;

      // Move day 3 -> day 1: day1 and day2 shift up (+1).
      final movedDown = await repo.updateWorkoutPlanDay(
        workoutPlanDayId: day3.id,
        day: 1,
      );
      expect(movedDown.isOk(), isTrue);
      expect(movedDown.value.day, 1);

      Future<Map<int, int>> readDaysById() async {
        final rows = await db.query(
          WorkoutPlanDay.table,
          where: '${WorkoutPlanDayColumns.workoutPlanWeekId.value} = ?',
          whereArgs: [weekId],
        );
        return {
          for (final row in rows)
            row[WorkoutPlanDayColumns.id.value] as int:
                row[WorkoutPlanDayColumns.day.value] as int,
        };
      }

      expect(await readDaysById(), {day3.id: 1, day1.id: 2, day2.id: 3});

      // Move day3 from 1 -> 2: only day1 (in (1, 2]) shifts down (-1);
      // day2 at 3 remains untouched.
      final movedUp = await repo.updateWorkoutPlanDay(
        workoutPlanDayId: day3.id,
        day: 2,
      );
      expect(movedUp.isOk(), isTrue);
      expect(movedUp.value.day, 2);

      expect(await readDaysById(), {day1.id: 1, day3.id: 2, day2.id: 3});
    });
  });

  group('WorkoutPlanRecordRepository regressions', () {
    tearDown(testDatabase.clearWorkoutPlanTables);

    test('isolates template week lookups and totals across plan versions and runs Dao.rawCount', () async {
      final db = await testDatabase.db;
      final planId = await insertWorkoutPlan(db);
      final workoutA = await insertWorkout(db);
      final workoutB = await insertWorkout(db);
      final workoutC = await insertWorkout(db);

      final planRepo = WorkoutPlanRepository.create();
      final recordRepo = WorkoutPlanRecordRepository.create();

      // Version 1: only week 1, totalWorkouts = 1.
      final v1Result = await planRepo.createWorkoutPlanVersionWithWeeks(
        workoutPlanId: planId,
        weeks: [
          WorkoutPlanWeekBatchCreateInput(
            startWeek: 1,
            endWeek: 1,
            days: [
              WorkoutPlanDayBatchCreateInput(
                day: 1,
                workouts: [
                  WorkoutPlanWorkoutBatchCreateInput(workoutId: workoutA),
                ],
              ),
            ],
          ),
        ],
      );
      expect(v1Result.isOk(), isTrue);
      final v1Record = (await recordRepo.createWorkoutPlanRecord(
        WorkoutPlanRecordInput(workoutPlanId: planId),
      )).value;
      expect(v1Record.workoutPlanVersion, 1);

      // Version 2: weeks 1..2 with 2 workouts/week => totalWorkouts = 4.
      final v2Result = await planRepo.createWorkoutPlanVersionWithWeeks(
        workoutPlanId: planId,
        weeks: [
          WorkoutPlanWeekBatchCreateInput(
            startWeek: 1,
            endWeek: 2,
            days: [
              WorkoutPlanDayBatchCreateInput(
                day: 1,
                workouts: [
                  WorkoutPlanWorkoutBatchCreateInput(workoutId: workoutB),
                  WorkoutPlanWorkoutBatchCreateInput(workoutId: workoutC),
                ],
              ),
            ],
          ),
        ],
      );
      expect(v2Result.isOk(), isTrue);
      final v2Record = (await recordRepo.createWorkoutPlanRecord(
        WorkoutPlanRecordInput(workoutPlanId: planId),
      )).value;
      expect(v2Record.workoutPlanVersion, 2);

      final workoutRecA = await insertWorkoutRecord(db, workoutA);
      final workoutRecB = await insertWorkoutRecord(db, workoutB);

      // Requesting week 2 on v1 record must NOT fall through to v2's week 2 template.
      final v1Week2Miss = await recordRepo.upsertWorkoutPlanWorkoutRecord(
        WorkoutPlanWorkoutRecordInput(
          workoutPlanRecordId: v1Record.id,
          workoutRecordId: workoutRecA,
          status: ProgressStatus.completed,
          week: 2,
          weekDay: 1,
          workoutPosition: 1,
        ),
      );
      expect(v1Week2Miss.isErr(), isTrue);
      expect(v1Week2Miss.error.type, SingleErrorTypes.notFound);

      // Requesting week 2 on v2 record succeeds using v2's template.
      final v2Week2Hit = await recordRepo.upsertWorkoutPlanWorkoutRecord(
        WorkoutPlanWorkoutRecordInput(
          workoutPlanRecordId: v2Record.id,
          workoutRecordId: workoutRecB,
          status: ProgressStatus.completed,
          week: 2,
          weekDay: 1,
          workoutPosition: 1,
        ),
      );
      expect(v2Week2Hit.isOk(), isTrue);

      final v1Total = await recordRepo.getTotalWorkoutsCount(
        planId,
        workoutPlanVersion: 1,
      );
      final v2Total = await recordRepo.getTotalWorkoutsCount(
        planId,
        workoutPlanVersion: 2,
      );
      expect(v1Total.value, 1);
      expect(v2Total.value, 4);

      final completedV1 = await recordRepo.upsertWorkoutPlanWorkoutRecord(
        WorkoutPlanWorkoutRecordInput(
          workoutPlanRecordId: v1Record.id,
          workoutRecordId: workoutRecA,
          status: ProgressStatus.completed,
          week: 1,
          weekDay: 1,
          workoutPosition: 1,
        ),
      );
      expect(completedV1.isOk(), isTrue);
      expect(completedV1.value.status, ProgressStatus.completed);
      expect(v2Week2Hit.value.status, ProgressStatus.inProgress);

      final progressV2 = await recordRepo.getPlanProgressPercentage(
        v2Record.id,
        planId,
        2,
      );
      expect(progressV2.isOk(), isTrue);
      expect(progressV2.value, 25.0);

      final weekDao = Dao<WorkoutPlanWeek>(
        databaseHelper: DatabaseHelper(),
        tableName: WorkoutPlanWeek.table,
        fromMap: WorkoutPlanWeek.fromMap,
      );
      final directRawCount = await weekDao.rawCount(
        'SELECT COUNT(*) AS count FROM ${WorkoutPlanWeek.table} WHERE ${WorkoutPlanWeekColumns.workoutPlanId.value} = ?',
        [planId],
      );
      expect(directRawCount, 2);
    });
  });

  test(
    'concurrent daily log reads and water updates share one saved row',
    () async {
      final repo = MacroTrackingRepository.create();
      final date = DateTime(2026, 9, 12);
      final results = await Future.wait([
        repo.getDailyLogByDate(date),
        repo.getDailyLogByDate(date),
        repo.updateWaterIntake(date: date, waterIntakeMl: 250),
      ]);

      expect(results.every((result) => result.isOk()), isTrue);
      final saved = (await repo.getDailyLogByDate(date)).value;
      expect(saved.id, greaterThan(0));
      expect(results.map((result) => result.value.id).toSet(), {saved.id});
      expect(saved.waterIntakeMl, 250);
    },
  );

  test('concurrent meal plan updates save distinct versions', () async {
    final repo = MealPlanRepository.create();
    MealPlanInput input(String name) => MealPlanInput(
      name: name,
      weeks: const [
        MealPlanWeekInput(weekNumber: 1, phase: MealPlanPhase.maintain),
      ],
    );
    final plan = (await repo.createMealPlan(input('Initial plan'))).value;

    final results = await Future.wait([
      repo.updateMealPlan(plan.id, input('First edit')),
      repo.updateMealPlan(plan.id, input('Second edit')),
    ]);

    expect(results.every((result) => result.isOk()), isTrue);
    expect(results.map((result) => result.value.version).toSet(), {2, 3});
    for (final result in results) {
      final saved = (await repo.getMealPlan(
        plan.id,
        version: result.value.version,
      )).value;
      expect(saved.weeks.single.id, result.value.weeks.single.id);
    }
  });

  test('macro diary lookups return typed SQLite failures', () async {
    final repo = MacroTrackingRepository.create();
    final food = (await FoodRepository.create().createFood(
      FoodInput(
        name: uniqueName('Test food'),
        category: FoodCategory.fruits,
        servingSizeBaseGrams: 100,
        caloriesBase: 90,
        proteinBase: 1,
        carbsBase: 23,
        fatBase: 0,
        portions: const [],
      ),
    )).value;
    final date = DateTime(2025, 8, 9);
    final db = await testDatabase.db;
    await db.execute(
      'CREATE TEMP VIEW ${FoodPortion.table} AS SELECT 1 AS unused',
    );
    addTearDown(() => db.execute('DROP VIEW temp.${FoodPortion.table}'));

    final portionFailure = await repo.logFoodItem(
      logTime: date,
      mealType: MealType.breakfast,
      foodId: food.id,
      portionId: 1,
      amount: 1,
    );
    expect(portionFailure.error.type, SingleErrorTypes.operationFailure);
    expect(portionFailure.error.description, 'Failed to load food portion');

    await db.execute(
      'CREATE TEMP VIEW ${DailyNutritionLog.table} AS SELECT 1 AS unused',
    );
    addTearDown(() => db.execute('DROP VIEW temp.${DailyNutritionLog.table}'));
    final diaryFailure = await repo.getDailyLogByDate(date);
    expect(diaryFailure.error.type, SingleErrorTypes.operationFailure);
    expect(
      diaryFailure.error.description,
      'Failed to find daily nutrition log',
    );
  });

  test('scheduled workout counts return a typed SQLite failure', () async {
    final db = await testDatabase.db;
    await db.execute(
      'CREATE TEMP VIEW ${WorkoutPlanWeek.table} AS SELECT 1 AS unused',
    );
    addTearDown(() => db.execute('DROP VIEW temp.${WorkoutPlanWeek.table}'));

    final result = await WorkoutPlanRecordRepository.create()
        .getTotalWorkoutsCount(1, workoutPlanVersion: 1);
    expect(result.error.type, OperationErrorTypes.operationFailure);
    expect(result.error.description, 'Failed to get total workouts count');
  });

  test('query helpers return typed failures for SQLite errors', () async {
    final dao = Dao<Workout>(
      databaseHelper: DatabaseHelper(),
      tableName: 'missing_workout_table',
      fromMap: Workout.fromMap,
    );
    final page = await fetchPaginatedWithTotal(
      dao: dao,
      failureType: OperationErrorTypes.operationFailure,
      limit: 10,
      offset: 10,
    );
    final rows = await selectManyInChunks(
      dao: dao,
      failureType: SingleErrorTypes.operationFailure,
      column: WorkoutColumns.id,
      values: [1],
    );
    expect(page.error.type, OperationErrorTypes.operationFailure);
    expect(rows.error.type, SingleErrorTypes.operationFailure);
  });

  test(
    'starting an older meal plan version uses its schedule and totals',
    () async {
      final plans = MealPlanRepository.create();
      final records = MealPlanRecordRepository.create();
      MealPlanInput input(List<MealPlanDayInput> days) => MealPlanInput(
        name: uniqueName('Versioned meal plan'),
        weeks: [
          MealPlanWeekInput(
            weekNumber: 1,
            phase: MealPlanPhase.maintain,
            days: days,
          ),
        ],
      );
      final original = (await plans.createMealPlan(
        input(const [MealPlanDayInput(day: 1)]),
      )).value;
      final edited = (await plans.updateMealPlan(
        original.id,
        input(const [MealPlanDayInput(day: 1), MealPlanDayInput(day: 2)]),
      )).value;
      expect(edited.totalDays, 2);

      final started = (await records.startMealPlan(
        mealPlanId: original.id,
        version: original.version,
      )).value;
      final active = (await records.getActiveMealPlanRecord()).value;
      expect(started.totalDays, 1);
      expect(active.totalDays, 1);
      expect(
        active.weeks.single.days.single.mealPlanDayId,
        original.weeks.single.days.single.id,
      );
    },
  );

  test(
    'starting a replacement meal plan rolls back when a day fails to save',
    () async {
      final plans = MealPlanRepository.create();
      final records = MealPlanRecordRepository.create();
      final plan = (await plans.createMealPlan(
        MealPlanInput(
          name: uniqueName('Meal plan with one day'),
          weeks: const [
            MealPlanWeekInput(
              weekNumber: 1,
              phase: MealPlanPhase.maintain,
              days: [MealPlanDayInput(day: 1)],
            ),
          ],
        ),
      )).value;
      final active = (await records.startMealPlan(mealPlanId: plan.id)).value;
      final db = await testDatabase.db;
      await db.execute("""
      CREATE TEMP TRIGGER fail_meal_plan_day_record
      BEFORE INSERT ON ${MealPlanDayRecord.table}
      BEGIN SELECT RAISE(ABORT, 'forced test failure'); END
    """);
      addTearDown(() => db.execute('DROP TRIGGER fail_meal_plan_day_record'));

      final failed = await records.startMealPlan(mealPlanId: plan.id);
      expect(failed.error.type, SingleErrorTypes.operationFailure);
      expect((await records.getActiveMealPlanRecord()).value.id, active.id);
    },
  );

  test(
    'a rejected schedule row rolls back the entire meal plan version',
    () async {
      final plans = MealPlanRepository.create();
      MealPlanInput input(int day) => MealPlanInput(
        name: uniqueName('Meal plan schedule'),
        weeks: [
          MealPlanWeekInput(
            weekNumber: 1,
            phase: MealPlanPhase.maintain,
            days: [MealPlanDayInput(day: day)],
          ),
        ],
      );
      final plan = (await plans.createMealPlan(input(1))).value;

      final failed = await plans.updateMealPlan(plan.id, input(8));

      expect(failed.error.type, SingleErrorTypes.operationFailure);
      expect((await plans.getMealPlan(plan.id)).value.version, plan.version);
      final db = await testDatabase.db;
      final weeks = await db.query(
        MealPlanWeek.table,
        where: MealPlanWeekColumns.mealPlanId.equal,
        whereArgs: [plan.id],
      );
      expect(weeks.single[MealPlanWeekColumns.planVersion.value], plan.version);
    },
  );

  test('favoriting an open meal plan preserves its loaded weeks', () async {
    final repo = MealPlanRepository.create();
    final plan = (await repo.createMealPlan(
      const MealPlanInput(
        name: 'Favorite plan',
        weeks: [
          MealPlanWeekInput(weekNumber: 1, phase: MealPlanPhase.maintain),
        ],
      ),
    )).value;
    final cubit = MealPlanCubit(mealPlanRepository: repo);
    addTearDown(cubit.close);

    await cubit.getMealPlan(plan.id);
    expect(cubit.state.selectedMealPlan!.weeks, hasLength(1));
    expect(await cubit.toggleFavorite(plan.id), isTrue);
    expect(cubit.state.selectedMealPlan!.isFavorite, isTrue);
    expect(cubit.state.selectedMealPlan!.weeks, hasLength(1));
  });

  test('batch workout save returns sets in read order and preserves absent children', () async {
    final db = await testDatabase.db;
    final workoutId = await insertWorkout(db);
    await db.update(
      Workout.table,
      {WorkoutColumns.version.value: 2},
      where: WorkoutColumns.id.equal,
      whereArgs: [workoutId],
    );
    final workoutSetId = await db.insert(
      WorkoutSet.table,
      WorkoutSet.create(
        position: 1,
        workoutId: workoutId,
        setType: WorkoutSetType.standard,
        minSets: 2,
        recommendedRestSecs: 0,
        workoutVersion: 1,
      ).toMap(),
    );
    final now = DateTime.now();
    final repo = WorkoutRecordRepository.create();
    final input = WorkoutRecordBatchInput(
      workoutId: workoutId,
      version: 1,
      startedAt: now,
      completedAt: now,
      sets: [
        for (final number in [2, 1])
          WorkoutSetRecordBatchInput(
            workoutSetId: workoutSetId,
            setNumber: number,
            startedAt: now,
            exercises: const [],
          ),
      ],
    );
    final saved = (await repo.batchCreateWorkoutRecord(input)).value;

    final fetched = (await repo.getWorkoutRecord(saved.id)).value;
    expect(saved.version, 1);
    expect(fetched.version, 1);
    expect(saved.setRecords!.map((set) => set.setNumber), [1, 2]);
    expect(saved.setRecords, fetched.setRecords);
    expect(saved.setRecords!.map((set) => set.setExerciseRecords), [
      null,
      null,
    ]);

    await db.execute("""
      CREATE TEMP TRIGGER fail_second_workout_set_record
      BEFORE INSERT ON ${WorkoutSetRecord.table}
      WHEN NEW.${WorkoutSetRecordColumns.setNumber.value} = 1
      BEGIN SELECT RAISE(ABORT, 'forced test failure'); END
    """);
    addTearDown(
      () => db.execute('DROP TRIGGER fail_second_workout_set_record'),
    );

    final failed = await repo.batchUpdateWorkoutRecord(saved.id, input);
    expect(failed.error.type, OperationErrorTypes.operationFailure);
    final afterFailure = (await repo.getWorkoutRecord(saved.id)).value;
    expect(afterFailure.setRecords, fetched.setRecords);
  });

  test('RecipeRepository preserves existing items on failed update and toggleFavorite leaves items intact', () async {
    final foodRepo = FoodRepository.create();
    final recipeRepo = RecipeRepository.create();

    final food = (await foodRepo.createFood(
      FoodInput(
        name: uniqueName('Banana'),
        category: FoodCategory.fruits,
        servingSizeBaseGrams: 100,
        caloriesBase: 90,
        proteinBase: 1,
        carbsBase: 23,
        fatBase: 0,
        portions: const [
          FoodPortionInput(portionName: 'Medium', gramWeight: 120),
        ],
      ),
    )).value;

    final recipe = (await recipeRepo.createRecipe(
      RecipeInput(
        name: uniqueName('Smoothie'),
        servingsYield: 1,
        items: [
          RecipeItemInput(
            foodId: food.id,
            portionId: food.portions.single.id,
            amount: 1,
          ),
        ],
      ),
    )).value;

    final failedUpdate = await recipeRepo.updateRecipe(
      recipe.id,
      RecipeInput(
        name: uniqueName('Broken Smoothie'),
        servingsYield: 1,
        items: [RecipeItemInput(foodId: food.id + 999999, amount: 100)],
      ),
    );
    expect(failedUpdate.isErr(), isTrue);
    expect(failedUpdate.error.type, SingleErrorTypes.notFound);

    final db = await testDatabase.db;
    final remainingItems = await db.query(
      RecipeItem.table,
      where: '${RecipeItemColumns.recipeId.value} = ?',
      whereArgs: [recipe.id],
    );
    expect(remainingItems, hasLength(1));

    await db.execute("""
      CREATE TEMP TRIGGER fail_recipe_item
      BEFORE INSERT ON ${RecipeItem.table}
      BEGIN SELECT RAISE(ABORT, 'forced test failure'); END
    """);
    addTearDown(() => db.execute('DROP TRIGGER fail_recipe_item'));

    final failedInsert = await recipeRepo.updateRecipe(
      recipe.id,
      RecipeInput(
        name: uniqueName('Replacement Smoothie'),
        servingsYield: 1,
        items: [RecipeItemInput(foodId: food.id, amount: 100)],
      ),
    );
    expect(failedInsert.error.type, SingleErrorTypes.operationFailure);
    final afterFailure = (await recipeRepo.getRecipe(recipe.id)).value;
    expect(afterFailure.name, recipe.name);
    expect(afterFailure.items, recipe.items);

    final toggledOn = await recipeRepo.toggleFavorite(recipe.id);
    expect(toggledOn.isOk(), isTrue);
    expect(toggledOn.value.isFavorite, isTrue);
    expect(toggledOn.value.items, hasLength(1));
    expect(toggledOn.value.items.single.portionName, 'Medium');
  });

  test('MacroTrackingRepository logs portion names, batches range queries, and keeps updated active goal active', () async {
    final foodRepo = FoodRepository.create();
    final macroRepo = MacroTrackingRepository.create();

    final food = (await foodRepo.createFood(
      FoodInput(
        name: uniqueName('Rice'),
        category: FoodCategory.grainsAndCereals,
        servingSizeBaseGrams: 100,
        caloriesBase: 200,
        proteinBase: 4,
        carbsBase: 44,
        fatBase: 1,
        portions: const [FoodPortionInput(portionName: 'Cup', gramWeight: 150)],
      ),
    )).value;

    final dayOne = DateTime(2026, 9, 10, 8, 30);
    final dayTwo = DateTime(2026, 9, 11, 13, 0);

    final createdEmptyDay = await macroRepo.getDailyLogByDate(dayOne);
    expect(createdEmptyDay.isOk(), isTrue);
    expect(createdEmptyDay.value.meals, isEmpty);

    final loggedWithPortion = await macroRepo.logFoodItem(
      logTime: dayOne,
      mealType: MealType.breakfast,
      foodId: food.id,
      portionId: food.portions.single.id,
      amount: 2, // 2 * 150g = 300g => 3x base (600 kcal, 12P, 132C, 3F)
    );
    expect(loggedWithPortion.isOk(), isTrue);
    expect(loggedWithPortion.value.totalCalories, 600);
    expect(loggedWithPortion.value.totalProtein, 12);
    expect(loggedWithPortion.value.totalCarbs, 132);
    expect(loggedWithPortion.value.totalFat, 3);
    expect(loggedWithPortion.value.items.single.portionName, 'Cup');

    final loggedGrams = await macroRepo.logFoodItem(
      logTime: dayTwo,
      mealType: MealType.lunch,
      foodId: food.id,
      amount: 50,
    );
    expect(loggedGrams.isOk(), isTrue);
    expect(loggedGrams.value.items.single.portionName, isNull);

    final fetchedDayOne = await macroRepo.getDailyLogByDate(dayOne);
    expect(fetchedDayOne.isOk(), isTrue);
    expect(fetchedDayOne.value.id, createdEmptyDay.value.id);
    expect(fetchedDayOne.value.meals.single.items.single.portionName, 'Cup');

    final range = await macroRepo.getDailyLogsForRange(
      start: dayOne,
      end: dayTwo,
    );
    expect(range.isOk(), isTrue);
    expect(range.value, hasLength(2));
    expect(range.value.first.totalCalories, 600);
    expect(range.value.last.totalCalories, 100);

    final goalA = (await macroRepo.createMacroGoal(
      const WeekMacroGoalInput(
        name: 'Goal A',
        targetCalories: 2000,
        targetProtein: 150,
        targetCarbs: 200,
        targetFat: 60,
        phase: WeightGoalPhase.maintain,
        isActive: true,
      ),
    )).value;
    final goalB = (await macroRepo.createMacroGoal(
      const WeekMacroGoalInput(
        name: 'Goal B',
        targetCalories: 2300,
        targetProtein: 160,
        targetCarbs: 250,
        targetFat: 70,
        phase: WeightGoalPhase.bulk,
        isActive: true,
      ),
    )).value;

    final db = await testDatabase.db;
    await db.update(
      WeekMacroGoal.table,
      {WeekMacroGoalColumns.updatedAt.value: 1000},
      where: '${WeekMacroGoalColumns.id.value} = ?',
      whereArgs: [goalB.id],
    );
    await db.update(
      DayMacroGoal.table,
      {DayMacroGoalColumns.updatedAt.value: 1000},
      where: '${DayMacroGoalColumns.weekMacroGoalId.value} = ?',
      whereArgs: [goalB.id],
    );

    final reactivatedA = await macroRepo.updateMacroGoal(
      goalA.id,
      const WeekMacroGoalInput(
        name: 'Goal A Updated',
        targetCalories: 2100,
        targetProtein: 155,
        targetCarbs: 210,
        targetFat: 65,
        phase: WeightGoalPhase.maintain,
        isActive: true,
      ),
    );
    expect(reactivatedA.isOk(), isTrue);
    expect(reactivatedA.value.isActive, isTrue);
    expect(reactivatedA.value.days.every((d) => d.isActive), isTrue);

    final goalBRow = (await db.query(
      WeekMacroGoal.table,
      where: '${WeekMacroGoalColumns.id.value} = ?',
      whereArgs: [goalB.id],
    )).single;
    expect(goalBRow[WeekMacroGoalColumns.isActive.value], 0);
    expect(
      goalBRow[WeekMacroGoalColumns.updatedAt.value] as int,
      greaterThan(1000),
    );

    final goalBDayRows = await db.query(
      DayMacroGoal.table,
      where: '${DayMacroGoalColumns.weekMacroGoalId.value} = ?',
      whereArgs: [goalB.id],
    );
    expect(
      goalBDayRows.every(
        (row) =>
            row[DayMacroGoalColumns.isActive.value] == 0 &&
            (row[DayMacroGoalColumns.updatedAt.value] as int) > 1000,
      ),
      isTrue,
    );
  });

  group('Macro goal transaction rollback', () {
    final repo = MacroTrackingRepository.create();

    WeekMacroGoalInput goal(String name, {bool active = true}) {
      return WeekMacroGoalInput(
        name: uniqueName(name),
        targetCalories: 2000,
        targetProtein: 150,
        targetCarbs: 200,
        targetFat: 60,
        phase: WeightGoalPhase.maintain,
        isActive: active,
      );
    }

    test(
      'failed daily deactivation preserves the active weekly goal',
      () async {
        final existing = (await repo.createMacroGoal(goal('Active'))).value;
        final db = await testDatabase.db;
        await db.execute("""
        CREATE TEMP TRIGGER reject_macro_goal_deactivation
        BEFORE UPDATE OF ${DayMacroGoalColumns.isActive.value} ON ${DayMacroGoal.table}
        WHEN NEW.${DayMacroGoalColumns.isActive.value} = 0
        BEGIN SELECT RAISE(ABORT, 'forced test failure'); END
      """);
        addTearDown(
          () => db.execute('DROP TRIGGER reject_macro_goal_deactivation'),
        );

        final failed = await repo.createMacroGoal(goal('Replacement'));

        expect(failed.error.type, SingleErrorTypes.operationFailure);
        final active = (await repo.getActiveMacroGoal()).value;
        expect(active.id, existing.id);
        expect(active.days, existing.days);
      },
    );

    test(
      'a skipped daily insert rolls back the goal update and activation',
      () async {
        final existing = (await repo.createMacroGoal(goal('Active'))).value;
        final original = (await repo.createMacroGoal(
          goal('Inactive', active: false),
        )).value;
        final db = await testDatabase.db;
        final originalDays = await db.query(
          DayMacroGoal.table,
          where: DayMacroGoalColumns.weekMacroGoalId.equal,
          whereArgs: [original.id],
        );
        await db.execute("""
        CREATE TEMP TRIGGER skip_macro_goal_day_insert
        BEFORE INSERT ON ${DayMacroGoal.table}
        BEGIN SELECT RAISE(IGNORE); END
      """);
        addTearDown(
          () => db.execute('DROP TRIGGER skip_macro_goal_day_insert'),
        );

        final failed = await repo.updateMacroGoal(original.id, goal('Edited'));

        expect(failed.error.type, SingleErrorTypes.operationFailure);
        final active = (await repo.getActiveMacroGoal()).value;
        expect(active.id, existing.id);
        expect(active.days, existing.days);
        final unchanged = (await db.query(
          WeekMacroGoal.table,
          where: WeekMacroGoalColumns.id.equal,
          whereArgs: [original.id],
        )).single;
        expect(unchanged[WeekMacroGoalColumns.name.value], original.name);
        expect(unchanged[WeekMacroGoalColumns.isActive.value], 0);
        expect(
          await db.query(
            DayMacroGoal.table,
            where: DayMacroGoalColumns.weekMacroGoalId.equal,
            whereArgs: [original.id],
          ),
          originalDays,
        );
      },
    );
  });

  test('WeightRecordRepository updates status, completedAt, and updatedAt when replacing active goal', () async {
    final weightRepo = WeightRecordRepository.create();
    final db = await testDatabase.db;

    final firstGoal = (await weightRepo.createWeightGoal(
      WeightGoalInput(
        targetWeight: 72000,
        startDate: DateTime(2026, 8, 1),
        phase: WeightGoalPhase.cut,
      ),
    )).value;

    await db.update(
      WeightGoal.table,
      {WeightGoalColumns.updatedAt.value: 1000},
      where: '${WeightGoalColumns.id.value} = ?',
      whereArgs: [firstGoal.id],
    );

    final secondGoal = await weightRepo.createWeightGoal(
      WeightGoalInput(
        targetWeight: 76000,
        startDate: DateTime(2026, 8, 15),
        phase: WeightGoalPhase.bulk,
      ),
    );
    expect(secondGoal.isOk(), isTrue);

    final firstGoalRow = (await db.query(
      WeightGoal.table,
      where: '${WeightGoalColumns.id.value} = ?',
      whereArgs: [firstGoal.id],
    )).single;
    expect(
      firstGoalRow[WeightGoalColumns.status.value],
      ProgressStatus.abandoned.value,
    );
    expect(firstGoalRow[WeightGoalColumns.completedAt.value], isNotNull);
    expect(
      firstGoalRow[WeightGoalColumns.updatedAt.value] as int,
      greaterThan(1000),
    );
  });
}
