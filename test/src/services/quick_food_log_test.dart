import 'package:flutter_test/flutter_test.dart';
import 'package:myfitnesstale/src/cubits/macro_tracking_cubit.dart';
import 'package:myfitnesstale/src/services/common/errors.dart';
import 'package:myfitnesstale/src/services/inputs/quick_food_log_input.dart';
import 'package:myfitnesstale/src/services/macro_tracking_service.dart';

import '../../support/test_database.dart';

void main() {
  final database = TestDatabase();
  final service = MacroTrackingService();
  setUp(database.initialize);
  tearDown(database.destroy);

  const input = QuickFoodLogInput(
    name: '  Lunch out  ',
    calories: 525,
    protein: 30,
    carbs: 60,
    fat: 15,
  );

  test(
    'quick add persists snapshots, refreshes Cubit totals, and deletes',
    () async {
      final db = await database.db;
      final foodsBefore = await db.query('foods');
      final recipesBefore = await db.query('recipes');
      final cubit = MacroTrackingCubit();
      addTearDown(cubit.close);
      final time = DateTime(2025, 1, 10, 8, 30);
      await cubit.getDailyLog(time);
      expect(await cubit.logQuickFood(input, logTime: time), isTrue);
      expect(await cubit.logQuickFood(input, logTime: time), isTrue);
      var day = cubit.state.selectedDailyLog!;
      expect(day.date, 20250110);
      expect(day.totalCalories, 1050);
      expect(day.totalProtein, 60);
      expect(day.totalCarbs, 120);
      expect(day.totalFat, 30);
      expect(day.meals, hasLength(2));
      expect(day.meals.map((m) => m.logTime), [time, time]);
      final item = day.meals.first.items.single;
      expect(item.id, greaterThan(0));
      expect(item.loggedFoodName, 'Lunch out');
      expect(item.foodId, isNull);
      expect(item.portionId, isNull);
      expect(item.amount, 1);
      expect(day.meals.first.recipeId, isNull);
      expect(await db.query('foods'), foodsBefore);
      expect(await db.query('recipes'), recipesBefore);
      final stored = (await db.query('meal_logs')).first;
      expect(stored['log_time'], time.millisecondsSinceEpoch ~/ 1000);
      expect((await service.getDailyLogByDate(time)).value, day);

      expect(await cubit.deleteMealLogItem(item.id), isTrue);
      day = cubit.state.selectedDailyLog!;
      expect(day.meals.expand((m) => m.items), hasLength(1));
      expect(day.totalCalories, 525);
      expect(day.totalProtein, 30);
      expect(day.totalCarbs, 60);
      expect(day.totalFat, 15);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.error, isNull);
    },
  );

  test(
    'invalid quick entries return validation errors without writes',
    () async {
      final invalid = [
        const QuickFoodLogInput(
          name: ' ',
          calories: 1,
          protein: 1,
          carbs: 1,
          fat: 1,
        ),
        const QuickFoodLogInput(
          name: 'x',
          calories: -1,
          protein: 1,
          carbs: 1,
          fat: 1,
        ),
        const QuickFoodLogInput(
          name: 'x',
          calories: 1,
          protein: -1,
          carbs: 1,
          fat: 1,
        ),
        const QuickFoodLogInput(
          name: 'x',
          calories: 1,
          protein: 1,
          carbs: -1,
          fat: 1,
        ),
        const QuickFoodLogInput(
          name: 'x',
          calories: 1,
          protein: 1,
          carbs: 1,
          fat: -1,
        ),
      ];
      final cubit = MacroTrackingCubit();
      addTearDown(cubit.close);
      for (final entry in invalid) {
        final result = await service.logQuickFood(entry);
        expect(result.isErr(), isTrue);
        expect(result.error.type, SingleErrorTypes.invalidInput);
      }
      expect(await cubit.logQuickFood(invalid.first), isFalse);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.error?.type, SingleErrorTypes.invalidInput.name);
      final db = await database.db;
      expect(await db.query('daily_nutrition_logs'), isEmpty);
      expect(await db.query('meal_logs'), isEmpty);
      expect(await db.query('meal_log_items'), isEmpty);
    },
  );

  test(
    'failed item insertion rolls back the day and meal atomically',
    () async {
      final db = await database.db;
      await db.execute('''
      CREATE TRIGGER fail_quick_add BEFORE INSERT ON meal_log_items
      BEGIN SELECT RAISE(ABORT, 'Test insert failure'); END;
    ''');
      final result = await service.logQuickFood(
        input,
        logTime: DateTime(2025, 1, 10),
      );
      expect(result.isErr(), isTrue);
      expect(result.error.type, SingleErrorTypes.operationFailure);
      expect(await db.query('daily_nutrition_logs'), isEmpty);
      expect(await db.query('meal_logs'), isEmpty);
      expect(await db.query('meal_log_items'), isEmpty);
    },
  );

  test(
    'manual calorie totals and midnight local dates are preserved',
    () async {
      final time = DateTime(2025, 1, 11);
      final result = await service.logQuickFood(
        const QuickFoodLogInput(
          name: 'Label calories',
          calories: 123,
          protein: 0,
          carbs: 0,
          fat: 0,
        ),
        logTime: time.toUtc(),
      );
      expect(result.isOk(), isTrue);
      expect(result.value.logTime, time);
      final day = (await service.getDailyLogByDate(time)).value;
      expect(day.date, 20250111);
      expect(day.totalCalories, 123);
      expect(day.totalProtein, 0);
    },
  );
}
