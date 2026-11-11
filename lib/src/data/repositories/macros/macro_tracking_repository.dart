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

import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';

import '../../../utils/errors.dart';
import '../../../utils/nullable.dart';
import '../../../utils/result.dart';
import '../../models/sqlite/daily_nutrition_log_model.dart';
import '../../models/sqlite/day_macro_goal_model.dart';
import '../../models/sqlite/food_model.dart';
import '../../models/sqlite/food_portion_model.dart';
import '../../models/sqlite/meal_log_item_model.dart';
import '../../models/sqlite/meal_log_model.dart';
import '../../models/sqlite/recipe_model.dart';
import '../../models/sqlite/week_macro_goal_model.dart';
import '../../services/common.dart';
import '../../services/sqlite/dao.dart';
import '../../services/sqlite/database_helper.dart';
import '../../utils/dates.dart';
import '../../utils/enums.dart';
import '../../utils/json_data.dart';
import '../../utils/where_builder.dart';
import '../core/dtos/paginated_dto.dart';
import '../core/repository.dart';
import '../core/repository_helpers.dart';
import './dtos/macro_tracking_dto.dart';
import 'inputs/day_macro_goal_input.dart';
import 'inputs/quick_food_log_input.dart';
import 'inputs/week_macro_goal_input.dart';

final class MacroTrackingRepository implements Repository {
  final Dao<Food> _foodDao;
  final Dao<Recipe> _recipeDao;
  final Dao<FoodPortion> _foodPortionDao;
  final Dao<WeekMacroGoal> _weekMacroGoalDao;
  final Dao<DayMacroGoal> _dayMacroGoalDao;
  final Dao<DailyNutritionLog> _dailyLogDao;
  final Dao<MealLog> _mealLogDao;
  final Dao<MealLogItem> _mealLogItemDao;

  final Logger _logger = Logger('Macro Tracking Repository');

  MacroTrackingRepository({
    required this._foodDao,
    required this._recipeDao,
    required this._foodPortionDao,
    required this._weekMacroGoalDao,
    required this._dayMacroGoalDao,
    required this._dailyLogDao,
    required this._mealLogDao,
    required this._mealLogItemDao,
  });

  factory MacroTrackingRepository.create([DatabaseHelper? databaseHelper]) {
    final helper = databaseHelper ?? DatabaseHelper();
    return MacroTrackingRepository(
      foodDao: Dao<Food>(
        databaseHelper: helper,
        tableName: Food.table,
        fromMap: Food.fromMap,
      ),
      recipeDao: Dao<Recipe>(
        databaseHelper: helper,
        tableName: Recipe.table,
        fromMap: Recipe.fromMap,
      ),
      foodPortionDao: Dao<FoodPortion>(
        databaseHelper: helper,
        tableName: FoodPortion.table,
        fromMap: FoodPortion.fromMap,
      ),
      weekMacroGoalDao: Dao<WeekMacroGoal>(
        databaseHelper: helper,
        tableName: WeekMacroGoal.table,
        fromMap: WeekMacroGoal.fromMap,
      ),
      dayMacroGoalDao: Dao<DayMacroGoal>(
        databaseHelper: helper,
        tableName: DayMacroGoal.table,
        fromMap: DayMacroGoal.fromMap,
      ),
      dailyLogDao: Dao<DailyNutritionLog>(
        databaseHelper: helper,
        tableName: DailyNutritionLog.table,
        fromMap: DailyNutritionLog.fromMap,
      ),
      mealLogDao: Dao<MealLog>(
        databaseHelper: helper,
        tableName: MealLog.table,
        fromMap: MealLog.fromMap,
      ),
      mealLogItemDao: Dao<MealLogItem>(
        databaseHelper: helper,
        tableName: MealLogItem.table,
        fromMap: MealLogItem.fromMap,
      ),
    );
  }

  Result<List<DayMacroGoalInput>, ServiceError<SingleErrorTypes>>
  _resolveAndValidateDayInputs(WeekMacroGoalInput input) {
    final List<DayMacroGoalInput> dayInputs = input.days.isEmpty
        ? (input.goalType == MacroGoalType.flat
              ? [
                  DayMacroGoalInput(
                    name: input.name,
                    days: DayOfWeek.values,
                    targetCalories: input.targetCalories,
                    targetProtein: input.targetProtein,
                    targetCarbs: input.targetCarbs,
                    targetFat: input.targetFat,
                    targetFiber: input.targetFiber,
                    targetSodium: input.targetSodium,
                    targetWaterIntakeMl: input.targetWaterIntakeMl,
                    phase: input.phase,
                    isActive: input.isActive,
                  ),
                ]
              : const [])
        : input.days;

    if (dayInputs.isEmpty) {
      return err(
        const ServiceError<SingleErrorTypes>(
          type: SingleErrorTypes.invalidInput,
          description: 'Macro goal requires day configurations',
        ),
      );
    }

    if (input.goalType == MacroGoalType.flat && dayInputs.length != 1) {
      return err(
        const ServiceError<SingleErrorTypes>(
          type: SingleErrorTypes.invalidInput,
          description:
              'Flat macro goal must have exactly one day configuration',
        ),
      );
    }

    if (input.goalType == MacroGoalType.calorieCycling &&
        dayInputs.length < 2) {
      return err(
        const ServiceError<SingleErrorTypes>(
          type: SingleErrorTypes.invalidInput,
          description:
              'Calorie cycling macro goal requires at least two day groups',
        ),
      );
    }

    if (input.targetCalories < 0 ||
        input.targetProtein < 0 ||
        input.targetCarbs < 0 ||
        input.targetFat < 0 ||
        (input.targetFiber.value != null && input.targetFiber.value! < 0) ||
        (input.targetSodium.value != null && input.targetSodium.value! < 0) ||
        (input.targetWaterIntakeMl.value != null &&
            input.targetWaterIntakeMl.value! < 0)) {
      return err(
        const ServiceError<SingleErrorTypes>(
          type: SingleErrorTypes.invalidInput,
          description: 'Macro targets cannot be negative',
        ),
      );
    }

    final seenDays = <DayOfWeek>{};
    int totalDaysCount = 0;

    for (final dayInput in dayInputs) {
      if (dayInput.days.isEmpty) {
        return err(
          const ServiceError<SingleErrorTypes>(
            type: SingleErrorTypes.invalidInput,
            description: 'Each day configuration must have at least one day',
          ),
        );
      }
      if (dayInput.targetCalories < 0 ||
          dayInput.targetProtein < 0 ||
          dayInput.targetCarbs < 0 ||
          dayInput.targetFat < 0 ||
          (dayInput.targetFiber.value != null &&
              dayInput.targetFiber.value! < 0) ||
          (dayInput.targetSodium.value != null &&
              dayInput.targetSodium.value! < 0) ||
          (dayInput.targetWaterIntakeMl.value != null &&
              dayInput.targetWaterIntakeMl.value! < 0)) {
        return err(
          const ServiceError<SingleErrorTypes>(
            type: SingleErrorTypes.invalidInput,
            description: 'Macro targets cannot be negative',
          ),
        );
      }
      totalDaysCount += dayInput.days.length;
      seenDays.addAll(dayInput.days);
    }

    if (totalDaysCount != 7 || seenDays.length != 7) {
      return err(
        const ServiceError<SingleErrorTypes>(
          type: SingleErrorTypes.invalidInput,
          description: 'Day macro goals must cover all 7 days of the week without duplicates',
        ),
      );
    }

    return ok(dayInputs);
  }

  ({
    int calories,
    int protein,
    int carbs,
    int fat,
    int? fiber,
    int? sodium,
    int? water,
  })
  _computeWeeklyTotals(List<DayMacroGoalInput> dayInputs) {
    int totalCalories = 0;
    int totalProtein = 0;
    int totalCarbs = 0;
    int totalFat = 0;
    int totalFiber = 0;
    bool hasFiber = false;
    int totalSodium = 0;
    bool hasSodium = false;
    int totalWater = 0;
    bool hasWater = false;

    for (final d in dayInputs) {
      final count = d.days.length;
      totalCalories += d.targetCalories * count;
      totalProtein += d.targetProtein * count;
      totalCarbs += d.targetCarbs * count;
      totalFat += d.targetFat * count;
      if (d.targetFiber.value != null) {
        hasFiber = true;
        totalFiber += d.targetFiber.value! * count;
      }
      if (d.targetSodium.value != null) {
        hasSodium = true;
        totalSodium += d.targetSodium.value! * count;
      }
      if (d.targetWaterIntakeMl.value != null) {
        hasWater = true;
        totalWater += d.targetWaterIntakeMl.value! * count;
      }
    }

    return (
      calories: totalCalories,
      protein: totalProtein,
      carbs: totalCarbs,
      fat: totalFat,
      fiber: hasFiber ? totalFiber : null,
      sodium: hasSodium ? totalSodium : null,
      water: hasWater ? totalWater : null,
    );
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>>
  _deactivateActiveMacroGoals(Transaction txn, {int? excludeWeekId}) async {
    const failure = ServiceError(
      type: SingleErrorTypes.operationFailure,
      description: 'Failed to deactivate active macro goals',
    );
    try {
      final now = DateUtilities.getNowUtcUnix();
      final weekWhere = WhereBuilder()
        ..and(WeekMacroGoalColumns.isActive.equal, 1);
      final dayWhere = WhereBuilder()
        ..and(DayMacroGoalColumns.isActive.equal, 1);
      if (excludeWeekId != null) {
        weekWhere.and(WeekMacroGoalColumns.id.notEqual, excludeWeekId);
        dayWhere.and(
          DayMacroGoalColumns.weekMacroGoalId.notEqual,
          excludeWeekId,
        );
      }

      await txn.update(
        WeekMacroGoal.table,
        {
          WeekMacroGoalColumns.isActive.value: 0,
          WeekMacroGoalColumns.updatedAt.value: now,
        },
        where: weekWhere.where,
        whereArgs: weekWhere.args,
      );
      await txn.update(
        DayMacroGoal.table,
        {
          DayMacroGoalColumns.isActive.value: 0,
          DayMacroGoalColumns.updatedAt.value: now,
        },
        where: dayWhere.where,
        whereArgs: dayWhere.args,
      );
      return ok(null);
    } catch (error, stackTrace) {
      _logger.severe(failure.description, error, stackTrace);
      return err(failure);
    }
  }

  Future<Result<List<DayMacroGoal>, ServiceError<SingleErrorTypes>>>
  _insertDayMacroGoals(
    Transaction txn,
    int weekId,
    WeekMacroGoalInput input,
    List<DayMacroGoalInput> dayInputs,
  ) async {
    const failure = ServiceError(
      type: SingleErrorTypes.operationFailure,
      description: 'Failed to save daily macro goals',
    );
    try {
      final createdDays = <DayMacroGoal>[];
      for (final d in dayInputs) {
        final dayModel = DayMacroGoal.create(
          weekMacroGoalId: weekId,
          days: d.days,
          name: d.name,
          targetCalories: d.targetCalories,
          targetProtein: d.targetProtein,
          targetCarbs: d.targetCarbs,
          targetFat: d.targetFat,
          targetFiber: d.targetFiber.value,
          targetSodium: d.targetSodium.value,
          targetWaterIntakeMl: d.targetWaterIntakeMl.value,
          phase: d.phase ?? input.phase,
          isActive: input.isActive,
        );
        final dayId = await _dayMacroGoalDao.insert(dayModel, txn);
        if (dayId <= 0) return err(failure);
        createdDays.add(dayModel.copyWith(id: Nullable(dayId)));
      }
      return ok(createdDays);
    } catch (error, stackTrace) {
      _logger.severe(failure.description, error, stackTrace);
      return err(failure);
    }
  }

  Future<Result<MacroGoalDto, ServiceError<SingleErrorTypes>>> createMacroGoal(
    WeekMacroGoalInput input,
  ) async {
    _logger.info('Creating macro goal: ${input.name}');
    try {
      final dayInputsResult = _resolveAndValidateDayInputs(input);
      if (dayInputsResult.isErr()) {
        return err(dayInputsResult.error);
      }

      final dayInputs = dayInputsResult.value;
      final totals = _computeWeeklyTotals(dayInputs);

      final weekGoal = WeekMacroGoal.create(
        name: input.name,
        totalTargetCalories: totals.calories,
        totalTargetProtein: totals.protein,
        totalTargetCarbs: totals.carbs,
        totalTargetFat: totals.fat,
        totalTargetFiber: totals.fiber,
        totalTargetSodium: totals.sodium,
        totalTargetWaterIntakeMl: totals.water,
        goalType: input.goalType,
        phase: input.phase,
        isActive: input.isActive,
      );

      final dto = await _weekMacroGoalDao.startTransaction<MacroGoalDto>((
        txn,
      ) async {
        if (input.isActive) {
          final deactivation = await _deactivateActiveMacroGoals(txn);
          // A daily goal update can fail after the weekly goals were updated.
          if (deactivation.isErr()) throw deactivation.error;
        }

        final weekId = await _weekMacroGoalDao.insert(weekGoal, txn);
        final daysResult = await _insertDayMacroGoals(
          txn,
          weekId,
          input,
          dayInputs,
        );
        // Roll back the parent write and any changes to existing goals.
        if (daysResult.isErr()) throw daysResult.error;

        return MacroGoalDto.fromWeekModel(
          weekGoal.copyWith(id: Nullable(weekId)),
          daysResult.value,
        );
      });

      _logger.info('Created macro goal with id: ${dto.id}');
      return ok(dto);
    } on ServiceError<SingleErrorTypes> catch (error) {
      return err(error);
    } catch (e) {
      _logger.severe('Failed to create macro goal', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to create macro goal',
        ),
      );
    }
  }

  Future<Result<MacroGoalDto, ServiceError<SingleErrorTypes>>> updateMacroGoal(
    int id,
    WeekMacroGoalInput input,
  ) async {
    _logger.info('Updating macro goal: $id');
    try {
      final existing = await _weekMacroGoalDao.selectOne(id);
      if (existing == null) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Macro goal not found',
          ),
        );
      }

      final dayInputsResult = _resolveAndValidateDayInputs(input);
      if (dayInputsResult.isErr()) {
        return err(dayInputsResult.error);
      }
      final dayInputs = dayInputsResult.value;
      final totals = _computeWeeklyTotals(dayInputs);

      return await _weekMacroGoalDao.startTransaction<
        Result<MacroGoalDto, ServiceError<SingleErrorTypes>>
      >((txn) async {
        if (input.isActive) {
          final deactivation = await _deactivateActiveMacroGoals(
            txn,
            excludeWeekId: id,
          );
          // A daily goal update can fail after the weekly goals were updated.
          if (deactivation.isErr()) throw deactivation.error;
        }

        final updated = existing.copyWith(
          name: Nullable(input.name),
          totalTargetCalories: totals.calories,
          totalTargetProtein: totals.protein,
          totalTargetCarbs: totals.carbs,
          totalTargetFat: totals.fat,
          totalTargetFiber: Nullable(totals.fiber),
          totalTargetSodium: Nullable(totals.sodium),
          totalTargetWaterIntakeMl: Nullable(totals.water),
          goalType: input.goalType,
          phase: input.phase,
          isActive: input.isActive,
          updatedAt: DateUtilities.getNowUtcUnix(),
        );

        await _weekMacroGoalDao.update(updated, txn);
        await _dayMacroGoalDao.deleteMany(
          where: DayMacroGoalColumns.weekMacroGoalId.equal,
          whereArgs: [id],
          trx: txn,
        );

        final daysResult = await _insertDayMacroGoals(
          txn,
          id,
          input,
          dayInputs,
        );
        // Roll back the parent write and any changes to existing goals.
        if (daysResult.isErr()) throw daysResult.error;

        return ok(MacroGoalDto.fromWeekModel(updated, daysResult.value));
      });
    } on ServiceError<SingleErrorTypes> catch (error) {
      return err(error);
    } catch (e) {
      _logger.severe('Failed to update macro goal with id $id', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to update macro goal',
        ),
      );
    }
  }

  Future<Result<MacroGoalDto, ServiceError<SingleErrorTypes>>>
  completeMacroGoal(int id) async {
    _logger.info('Completing macro goal: $id');
    try {
      final existing = await _weekMacroGoalDao.selectOne(id);
      if (existing == null) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Macro goal not found',
          ),
        );
      }
      final now = DateUtilities.getNowUtcUnix();
      final updated = existing.copyWith(isActive: false, updatedAt: now);
      return await _weekMacroGoalDao.startTransaction<
        Result<MacroGoalDto, ServiceError<SingleErrorTypes>>
      >((txn) async {
        final dayGoals = await _dayMacroGoalDao.selectMany(
          where: DayMacroGoalColumns.weekMacroGoalId.equal,
          whereArgs: [id],
          orderBy: [DayMacroGoalColumns.id.orderAsc],
          trx: txn,
        );
        await _weekMacroGoalDao.update(updated, txn);
        if (dayGoals.isNotEmpty) {
          await txn.update(
            DayMacroGoal.table,
            {
              DayMacroGoalColumns.isActive.value: 0,
              DayMacroGoalColumns.updatedAt.value: now,
            },
            where: DayMacroGoalColumns.weekMacroGoalId.equal,
            whereArgs: [id],
          );
        }
        final updatedDayGoals = dayGoals
            .map((dayGoal) => dayGoal.copyWith(isActive: false, updatedAt: now))
            .toList();
        return ok(MacroGoalDto.fromWeekModel(updated, updatedDayGoals));
      });
    } catch (e) {
      _logger.severe('Failed to complete macro goal', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to complete macro goal',
        ),
      );
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>> deleteMacroGoal(
    int id,
  ) async {
    _logger.info('Deleting macro goal: $id');
    try {
      final deleted = await _weekMacroGoalDao.deleteOne(id);
      if (!deleted) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Macro goal not found',
          ),
        );
      }
      return ok(null);
    } catch (e) {
      _logger.severe('Failed to delete macro goal with id $id', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to delete macro goal',
        ),
      );
    }
  }

  Future<Result<MacroGoalDto, ServiceError<SingleErrorTypes>>>
  getActiveMacroGoal() async {
    _logger.info('Getting active macro goal');
    try {
      final goals = await _weekMacroGoalDao.selectMany(
        where: WeekMacroGoalColumns.isActive.equal,
        whereArgs: [1],
        orderBy: [WeekMacroGoalColumns.createdAt.orderDesc],
        limit: 1,
      );
      if (goals.isEmpty) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'No active macro goal found',
          ),
        );
      }
      final activeWeek = goals.first;
      final dayGoals = await _dayMacroGoalDao.selectMany(
        where: DayMacroGoalColumns.weekMacroGoalId.equal,
        whereArgs: [activeWeek.id],
        orderBy: [DayMacroGoalColumns.id.orderAsc],
      );
      return ok(MacroGoalDto.fromWeekModel(activeWeek, dayGoals));
    } catch (e) {
      _logger.severe('Failed to get active macro goal', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to get active macro goal',
        ),
      );
    }
  }

  Future<
    Result<
      PaginatedDto<MacroGoalDto, WeekMacroGoal>,
      ServiceError<OperationErrorTypes>
    >
  >
  getMacroGoals({
    int limit = kDefaultLimit,
    int offset = kDefaultOffset,
  }) async {
    _logger.info('Getting macro goals history');
    try {
      final pageResult = await fetchPaginatedWithTotal(
        failureType: OperationErrorTypes.operationFailure,
        dao: _weekMacroGoalDao,
        limit: limit,
        offset: offset,
        orderBy: [WeekMacroGoalColumns.createdAt.orderDesc],
      );
      if (pageResult.isErr()) return err(pageResult.error);
      final (goals, total) = pageResult.value;

      final dayGoalsByWeekId = <int, List<DayMacroGoal>>{};
      if (goals.isNotEmpty) {
        final weekIds = goals.map((g) => g.id!).toList();
        final allDayGoalsResult = await selectManyInChunks(
          failureType: OperationErrorTypes.operationFailure,
          dao: _dayMacroGoalDao,
          column: DayMacroGoalColumns.weekMacroGoalId,
          values: weekIds,
          orderBy: [DayMacroGoalColumns.id.orderAsc],
        );
        if (allDayGoalsResult.isErr()) return err(allDayGoalsResult.error);
        final allDayGoals = allDayGoalsResult.value;
        for (final dayGoal in allDayGoals) {
          dayGoalsByWeekId
              .putIfAbsent(dayGoal.weekMacroGoalId, () => <DayMacroGoal>[])
              .add(dayGoal);
        }
      }

      return ok(
        PaginatedDto<MacroGoalDto, WeekMacroGoal>(
          data: goals
              .map(
                (g) => MacroGoalDto.fromWeekModel(
                  g,
                  dayGoalsByWeekId[g.id] ?? const <DayMacroGoal>[],
                ),
              )
              .toList(),
          total: total,
          limit: limit,
          offset: offset,
        ),
      );
    } catch (e) {
      _logger.severe('Failed to get macro goals', e);
      return err(
        const ServiceError(
          type: OperationErrorTypes.operationFailure,
          description: 'Failed to get macro goals',
        ),
      );
    }
  }

  // ==================== DAILY LOGS & MEALS ====================

  Future<DailyNutritionLog?> _findDailyLog(
    int numericDate, [
    Transaction? txn,
  ]) async {
    final rows = await _dailyLogDao.selectMany(
      where: DailyNutritionLogColumns.date.equal,
      whereArgs: [numericDate],
      limit: 1,
      trx: txn,
    );
    return rows.firstOrNull;
  }

  Future<DailyNutritionLog> _getOrCreateDailyLogInternal(
    Transaction txn,
    int numericDate,
  ) async {
    final existing = await _findDailyLog(numericDate, txn);
    if (existing != null) {
      return existing;
    }

    final newLog = DailyNutritionLog.create(date: numericDate);
    final id = await _dailyLogDao.insert(newLog, txn);
    return newLog.copyWith(id: Nullable(id));
  }

  Future<FoodPortion?> _loadPortionForFood(int foodId, int portionId) async {
    final portionWhere = WhereBuilder()
      ..and(FoodPortionColumns.id.equal, portionId)
      ..and(FoodPortionColumns.foodId.equal, foodId);
    final rows = await _foodPortionDao.selectMany(
      where: portionWhere.where,
      whereArgs: portionWhere.args,
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Micronutrients? _scaleMicronutrients(Micronutrients? micros, num scale) {
    if (micros == null) {
      return null;
    }
    final Map<String, dynamic> scaledMap = {};
    for (final entry in micros.toMap().entries) {
      if (entry.value is num) {
        scaledMap[entry.key] = ((entry.value as num) * scale).round();
      }
    }
    return Micronutrients.fromMap(scaledMap);
  }

  Future<Result<Map<int, List<MealLogDto>>, ServiceError<E>>>
  _loadMealsByDailyLogIds<E extends ErrorTypes>(
    List<int> dailyLogIds,
    E failureType,
  ) async {
    if (dailyLogIds.isEmpty) {
      return ok(const {});
    }

    final mealRowsResult = await selectManyInChunks(
      failureType: failureType,
      dao: _mealLogDao,
      column: MealLogColumns.dailyLogId,
      values: dailyLogIds,
      orderBy: [MealLogColumns.logTime.orderAsc, MealLogColumns.id.orderAsc],
    );
    if (mealRowsResult.isErr()) return err(mealRowsResult.error);
    final mealRows = mealRowsResult.value;
    if (mealRows.isEmpty) {
      return ok(const {});
    }

    final mealIds = mealRows.map((m) => m.id!).toList();
    final itemRowsResult = await selectManyInChunks(
      failureType: failureType,
      dao: _mealLogItemDao,
      column: MealLogItemColumns.mealLogId,
      values: mealIds,
      orderBy: [
        MealLogItemColumns.createdAt.orderAsc,
        MealLogItemColumns.id.orderAsc,
      ],
    );
    if (itemRowsResult.isErr()) return err(itemRowsResult.error);
    final itemRows = itemRowsResult.value;

    final portionIds = itemRows
        .map((item) => item.portionId)
        .whereType<int>()
        .toSet()
        .toList();
    final portionNamesById = <int, String>{};
    if (portionIds.isNotEmpty) {
      final portionsResult = await selectManyInChunks(
        failureType: failureType,
        dao: _foodPortionDao,
        column: FoodPortionColumns.id,
        values: portionIds,
      );
      if (portionsResult.isErr()) return err(portionsResult.error);
      final portions = portionsResult.value;
      for (final portion in portions) {
        portionNamesById[portion.id!] = portion.portionName;
      }
    }

    final itemsByMealId = <int, List<MealLogItemDto>>{};
    for (final item in itemRows) {
      final portionName = item.portionId != null
          ? portionNamesById[item.portionId!]
          : null;
      itemsByMealId
          .putIfAbsent(item.mealLogId, () => <MealLogItemDto>[])
          .add(MealLogItemDto.fromModel(item, portionName: portionName));
    }

    final mealsByDailyLogId = <int, List<MealLogDto>>{};
    for (final meal in mealRows) {
      mealsByDailyLogId
          .putIfAbsent(meal.dailyLogId, () => <MealLogDto>[])
          .add(
            MealLogDto.fromModel(
              meal,
              items: itemsByMealId[meal.id!] ?? const <MealLogItemDto>[],
            ),
          );
    }

    return ok(mealsByDailyLogId);
  }

  Future<Result<DailyNutritionLogDto, ServiceError<SingleErrorTypes>>>
  getDailyLogByDate(DateTime localDate) async {
    final numericDate = DateUtilities.getNumericDate(localDate);
    _logger.info('Getting daily log for date $numericDate');
    try {
      final dailyLog =
          await _findDailyLog(numericDate) ??
          await _dailyLogDao.startTransaction<DailyNutritionLog>(
            (txn) => _getOrCreateDailyLogInternal(txn, numericDate),
          );
      final mealsResult = await _loadMealsByDailyLogIds([
        dailyLog.id!,
      ], SingleErrorTypes.operationFailure);
      if (mealsResult.isErr()) return err(mealsResult.error);
      final meals = mealsResult.value[dailyLog.id!] ?? const <MealLogDto>[];
      return ok(DailyNutritionLogDto.fromModel(dailyLog, meals: meals));
    } catch (e) {
      _logger.severe('Failed to get daily log for date $numericDate', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to get daily nutrition log',
        ),
      );
    }
  }

  Future<Result<List<DailyNutritionLogDto>, ServiceError<OperationErrorTypes>>>
  getDailyLogsForRange({required DateTime start, required DateTime end}) async {
    final startNum = DateUtilities.getNumericDate(start);
    final endNum = DateUtilities.getNumericDate(end);
    _logger.info('Getting daily logs for range $startNum to $endNum');
    try {
      final rangeWhere = WhereBuilder()
        ..and(DailyNutritionLogColumns.date.greaterThanOrEqual, startNum)
        ..and(DailyNutritionLogColumns.date.lessThanOrEqual, endNum);
      final logRows = await _dailyLogDao.selectMany(
        where: rangeWhere.where,
        whereArgs: rangeWhere.args,
        orderBy: [DailyNutritionLogColumns.date.orderAsc],
      );
      if (logRows.isEmpty) {
        return ok(const []);
      }

      final mealsResult = await _loadMealsByDailyLogIds(
        logRows.map((row) => row.id!).toList(),
        OperationErrorTypes.operationFailure,
      );
      if (mealsResult.isErr()) return err(mealsResult.error);
      final mealsByDailyLogId = mealsResult.value;
      final logs = logRows
          .map(
            (row) => DailyNutritionLogDto.fromModel(
              row,
              meals: mealsByDailyLogId[row.id!] ?? const <MealLogDto>[],
            ),
          )
          .toList();

      return ok(logs);
    } catch (e) {
      _logger.severe('Failed to get daily logs for range', e);
      return err(
        const ServiceError(
          type: OperationErrorTypes.operationFailure,
          description: 'Failed to get daily logs',
        ),
      );
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
      final updated = await _dailyLogDao.startTransaction((txn) async {
        final existing = await _findDailyLog(numericDate, txn);
        if (existing == null) {
          final newLog = DailyNutritionLog.create(
            date: numericDate,
            waterIntakeMl: waterIntakeMl,
          );
          final id = await _dailyLogDao.insert(newLog, txn);
          return newLog.copyWith(id: Nullable(id));
        }

        final updated = existing.copyWith(
          waterIntakeMl: waterIntakeMl,
          updatedAt: DateUtilities.getNowUtcUnix(),
        );
        await _dailyLogDao.update(updated, txn);
        return updated;
      });
      final mealsResult = await _loadMealsByDailyLogIds([
        updated.id!,
      ], SingleErrorTypes.operationFailure);
      if (mealsResult.isErr()) return err(mealsResult.error);
      final meals = mealsResult.value[updated.id!] ?? const <MealLogDto>[];
      return ok(DailyNutritionLogDto.fromModel(updated, meals: meals));
    } catch (e) {
      _logger.severe('Failed to update water intake', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to update water intake',
        ),
      );
    }
  }

  Future<Result<MealLogDto, ServiceError<SingleErrorTypes>>> logFoodItem({
    DateTime? logTime,
    required MealType mealType,
    required int foodId,
    int? portionId,
    required int amount,
  }) async {
    final effectiveTime = (logTime ?? DateTime.now()).toLocal();
    final logUnix = DateUtilities.getDateUnix(effectiveTime);
    final numericDate = DateUtilities.getNumericDate(effectiveTime);

    _logger.info('Logging food $foodId for meal $mealType at $numericDate');
    try {
      final foodFuture = _foodDao.selectOne(foodId);
      final portionFuture = portionId != null
          ? _loadPortionForFood(foodId, portionId)
          : Future<FoodPortion?>.value(null);
      final (food, portion) = await (foodFuture, portionFuture).wait;

      if (food == null) {
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Food with id $foodId not found',
          ),
        );
      }

      double effectiveGrams = amount.toDouble();
      String? portionName;
      if (portionId != null) {
        if (portion == null) {
          return err(
            ServiceError(
              type: SingleErrorTypes.notFound,
              description:
                  'Portion with id $portionId not found for food $foodId',
            ),
          );
        }
        portionName = portion.portionName;
        effectiveGrams = (amount * portion.gramWeight).toDouble();
      }

      final double scale = food.servingSizeBaseGrams > 0
          ? effectiveGrams / food.servingSizeBaseGrams
          : 1.0;

      final int itemCals = (food.caloriesBase * scale).round();
      final int itemProtein = (food.proteinBase * scale).round();
      final int itemCarbs = (food.carbsBase * scale).round();
      final int itemFat = (food.fatBase * scale).round();
      final Micronutrients? itemMicros = _scaleMicronutrients(
        food.micros,
        scale,
      );

      return await _dailyLogDao.startTransaction<
        Result<MealLogDto, ServiceError<SingleErrorTypes>>
      >((txn) async {
        final dailyLog = await _getOrCreateDailyLogInternal(txn, numericDate);

        // Each submission retains its own time and nutrition snapshot.
        final newMeal = MealLog.create(
          dailyLogId: dailyLog.id!,
          mealType: mealType,
          logTime: logUnix,
          totalCalories: itemCals,
          totalProtein: itemProtein,
          totalCarbs: itemCarbs,
          totalFat: itemFat,
        );
        final mealLogId = await _mealLogDao.insert(newMeal, txn);
        final savedMeal = newMeal.copyWith(id: Nullable(mealLogId));

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
        final itemId = await _mealLogItemDao.insert(logItem, txn);

        return ok(
          MealLogDto.fromModel(
            savedMeal,
            items: [
              MealLogItemDto.fromModel(
                logItem.copyWith(id: Nullable(itemId)),
                portionName: portionName,
              ),
            ],
          ),
        );
      });
    } catch (e) {
      _logger.severe('Failed to log food item', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to log food item',
        ),
      );
    }
  }

  Future<Result<MealLogDto, ServiceError<SingleErrorTypes>>> logQuickFood(
    QuickFoodLogInput input, {
    DateTime? logTime,
    MealType mealType = MealType.snack,
  }) async {
    if (input.name.trim().isEmpty ||
        input.calories < 0 ||
        input.protein < 0 ||
        input.carbs < 0 ||
        input.fat < 0) {
      return err(
        const ServiceError(
          type: SingleErrorTypes.invalidInput,
          description: 'Enter a name and non-negative nutrition totals.',
        ),
      );
    }
    final time = (logTime ?? DateTime.now()).toLocal();
    try {
      return await _dailyLogDao.startTransaction<
        Result<MealLogDto, ServiceError<SingleErrorTypes>>
      >((txn) async {
        final dailyLog = await _getOrCreateDailyLogInternal(
          txn,
          DateUtilities.getNumericDate(time),
        );
        final meal = MealLog.create(
          dailyLogId: dailyLog.id!,
          mealType: mealType,
          logTime: DateUtilities.getDateUnix(time),
          totalCalories: input.calories,
          totalProtein: input.protein,
          totalCarbs: input.carbs,
          totalFat: input.fat,
        );
        final mealId = await _mealLogDao.insert(meal, txn);
        final item = MealLogItem.create(
          mealLogId: mealId,
          amount: 1,
          loggedFoodName: input.name.trim(),
          loggedCalories: input.calories,
          loggedProtein: input.protein,
          loggedCarbs: input.carbs,
          loggedFat: input.fat,
        );
        final itemId = await _mealLogItemDao.insert(item, txn);
        return ok(
          MealLogDto.fromModel(
            meal.copyWith(id: Nullable(mealId)),
            items: [
              MealLogItemDto.fromModel(item.copyWith(id: Nullable(itemId))),
            ],
          ),
        );
      });
    } catch (e) {
      _logger.severe('Failed to quick add food', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to save this diary entry.',
        ),
      );
    }
  }

  Future<Result<MealLogDto, ServiceError<SingleErrorTypes>>> logRecipe({
    DateTime? logTime,
    required MealType mealType,
    required int recipeId,
    int servings = 1,
  }) async {
    final effectiveTime = (logTime ?? DateTime.now()).toLocal();
    final logUnix = DateUtilities.getDateUnix(effectiveTime);
    final numericDate = DateUtilities.getNumericDate(effectiveTime);
    final actualServings = servings < 1 ? 1 : servings;

    _logger.info('Logging recipe $recipeId for meal $mealType');
    try {
      final recipe = await _recipeDao.selectOne(recipeId);
      if (recipe == null) {
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Recipe with id $recipeId not found',
          ),
        );
      }

      final itemCals = recipe.servingCalories * actualServings;
      final itemProtein = recipe.servingProtein * actualServings;
      final itemCarbs = recipe.servingCarbs * actualServings;
      final itemFat = recipe.servingFat * actualServings;
      final itemMicros = _scaleMicronutrients(
        recipe.servingMicros,
        actualServings,
      );

      return await _dailyLogDao.startTransaction<
        Result<MealLogDto, ServiceError<SingleErrorTypes>>
      >((txn) async {
        final dailyLog = await _getOrCreateDailyLogInternal(txn, numericDate);

        final newMeal = MealLog.create(
          dailyLogId: dailyLog.id!,
          mealType: mealType,
          recipeId: recipeId,
          logTime: logUnix,
          totalCalories: itemCals,
          totalProtein: itemProtein,
          totalCarbs: itemCarbs,
          totalFat: itemFat,
        );
        final mealLogId = await _mealLogDao.insert(newMeal, txn);
        final savedMeal = newMeal.copyWith(id: Nullable(mealLogId));

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
        final itemId = await _mealLogItemDao.insert(logItem, txn);

        return ok(
          MealLogDto.fromModel(
            savedMeal,
            items: [
              MealLogItemDto.fromModel(logItem.copyWith(id: Nullable(itemId))),
            ],
          ),
        );
      });
    } catch (e) {
      _logger.severe('Failed to log recipe', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to log recipe',
        ),
      );
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>> deleteMealLog(
    int mealLogId,
  ) async {
    _logger.info('Deleting meal log: $mealLogId');
    try {
      final deleted = await _mealLogDao.deleteOne(mealLogId);
      if (!deleted) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Meal log not found',
          ),
        );
      }
      return ok(null);
    } catch (e) {
      _logger.severe('Failed to delete meal log with id $mealLogId', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to delete meal log',
        ),
      );
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>> deleteMealLogItem(
    int itemId,
  ) async {
    _logger.info('Deleting meal log item: $itemId');
    try {
      return await _dailyLogDao
          .startTransaction<Result<void, ServiceError<SingleErrorTypes>>>((
            txn,
          ) async {
            final item = await _mealLogItemDao.selectOne(itemId, txn);
            if (item == null) {
              return err(
                const ServiceError(
                  type: SingleErrorTypes.notFound,
                  description: 'Meal log item not found',
                ),
              );
            }

            final mealLogId = item.mealLogId;
            await _mealLogItemDao.deleteOne(itemId, txn);

            // Recompute meal log totals
            final remainingItems = await _mealLogItemDao.selectMany(
              where: MealLogItemColumns.mealLogId.equal,
              whereArgs: [mealLogId],
              trx: txn,
            );

            final mealLog = await _mealLogDao.selectOne(mealLogId, txn);
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
              await _mealLogDao.update(updatedMeal, txn);
            }

            return ok(null);
          });
    } catch (e) {
      _logger.severe('Failed to delete meal log item with id $itemId', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to delete meal log item',
        ),
      );
    }
  }
}
