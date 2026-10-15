import 'package:flutter_test/flutter_test.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/services/food_service.dart';
import 'package:myfitnesstale/src/services/inputs/food_input.dart';
import 'package:myfitnesstale/src/services/inputs/recipe_input.dart';
import 'package:myfitnesstale/src/services/macro_tracking_service.dart';
import 'package:myfitnesstale/src/services/recipe_service.dart';

import '../../support/test_database.dart';

void main() {
  final database = TestDatabase();
  setUpAll(database.initialize);
  tearDownAll(database.destroy);

  test(
    'timed submissions survive reload, roll up, and delete independently',
    () async {
      final service = MacroTrackingService();
      final food = (await FoodService().createFood(
        FoodInput(
          name: 'Timeline oats',
          category: FoodCategory.grainsAndCereals,
          caloriesBase: 100,
          proteinBase: 10,
          carbsBase: 20,
          fatBase: 2,
          servingSizeBaseGrams: 100,
          portions: const [],
        ),
      )).value;
      final recipe = (await RecipeService().createRecipe(
        RecipeInput(
          name: 'Timeline recipe',
          servingsYield: 1,
          items: [RecipeItemInput(foodId: food.id, amount: 100)],
        ),
      )).value;
      // Include identical timestamps, multiple entries within an hour, and midnight.
      final times = [
        DateTime(2025, 1, 10),
        DateTime(2025, 1, 10, 8, 5),
        DateTime(2025, 1, 10, 8, 5),
        DateTime(2025, 1, 10, 8, 45),
        DateTime(2025, 1, 10, 23, 59),
      ];
      for (final time in times) {
        final result = await service.logFoodItem(
          logTime: time,
          mealType: MealType.snack,
          foodId: food.id,
          amount: 100,
        );
        expect(result.isOk(), isTrue);
        expect(result.value.logTime, time);
      }
      final recipeLog = await service.logRecipe(
        logTime: DateTime(2025, 1, 10, 12, 30),
        mealType: MealType.snack,
        recipeId: recipe.id,
        servings: 2,
      );
      expect(recipeLog.isOk(), isTrue);
      final tomorrow = await service.logRecipe(
        logTime: DateTime(2025, 1, 11),
        mealType: MealType.snack,
        recipeId: recipe.id,
      );
      expect(tomorrow.isOk(), isTrue);

      var day = (await service.getDailyLogByDate(times.first)).value;
      expect(day.date, 20250110);
      expect(day.meals, hasLength(6));
      expect(day.meals.map((m) => m.id).toSet(), hasLength(6));
      expect(day.meals.map((m) => m.logTime), [
        ...times.take(4),
        DateTime(2025, 1, 10, 12, 30),
        times.last,
      ]);
      expect(day.totalCalories, 700);
      expect(day.totalProtein, 70);
      expect(day.totalCarbs, 140);
      expect(day.totalFat, 14);
      expect(day.meals.where((m) => m.logTime.hour == 8), hasLength(3));
      expect(
        (await service.getDailyLogByDate(DateTime(2025, 1, 11)))
            .value
            .totalCalories,
        100,
      );

      final item = day.meals[1].items.single;
      expect((await service.deleteMealLogItem(item.id)).isOk(), isTrue);
      day = (await service.getDailyLogByDate(times.first)).value;
      expect(day.meals.expand((m) => m.items), hasLength(5));
      expect(day.totalCalories, 600);
      expect(day.totalProtein, 60);
      expect(day.totalCarbs, 120);
      expect(day.totalFat, 12);
      expect(day.meals.first.logTime, times.first);
      expect(day.meals.last.logTime, times.last);
    },
  );
}
