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

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

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
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/ui/core/view_models/favorite_request_serializer.dart';
import 'package:myfitnesstale/src/ui/foods/view_models/food_cubit.dart';
import 'package:myfitnesstale/src/ui/meal_plans/view_models/meal_plan_cubit.dart';
import 'package:myfitnesstale/src/ui/recipes/view_models/recipe_cubit.dart';

import '../../support/test_database.dart';

class _SerializerTestCubit extends Cubit<int> with FavoriteRequestSerializer {
  final List<String> events = [];

  _SerializerTestCubit() : super(0);

  Future<int> toggleWithGate(String label, Completer<void> gate) {
    return serializeFavorite(() async {
      events.add('start:$label');
      await gate.future;
      if (isClosed) return state;
      emit(state + 1);
      events.add('end:$label');
      return state;
    });
  }

  Future<bool> failingOp(String label) {
    return serializeFavorite(() async {
      events.add('fail:$label');
      throw StateError('boom');
    });
  }
}

void main() {
  final database = TestDatabase();

  group('FavoriteRequestSerializer', () {
    test('executes concurrent async favorite requests strictly sequentially in FIFO order', () async {
      final cubit = _SerializerTestCubit();
      addTearDown(cubit.close);

      final firstGate = Completer<void>();
      final secondGate = Completer<void>();
      secondGate.complete();

      final firstFuture = cubit.toggleWithGate('first', firstGate);
      final secondFuture = cubit.toggleWithGate('second', secondGate);
      await pumpEventQueue();

      expect(cubit.events, equals(['start:first']));
      expect(cubit.state, 0);

      firstGate.complete();
      expect(await firstFuture, 1);
      expect(await secondFuture, 2);
      expect(
        cubit.events,
        equals(['start:first', 'end:first', 'start:second', 'end:second']),
      );
    });

    test(
      'continues processing subsequent queued requests after an error',
      () async {
        final cubit = _SerializerTestCubit();
        addTearDown(cubit.close);

        final secondGate = Completer<void>()..complete();
        await expectLater(cubit.failingOp('err'), throwsStateError);

        final result = await cubit.toggleWithGate('recovered', secondGate);
        expect(result, 1);
        expect(
          cubit.events,
          equals(['fail:err', 'start:recovered', 'end:recovered']),
        );
      },
    );
  });

  group('SQLite-backed Cubit favorite concurrency', () {
    setUp(database.initialize);
    tearDown(database.destroy);

    test('RecipeCubit.toggleFavorite serializes concurrent toggles and stays synced', () async {
      final foodRepo = FoodRepository.create();
      final recipeRepo = RecipeRepository.create();
      final food = (await foodRepo.createFood(
        const FoodInput(
          name: 'Banana',
          category: FoodCategory.fruits,
          servingSizeBaseGrams: 100,
          caloriesBase: 89,
          proteinBase: 1,
          carbsBase: 23,
          fatBase: 0,
          portions: [FoodPortionInput(portionName: 'Medium', gramWeight: 118)],
        ),
      )).value;
      final recipe = (await recipeRepo.createRecipe(
        RecipeInput(
          name: 'Smoothie',
          servingsYield: 1,
          items: [
            RecipeItemInput(
              foodId: food.id,
              portionId: food.portions.first.id,
              amount: 1,
            ),
          ],
        ),
      )).value;

      final cubit = RecipeCubit(recipeRepository: recipeRepo);
      addTearDown(cubit.close);
      await cubit.getRecipe(recipe.id);
      await cubit.getRecipes();

      final twoResults = await Future.wait([
        cubit.toggleFavorite(recipe.id),
        cubit.toggleFavorite(recipe.id),
      ]);
      expect(twoResults, equals([true, true]));
      expect(cubit.state.selectedRecipe?.isFavorite, isFalse);
      expect(
        cubit.state.recipes.firstWhere((r) => r.id == recipe.id).isFavorite,
        isFalse,
      );
      expect((await recipeRepo.getRecipe(recipe.id)).value.isFavorite, isFalse);

      final threeResults = await Future.wait([
        cubit.toggleFavorite(recipe.id),
        cubit.toggleFavorite(recipe.id),
        cubit.toggleFavorite(recipe.id),
      ]);
      expect(threeResults, equals([true, true, true]));
      expect(cubit.state.selectedRecipe?.isFavorite, isTrue);
      expect(
        cubit.state.recipes.firstWhere((r) => r.id == recipe.id).isFavorite,
        isTrue,
      );
      expect((await recipeRepo.getRecipe(recipe.id)).value.isFavorite, isTrue);
    });

    test('FoodCubit.toggleFavorite serializes concurrent toggles and closes safely', () async {
      final foodRepo = FoodRepository.create();
      final food = (await foodRepo.createFood(
        const FoodInput(
          name: 'Almonds',
          category: FoodCategory.nutsAndSeeds,
          servingSizeBaseGrams: 100,
          caloriesBase: 579,
          proteinBase: 21,
          carbsBase: 22,
          fatBase: 50,
          portions: [],
        ),
      )).value;

      final cubit = FoodCubit(foodRepository: foodRepo);
      await cubit.getFood(food.id);
      await cubit.getFoods();

      final results = await Future.wait([
        cubit.toggleFavorite(food.id),
        cubit.toggleFavorite(food.id),
        cubit.toggleFavorite(food.id),
      ]);
      expect(results, equals([true, true, true]));
      expect(cubit.state.selectedFood?.isFavorite, isTrue);
      expect((await foodRepo.getFood(food.id)).value.isFavorite, isTrue);

      final pendingBeforeClose = cubit.toggleFavorite(food.id);
      await cubit.close();
      expect(await pendingBeforeClose, isA<bool>());
    });

    test('MealPlanCubit.toggleFavorite serializes concurrent toggles and preserves selected details', () async {
      final foodRepo = FoodRepository.create();
      final mealPlanRepo = MealPlanRepository.create();
      final food = (await foodRepo.createFood(
        const FoodInput(
          name: 'Rice',
          category: FoodCategory.grainsAndCereals,
          servingSizeBaseGrams: 100,
          caloriesBase: 130,
          proteinBase: 3,
          carbsBase: 28,
          fatBase: 0,
          portions: [],
        ),
      )).value;
      final plan = (await mealPlanRepo.createMealPlan(
        MealPlanInput(
          name: 'Bulk Plan',
          weeks: [
            MealPlanWeekInput(
              weekNumber: 1,
              phase: MealPlanPhase.bulk,
              days: [
                MealPlanDayInput(
                  day: 1,
                  meals: [
                    MealPlanMealInput(
                      position: 0,
                      mealType: MealType.dinner,
                      name: 'Dinner',
                      items: [
                        MealPlanMealItemInput(foodId: food.id, amount: 200),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      )).value;

      final cubit = MealPlanCubit(mealPlanRepository: mealPlanRepo);
      addTearDown(cubit.close);
      await cubit.getMealPlan(plan.id);
      await cubit.getMealPlans();

      final twoResults = await Future.wait([
        cubit.toggleFavorite(plan.id),
        cubit.toggleFavorite(plan.id),
      ]);
      expect(twoResults, equals([true, true]));
      expect(cubit.state.selectedMealPlan?.isFavorite, isFalse);
      expect(cubit.state.selectedMealPlan?.weeks, hasLength(1));
      expect(
        cubit.state.mealPlans.firstWhere((p) => p.id == plan.id).isFavorite,
        isFalse,
      );
    });
  });
}
