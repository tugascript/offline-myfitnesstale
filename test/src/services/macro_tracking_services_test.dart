import 'package:myfitnesstale/src/services/inputs/macro_goal_input.dart';
import 'package:myfitnesstale/src/services/inputs/food_input.dart';
import 'package:myfitnesstale/src/common/nullable.dart';
import 'package:myfitnesstale/src/services/inputs/meal_plan_input.dart';
import 'package:myfitnesstale/src/services/inputs/recipe_input.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/models/food_model.dart';
import 'package:myfitnesstale/src/models/food_portion_model.dart';
import 'package:myfitnesstale/src/models/macro_goal_model.dart';
import 'package:myfitnesstale/src/models/meal_plan_record_model.dart';
import 'package:myfitnesstale/src/services/common/errors.dart';
import 'package:myfitnesstale/src/services/food_service.dart';
import 'package:myfitnesstale/src/services/macro_tracking_service.dart';
import 'package:myfitnesstale/src/services/meal_plan_record_service.dart';
import 'package:myfitnesstale/src/services/meal_plan_service.dart';
import 'package:myfitnesstale/src/services/recipe_service.dart';

import '../../support/test_database.dart';

void main() {
  final testDatabase = TestDatabase();
  final foodService = FoodService();
  final recipeService = RecipeService();
  final macroTrackingService = MacroTrackingService();
  final mealPlanService = MealPlanService();
  final mealPlanRecordService = MealPlanRecordService();

  setUpAll(() async {
    await testDatabase.initialize();
  });

  tearDownAll(() async {
    await testDatabase.destroy();
  });

  group('FoodService', () {
    test(
        'food create, search, and delete, including rejection of CreatedBy.system',
        () async {
      // 1. Create food with portion
      final createResult = await foodService.createFood(FoodInput(
        name: 'Greek Yogurt 0%',
        category: FoodCategory.dairyAndEggs,
        caloriesBase: 59,
        proteinBase: 10,
        carbsBase: 4,
        fatBase: 0,
        portions: const [
          FoodPortionInput(portionName: '1 cup (170g)', gramWeight: 170),
        ],
        servingSizeBaseGrams: 100,
      ));
      expect(createResult.isOk(), isTrue);
      final foodDto = createResult.value;
      expect(foodDto.name, 'Greek Yogurt 0%');
      expect(foodDto.portions.length, 1);
      expect(foodDto.portions.first.gramWeight, 170);

      // 2. Search food
      final searchResult = await foodService.getFoods(name: 'Greek Yogurt');
      expect(searchResult.isOk(), isTrue);
      expect(searchResult.value.data.any((f) => f.id == foodDto.id), isTrue);

      // 3. System food rejection
      final db = await testDatabase.db;
      final systemFood = Food.create(
        name: 'System Apple',
        servingSizeBaseGrams: 100,
        category: FoodCategory.fruits,
        caloriesBase: 52,
        proteinBase: 0,
        carbsBase: 14,
        fatBase: 0,
        createdBy: CreatedBy.system,
      );
      final systemFoodId = await db.insert(Food.table, systemFood.toMap());

      // Try update system food
      final updateSysResult = await foodService.updateFood(
          systemFoodId,
          FoodInput(
            name: 'Hacked Apple',
            category: FoodCategory.fruits,
            caloriesBase: 52,
            proteinBase: 0,
            carbsBase: 14,
            fatBase: 0,
            servingSizeBaseGrams: 100,
            portions: const [],
          ));
      expect(updateSysResult.isErr(), isTrue);
      expect(updateSysResult.error.type, SingleErrorTypes.invalidInput);

      // Try delete system food
      final deleteSysResult = await foodService.deleteFood(systemFoodId);
      expect(deleteSysResult.isErr(), isTrue);
      expect(deleteSysResult.error.type, SingleErrorTypes.invalidInput);

      // 4. Delete user food succeeds
      final deleteResult = await foodService.deleteFood(foodDto.id);
      expect(deleteResult.isOk(), isTrue);

      // Verify cascading delete of portions
      final portions = await db.query(
        FoodPortion.table,
        where: '${FoodPortionColumns.foodId.value} = ?',
        whereArgs: [foodDto.id],
      );
      expect(portions, isEmpty);
    });
  });

  group('RecipeService', () {
    test('recipe create with items and recomputed serving macros', () async {
      // Create ingredients
      final food1Result = await foodService.createFood(FoodInput(
        name: 'Rolled Oats',
        category: FoodCategory.grainsAndCereals,
        servingSizeBaseGrams: 100,
        caloriesBase: 380,
        proteinBase: 13,
        carbsBase: 68,
        fatBase: 7,
        portions: const [],
      ));
      expect(food1Result.isOk(), isTrue);
      final oats = food1Result.value;

      final food2Result = await foodService.createFood(FoodInput(
        name: 'Whey Protein Powder',
        category: FoodCategory.supplements,
        servingSizeBaseGrams: 100,
        caloriesBase: 400,
        proteinBase: 80,
        carbsBase: 5,
        fatBase: 3,
        portions: const [],
      ));
      expect(food2Result.isOk(), isTrue);
      final whey = food2Result.value;

      // Recipe: 2 servings
      // Oats: 100g (380 cals, 13g P, 68g C, 7g F)
      // Whey: 50g (200 cals, 40g P, 2.5g -> 3g C, 1.5g -> 2g F)
      // Total cals: 580 -> per serving (yield=2): 290 cals
      // Total protein: 53 -> per serving: 27g
      // Total carbs: 71 -> per serving: 36g
      // Total fat: 9 -> per serving: 5g
      final recipeResult = await recipeService.createRecipe(RecipeInput(
        name: 'Proats',
        servingsYield: 2,
        items: [
          RecipeItemInput(foodId: oats.id, amount: 100),
          RecipeItemInput(foodId: whey.id, amount: 50),
        ],
      ));
      expect(recipeResult.isOk(), isTrue);
      final recipe = recipeResult.value;

      expect(recipe.name, 'Proats');
      expect(recipe.servingsYield, 2);
      expect(recipe.servingCalories, 290);
      expect(recipe.servingProtein, 27);
      expect(recipe.servingCarbs, 36);
      expect(recipe.servingFat, 5);
      expect(recipe.items.length, 2);
    });
  });

  group('MacroTrackingService', () {
    test(
        'one active macro goal, and a meal log that get-or-creates the daily log and rolls totals up',
        () async {
      // 1. Create first goal (active)
      final goal1 = await macroTrackingService.createMacroGoal(MacroGoalInput(
        name: 'Bulk Goal',
        targetCalories: 3000,
        targetProtein: 200,
        targetCarbs: 350,
        targetFat: 80,
        phase: WeightGoalPhase.bulk,
        isActive: true,
      ));
      expect(goal1.isOk(), isTrue);
      expect(goal1.value.isActive, isTrue);

      // Create second goal (active) -> clears first goal
      final goal2 = await macroTrackingService.createMacroGoal(MacroGoalInput(
        name: 'Cut Goal',
        targetCalories: 2000,
        targetProtein: 180,
        targetCarbs: 180,
        targetFat: 50,
        phase: WeightGoalPhase.cut,
        isActive: true,
      ));
      expect(goal2.isOk(), isTrue);
      expect(goal2.value.isActive, isTrue);

      // Verify only goal2 is active
      final activeGoal = await macroTrackingService.getActiveMacroGoal();
      expect(activeGoal.isOk(), isTrue);
      expect(activeGoal.value.id, goal2.value.id);

      final db = await testDatabase.db;
      final g1Rows = await db.query(
        MacroGoal.table,
        where: '${MacroGoalColumns.id.value} = ?',
        whereArgs: [goal1.value.id],
      );
      expect(g1Rows.first[MacroGoalColumns.isActive.value], 0);

      // 2. Log food item for a specific date
      final date = DateTime(2026, 10, 12, 12, 30);
      final foodResult = await foodService.createFood(FoodInput(
        name: 'Chicken Breast Raw',
        category: FoodCategory.meatAndPoultry,
        caloriesBase: 165,
        proteinBase: 31,
        carbsBase: 0,
        fatBase: 4,
        servingSizeBaseGrams: 100,
        portions: const [],
      ));
      final chicken = foodResult.value;

      final mealResult = await macroTrackingService.logFoodItem(
        logTime: date,
        mealType: MealType.lunch,
        foodId: chicken.id,
        amount: 200, // 200g: 330 cals, 62g protein, 0g carbs, 8g fat
      );
      expect(mealResult.isOk(), isTrue);
      final mealLog = mealResult.value;
      expect(mealLog.totalCalories, 330);
      expect(mealLog.totalProtein, 62);
      expect(mealLog.totalFat, 8);

      // Daily log was created and rolled up
      final dailyLogResult = await macroTrackingService.getDailyLogByDate(date);
      expect(dailyLogResult.isOk(), isTrue);
      final dailyLog = dailyLogResult.value;
      expect(dailyLog.date, 20261012);
      expect(dailyLog.totalCalories, 330);
      expect(dailyLog.totalProtein, 62);
      expect(dailyLog.meals.length, 1);
    });
  });

  group('MealPlanService', () {
    test('meal-plan save of a week with a day, meal, and item', () async {
      final eggResult = await foodService.createFood(FoodInput(
        name: 'Whole Egg',
        category: FoodCategory.dairyAndEggs,
        caloriesBase: 143,
        proteinBase: 13,
        carbsBase: 1,
        fatBase: 10,
        servingSizeBaseGrams: 100,
        portions: const [],
      ));
      final egg = eggResult.value;

      final planResult = await mealPlanService.createMealPlan(MealPlanInput(
        name: 'Simple 1-Week Cut',
        description: Nullable('Single week test plan'),
        weeks: [
          MealPlanWeekInput(
            weekNumber: 1,
            phase: MealPlanPhase.cut,
            days: [
              MealPlanDayInput(
                day: 1,
                name: 'Monday',
                meals: [
                  MealPlanMealInput(
                    position: 1,
                    timeOfDay: '08:00',
                    mealType: MealType.breakfast,
                    name: 'Morning Eggs',
                    items: [
                      MealPlanMealItemInput(foodId: egg.id, amount: 150),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ));
      expect(planResult.isOk(), isTrue);
      final plan = planResult.value;
      expect(plan.name, 'Simple 1-Week Cut');
      expect(plan.totalWeeks, 1);
      expect(plan.totalDays, 1);
      expect(plan.totalMeals, 1);

      // Load with full tree
      final fetchedResult = await mealPlanService.getMealPlan(plan.id);
      expect(fetchedResult.isOk(), isTrue);
      final fetched = fetchedResult.value;
      expect(fetched.weeks.length, 1);
      expect(fetched.weeks.first.days.length, 1);
      expect(fetched.weeks.first.days.first.meals.length, 1);
      expect(fetched.weeks.first.days.first.meals.first.items.length, 1);
      expect(
        fetched.weeks.first.days.first.meals.first.items.first.totalCalories,
        (143 * 1.5).round(),
      );
    });
  });

  group('MealPlanRecordService', () {
    test('starting a second meal plan abandons the previous in-progress record',
        () async {
      final eggResult = await foodService.createFood(FoodInput(
        name: 'Egg White',
        category: FoodCategory.dairyAndEggs,
        caloriesBase: 52,
        proteinBase: 11,
        carbsBase: 1,
        fatBase: 0,
        servingSizeBaseGrams: 100,
        portions: const [],
      ));
      final egg = eggResult.value;

      final plan1Result = await mealPlanService.createMealPlan(MealPlanInput(
        name: 'Plan 1',
        weeks: [
          MealPlanWeekInput(
            weekNumber: 1,
            phase: MealPlanPhase.cut,
            days: [
              MealPlanDayInput(
                day: 1,
                meals: [
                  MealPlanMealInput(
                    position: 1,
                    mealType: MealType.breakfast,
                    name: 'Meal',
                    items: [MealPlanMealItemInput(foodId: egg.id, amount: 100)],
                  ),
                ],
              ),
            ],
          ),
        ],
      ));
      final plan1 = plan1Result.value;

      final plan2Result = await mealPlanService.createMealPlan(MealPlanInput(
        name: 'Plan 2',
        weeks: [
          MealPlanWeekInput(
            weekNumber: 1,
            phase: MealPlanPhase.bulk,
            days: [
              MealPlanDayInput(
                day: 1,
                meals: [
                  MealPlanMealInput(
                    position: 1,
                    mealType: MealType.breakfast,
                    name: 'Meal',
                    items: [MealPlanMealItemInput(foodId: egg.id, amount: 100)],
                  ),
                ],
              ),
            ],
          ),
        ],
      ));
      final plan2 = plan2Result.value;

      // Start plan 1
      final start1 =
          await mealPlanRecordService.startMealPlan(mealPlanId: plan1.id);
      expect(start1.isOk(), isTrue);
      expect(start1.value.status, ProgressStatus.inProgress);
      final record1Id = start1.value.id;

      // Verify active
      final active1 = await mealPlanRecordService.getActiveMealPlanRecord();
      expect(active1.isOk(), isTrue);
      expect(active1.value.id, record1Id);

      // Start plan 2
      final start2 =
          await mealPlanRecordService.startMealPlan(mealPlanId: plan2.id);
      expect(start2.isOk(), isTrue);
      expect(start2.value.status, ProgressStatus.inProgress);
      final record2Id = start2.value.id;

      // Verify record 1 is abandoned and record 2 is in-progress
      final db = await testDatabase.db;
      final rec1Rows = await db.query(
        MealPlanRecord.table,
        where: '${MealPlanRecordColumns.id.value} = ?',
        whereArgs: [record1Id],
      );
      expect(rec1Rows.first[MealPlanRecordColumns.status.value],
          ProgressStatus.abandoned.value);

      final active2 = await mealPlanRecordService.getActiveMealPlanRecord();
      expect(active2.isOk(), isTrue);
      expect(active2.value.id, record2Id);
    });
  });
}
