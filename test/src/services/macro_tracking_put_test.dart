import 'package:flutter_test/flutter_test.dart';
import 'package:myfitnesstale/src/common/nullable.dart';
import 'package:myfitnesstale/src/models/common.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/models/exercise_model.dart';
import 'package:myfitnesstale/src/cubits/food_cubit.dart';
import 'package:myfitnesstale/src/cubits/meal_plan_cubit.dart';
import 'package:myfitnesstale/src/cubits/weight_record_cubit.dart';
import 'package:myfitnesstale/src/services/exercise_record_service.dart';
import 'package:myfitnesstale/src/services/inputs/strength_goal_input.dart';
import 'package:myfitnesstale/src/services/inputs/weight_goal_input.dart';
import 'package:myfitnesstale/src/services/inputs/weight_record_input.dart';
import 'package:myfitnesstale/src/services/common/errors.dart';
import 'package:myfitnesstale/src/services/food_service.dart';
import 'package:myfitnesstale/src/services/recipe_service.dart';
import 'package:myfitnesstale/src/services/meal_plan_service.dart';
import 'package:myfitnesstale/src/services/meal_plan_record_service.dart';
import 'package:myfitnesstale/src/services/macro_tracking_service.dart';
import 'package:myfitnesstale/src/services/weight_record_service.dart';
import 'package:myfitnesstale/src/services/inputs/food_input.dart';
import 'package:myfitnesstale/src/services/inputs/recipe_input.dart';
import 'package:myfitnesstale/src/services/inputs/meal_plan_input.dart';
import 'package:myfitnesstale/src/services/inputs/macro_goal_input.dart';

import '../../support/test_database.dart';

void main() {
  final database = TestDatabase();
  setUpAll(database.initialize);
  tearDownAll(database.destroy);

  const foodInput = FoodInput(
    name: 'Oats',
    category: FoodCategory.grainsAndCereals,
    servingSizeBaseGrams: 100,
    caloriesBase: 400,
    proteinBase: 10,
    carbsBase: 60,
    fatBase: 8,
    portions: [],
  );

  test(
    'food Cubit keeps paging and clears nullable category filters',
    () async {
      await FoodService().createFood(foodInput);
      await FoodService().createFood(foodInput);
      final cubit = FoodCubit();
      addTearDown(cubit.close);
      await cubit.getFoods(
        search: 'Oats',
        category: FoodCategory.grainsAndCereals,
        limit: 1,
      );
      expect(cubit.state.foods.length, 1);
      expect(cubit.state.foodPagination.limit, 1);
      await cubit.getFoods(
        search: 'Oats',
        category: FoodCategory.grainsAndCereals,
        limit: 1,
        offset: 1,
      );
      expect(cubit.state.foods.length, 2);
      expect(cubit.state.foodPagination.offset, 1);
      await cubit.getFoods(limit: 1);
      expect(cubit.state.foodPagination.category, isNull);
      expect(cubit.state.foodPagination.name, isEmpty);
      expect(cubit.state.foodPagination.offset, 0);
      expect(cubit.state.foods.length, 1);
    },
  );

  test('meal-plan Cubit preserves favorite filters after a PUT', () async {
    final service = MealPlanService();
    final plan = (await service.createMealPlan(
      const MealPlanInput(name: 'Favorite paging plan', weeks: []),
    )).value;
    await service.toggleFavorite(plan.id);
    final cubit = MealPlanCubit();
    addTearDown(cubit.close);
    await cubit.getMealPlans(isFavorite: true, limit: 1);
    expect(
      await cubit.updateMealPlan(
        plan.id,
        const MealPlanInput(name: 'Favorite renamed', weeks: []),
      ),
      isTrue,
    );
    expect(cubit.state.mealPlanPagination.isFavorite, isTrue);
    expect(cubit.state.mealPlanPagination.limit, 1);
    expect(cubit.state.mealPlans.every((p) => p.isFavorite), isTrue);
  });

  test(
    'strength-goal create and update share input and clear completion',
    () async {
      final db = await database.db;
      final exercise = Exercise.create(
        name: 'Bench press',
        muscleGroup: MuscleGroup.push,
        muscles: const TargetMuscles(primary: {}, secondary: {}),
      );
      final exerciseId = await db.insert(Exercise.table, exercise.toMap());
      final service = ExerciseRecordService();
      final created = await service.createStrengthGoal(
        StrengthGoalInput(
          exerciseId: exerciseId,
          name: 'Completed goal',
          targetReps: 5,
          targetWeight: 80000,
          targetMaxStrength: 90000,
          startDate: DateTime(2026, 10, 1),
          status: ProgressStatus.completed,
          completedAt: Nullable(DateTime(2026, 10, 2)),
        ),
      );
      expect(created.isOk(), isTrue);
      final other = await service.createStrengthGoal(
        StrengthGoalInput(
          exerciseId: exerciseId,
          name: 'Other active goal',
          targetReps: 5,
          targetWeight: 81000,
          targetMaxStrength: 94000,
          startDate: DateTime(2026, 10, 3),
        ),
      );
      expect(other.isOk(), isTrue);
      final updated = await service.updateStrengthGoal(
        created.value.id,
        StrengthGoalInput(
          exerciseId: exerciseId,
          name: 'Reopened',
          targetReps: 6,
          targetWeight: 82000,
          targetMaxStrength: 95000,
          startDate: DateTime(2026, 10, 3),
        ),
      );
      expect(updated.isOk(), isTrue);
      expect(updated.value.completedAt, isNull);
      expect(updated.value.targetWeight, 82000);
      expect(
        (await service.getStrengthGoal(other.value.id)).value.status,
        ProgressStatus.abandoned,
      );
      expect(
        (await service.getStrengthGoal(created.value.id)).value,
        updated.value,
      );
    },
  );

  test(
    'food PUT clears nullable fields and accepts immutable portions',
    () async {
      final service = FoodService();
      final created = await service.createFood(
        const FoodInput(
          name: 'Oats',
          category: FoodCategory.grainsAndCereals,
          brand: Nullable('Mill'),
          barcode: Nullable('123'),
          servingSizeBaseGrams: 100,
          caloriesBase: 400,
          proteinBase: 10,
          carbsBase: 60,
          fatBase: 8,
          sodiumBase: Nullable(5),
          portions: [
            FoodPortionInput(portionName: 'Z cup', gramWeight: 80),
            FoodPortionInput(portionName: 'A spoon', gramWeight: 10),
          ],
        ),
      );
      expect(created.isOk(), isTrue);
      const replacement = FoodInput(
        name: 'Oats edited',
        category: FoodCategory.grainsAndCereals,
        servingSizeBaseGrams: 50,
        caloriesBase: 200,
        proteinBase: 5,
        carbsBase: 30,
        fatBase: 4,
        portions: [
          FoodPortionInput(portionName: 'Z cup', gramWeight: 80),
          FoodPortionInput(portionName: 'A spoon', gramWeight: 10),
        ],
      );
      final updated = await service.updateFood(created.value.id, replacement);
      expect(updated.isOk(), isTrue);
      expect(updated.value.brand, isNull);
      expect(updated.value.barcode, isNull);
      expect(updated.value.sodiumBase, isNull);
      expect(updated.value.servingSizeBaseGrams, 50);
      expect(replacement.portions.first.portionName, 'Z cup');
      expect(
        updated.value.portions.map((p) => p.id).toSet(),
        created.value.portions.map((p) => p.id).toSet(),
      );
    },
  );

  test(
    'recipe PUT recalculates yield, clears fields, and rolls back failure',
    () async {
      final food = (await FoodService().createFood(
        const FoodInput(
          name: 'Fortified oats',
          category: FoodCategory.grainsAndCereals,
          servingSizeBaseGrams: 100,
          caloriesBase: 400,
          proteinBase: 10,
          carbsBase: 60,
          fatBase: 8,
          micros: Nullable(Micronutrients(potassiumMg: 100)),
          portions: [],
        ),
      )).value;
      final service = RecipeService();
      final created = await service.createRecipe(
        RecipeInput(
          name: 'Porridge',
          description: const Nullable('Original'),
          servingsYield: 1,
          items: [RecipeItemInput(foodId: food.id, amount: 100)],
        ),
      );
      final replaced = await service.updateRecipe(
        created.value.id,
        RecipeInput(
          name: 'Two servings',
          servingsYield: 2,
          items: [RecipeItemInput(foodId: food.id, amount: 100)],
        ),
      );
      expect(replaced.isOk(), isTrue);
      expect(replaced.value.description, isNull);
      expect(replaced.value.servingCalories, 200);
      final failure = await service.updateRecipe(
        created.value.id,
        const RecipeInput(
          name: 'Invalid',
          servingsYield: 1,
          items: [RecipeItemInput(foodId: -1, amount: 100)],
        ),
      );
      expect(failure.error.type, SingleErrorTypes.notFound);
      final afterFailure = (await service.getRecipe(created.value.id)).value;
      expect(afterFailure, replaced.value);
      final empty = await service.updateRecipe(
        created.value.id,
        const RecipeInput(name: 'Empty', servingsYield: 1, items: []),
      );
      expect(empty.value.servingCalories, 0);
      expect(empty.value.servingMicros, isNull);
      expect(empty.value.items, isEmpty);
    },
  );

  test(
    'meal-plan PUT keeps originating versions and rolls back invalid input',
    () async {
      final food = (await FoodService().createFood(foodInput)).value;
      List<MealPlanWeekInput> weeks(int foodId) => [
        MealPlanWeekInput(
          weekNumber: 1,
          phase: MealPlanPhase.maintain,
          days: [
            MealPlanDayInput(
              day: 1,
              meals: [
                MealPlanMealInput(
                  position: 1,
                  mealType: MealType.breakfast,
                  name: 'Breakfast',
                  items: [MealPlanMealItemInput(foodId: foodId, amount: 100)],
                ),
              ],
            ),
          ],
        ),
      ];
      final service = MealPlanService();
      final created = (await service.createMealPlan(
        MealPlanInput(
          name: 'Original',
          description: const Nullable('Original description'),
          weeks: weeks(food.id),
        ),
      )).value;
      final recordService = MealPlanRecordService();
      final started = await recordService.startMealPlan(mealPlanId: created.id);
      expect(started.isOk(), isTrue);
      final originalDayId = started.value.weeks.first.days.first.mealPlanDayId;
      final replaced = await service.updateMealPlan(
        created.id,
        MealPlanInput(name: 'Edited', weeks: weeks(food.id)),
      );
      expect(replaced.isOk(), isTrue);
      expect(replaced.value.version, created.version + 1);
      expect(replaced.value.description, isNull);
      final original = await service.getMealPlan(
        created.id,
        version: created.version,
      );
      expect(original.value.version, created.version);
      expect(original.value.weeks.first.days.first.id, originalDayId);
      final active = (await recordService.getActiveMealPlanRecord()).value;
      expect(active.mealPlanVersion, created.version);
      expect(active.weeks.first.days.first.mealPlanDayId, originalDayId);
      final invalid = await service.updateMealPlan(
        created.id,
        MealPlanInput(name: 'Invalid', weeks: weeks(-1)),
      );
      expect(invalid.error.type, SingleErrorTypes.notFound);
      expect((await service.getMealPlan(created.id)).value, replaced.value);
      expect(
        (await recordService.completeCurrentDay(recordId: active.id)).isOk(),
        isTrue,
      );
    },
  );

  test(
    'macro-goal PUT clears water and preserves a single active goal',
    () async {
      final service = MacroTrackingService();
      final first = (await service.createMacroGoal(
        const MacroGoalInput(
          name: 'First',
          targetCalories: 2000,
          targetProtein: 100,
          targetCarbs: 200,
          targetFat: 60,
          phase: WeightGoalPhase.maintain,
          targetWaterIntakeMl: Nullable(2500),
        ),
      )).value;
      final second = (await service.createMacroGoal(
        const MacroGoalInput(
          name: 'Second',
          targetCalories: 2200,
          targetProtein: 110,
          targetCarbs: 220,
          targetFat: 65,
          phase: WeightGoalPhase.bulk,
        ),
      )).value;
      final updated = await service.updateMacroGoal(
        first.id,
        const MacroGoalInput(
          name: 'First edited',
          targetCalories: 1800,
          targetProtein: 120,
          targetCarbs: 150,
          targetFat: 60,
          phase: WeightGoalPhase.cut,
        ),
      );
      expect(updated.value.targetWaterIntakeMl, isNull);
      expect((await service.getActiveMacroGoal()).value.id, first.id);
      final all = (await service.getMacroGoals()).value.data;
      expect(all.singleWhere((goal) => goal.id == second.id).isActive, isFalse);
    },
  );

  test(
    'weight-goal and weight-record PUT share inputs and clear nullable fields',
    () async {
      final service = WeightRecordService();
      final createdGoal = await service.createWeightGoal(
        WeightGoalInput(
          targetWeight: 75000,
          targetFatPercentage: const Nullable(1500),
          startDate: DateTime(2026, 10, 1),
          phase: WeightGoalPhase.cut,
          status: ProgressStatus.completed,
          completedAt: Nullable(DateTime(2026, 10, 2)),
        ),
      );
      expect(createdGoal.isOk(), isTrue);

      final activeGoal = await service.createWeightGoal(
        WeightGoalInput(
          targetWeight: 78000,
          startDate: DateTime(2026, 10, 3),
          phase: WeightGoalPhase.maintain,
        ),
      );
      expect(activeGoal.isOk(), isTrue);

      final updatedGoal = await service.updateWeightGoal(
        createdGoal.value.id,
        WeightGoalInput(
          targetWeight: 74000,
          startDate: DateTime(2026, 10, 4),
          phase: WeightGoalPhase.cut,
        ),
      );
      expect(updatedGoal.isOk(), isTrue);
      expect(updatedGoal.value.targetFatPercentage, isNull);
      expect(updatedGoal.value.completedAt, isNull);
      expect(updatedGoal.value.status, ProgressStatus.inProgress);
      expect(
        (await service.getWeightGoal(activeGoal.value.id)).value.status,
        ProgressStatus.abandoned,
      );

      final cubit = WeightRecordCubit();
      addTearDown(cubit.close);
      await cubit.createWeightRecord(
        WeightRecordInput(
          weight: 81000,
          recordDate: DateTime(2026, 10, 5),
          fatPercentage: const Nullable(1750),
          pictureUri: const Nullable('file:///weight.jpg'),
        ),
      );
      final createdRecord = cubit.state.selectedWeightRecord!;
      expect(createdRecord.fatPercentage, 1750);
      expect(createdRecord.pictureUri, 'file:///weight.jpg');

      await cubit.updateWeightRecord(
        createdRecord.id,
        WeightRecordInput(weight: 80500, recordDate: DateTime(2026, 10, 6)),
      );
      final updatedRecord = cubit.state.selectedWeightRecord!;
      expect(updatedRecord.weight, 80500);
      expect(updatedRecord.fatPercentage, isNull);
      expect(updatedRecord.pictureUri, isNull);
      expect(
        (await service.getWeightRecord(createdRecord.id)).value,
        updatedRecord,
      );
    },
  );
}
