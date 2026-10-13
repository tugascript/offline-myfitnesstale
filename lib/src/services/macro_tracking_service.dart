import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';

import '../common/nullable.dart';
import '../models/common.dart';
import '../models/daily_nutrition_log_model.dart';
import '../models/db.dart';
import '../models/enums.dart';
import '../models/food_model.dart';
import '../models/food_portion_model.dart';
import '../models/macro_goal_model.dart';
import '../models/meal_log_item_model.dart';
import '../models/meal_log_model.dart';
import '../models/recipe_model.dart';
import '../models/repository.dart';
import '../models/utilities.dart';
import 'common/errors.dart';
import 'common/result.dart';
import 'dtos/macro_tracking_dto.dart';
import 'dtos/paginated_dto.dart';

class MacroTrackingService {
  MacroTrackingService._();

  static final MacroTrackingService _instance = MacroTrackingService._();

  factory MacroTrackingService() => _instance;

  final Logger _logger = Logger('Macro Tracking Service');

  final Repository<MacroGoal> _macroGoalRepository = Repository<MacroGoal>(
    databaseHelper: DatabaseHelper(),
    tableName: MacroGoal.table,
    fromMap: MacroGoal.fromMap,
  );

  final Repository<DailyNutritionLog> _dailyLogRepository =
      Repository<DailyNutritionLog>(
    databaseHelper: DatabaseHelper(),
    tableName: DailyNutritionLog.table,
    fromMap: DailyNutritionLog.fromMap,
  );

  final Repository<MealLog> _mealLogRepository = Repository<MealLog>(
    databaseHelper: DatabaseHelper(),
    tableName: MealLog.table,
    fromMap: MealLog.fromMap,
  );

  final Repository<MealLogItem> _mealLogItemRepository =
      Repository<MealLogItem>(
    databaseHelper: DatabaseHelper(),
    tableName: MealLogItem.table,
    fromMap: MealLogItem.fromMap,
  );

  // ==================== MACRO GOALS ====================

  Future<Result<MacroGoalDto, ServiceError<SingleErrorTypes>>> createMacroGoal({
    required String name,
    required int targetCalories,
    required int targetProtein,
    required int targetCarbs,
    required int targetFat,
    int? targetWaterIntakeMl,
    required WeightGoalPhase phase,
    bool isActive = true,
  }) async {
    _logger.info('Creating macro goal: $name');
    try {
      final goal = MacroGoal.create(
        profileId: 1, // unused in db
        name: name,
        targetCalories: targetCalories,
        targetProtein: targetProtein,
        targetCarbs: targetCarbs,
        targetFat: targetFat,
        targetWaterIntakeMl: targetWaterIntakeMl,
        phase: phase,
        isActive: isActive,
      );

      final db = await DatabaseHelper().db;
      final int id = await db.transaction<int>((txn) async {
        if (isActive) {
          await txn.update(
            MacroGoal.table,
            {MacroGoalColumns.isActive.value: 0},
            where: '${MacroGoalColumns.isActive.value} = ?',
            whereArgs: [1],
          );
        }
        return await _macroGoalRepository.insert(goal, txn);
      });

      _logger.info('Created macro goal with id: $id');
      return ok(MacroGoalDto.fromModel(goal.copyWith(id: Nullable(id))));
    } catch (e) {
      _logger.severe('Failed to create macro goal', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to create macro goal',
      ));
    }
  }

  Future<Result<MacroGoalDto, ServiceError<SingleErrorTypes>>> updateMacroGoal({
    required int id,
    String? name,
    int? targetCalories,
    int? targetProtein,
    int? targetCarbs,
    int? targetFat,
    int? targetWaterIntakeMl,
    WeightGoalPhase? phase,
    bool? isActive,
  }) async {
    _logger.info('Updating macro goal: $id');
    try {
      final existing = await _macroGoalRepository.selectOne(id);
      if (existing == null) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Macro goal not found',
        ));
      }

      final db = await DatabaseHelper().db;
      return await db
          .transaction<Result<MacroGoalDto, ServiceError<SingleErrorTypes>>>(
        (txn) async {
          if (isActive == true) {
            await txn.update(
              MacroGoal.table,
              {MacroGoalColumns.isActive.value: 0},
              where: '${MacroGoalColumns.isActive.value} = ?',
              whereArgs: [1],
            );
          }

          final updated = existing.copyWith(
            name: name,
            targetCalories: targetCalories,
            targetProtein: targetProtein,
            targetCarbs: targetCarbs,
            targetFat: targetFat,
            targetWaterIntakeMl: targetWaterIntakeMl != null
                ? Nullable(targetWaterIntakeMl)
                : null,
            phase: phase,
            isActive: isActive,
            updatedAt: DateUtilities.getNowUtcUnix(),
          );

          await _macroGoalRepository.update(updated, txn);
          return ok(MacroGoalDto.fromModel(updated));
        },
      );
    } catch (e) {
      _logger.severe('Failed to update macro goal with id $id', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to update macro goal',
      ));
    }
  }

  Future<Result<MacroGoalDto, ServiceError<SingleErrorTypes>>>
      completeMacroGoal(
    int id,
  ) async {
    _logger.info('Completing macro goal: $id');
    return updateMacroGoal(id: id, isActive: false);
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>> deleteMacroGoal(
    int id,
  ) async {
    _logger.info('Deleting macro goal: $id');
    try {
      final deleted = await _macroGoalRepository.deleteOne(id);
      if (!deleted) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Macro goal not found',
        ));
      }
      return ok(null);
    } catch (e) {
      _logger.severe('Failed to delete macro goal with id $id', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to delete macro goal',
      ));
    }
  }

  Future<Result<MacroGoalDto, ServiceError<SingleErrorTypes>>>
      getActiveMacroGoal() async {
    _logger.info('Getting active macro goal');
    try {
      final goals = await _macroGoalRepository.selectMany(
        where: MacroGoalColumns.isActive.equal,
        whereArgs: [1],
        orderBy: [MacroGoalColumns.createdAt.orderDesc],
        limit: 1,
      );
      if (goals.isEmpty) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'No active macro goal found',
        ));
      }
      return ok(MacroGoalDto.fromModel(goals.first));
    } catch (e) {
      _logger.severe('Failed to get active macro goal', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to get active macro goal',
      ));
    }
  }

  Future<
      Result<PaginatedDto<MacroGoalDto, MacroGoal>,
          ServiceError<OperationErrorTypes>>> getMacroGoals({
    int limit = kDefaultLimit,
    int offset = kDefaultOffset,
  }) async {
    _logger.info('Getting macro goals history');
    try {
      final goals = await _macroGoalRepository.selectPaginated(
        limit: limit,
        offset: offset,
        orderBy: [MacroGoalColumns.createdAt.orderDesc],
      );
      final total = await _macroGoalRepository.count();

      return ok(PaginatedDto<MacroGoalDto, MacroGoal>.mapData(
        data: goals,
        mapper: (g) => MacroGoalDto.fromModel(g),
        total: total,
        limit: limit,
        offset: offset,
      ));
    } catch (e) {
      _logger.severe('Failed to get macro goals', e);
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to get macro goals',
      ));
    }
  }

  // ==================== DAILY LOGS & MEALS ====================

  Future<DailyNutritionLog> _getOrCreateDailyLogInternal(
    Transaction txn,
    int numericDate,
  ) async {
    final existingRows = await txn.query(
      DailyNutritionLog.table,
      where: '${DailyNutritionLogColumns.date.value} = ?',
      whereArgs: [numericDate],
      limit: 1,
    );
    if (existingRows.isNotEmpty) {
      return DailyNutritionLog.fromMap(existingRows.first);
    }

    final newLog = DailyNutritionLog.create(date: numericDate);
    final id = await _dailyLogRepository.insert(newLog, txn);
    return newLog.copyWith(id: Nullable(id));
  }

  Future<Result<DailyNutritionLogDto, ServiceError<SingleErrorTypes>>>
      getDailyLogByDate(DateTime localDate) async {
    final numericDate = DateUtilities.getNumericDate(localDate);
    _logger.info('Getting daily log for date $numericDate');
    try {
      final db = await DatabaseHelper().db;
      return await db.transaction<
          Result<DailyNutritionLogDto, ServiceError<SingleErrorTypes>>>(
        (txn) async {
          final dailyLog = await _getOrCreateDailyLogInternal(txn, numericDate);
          final meals = await _loadMealsForDailyLog(txn, dailyLog.id!);
          return ok(DailyNutritionLogDto.fromModel(dailyLog, meals: meals));
        },
      );
    } catch (e) {
      _logger.severe('Failed to get daily log for date $numericDate', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to get daily nutrition log',
      ));
    }
  }

  Future<List<MealLogDto>> _loadMealsForDailyLog(
    Transaction txn,
    int dailyLogId,
  ) async {
    final mealRows = await txn.query(
      MealLog.table,
      where: '${MealLogColumns.dailyLogId.value} = ?',
      whereArgs: [dailyLogId],
      orderBy: '${MealLogColumns.logTime.value} ASC',
    );

    final List<MealLogDto> mealDtos = [];
    for (final mRow in mealRows) {
      final meal = MealLog.fromMap(mRow);
      final itemRows = await txn.query(
        MealLogItem.table,
        where: '${MealLogItemColumns.mealLogId.value} = ?',
        whereArgs: [meal.id!],
        orderBy: '${MealLogItemColumns.createdAt.value} ASC',
      );

      final List<MealLogItemDto> itemDtos = [];
      for (final iRow in itemRows) {
        final item = MealLogItem.fromMap(iRow);
        String? portionName;
        if (item.portionId != null) {
          final pRows = await txn.query(
            FoodPortion.table,
            where: '${FoodPortionColumns.id.value} = ?',
            whereArgs: [item.portionId!],
            limit: 1,
          );
          if (pRows.isNotEmpty) {
            portionName =
                pRows.first[FoodPortionColumns.portionName.value] as String?;
          }
        }
        itemDtos.add(MealLogItemDto.fromModel(item, portionName: portionName));
      }

      mealDtos.add(MealLogDto.fromModel(meal, items: itemDtos));
    }

    return mealDtos;
  }

  Future<Result<List<DailyNutritionLogDto>, ServiceError<OperationErrorTypes>>>
      getDailyLogsForRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final startNum = DateUtilities.getNumericDate(start);
    final endNum = DateUtilities.getNumericDate(end);
    _logger.info('Getting daily logs for range $startNum to $endNum');
    try {
      final db = await DatabaseHelper().db;
      final logs =
          await db.transaction<List<DailyNutritionLogDto>>((txn) async {
        final logRows = await txn.query(
          DailyNutritionLog.table,
          where:
              '${DailyNutritionLogColumns.date.value} >= ? AND ${DailyNutritionLogColumns.date.value} <= ?',
          whereArgs: [startNum, endNum],
          orderBy: '${DailyNutritionLogColumns.date.value} ASC',
        );

        final List<DailyNutritionLogDto> result = [];
        for (final row in logRows) {
          final dailyLog = DailyNutritionLog.fromMap(row);
          final meals = await _loadMealsForDailyLog(txn, dailyLog.id!);
          result.add(DailyNutritionLogDto.fromModel(dailyLog, meals: meals));
        }
        return result;
      });

      return ok(logs);
    } catch (e) {
      _logger.severe('Failed to get daily logs for range', e);
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to get daily logs',
      ));
    }
  }

  Future<Result<DailyNutritionLogDto, ServiceError<SingleErrorTypes>>>
      updateWaterIntake({
    required DateTime date,
    required int waterIntakeMl,
  }) async {
    final numericDate = DateUtilities.getNumericDate(date);
    _logger.info('Updating water intake for $numericDate to $waterIntakeMl ml');
    try {
      final db = await DatabaseHelper().db;
      return await db.transaction<
          Result<DailyNutritionLogDto, ServiceError<SingleErrorTypes>>>(
        (txn) async {
          final dailyLog = await _getOrCreateDailyLogInternal(txn, numericDate);
          final updated = dailyLog.copyWith(
            waterIntakeMl: waterIntakeMl,
            updatedAt: DateUtilities.getNowUtcUnix(),
          );
          await _dailyLogRepository.update(updated, txn);
          final meals = await _loadMealsForDailyLog(txn, updated.id!);
          return ok(DailyNutritionLogDto.fromModel(updated, meals: meals));
        },
      );
    } catch (e) {
      _logger.severe('Failed to update water intake', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to update water intake',
      ));
    }
  }

  Future<Result<MealLogDto, ServiceError<SingleErrorTypes>>> logFoodItem({
    DateTime? logTime,
    required MealType mealType,
    required int foodId,
    int? portionId,
    required int amount,
  }) async {
    final effectiveTime = logTime ?? DateTime.now();
    final logUnix = DateUtilities.getDateUnix(effectiveTime);
    final numericDate = DateUtilities.getNumericDate(effectiveTime);

    _logger.info('Logging food $foodId for meal $mealType at $numericDate');
    try {
      final db = await DatabaseHelper().db;
      return await db
          .transaction<Result<MealLogDto, ServiceError<SingleErrorTypes>>>(
        (txn) async {
          final foodRows = await txn.query(
            Food.table,
            where: '${FoodColumns.id.value} = ?',
            whereArgs: [foodId],
            limit: 1,
          );
          if (foodRows.isEmpty) {
            return err(ServiceError(
              type: SingleErrorTypes.notFound,
              description: 'Food with id $foodId not found',
            ));
          }
          final food = Food.fromMap(foodRows.first);

          double effectiveGrams = amount.toDouble();
          String? portionName;
          if (portionId != null) {
            final pRows = await txn.query(
              FoodPortion.table,
              where:
                  '${FoodPortionColumns.id.value} = ? AND ${FoodPortionColumns.foodId.value} = ?',
              whereArgs: [portionId, foodId],
              limit: 1,
            );
            if (pRows.isEmpty) {
              return err(ServiceError(
                type: SingleErrorTypes.notFound,
                description:
                    'Portion with id $portionId not found for food $foodId',
              ));
            }
            final portion = FoodPortion.fromMap(pRows.first);
            portionName = portion.portionName;
            effectiveGrams = (amount * portion.gramWeight).toDouble();
          }

          final double scale = food.servingSizeBase > 0
              ? effectiveGrams / food.servingSizeBase
              : 1.0;

          final int itemCals = (food.caloriesBase * scale).round();
          final int itemProtein = (food.proteinBase * scale).round();
          final int itemCarbs = (food.carbsBase * scale).round();
          final int itemFat = (food.fatBase * scale).round();

          Micronutrients? itemMicros;
          if (food.micros != null) {
            final Map<String, dynamic> scaledMap = {};
            for (final entry in food.micros!.toMap().entries) {
              if (entry.value is num) {
                scaledMap[entry.key] = ((entry.value as num) * scale).round();
              }
            }
            itemMicros = Micronutrients.fromMap(scaledMap);
          }

          final dailyLog = await _getOrCreateDailyLogInternal(txn, numericDate);

          // Find or create meal log for chosen mealType in this dailyLog
          final existingMealRows = await txn.query(
            MealLog.table,
            where:
                '${MealLogColumns.dailyLogId.value} = ? AND ${MealLogColumns.mealType.value} = ?',
            whereArgs: [dailyLog.id!, mealType.value],
            limit: 1,
          );

          int mealLogId;
          MealLog mealLog;
          if (existingMealRows.isEmpty) {
            final newMeal = MealLog.create(
              dailyLogId: dailyLog.id!,
              mealType: mealType,
              logTime: logUnix,
              totalCalories: 0,
              totalProtein: 0,
              totalCarbs: 0,
              totalFat: 0,
            );
            mealLogId = await _mealLogRepository.insert(newMeal, txn);
            mealLog = newMeal.copyWith(id: Nullable(mealLogId));
          } else {
            mealLog = MealLog.fromMap(existingMealRows.first);
            mealLogId = mealLog.id!;
          }

          // Insert MealLogItem
          final logItem = MealLogItem.create(
            mealLogId: mealLogId,
            foodId: foodId,
            portionId: portionId,
            amount: amount,
            loggedFoodName: food.name,
            loggedCalories: itemCals,
            loggedProtein: itemProtein,
            loggedCarbs: itemCarbs,
            loggedFat: itemFat,
            loggedMicros: itemMicros,
          );
          await _mealLogItemRepository.insert(logItem, txn);

          // Recompute meal log totals from all items
          final allItems = await _mealLogItemRepository.selectMany(
            where: MealLogItemColumns.mealLogId.equal,
            whereArgs: [mealLogId],
            trx: txn,
          );

          int sumCals = 0;
          int sumProtein = 0;
          int sumCarbs = 0;
          int sumFat = 0;
          for (final it in allItems) {
            sumCals += it.loggedCalories;
            sumProtein += it.loggedProtein;
            sumCarbs += it.loggedCarbs;
            sumFat += it.loggedFat;
          }

          final updatedMeal = mealLog.copyWith(
            totalCalories: sumCals,
            totalProtein: sumProtein,
            totalCarbs: sumCarbs,
            totalFat: sumFat,
            updatedAt: DateUtilities.getNowUtcUnix(),
          );
          await _mealLogRepository.update(updatedMeal, txn);

          final List<MealLogItemDto> itemDtos = allItems.map((it) {
            return MealLogItemDto.fromModel(
              it,
              portionName: it.id == logItem.id ? portionName : null,
            );
          }).toList();

          return ok(MealLogDto.fromModel(updatedMeal, items: itemDtos));
        },
      );
    } catch (e) {
      _logger.severe('Failed to log food item', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to log food item',
      ));
    }
  }

  Future<Result<MealLogDto, ServiceError<SingleErrorTypes>>> logRecipe({
    DateTime? logTime,
    required MealType mealType,
    required int recipeId,
    int servings = 1,
  }) async {
    final effectiveTime = logTime ?? DateTime.now();
    final logUnix = DateUtilities.getDateUnix(effectiveTime);
    final numericDate = DateUtilities.getNumericDate(effectiveTime);
    final actualServings = servings < 1 ? 1 : servings;

    _logger.info('Logging recipe $recipeId for meal $mealType');
    try {
      final db = await DatabaseHelper().db;
      return await db
          .transaction<Result<MealLogDto, ServiceError<SingleErrorTypes>>>(
        (txn) async {
          final recipeRows = await txn.query(
            Recipe.table,
            where: '${RecipeColumns.id.value} = ?',
            whereArgs: [recipeId],
            limit: 1,
          );
          if (recipeRows.isEmpty) {
            return err(ServiceError(
              type: SingleErrorTypes.notFound,
              description: 'Recipe with id $recipeId not found',
            ));
          }
          final recipe = Recipe.fromMap(recipeRows.first);

          final itemCals = recipe.servingCalories * actualServings;
          final itemProtein = recipe.servingProtein * actualServings;
          final itemCarbs = recipe.servingCarbs * actualServings;
          final itemFat = recipe.servingFat * actualServings;

          Micronutrients? itemMicros;
          if (recipe.servingMicros != null) {
            final Map<String, dynamic> scaled = {};
            for (final entry in recipe.servingMicros!.toMap().entries) {
              if (entry.value is num) {
                scaled[entry.key] =
                    ((entry.value as num) * actualServings).round();
              }
            }
            itemMicros = Micronutrients.fromMap(scaled);
          }

          final dailyLog = await _getOrCreateDailyLogInternal(txn, numericDate);

          final existingMealRows = await txn.query(
            MealLog.table,
            where:
                '${MealLogColumns.dailyLogId.value} = ? AND ${MealLogColumns.mealType.value} = ?',
            whereArgs: [dailyLog.id!, mealType.value],
            limit: 1,
          );

          int mealLogId;
          MealLog mealLog;
          if (existingMealRows.isEmpty) {
            final newMeal = MealLog.create(
              dailyLogId: dailyLog.id!,
              mealType: mealType,
              recipeId: recipeId,
              logTime: logUnix,
              totalCalories: 0,
              totalProtein: 0,
              totalCarbs: 0,
              totalFat: 0,
            );
            mealLogId = await _mealLogRepository.insert(newMeal, txn);
            mealLog = newMeal.copyWith(id: Nullable(mealLogId));
          } else {
            mealLog = MealLog.fromMap(existingMealRows.first);
            mealLogId = mealLog.id!;
          }

          final logItem = MealLogItem.create(
            mealLogId: mealLogId,
            amount: actualServings,
            loggedFoodName:
                '${recipe.name} ($actualServings serving${actualServings > 1 ? 's' : ''})',
            loggedCalories: itemCals,
            loggedProtein: itemProtein,
            loggedCarbs: itemCarbs,
            loggedFat: itemFat,
            loggedMicros: itemMicros,
          );
          await _mealLogItemRepository.insert(logItem, txn);

          final allItems = await _mealLogItemRepository.selectMany(
            where: MealLogItemColumns.mealLogId.equal,
            whereArgs: [mealLogId],
            trx: txn,
          );

          int sumCals = 0;
          int sumProtein = 0;
          int sumCarbs = 0;
          int sumFat = 0;
          for (final it in allItems) {
            sumCals += it.loggedCalories;
            sumProtein += it.loggedProtein;
            sumCarbs += it.loggedCarbs;
            sumFat += it.loggedFat;
          }

          final updatedMeal = mealLog.copyWith(
            recipeId: Nullable(recipeId),
            totalCalories: sumCals,
            totalProtein: sumProtein,
            totalCarbs: sumCarbs,
            totalFat: sumFat,
            updatedAt: DateUtilities.getNowUtcUnix(),
          );
          await _mealLogRepository.update(updatedMeal, txn);

          final List<MealLogItemDto> itemDtos =
              allItems.map((it) => MealLogItemDto.fromModel(it)).toList();

          return ok(MealLogDto.fromModel(updatedMeal, items: itemDtos));
        },
      );
    } catch (e) {
      _logger.severe('Failed to log recipe', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to log recipe',
      ));
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>> deleteMealLog(
    int mealLogId,
  ) async {
    _logger.info('Deleting meal log: $mealLogId');
    try {
      final deleted = await _mealLogRepository.deleteOne(mealLogId);
      if (!deleted) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Meal log not found',
        ));
      }
      return ok(null);
    } catch (e) {
      _logger.severe('Failed to delete meal log with id $mealLogId', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to delete meal log',
      ));
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>> deleteMealLogItem(
    int itemId,
  ) async {
    _logger.info('Deleting meal log item: $itemId');
    try {
      final db = await DatabaseHelper().db;
      return await db.transaction<Result<void, ServiceError<SingleErrorTypes>>>(
        (txn) async {
          final item = await _mealLogItemRepository.selectOne(itemId, txn);
          if (item == null) {
            return err(const ServiceError(
              type: SingleErrorTypes.notFound,
              description: 'Meal log item not found',
            ));
          }

          final mealLogId = item.mealLogId;
          await _mealLogItemRepository.deleteOne(itemId, txn);

          // Recompute meal log totals
          final remainingItems = await _mealLogItemRepository.selectMany(
            where: MealLogItemColumns.mealLogId.equal,
            whereArgs: [mealLogId],
            trx: txn,
          );

          final mealLog = await _mealLogRepository.selectOne(mealLogId, txn);
          if (mealLog != null) {
            int sumCals = 0;
            int sumProtein = 0;
            int sumCarbs = 0;
            int sumFat = 0;
            for (final it in remainingItems) {
              sumCals += it.loggedCalories;
              sumProtein += it.loggedProtein;
              sumCarbs += it.loggedCarbs;
              sumFat += it.loggedFat;
            }

            final updatedMeal = mealLog.copyWith(
              totalCalories: sumCals,
              totalProtein: sumProtein,
              totalCarbs: sumCarbs,
              totalFat: sumFat,
              updatedAt: DateUtilities.getNowUtcUnix(),
            );
            await _mealLogRepository.update(updatedMeal, txn);
          }

          return ok(null);
        },
      );
    } catch (e) {
      _logger.severe('Failed to delete meal log item with id $itemId', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to delete meal log item',
      ));
    }
  }
}
