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

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:myfitnesstale/src/data/utils/json_data.dart';
import 'package:myfitnesstale/src/data/models/sqlite/daily_nutrition_log_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/day_macro_goal_model.dart';
import 'package:myfitnesstale/src/data/services/sqlite/database_helper.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/models/sqlite/food_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/food_portion_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/meal_log_item_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/meal_log_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/recipe_item_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/recipe_model.dart';

import 'package:myfitnesstale/src/data/models/sqlite/week_macro_goal_model.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:myfitnesstale/src/data/utils/dates.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  final databaseHelper = DatabaseHelper();
  late Directory temporaryDirectory;
  late String originalDatabasesPath;

  setUp(() async {
    databaseFactory = databaseFactoryFfi;
    await databaseHelper.resetForTesting();
    originalDatabasesPath = await databaseFactory.getDatabasesPath();
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'myfitnesstale_nutrition_test_',
    );
    await databaseFactory.setDatabasesPath(temporaryDirectory.path);
  });

  tearDown(() async {
    await databaseHelper.resetForTesting();
    await databaseFactory.setDatabasesPath(originalDatabasesPath);
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('creates nutrition tables and satisfies foreign key checks', () async {
    await databaseHelper.initialize();
    final db = await databaseHelper.db;

    final fkCheck = await db.rawQuery('PRAGMA foreign_key_check');
    expect(fkCheck, isEmpty);

    // 1. Insert WeekMacroGoal and DayMacroGoal
    final weekGoal = WeekMacroGoal.create(
      name: 'Cycling Cut',
      totalTargetCalories: 14000,
      totalTargetProtein: 1120,
      totalTargetCarbs: 1400,
      totalTargetFat: 420,
      goalType: MacroGoalType.calorieCycling,
      phase: WeightGoalPhase.cut,
    );
    final weekGoalId = await db.insert(WeekMacroGoal.table, weekGoal.toMap());
    expect(weekGoalId, isPositive);

    final dayGoal = DayMacroGoal.create(
      weekMacroGoalId: weekGoalId,
      days: const [DayOfWeek.saturday, DayOfWeek.sunday],
      name: 'Weekends',
      targetCalories: 2500,
      targetProtein: 160,
      targetCarbs: 280,
      targetFat: 82,
      phase: WeightGoalPhase.cut,
    );
    final dayGoalId = await db.insert(DayMacroGoal.table, dayGoal.toMap());
    expect(dayGoalId, isPositive);
    final dayGoalRows = await db.query(
      DayMacroGoal.table,
      where: '${DayMacroGoalColumns.id.value} = ?',
      whereArgs: [dayGoalId],
    );
    final fetchedDayGoal = DayMacroGoal.fromMap(dayGoalRows.first);
    expect(fetchedDayGoal.days, const [DayOfWeek.saturday, DayOfWeek.sunday]);
    expect(fetchedDayGoal.targetCalories, 2500);

    final defaultedDayGoal = DayMacroGoal.fromMap({
      DayMacroGoalColumns.id.value: 99,
      DayMacroGoalColumns.weekMacroGoalId.value: weekGoalId,
      DayMacroGoalColumns.days.value: '[1]',
      DayMacroGoalColumns.targetCalories.value: 2000,
      DayMacroGoalColumns.targetProtein.value: 150,
      DayMacroGoalColumns.targetCarbs.value: 200,
      DayMacroGoalColumns.targetFat.value: 65,
      DayMacroGoalColumns.createdAt.value: 1,
      DayMacroGoalColumns.updatedAt.value: 1,
    });
    expect(defaultedDayGoal.isActive, isTrue);
    expect(defaultedDayGoal.phase, WeightGoalPhase.maintain);

    // 3. Insert Food with FoodCategory enum and Micronutrients JSON
    final food = Food.create(
      name: 'Chicken Breast',
      category: FoodCategory.meatAndPoultry,
      caloriesBase: 165,
      proteinBase: 31,
      carbsBase: 0,
      fatBase: 4,
      servingSizeBaseGrams: 100,
      sodiumBase: 74,
      micros: const Micronutrients(potassiumMg: 256, ironMg: 1),
    );
    final foodId = await db.insert(Food.table, food.toMap());
    expect(foodId, isPositive);

    final foodRows = await db.query(
      Food.table,
      where: '${FoodColumns.id.value} = ?',
      whereArgs: [foodId],
    );
    final fetchedFood = Food.fromMap(foodRows.first);
    expect(fetchedFood.sodiumBase, 74);
    expect(fetchedFood.micros?.potassiumMg, 256);
    expect(fetchedFood.micros?.ironMg, 1);

    // 4. Insert FoodPortion
    final portion = FoodPortion.create(
      foodId: foodId,
      portionName: '1 cooked breast (150g)',
      gramWeight: 150,
    );
    final portionId = await db.insert(FoodPortion.table, portion.toMap());
    expect(portionId, isPositive);

    // 5. Insert DailyNutritionLog using YYYYMMDD date format
    final localNow = DateTime(2026, 10, 7);
    final numericDate = DateUtilities.getNumericDate(localNow); // 20261007
    expect(numericDate, 20261007);

    final dailyLog = DailyNutritionLog.create(
      date: numericDate,
      waterIntakeMl: 2500,
      notes: 'Great workout today',
    );
    final dailyLogId = await db.insert(
      DailyNutritionLog.table,
      dailyLog.toMap(),
    );
    expect(dailyLogId, isPositive);

    // 6. Insert MealLog
    final mealLog = MealLog.create(
      dailyLogId: dailyLogId,
      mealType: MealType.lunch,
      logTime: DateUtilities.getNowUtcUnix(),
      totalCalories: 248,
      totalProtein: 47,
      totalCarbs: 0,
      totalFat: 6,
    );
    final mealLogId = await db.insert(MealLog.table, mealLog.toMap());
    expect(mealLogId, isPositive);

    // 7. Insert MealLogItem with snapshot values including loggedMicros
    final mealLogItem = MealLogItem.create(
      mealLogId: mealLogId,
      foodId: foodId,
      portionId: portionId,
      amount: 150,
      loggedFoodName: 'Chicken Breast',
      loggedCalories: 248,
      loggedProtein: 47,
      loggedCarbs: 0,
      loggedFat: 6,
      loggedMicros: const Micronutrients(potassiumMg: 384, ironMg: 2),
    );
    final itemId = await db.insert(MealLogItem.table, mealLogItem.toMap());
    expect(itemId, isPositive);

    // 8. Query daily log by numeric date
    final dailyRows = await db.query(
      DailyNutritionLog.table,
      where: '${DailyNutritionLogColumns.date.value} = ?',
      whereArgs: [numericDate],
    );
    expect(dailyRows.length, 1);
    final fetchedDaily = DailyNutritionLog.fromMap(dailyRows.first);
    expect(fetchedDaily.date, 20261007);
    expect(fetchedDaily.waterIntakeMl, 2500);

    // 9. Query items for that daily log
    final items = await db.rawQuery(
      '''
      SELECT item.* 
      FROM ${MealLogItem.table} item
      JOIN ${MealLog.table} meal ON item.${MealLogItemColumns.mealLogId.value} = meal.${MealLogColumns.id.value}
      WHERE meal.${MealLogColumns.dailyLogId.value} = ?
    ''',
      [dailyLogId],
    );

    expect(items.length, 1);
    final fetchedItem = MealLogItem.fromMap(items.first);
    expect(fetchedItem.loggedFoodName, 'Chicken Breast');
    expect(fetchedItem.loggedProtein, 47);
    expect(fetchedItem.loggedMicros?.potassiumMg, 384);
    expect(fetchedItem.loggedMicros?.ironMg, 2);

    // 10. Verify recipes and recipe items
    final recipe = Recipe.create(
      name: 'Chicken Rice Bowl',
      servingsYield: 2,
      servingCalories: 400,
      servingProtein: 40,
      servingCarbs: 30,
      servingFat: 10,
    );
    final recipeId = await db.insert(Recipe.table, recipe.toMap());
    final recipeItem = RecipeItem.create(
      recipeId: recipeId,
      foodId: foodId,
      portionId: portionId,
      amount: 1,
      totalCalories: 248,
      totalProtein: 47,
      totalCarbs: 0,
      totalFat: 6,
    );
    final recipeItemId = await db.insert(RecipeItem.table, recipeItem.toMap());
    expect(recipeItemId, isPositive);

    // 11. Foreign key validation
    final finalFkCheck = await db.rawQuery('PRAGMA foreign_key_check');
    expect(finalFkCheck, isEmpty);

    // 12. Test cascade delete of DailyNutritionLog
    await db.delete(
      DailyNutritionLog.table,
      where: '${DailyNutritionLogColumns.id.value} = ?',
      whereArgs: [dailyLogId],
    );
    final remainingMealLogs = await db.query(
      MealLog.table,
      where: '${MealLogColumns.id.value} = ?',
      whereArgs: [mealLogId],
    );
    final remainingMealItems = await db.query(
      MealLogItem.table,
      where: '${MealLogItemColumns.id.value} = ?',
      whereArgs: [itemId],
    );
    expect(remainingMealLogs, isEmpty);
    expect(remainingMealItems, isEmpty);
  });
}
