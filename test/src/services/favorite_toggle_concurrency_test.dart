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

import 'package:myfitnesstale/src/data/repositories/exercises/exercise_repository.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/inputs/equipment_input.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/inputs/exercise_input.dart';
import 'package:myfitnesstale/src/data/repositories/foods/food_repository.dart';
import 'package:myfitnesstale/src/data/repositories/foods/inputs/food_input.dart';
import 'package:myfitnesstale/src/data/repositories/foods/inputs/food_portion_input.dart';
import 'package:myfitnesstale/src/data/repositories/meal_plans/inputs/meal_plan_day_input.dart';
import 'package:myfitnesstale/src/data/repositories/meal_plans/inputs/meal_plan_input.dart';
import 'package:myfitnesstale/src/data/repositories/meal_plans/inputs/meal_plan_meal_input.dart';
import 'package:myfitnesstale/src/data/repositories/meal_plans/inputs/meal_plan_meal_item_input.dart';
import 'package:myfitnesstale/src/data/repositories/meal_plans/inputs/meal_plan_week_input.dart';
import 'package:myfitnesstale/src/data/repositories/meal_plans/meal_plan_repository.dart';
import 'package:myfitnesstale/src/data/repositories/recipes/inputs/recipe_input.dart';
import 'package:myfitnesstale/src/data/repositories/recipes/inputs/recipe_item_input.dart';
import 'package:myfitnesstale/src/data/repositories/recipes/recipe_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/inputs/workout_plan_input.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/inputs/workout_input.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/workout_repository.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/utils/json_data.dart';

import '../../support/test_database.dart';

void main() {
  final database = TestDatabase();

  setUp(database.initialize);
  tearDown(database.destroy);

  group('Favorite toggle transaction concurrency regressions', () {
    test('RecipeRepository.toggleFavorite serializes concurrent toggles and preserves items', () async {
      final foodRepo = FoodRepository.create();
      final recipeRepo = RecipeRepository.create();

      final foodResult = await foodRepo.createFood(
        const FoodInput(
          name: 'Oats',
          category: FoodCategory.grainsAndCereals,
          servingSizeBaseGrams: 100,
          caloriesBase: 389,
          proteinBase: 17,
          carbsBase: 66,
          fatBase: 7,
          portions: [FoodPortionInput(portionName: 'Cup', gramWeight: 80)],
        ),
      );
      expect(foodResult.isOk(), isTrue);
      final food = foodResult.value;
      final portionId = food.portions.first.id;

      final recipeResult = await recipeRepo.createRecipe(
        RecipeInput(
          name: 'Overnight Oats',
          servingsYield: 1,
          items: [
            RecipeItemInput(foodId: food.id, portionId: portionId, amount: 1),
          ],
        ),
      );
      expect(recipeResult.isOk(), isTrue);
      final recipeId = recipeResult.value.id;

      final twoToggles = await Future.wait([
        recipeRepo.toggleFavorite(recipeId),
        recipeRepo.toggleFavorite(recipeId),
      ]);
      expect(twoToggles.every((r) => r.isOk()), isTrue);
      expect(
        twoToggles.map((r) => r.value.isFavorite).toSet(),
        equals({true, false}),
      );
      for (final result in twoToggles) {
        expect(result.value.items, hasLength(1));
        expect(result.value.items.first.foodName, equals('Oats'));
        expect(result.value.items.first.portionName, equals('Cup'));
      }

      final afterTwo = await recipeRepo.getRecipe(recipeId);
      expect(afterTwo.value.isFavorite, isFalse);

      final threeToggles = await Future.wait([
        recipeRepo.toggleFavorite(recipeId),
        recipeRepo.toggleFavorite(recipeId),
        recipeRepo.toggleFavorite(recipeId),
      ]);
      expect(threeToggles.every((r) => r.isOk()), isTrue);
      expect(threeToggles.where((r) => r.value.isFavorite).length, equals(2));
      expect(threeToggles.where((r) => !r.value.isFavorite).length, equals(1));

      final afterThree = await recipeRepo.getRecipe(recipeId);
      expect(afterThree.value.isFavorite, isTrue);
    });

    test('FoodRepository.toggleFavorite serializes concurrent toggles and loads portions atomically', () async {
      final foodRepo = FoodRepository.create();
      final created = await foodRepo.createFood(
        const FoodInput(
          name: 'Greek Yogurt',
          category: FoodCategory.dairyAndEggs,
          servingSizeBaseGrams: 100,
          caloriesBase: 59,
          proteinBase: 10,
          carbsBase: 4,
          fatBase: 0,
          portions: [FoodPortionInput(portionName: 'Bowl', gramWeight: 150)],
        ),
      );
      expect(created.isOk(), isTrue);
      final foodId = created.value.id;

      final twoToggles = await Future.wait([
        foodRepo.toggleFavorite(foodId),
        foodRepo.toggleFavorite(foodId),
      ]);
      expect(twoToggles.every((r) => r.isOk()), isTrue);
      expect(
        twoToggles.map((r) => r.value.isFavorite).toSet(),
        equals({true, false}),
      );
      for (final result in twoToggles) {
        expect(result.value.portions, hasLength(1));
        expect(result.value.portions.first.portionName, equals('Bowl'));
      }
      expect((await foodRepo.getFood(foodId)).value.isFavorite, isFalse);

      final threeToggles = await Future.wait([
        foodRepo.toggleFavorite(foodId),
        foodRepo.toggleFavorite(foodId),
        foodRepo.toggleFavorite(foodId),
      ]);
      expect(threeToggles.every((r) => r.isOk()), isTrue);
      expect((await foodRepo.getFood(foodId)).value.isFavorite, isTrue);
    });

    test(
      'MealPlanRepository.toggleFavorite serializes concurrent toggles',
      () async {
        final foodRepo = FoodRepository.create();
        final mealPlanRepo = MealPlanRepository.create();

        final food = (await foodRepo.createFood(
          const FoodInput(
            name: 'Chicken Breast',
            category: FoodCategory.meatAndPoultry,
            servingSizeBaseGrams: 100,
            caloriesBase: 165,
            proteinBase: 31,
            carbsBase: 0,
            fatBase: 4,
            portions: [],
          ),
        )).value;

        final created = await mealPlanRepo.createMealPlan(
          MealPlanInput(
            name: 'Lean Plan',
            weeks: [
              MealPlanWeekInput(
                weekNumber: 1,
                phase: MealPlanPhase.cut,
                days: [
                  MealPlanDayInput(
                    day: 1,
                    meals: [
                      MealPlanMealInput(
                        position: 0,
                        mealType: MealType.lunch,
                        name: 'Lunch',
                        items: [
                          MealPlanMealItemInput(foodId: food.id, amount: 150),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
        expect(created.isOk(), isTrue);
        final planId = created.value.id;

        final twoToggles = await Future.wait([
          mealPlanRepo.toggleFavorite(planId),
          mealPlanRepo.toggleFavorite(planId),
        ]);
        expect(twoToggles.every((r) => r.isOk()), isTrue);
        expect(
          twoToggles.map((r) => r.value.isFavorite).toSet(),
          equals({true, false}),
        );
        expect(
          (await mealPlanRepo.getMealPlan(planId)).value.isFavorite,
          isFalse,
        );

        final threeToggles = await Future.wait([
          mealPlanRepo.toggleFavorite(planId),
          mealPlanRepo.toggleFavorite(planId),
          mealPlanRepo.toggleFavorite(planId),
        ]);
        expect(threeToggles.every((r) => r.isOk()), isTrue);
        expect(
          (await mealPlanRepo.getMealPlan(planId)).value.isFavorite,
          isTrue,
        );
      },
    );

    test('ExerciseRepository.updateExerciseFavorite runs in transaction with joined equipment and preserves concurrent edits', () async {
      final repo = ExerciseRepository.create();
      final equipment = (await repo.createEquipment(
        const EquipmentInput(name: 'Kettlebell'),
      )).value;

      final created = await repo.createExercise(
        ExerciseInput(
          name: 'Goblet Squat',
          muscleGroup: MuscleGroup.legs,
          muscles: const TargetMuscles(primary: {Muscle.chest}, secondary: {}),
          equipmentIds: {equipment.id},
        ),
      );
      expect(created.isOk(), isTrue);
      final exerciseId = created.value.id;

      final results = await Future.wait([
        repo.updateExercise(
          exerciseId,
          ExerciseInput(
            name: 'Goblet Squat Updated',
            muscleGroup: MuscleGroup.legs,
            muscles: const TargetMuscles(
              primary: {Muscle.chest},
              secondary: {},
            ),
            equipmentIds: {equipment.id},
            isFavorite: true,
          ),
        ),
        repo.updateExerciseFavorite(exerciseId, true),
      ]);
      expect(results.every((r) => r.isOk()), isTrue);
      expect(results[1].value.equipments, hasLength(1));
      expect(results[1].value.equipments!.first.name, equals('Kettlebell'));

      final persisted = (await repo.getExercise(exerciseId)).value;
      expect(persisted.name, equals('Goblet Squat Updated'));
      expect(persisted.isFavorite, isTrue);
    });

    test('WorkoutRepository.updateWorkoutFavorite runs atomically and preserves concurrent edits', () async {
      final repo = WorkoutRepository.create();
      final created = await repo.createWorkout(
        const WorkoutInput(name: 'Upper A', difficulty: Difficulty.beginner),
      );
      expect(created.isOk(), isTrue);
      final workoutId = created.value.id;

      final results = await Future.wait([
        repo.updateWorkout(
          workoutId,
          const WorkoutInput(
            name: 'Upper A Updated',
            difficulty: Difficulty.intermediate,
            isFavorite: true,
          ),
        ),
        repo.updateWorkoutFavorite(workoutId, true),
      ]);
      expect(results.every((r) => r.isOk()), isTrue);

      final persisted = (await repo.getWorkout(workoutId)).value;
      expect(persisted.name, equals('Upper A Updated'));
      expect(persisted.isFavorite, isTrue);
    });

    test('WorkoutPlanRepository.updateWorkoutPlanFavorite runs atomically and preserves concurrent edits', () async {
      final repo = WorkoutPlanRepository.create();
      final created = await repo.createWorkoutPlan(
        const WorkoutPlanInput(
          name: 'Hypertrophy',
          difficulty: Difficulty.intermediate,
        ),
      );
      expect(created.isOk(), isTrue);
      final planId = created.value.id;

      final results = await Future.wait([
        repo.updateWorkoutPlan(
          planId,
          const WorkoutPlanInput(
            name: 'Hypertrophy Updated',
            difficulty: Difficulty.advanced,
            isFavorite: true,
          ),
        ),
        repo.updateWorkoutPlanFavorite(planId, true),
      ]);
      expect(results.every((r) => r.isOk()), isTrue);

      final persisted = (await repo.getWorkoutPlan(planId)).value;
      expect(persisted.name, equals('Hypertrophy Updated'));
      expect(persisted.isFavorite, isTrue);
    });
  });
}
