import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:myfitnesstale/src/models/common.dart';
import 'package:myfitnesstale/src/models/daily_nutrition_log_model.dart';
import 'package:myfitnesstale/src/models/db.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/models/food_model.dart';
import 'package:myfitnesstale/src/models/food_portion_model.dart';
import 'package:myfitnesstale/src/models/macro_goal_model.dart';
import 'package:myfitnesstale/src/models/meal_log_item_model.dart';
import 'package:myfitnesstale/src/models/meal_log_model.dart';
import 'package:myfitnesstale/src/models/meal_plan_day_model.dart';
import 'package:myfitnesstale/src/models/meal_plan_meal_item_model.dart';
import 'package:myfitnesstale/src/models/meal_plan_meal_model.dart';
import 'package:myfitnesstale/src/models/meal_plan_model.dart';
import 'package:myfitnesstale/src/models/meal_plan_record_model.dart';
import 'package:myfitnesstale/src/models/meal_plan_week_model.dart';
import 'package:myfitnesstale/src/models/profile_model.dart';
import 'package:myfitnesstale/src/models/recipe_item_model.dart';
import 'package:myfitnesstale/src/models/recipe_model.dart';
import 'package:myfitnesstale/src/models/utilities.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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

    // 1. Insert Profile for MacroGoal
    final profileId = await db.insert(
      Profile.table,
      Profile.create(
        'Athlete',
        180,
        Gender.male,
        DateTime(1995, 5, 20),
      ).toMap(),
    );

    // 2. Insert MacroGoal
    final macroGoal = MacroGoal.create(
      profileId: profileId,
      name: 'High Protein Cut',
      targetCalories: 2200,
      targetProtein: 200,
      targetCarbs: 200,
      targetFat: 60,
    );
    final macroGoalId = await db.insert(MacroGoal.table, macroGoal.toMap());
    expect(macroGoalId, isPositive);

    // 3. Insert Food with FoodCategory enum and Micronutrients JSON
    final food = Food.create(
      name: 'Chicken Breast',
      category: FoodCategory.meatAndPoultry,
      caloriesBase: 165,
      proteinBase: 31,
      carbsBase: 0,
      fatBase: 4,
      servingSizeBase: 100,
      servingUnitBase: 'g',
      micros: const Micronutrients(
        sodiumMg: 74,
        potassiumMg: 256,
        ironMg: 1,
      ),
    );
    final foodId = await db.insert(Food.table, food.toMap());
    expect(foodId, isPositive);

    final foodRows = await db.query(
      Food.table,
      where: '${FoodColumns.id.value} = ?',
      whereArgs: [foodId],
    );
    final fetchedFood = Food.fromMap(foodRows.first);
    expect(fetchedFood.micros?.sodiumMg, 74);
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
    final dailyLogId =
        await db.insert(DailyNutritionLog.table, dailyLog.toMap());
    expect(dailyLogId, isPositive);

    // 6. Insert MealLog
    final mealLog = MealLog.create(
      dailyLogId: dailyLogId,
      mealType: MealType.lunch,
      displayOrder: 1,
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
      loggedMicros: const Micronutrients(
        sodiumMg: 111,
        potassiumMg: 384,
        ironMg: 2,
      ),
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
    final items = await db.rawQuery('''
      SELECT item.* 
      FROM ${MealLogItem.table} item
      JOIN ${MealLog.table} meal ON item.${MealLogItemColumns.mealLogId.value} = meal.${MealLogColumns.id.value}
      WHERE meal.${MealLogColumns.dailyLogId.value} = ?
    ''', [dailyLogId]);

    expect(items.length, 1);
    final fetchedItem = MealLogItem.fromMap(items.first);
    expect(fetchedItem.loggedFoodName, 'Chicken Breast');
    expect(fetchedItem.loggedProtein, 47);
    expect(fetchedItem.loggedMicros?.sodiumMg, 111);
    expect(fetchedItem.loggedMicros?.potassiumMg, 384);
    expect(fetchedItem.loggedMicros?.ironMg, 2);

    // 10. Verify recipes and recipe items
    final recipe = Recipe.create(
      name: 'Chicken Rice Bowl',
      servingsYield: 2,
    );
    final recipeId = await db.insert(Recipe.table, recipe.toMap());
    final recipeItem = RecipeItem.create(
      recipeId: recipeId,
      foodId: foodId,
      portionId: portionId,
      amount: 1,
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

  test(
      'creates and queries meal plan with 1..52 weeks, phases, days, and meals',
      () async {
    await databaseHelper.initialize();
    final db = await databaseHelper.db;

    // 1. Create a 52-week annual meal plan
    final plan = MealPlan.create(
      name: 'Annual Periodized Nutrition',
      description:
          '52-week nutrition plan with cutting, maintaining, and bulking phases',
      totalWeeks: 52,
      totalDays: 364,
    );
    final planId = await db.insert(MealPlan.table, plan.toMap());
    expect(planId, isPositive);

    // 2. Insert week 1 (cutting phase) and week 52 (bulking phase)
    final week1 = MealPlanWeek.create(
      mealPlanId: planId,
      weekNumber: 1,
      phase: MealPlanPhase.cut,
      targetCalories: 2100,
      targetProtein: 210,
      targetCarbs: 180,
      targetFat: 55,
    );
    final week1Id = await db.insert(MealPlanWeek.table, week1.toMap());
    expect(week1Id, isPositive);

    final week26 = MealPlanWeek.create(
      mealPlanId: planId,
      weekNumber: 26,
      phase: MealPlanPhase.maintain,
      targetCalories: 2600,
      targetProtein: 190,
      targetCarbs: 290,
      targetFat: 75,
    );
    final week26Id = await db.insert(MealPlanWeek.table, week26.toMap());
    expect(week26Id, isPositive);

    final week52 = MealPlanWeek.create(
      mealPlanId: planId,
      weekNumber: 52,
      phase: MealPlanPhase.bulk,
      targetCalories: 3100,
      targetProtein: 200,
      targetCarbs: 400,
      targetFat: 80,
    );
    final week52Id = await db.insert(MealPlanWeek.table, week52.toMap());
    expect(week52Id, isPositive);

    // 3. Insert Day for week 1 (Day 1 - Monday)
    final day1 = MealPlanDay.create(
      mealPlanId: planId,
      mealPlanWeekId: week1Id,
      day: 1,
      name: 'High Protein Monday',
    );
    final day1Id = await db.insert(MealPlanDay.table, day1.toMap());
    expect(day1Id, isPositive);

    // 4. Insert Meal in Day 1
    final meal1 = MealPlanMeal.create(
      mealPlanId: planId,
      mealPlanWeekId: week1Id,
      mealPlanDayId: day1Id,
      position: 1,
      timeOfDay: '08:00',
      mealType: MealType.breakfast,
      name: 'Power Breakfast',
    );
    final meal1Id = await db.insert(MealPlanMeal.table, meal1.toMap());
    expect(meal1Id, isPositive);

    // 5. Insert Food & MealPlanMealItem
    final food = Food.create(
      name: 'Oatmeal',
      category: FoodCategory.grainsAndCereals,
      caloriesBase: 389,
      proteinBase: 17,
      carbsBase: 66,
      fatBase: 7,
    );
    final foodId = await db.insert(Food.table, food.toMap());

    final mealItem = MealPlanMealItem.create(
      mealPlanMealId: meal1Id,
      foodId: foodId,
      amount: 80,
    );
    final mealItemId =
        await db.insert(MealPlanMealItem.table, mealItem.toMap());
    expect(mealItemId, isPositive);

    // 6. Start active MealPlanRecord
    final record = MealPlanRecord.create(
      mealPlanId: planId,
      currentWeek: 1,
      currentDay: 1,
      status: ProgressStatus.inProgress,
    );
    final recordId = await db.insert(MealPlanRecord.table, record.toMap());
    expect(recordId, isPositive);

    // 7. Verify PRAGMA foreign_key_check passes
    final fkCheck = await db.rawQuery('PRAGMA foreign_key_check');
    expect(fkCheck, isEmpty);

    // 8. Query and verify week phases
    final weeks = await db.query(
      MealPlanWeek.table,
      where: '${MealPlanWeekColumns.mealPlanId.value} = ?',
      whereArgs: [planId],
      orderBy: MealPlanWeekColumns.weekNumber.value,
    );
    expect(weeks.length, 3);
    final parsedWeek1 = MealPlanWeek.fromMap(weeks[0]);
    final parsedWeek26 = MealPlanWeek.fromMap(weeks[1]);
    final parsedWeek52 = MealPlanWeek.fromMap(weeks[2]);

    expect(parsedWeek1.weekNumber, 1);
    expect(parsedWeek1.phase, MealPlanPhase.cut);
    expect(parsedWeek26.weekNumber, 26);
    expect(parsedWeek26.phase, MealPlanPhase.maintain);
    expect(parsedWeek52.weekNumber, 52);
    expect(parsedWeek52.phase, MealPlanPhase.bulk);

    // 9. Cascade delete deletes child weeks, days, meals, items, and records
    await db.delete(
      MealPlan.table,
      where: '${MealPlanColumns.id.value} = ?',
      whereArgs: [planId],
    );
    expect(
      await db.query(
        MealPlanWeek.table,
        where: '${MealPlanWeekColumns.mealPlanId.value} = ?',
        whereArgs: [planId],
      ),
      isEmpty,
    );
    expect(
      await db.query(
        MealPlanDay.table,
        where: '${MealPlanDayColumns.mealPlanId.value} = ?',
        whereArgs: [planId],
      ),
      isEmpty,
    );
    expect(
      await db.query(
        MealPlanMeal.table,
        where: '${MealPlanMealColumns.mealPlanId.value} = ?',
        whereArgs: [planId],
      ),
      isEmpty,
    );
    expect(
      await db.query(
        MealPlanMealItem.table,
        where: '${MealPlanMealItemColumns.mealPlanMealId.value} = ?',
        whereArgs: [meal1Id],
      ),
      isEmpty,
    );
    expect(
      await db.query(
        MealPlanRecord.table,
        where: '${MealPlanRecordColumns.mealPlanId.value} = ?',
        whereArgs: [planId],
      ),
      isEmpty,
    );
  });
}
