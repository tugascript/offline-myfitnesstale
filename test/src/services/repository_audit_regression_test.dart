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
import 'package:myfitnesstale/src/data/models/sqlite/day_macro_goal_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/recipe_item_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/week_macro_goal_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/weight_goal_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_plan_day_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_plan_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_plan_week_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_record_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/workout_set_model.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/exercise_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/foods/food_repository.dart';
import 'package:myfitnesstale/src/data/repositories/foods/inputs/food_input.dart';
import 'package:myfitnesstale/src/data/repositories/foods/inputs/food_portion_input.dart';
import 'package:myfitnesstale/src/data/repositories/macros/inputs/week_macro_goal_input.dart';
import 'package:myfitnesstale/src/data/repositories/macros/macro_tracking_repository.dart';
import 'package:myfitnesstale/src/data/repositories/meal_plans/inputs/meal_plan_input.dart';
import 'package:myfitnesstale/src/data/repositories/meal_plans/inputs/meal_plan_week_input.dart';
import 'package:myfitnesstale/src/data/repositories/meal_plans/meal_plan_repository.dart';
import 'package:myfitnesstale/src/data/repositories/recipes/inputs/recipe_input.dart';
import 'package:myfitnesstale/src/data/repositories/recipes/inputs/recipe_item_input.dart';
import 'package:myfitnesstale/src/data/repositories/recipes/recipe_repository.dart';
import 'package:myfitnesstale/src/data/repositories/weight/inputs/weight_goal_input.dart';
import 'package:myfitnesstale/src/data/repositories/weight/weight_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_repository.dart';
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
      final v1Week2Miss = await recordRepo.updateWorkoutPlanWorkoutRecordStatus(
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
      final v2Week2Hit = await recordRepo.updateWorkoutPlanWorkoutRecordStatus(
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

      final completedV1 = await recordRepo.updateWorkoutPlanWorkoutRecordStatus(
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
    final saved = (await repo.batchCreateWorkoutRecord(
      WorkoutRecordBatchInput(
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
      ),
    )).value;

    final fetched = (await repo.getWorkoutRecord(saved.id)).value;
    expect(saved.version, 1);
    expect(fetched.version, 1);
    expect(saved.setRecords!.map((set) => set.setNumber), [1, 2]);
    expect(saved.setRecords, fetched.setRecords);
    expect(saved.setRecords!.map((set) => set.setExerciseRecords), [
      null,
      null,
    ]);
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
