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

import '../../models/sqlite/food_model.dart';
import '../../models/sqlite/food_portion_model.dart';
import '../../models/sqlite/meal_plan_day_model.dart';
import '../../models/sqlite/meal_plan_meal_item_model.dart';
import '../../models/sqlite/meal_plan_meal_model.dart';
import '../../models/sqlite/meal_plan_model.dart';
import '../../models/sqlite/meal_plan_week_model.dart';
import '../../models/sqlite/recipe_model.dart';
import '../../services/common.dart';
import '../../services/sqlite/database_helper.dart';
import '../../services/sqlite/dao.dart';
import '../../utils/dates.dart';
import '../../utils/enums.dart';
import '../../utils/where_builder.dart';
import '../../../utils/errors.dart';
import '../../../utils/nullable.dart';
import '../../../utils/result.dart';
import './dtos/meal_plan_dto.dart';
import '../core/dtos/paginated_dto.dart';
import './inputs/meal_plan_input.dart';
import './inputs/meal_plan_week_input.dart';
import '../core/repository.dart';

final class MealPlanRepository implements Repository {
  final Dao<Food> _foodDao;
  final Dao<Recipe> _recipeDao;
  final Dao<FoodPortion> _foodPortionDao;
  final Dao<MealPlan> _mealPlanDao;
  final Dao<MealPlanWeek> _weekDao;
  final Dao<MealPlanDay> _dayDao;
  final Dao<MealPlanMeal> _mealDao;
  final Dao<MealPlanMealItem> _itemDao;

  final Logger _logger = Logger('Meal Plan Repository');

  MealPlanRepository({
    required this._foodDao,
    required this._recipeDao,
    required this._foodPortionDao,
    required this._mealPlanDao,
    required this._weekDao,
    required this._dayDao,
    required this._mealDao,
    required this._itemDao,
  });

  factory MealPlanRepository.create([DatabaseHelper? databaseHelper]) {
    final helper = databaseHelper ?? DatabaseHelper();
    return MealPlanRepository(
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
      mealPlanDao: Dao<MealPlan>(
        databaseHelper: helper,
        tableName: MealPlan.table,
        fromMap: MealPlan.fromMap,
      ),
      weekDao: Dao<MealPlanWeek>(
        databaseHelper: helper,
        tableName: MealPlanWeek.table,
        fromMap: MealPlanWeek.fromMap,
      ),
      dayDao: Dao<MealPlanDay>(
        databaseHelper: helper,
        tableName: MealPlanDay.table,
        fromMap: MealPlanDay.fromMap,
      ),
      mealDao: Dao<MealPlanMeal>(
        databaseHelper: helper,
        tableName: MealPlanMeal.table,
        fromMap: MealPlanMeal.fromMap,
      ),
      itemDao: Dao<MealPlanMealItem>(
        databaseHelper: helper,
        tableName: MealPlanMealItem.table,
        fromMap: MealPlanMealItem.fromMap,
      ),
    );
  }

  Future<
    ({
      Map<int, Recipe> recipes,
      Map<int, Food> foods,
      Map<int, FoodPortion> portions,
    })
  >
  _loadMealPlanReferences(
    List<MealPlanWeekInput> weeks,
    Transaction txn,
  ) async {
    final recipeIds = <int>{};
    final foodIds = <int>{};
    final portionIds = <int>{};
    for (final week in weeks) {
      for (final day in week.days) {
        for (final meal in day.meals) {
          if (meal.recipeId != null) recipeIds.add(meal.recipeId!);
          for (final item in meal.items) {
            foodIds.add(item.foodId);
            if (item.portionId != null) portionIds.add(item.portionId!);
          }
        }
      }
    }

    final recipes = recipeIds.isEmpty
        ? <Recipe>[]
        : await _recipeDao.selectMany(
            where: RecipeColumns.id.inList(recipeIds.length),
            whereArgs: recipeIds.toList(),
            trx: txn,
          );
    final foods = foodIds.isEmpty
        ? <Food>[]
        : await _foodDao.selectMany(
            where: FoodColumns.id.inList(foodIds.length),
            whereArgs: foodIds.toList(),
            trx: txn,
          );
    final portions = portionIds.isEmpty
        ? <FoodPortion>[]
        : await _foodPortionDao.selectMany(
            where: FoodPortionColumns.id.inList(portionIds.length),
            whereArgs: portionIds.toList(),
            trx: txn,
          );
    final recipeById = {for (final recipe in recipes) recipe.id!: recipe};
    final foodById = {for (final food in foods) food.id!: food};
    final portionById = {for (final portion in portions) portion.id!: portion};

    for (final recipeId in recipeIds) {
      if (!recipeById.containsKey(recipeId)) {
        throw ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Recipe $recipeId not found',
        );
      }
    }
    for (final week in weeks) {
      for (final day in week.days) {
        for (final meal in day.meals) {
          for (final item in meal.items) {
            if (!foodById.containsKey(item.foodId)) {
              throw ServiceError(
                type: SingleErrorTypes.notFound,
                description: 'Food ${item.foodId} not found',
              );
            }
            if (item.portionId != null &&
                portionById[item.portionId]?.foodId != item.foodId) {
              throw ServiceError(
                type: SingleErrorTypes.notFound,
                description:
                    'Portion ${item.portionId} not found for food ${item.foodId}',
              );
            }
          }
        }
      }
    }

    return (recipes: recipeById, foods: foodById, portions: portionById);
  }

  Future<Result<MealPlanDto, ServiceError<SingleErrorTypes>>> createMealPlan(
    MealPlanInput input, [
    CreatedBy createdBy = CreatedBy.user,
  ]) async {
    final name = input.name;
    final description = input.description.value;
    final weeks = input.weeks;

    _logger.info('Creating meal plan: $name');
    try {
      return await _mealPlanDao.startTransaction<
        Result<MealPlanDto, ServiceError<SingleErrorTypes>>
      >((txn) async {
        final references = await _loadMealPlanReferences(weeks, txn);

        int planTotalMeals = 0;
        int planTotalDays = 0;
        for (final w in weeks) {
          planTotalDays += w.days.length;
          for (final d in w.days) {
            planTotalMeals += d.meals.length;
          }
        }

        final mealPlan = MealPlan.create(
          name: name,
          description: description,
          version: 1,
          totalWeeks: weeks.length,
          totalDays: planTotalDays,
          totalMeals: planTotalMeals,
          createdBy: createdBy,
        );
        final int planId = await _mealPlanDao.insert(mealPlan, txn);

        final List<MealPlanWeekDto> weekDtos = [];

        for (final wInput in weeks) {
          int weekTotalMeals = 0;
          int weekTotalCalories = 0;
          int weekTotalProtein = 0;
          int weekTotalCarbs = 0;
          int weekTotalFat = 0;
          int weekTotalFiber = 0;

          final List<MealPlanDayDto> dayDtos = [];

          // We will insert week after computing totals
          final tempWeek = MealPlanWeek.create(
            mealPlanId: planId,
            planVersion: 1,
            weekNumber: wInput.weekNumber,
            phase: wInput.phase,
            targetCalories: 0,
            targetProtein: 0,
            targetCarbs: 0,
            targetFat: 0,
            totalDays: wInput.days.length,
            totalMeals: 0,
            createdBy: createdBy,
          );
          final int weekId = await _weekDao.insert(tempWeek, txn);

          for (final dInput in wInput.days) {
            int dayTotalCalories = 0;
            int dayTotalProtein = 0;
            int dayTotalCarbs = 0;
            int dayTotalFat = 0;
            int dayTotalFiber = 0;

            final List<MealPlanMealDto> mealDtos = [];

            final tempDay = MealPlanDay.create(
              mealPlanId: planId,
              mealPlanWeekId: weekId,
              planVersion: 1,
              day: dInput.day,
              name: dInput.name,
              targetCalories: 0,
              targetProtein: 0,
              targetCarbs: 0,
              targetFat: 0,
              totalMeals: dInput.meals.length,
              createdBy: createdBy,
            );
            final int dayId = await _dayDao.insert(tempDay, txn);

            for (final mInput in dInput.meals) {
              int mealCalories = 0;
              int mealProtein = 0;
              int mealCarbs = 0;
              int mealFat = 0;
              int mealFiber = 0;
              String? recipeName;

              if (mInput.recipeId != null) {
                final recipe = references.recipes[mInput.recipeId];
                recipeName = recipe?.name;
                mealCalories += recipe?.servingCalories ?? 0;
                mealProtein += recipe?.servingProtein ?? 0;
                mealCarbs += recipe?.servingCarbs ?? 0;
                mealFat += recipe?.servingFat ?? 0;
              }

              final List<MealPlanMealItemDto> itemDtos = [];

              final tempMeal = MealPlanMeal.create(
                mealPlanId: planId,
                mealPlanWeekId: weekId,
                mealPlanDayId: dayId,
                planVersion: 1,
                position: mInput.position,
                timeOfDay: mInput.timeOfDay,
                mealType: mInput.mealType,
                name: mInput.name,
                recipeId: mInput.recipeId,
                totalCalories: 0,
                totalProtein: 0,
                totalCarbs: 0,
                totalFat: 0,
                createdBy: createdBy,
              );
              final int mealId = await _mealDao.insert(tempMeal, txn);

              for (final itemInput in mInput.items) {
                final food = references.foods[itemInput.foodId]!;

                double effectiveGrams = itemInput.amount.toDouble();
                String? portionName;
                if (itemInput.portionId != null) {
                  final portion = references.portions[itemInput.portionId]!;
                  portionName = portion.portionName;
                  effectiveGrams = (itemInput.amount * portion.gramWeight)
                      .toDouble();
                }

                final double scale = food.servingSizeBaseGrams > 0
                    ? effectiveGrams / food.servingSizeBaseGrams
                    : 1.0;

                final itemCals = (food.caloriesBase * scale).round();
                final itemProt = (food.proteinBase * scale).round();
                final itemCarbs = (food.carbsBase * scale).round();
                final itemFat = (food.fatBase * scale).round();
                final itemFiber = food.fiberBase != null
                    ? (food.fiberBase! * scale).round()
                    : null;

                mealCalories += itemCals;
                mealProtein += itemProt;
                mealCarbs += itemCarbs;
                mealFat += itemFat;
                if (itemFiber != null) {
                  mealFiber += itemFiber;
                }

                final mealItem = MealPlanMealItem.create(
                  mealPlanMealId: mealId,
                  foodId: itemInput.foodId,
                  portionId: itemInput.portionId,
                  amount: itemInput.amount,
                  totalCalories: itemCals,
                  totalProtein: itemProt,
                  totalCarbs: itemCarbs,
                  totalFat: itemFat,
                  totalFiber: itemFiber,
                );
                final int itemId = await _itemDao.insert(mealItem, txn);
                itemDtos.add(
                  MealPlanMealItemDto.fromModel(
                    mealItem.copyWith(id: Nullable(itemId)),
                    foodName: food.name,
                    portionName: portionName,
                  ),
                );
              }

              // Update Meal totals
              final updatedMeal = tempMeal.copyWith(
                id: Nullable(mealId),
                totalCalories: mealCalories,
                totalProtein: mealProtein,
                totalCarbs: mealCarbs,
                totalFat: mealFat,
                totalFiber: Nullable(mealFiber),
                updatedAt: DateUtilities.getNowUtcUnix(),
              );
              await _mealDao.update(updatedMeal, txn);
              mealDtos.add(
                MealPlanMealDto.fromModel(
                  updatedMeal,
                  recipeName: recipeName,
                  items: itemDtos,
                ),
              );

              dayTotalCalories += mealCalories;
              dayTotalProtein += mealProtein;
              dayTotalCarbs += mealCarbs;
              dayTotalFat += mealFat;
              dayTotalFiber += mealFiber;
            }

            // Update Day totals
            final updatedDay = tempDay.copyWith(
              id: Nullable(dayId),
              targetCalories: dayTotalCalories,
              targetProtein: dayTotalProtein,
              targetCarbs: dayTotalCarbs,
              targetFat: dayTotalFat,
              targetFiber: Nullable(dayTotalFiber),
              totalMeals: dInput.meals.length,
              updatedAt: DateUtilities.getNowUtcUnix(),
            );
            await _dayDao.update(updatedDay, txn);
            dayDtos.add(MealPlanDayDto.fromModel(updatedDay, meals: mealDtos));

            weekTotalMeals += dInput.meals.length;
            weekTotalCalories += dayTotalCalories;
            weekTotalProtein += dayTotalProtein;
            weekTotalCarbs += dayTotalCarbs;
            weekTotalFat += dayTotalFat;
            weekTotalFiber += dayTotalFiber;
          }

          final dayCount = wInput.days.isNotEmpty ? wInput.days.length : 1;
          final updatedWeek = tempWeek.copyWith(
            id: Nullable(weekId),
            targetCalories: (weekTotalCalories / dayCount).round(),
            targetProtein: (weekTotalProtein / dayCount).round(),
            targetCarbs: (weekTotalCarbs / dayCount).round(),
            targetFat: (weekTotalFat / dayCount).round(),
            targetFiber: Nullable((weekTotalFiber / dayCount).round()),
            totalDays: wInput.days.length,
            totalMeals: weekTotalMeals,
            updatedAt: DateUtilities.getNowUtcUnix(),
          );
          await _weekDao.update(updatedWeek, txn);
          weekDtos.add(MealPlanWeekDto.fromModel(updatedWeek, days: dayDtos));
        }

        final createdDto = MealPlanDto.fromModel(
          mealPlan.copyWith(id: Nullable(planId)),
          weeks: weekDtos,
        );
        _logger.info('Created meal plan with id $planId');
        return ok(createdDto);
      });
    } on ServiceError<SingleErrorTypes> catch (error) {
      return err(error);
    } catch (e) {
      _logger.severe('Failed to create meal plan', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to create meal plan',
        ),
      );
    }
  }

  Future<Result<MealPlanDto, ServiceError<SingleErrorTypes>>> getMealPlan(
    int id, {
    int? version,
  }) async {
    _logger.info('Getting meal plan with id $id');
    try {
      final MealPlan? plan = await _mealPlanDao.selectOne(id);
      if (plan == null) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Meal plan not found',
          ),
        );
      }

      final targetVersion = version ?? plan.version;

      final weeksWhere = WhereBuilder()
        ..and(MealPlanWeekColumns.mealPlanId.equal, id)
        ..and(MealPlanWeekColumns.planVersion.equal, targetVersion);
      final weeks = await _weekDao.selectMany(
        where: weeksWhere.where!,
        whereArgs: weeksWhere.args!,
        orderBy: [MealPlanWeekColumns.weekNumber.orderAsc],
      );

      final weekIds = weeks.map((week) => week.id!).toList();
      final days = weekIds.isEmpty
          ? <MealPlanDay>[]
          : await _dayDao.selectMany(
              where: MealPlanDayColumns.mealPlanWeekId.inList(weekIds.length),
              whereArgs: weekIds,
              orderBy: [MealPlanDayColumns.day.orderAsc],
            );
      final dayIds = days.map((day) => day.id!).toList();
      final meals = dayIds.isEmpty
          ? <MealPlanMeal>[]
          : await _mealDao.selectMany(
              where: MealPlanMealColumns.mealPlanDayId.inList(dayIds.length),
              whereArgs: dayIds,
              orderBy: [MealPlanMealColumns.position.orderAsc],
            );
      final mealIds = meals.map((meal) => meal.id!).toList();
      final items = mealIds.isEmpty
          ? <MealPlanMealItem>[]
          : await _itemDao.selectMany(
              where: MealPlanMealItemColumns.mealPlanMealId.inList(
                mealIds.length,
              ),
              whereArgs: mealIds,
            );

      final recipeIds = meals
          .map((meal) => meal.recipeId)
          .whereType<int>()
          .toSet()
          .toList();
      final recipes = recipeIds.isEmpty
          ? <Recipe>[]
          : await _recipeDao.selectMany(
              where: RecipeColumns.id.inList(recipeIds.length),
              whereArgs: recipeIds,
            );
      final foodIds = items.map((item) => item.foodId).toSet().toList();
      final foods = foodIds.isEmpty
          ? <Food>[]
          : await _foodDao.selectMany(
              where: FoodColumns.id.inList(foodIds.length),
              whereArgs: foodIds,
            );
      final portionIds = items
          .map((item) => item.portionId)
          .whereType<int>()
          .toSet()
          .toList();
      final portions = portionIds.isEmpty
          ? <FoodPortion>[]
          : await _foodPortionDao.selectMany(
              where: FoodPortionColumns.id.inList(portionIds.length),
              whereArgs: portionIds,
            );

      final recipeById = {for (final recipe in recipes) recipe.id!: recipe};
      final foodById = {for (final food in foods) food.id!: food};
      final portionById = {
        for (final portion in portions) portion.id!: portion,
      };
      final itemsByMealId = <int, List<MealPlanMealItem>>{};
      for (final item in items) {
        itemsByMealId.putIfAbsent(item.mealPlanMealId, () => []).add(item);
      }
      final mealsByDayId = <int, List<MealPlanMeal>>{};
      for (final meal in meals) {
        mealsByDayId.putIfAbsent(meal.mealPlanDayId, () => []).add(meal);
      }
      final daysByWeekId = <int, List<MealPlanDay>>{};
      for (final day in days) {
        daysByWeekId.putIfAbsent(day.mealPlanWeekId, () => []).add(day);
      }

      final weekDtos = weeks.map((week) {
        final dayDtos = (daysByWeekId[week.id] ?? const <MealPlanDay>[]).map((
          day,
        ) {
          final mealDtos = (mealsByDayId[day.id] ?? const <MealPlanMeal>[]).map(
            (meal) {
              final itemDtos =
                  (itemsByMealId[meal.id] ?? const <MealPlanMealItem>[]).map((
                    item,
                  ) {
                    return MealPlanMealItemDto.fromModel(
                      item,
                      foodName: foodById[item.foodId]?.name,
                      portionName: item.portionId == null
                          ? null
                          : portionById[item.portionId]?.portionName,
                    );
                  }).toList();
              return MealPlanMealDto.fromModel(
                meal,
                recipeName: recipeById[meal.recipeId]?.name,
                items: itemDtos,
              );
            },
          ).toList();
          return MealPlanDayDto.fromModel(day, meals: mealDtos);
        }).toList();
        return MealPlanWeekDto.fromModel(week, days: dayDtos);
      }).toList();

      return ok(
        MealPlanDto.fromModel(
          plan.copyWith(
            version: targetVersion,
            totalWeeks: weekDtos.length,
            totalDays: weekDtos.fold<int>(
              0,
              (total, week) => total + week.days.length,
            ),
            totalMeals: weekDtos.fold<int>(
              0,
              (total, week) =>
                  total +
                  week.days.fold<int>(
                    0,
                    (dayTotal, day) => dayTotal + day.meals.length,
                  ),
            ),
          ),
          weeks: weekDtos,
        ),
      );
    } on ServiceError<SingleErrorTypes> catch (error) {
      return err(error);
    } catch (e) {
      _logger.severe('Failed to get meal plan $id', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to get meal plan',
        ),
      );
    }
  }

  Future<
    Result<
      PaginatedDto<MealPlanDto, MealPlan>,
      ServiceError<OperationErrorTypes>
    >
  >
  getMealPlans({
    String? search,
    bool? isFavorite,
    int limit = kDefaultLimit,
    int offset = kDefaultOffset,
  }) async {
    _logger.info('Getting meal plans with search: $search');
    try {
      final where = WhereBuilder();
      if (search != null && search.trim().isNotEmpty) {
        where.and(MealPlanColumns.name.like, '%${search.trim()}%');
      }
      if (isFavorite != null) {
        where.and(MealPlanColumns.isFavorite.equal, isFavorite ? 1 : 0);
      }

      final List<MealPlan> plans = await _mealPlanDao.selectPaginated(
        where: where.where,
        whereArgs: where.args,
        limit: limit,
        offset: offset,
        orderBy: [MealPlanColumns.name.orderAsc],
      );
      final int total = await _mealPlanDao.count(
        where: where.where,
        whereArgs: where.args,
      );

      return ok(
        PaginatedDto<MealPlanDto, MealPlan>.mapData(
          data: plans,
          mapper: (p) => MealPlanDto.fromModel(p),
          total: total,
          limit: limit,
          offset: offset,
        ),
      );
    } catch (e) {
      _logger.severe('Failed to get meal plans', e);
      return err(
        const ServiceError(
          type: OperationErrorTypes.operationFailure,
          description: 'Failed to get meal plans',
        ),
      );
    }
  }

  Future<Result<MealPlanDto, ServiceError<SingleErrorTypes>>> updateMealPlan(
    int id,
    MealPlanInput input,
  ) async {
    final name = input.name;
    final weeks = input.weeks;

    _logger.info('Updating meal plan with id $id');
    try {
      final MealPlan? existing = await _mealPlanDao.selectOne(id);
      if (existing == null) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Meal plan not found',
          ),
        );
      }

      if (existing.createdBy == CreatedBy.system) {
        _logger.warning('Attempted to modify machine-authored meal plan $id');
        return err(
          const ServiceError(
            type: SingleErrorTypes.invalidInput,
            description: 'Cannot modify machine-authored meal plan',
          ),
        );
      }

      return await _mealPlanDao.startTransaction<
        Result<MealPlanDto, ServiceError<SingleErrorTypes>>
      >((txn) async {
        final references = await _loadMealPlanReferences(weeks, txn);

        final nextVersion = existing.version + 1;
        final List<MealPlanWeekDto> weekDtos = [];
        // Rebuild
        int planTotalMeals = 0;
        int planTotalDays = 0;
        final int planTotalWeeks = weeks.length;
        for (final w in weeks) {
          planTotalDays += w.days.length;
          for (final d in w.days) {
            planTotalMeals += d.meals.length;
          }
        }

        for (final wInput in weeks) {
          int weekTotalMeals = 0;
          int weekTotalCalories = 0;
          int weekTotalProtein = 0;
          int weekTotalCarbs = 0;
          int weekTotalFat = 0;
          int weekTotalFiber = 0;

          final List<MealPlanDayDto> dayDtos = [];

          final tempWeek = MealPlanWeek.create(
            mealPlanId: id,
            planVersion: nextVersion,
            weekNumber: wInput.weekNumber,
            phase: wInput.phase,
            targetCalories: 0,
            targetProtein: 0,
            targetCarbs: 0,
            targetFat: 0,
            totalDays: wInput.days.length,
            totalMeals: 0,
            createdBy: existing.createdBy,
          );
          final int weekId = await _weekDao.insert(tempWeek, txn);

          for (final dInput in wInput.days) {
            int dayTotalCalories = 0;
            int dayTotalProtein = 0;
            int dayTotalCarbs = 0;
            int dayTotalFat = 0;
            int dayTotalFiber = 0;

            final List<MealPlanMealDto> mealDtos = [];

            final tempDay = MealPlanDay.create(
              mealPlanId: id,
              mealPlanWeekId: weekId,
              planVersion: nextVersion,
              day: dInput.day,
              name: dInput.name,
              targetCalories: 0,
              targetProtein: 0,
              targetCarbs: 0,
              targetFat: 0,
              totalMeals: dInput.meals.length,
              createdBy: existing.createdBy,
            );
            final int dayId = await _dayDao.insert(tempDay, txn);

            for (final mInput in dInput.meals) {
              int mealCalories = 0;
              int mealProtein = 0;
              int mealCarbs = 0;
              int mealFat = 0;
              int mealFiber = 0;
              String? recipeName;

              if (mInput.recipeId != null) {
                final recipe = references.recipes[mInput.recipeId];
                recipeName = recipe?.name;
                mealCalories += recipe?.servingCalories ?? 0;
                mealProtein += recipe?.servingProtein ?? 0;
                mealCarbs += recipe?.servingCarbs ?? 0;
                mealFat += recipe?.servingFat ?? 0;
              }

              final List<MealPlanMealItemDto> itemDtos = [];

              final tempMeal = MealPlanMeal.create(
                mealPlanId: id,
                mealPlanWeekId: weekId,
                mealPlanDayId: dayId,
                planVersion: nextVersion,
                position: mInput.position,
                timeOfDay: mInput.timeOfDay,
                mealType: mInput.mealType,
                name: mInput.name,
                recipeId: mInput.recipeId,
                totalCalories: 0,
                totalProtein: 0,
                totalCarbs: 0,
                totalFat: 0,
                createdBy: existing.createdBy,
              );
              final int mealId = await _mealDao.insert(tempMeal, txn);

              for (final itemInput in mInput.items) {
                final food = references.foods[itemInput.foodId]!;

                double effectiveGrams = itemInput.amount.toDouble();
                String? portionName;
                if (itemInput.portionId != null) {
                  final portion = references.portions[itemInput.portionId]!;
                  portionName = portion.portionName;
                  effectiveGrams = (itemInput.amount * portion.gramWeight)
                      .toDouble();
                }

                final double scale = food.servingSizeBaseGrams > 0
                    ? effectiveGrams / food.servingSizeBaseGrams
                    : 1.0;

                final itemCals = (food.caloriesBase * scale).round();
                final itemProt = (food.proteinBase * scale).round();
                final itemCarbs = (food.carbsBase * scale).round();
                final itemFat = (food.fatBase * scale).round();
                final itemFiber = food.fiberBase != null
                    ? (food.fiberBase! * scale).round()
                    : null;

                mealCalories += itemCals;
                mealProtein += itemProt;
                mealCarbs += itemCarbs;
                mealFat += itemFat;
                if (itemFiber != null) {
                  mealFiber += itemFiber;
                }

                final mealItem = MealPlanMealItem.create(
                  mealPlanMealId: mealId,
                  foodId: itemInput.foodId,
                  portionId: itemInput.portionId,
                  amount: itemInput.amount,
                  totalCalories: itemCals,
                  totalProtein: itemProt,
                  totalCarbs: itemCarbs,
                  totalFat: itemFat,
                  totalFiber: itemFiber,
                );
                final int itemId = await _itemDao.insert(mealItem, txn);
                itemDtos.add(
                  MealPlanMealItemDto.fromModel(
                    mealItem.copyWith(id: Nullable(itemId)),
                    foodName: food.name,
                    portionName: portionName,
                  ),
                );
              }

              final updatedMeal = tempMeal.copyWith(
                id: Nullable(mealId),
                totalCalories: mealCalories,
                totalProtein: mealProtein,
                totalCarbs: mealCarbs,
                totalFat: mealFat,
                totalFiber: Nullable(mealFiber),
                updatedAt: DateUtilities.getNowUtcUnix(),
              );
              await _mealDao.update(updatedMeal, txn);
              mealDtos.add(
                MealPlanMealDto.fromModel(
                  updatedMeal,
                  recipeName: recipeName,
                  items: itemDtos,
                ),
              );

              dayTotalCalories += mealCalories;
              dayTotalProtein += mealProtein;
              dayTotalCarbs += mealCarbs;
              dayTotalFat += mealFat;
              dayTotalFiber += mealFiber;
            }

            final updatedDay = tempDay.copyWith(
              id: Nullable(dayId),
              targetCalories: dayTotalCalories,
              targetProtein: dayTotalProtein,
              targetCarbs: dayTotalCarbs,
              targetFat: dayTotalFat,
              targetFiber: Nullable(dayTotalFiber),
              totalMeals: dInput.meals.length,
              updatedAt: DateUtilities.getNowUtcUnix(),
            );
            await _dayDao.update(updatedDay, txn);
            dayDtos.add(MealPlanDayDto.fromModel(updatedDay, meals: mealDtos));

            weekTotalMeals += dInput.meals.length;
            weekTotalCalories += dayTotalCalories;
            weekTotalProtein += dayTotalProtein;
            weekTotalCarbs += dayTotalCarbs;
            weekTotalFat += dayTotalFat;
            weekTotalFiber += dayTotalFiber;
          }

          final dayCount = wInput.days.isNotEmpty ? wInput.days.length : 1;
          final updatedWeek = tempWeek.copyWith(
            id: Nullable(weekId),
            targetCalories: (weekTotalCalories / dayCount).round(),
            targetProtein: (weekTotalProtein / dayCount).round(),
            targetCarbs: (weekTotalCarbs / dayCount).round(),
            targetFat: (weekTotalFat / dayCount).round(),
            targetFiber: Nullable((weekTotalFiber / dayCount).round()),
            totalDays: wInput.days.length,
            totalMeals: weekTotalMeals,
            updatedAt: DateUtilities.getNowUtcUnix(),
          );
          await _weekDao.update(updatedWeek, txn);
          weekDtos.add(MealPlanWeekDto.fromModel(updatedWeek, days: dayDtos));
        }

        final updated = existing.copyWith(
          name: name,
          version: nextVersion,
          description: input.description,
          totalWeeks: planTotalWeeks,
          totalDays: planTotalDays,
          totalMeals: planTotalMeals,
          updatedAt: DateUtilities.getNowUtcUnix(),
        );

        await _mealPlanDao.update(updated, txn);
        _logger.info('Updated meal plan with id $id');
        return ok(MealPlanDto.fromModel(updated, weeks: weekDtos));
      });
    } on ServiceError<SingleErrorTypes> catch (error) {
      return err(error);
    } catch (e) {
      _logger.severe('Failed to update meal plan with id $id', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to update meal plan',
        ),
      );
    }
  }

  Future<Result<MealPlanDto, ServiceError<SingleErrorTypes>>> toggleFavorite(
    int id,
  ) async {
    _logger.info('Toggling favorite for meal plan with id $id');
    try {
      final MealPlan? plan = await _mealPlanDao.selectOne(id);
      if (plan == null) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Meal plan not found',
          ),
        );
      }

      final updated = plan.copyWith(
        isFavorite: !plan.isFavorite,
        updatedAt: DateUtilities.getNowUtcUnix(),
      );
      await _mealPlanDao.update(updated);
      return ok(MealPlanDto.fromModel(updated));
    } on ServiceError<SingleErrorTypes> catch (error) {
      return err(error);
    } catch (e) {
      _logger.severe('Failed to toggle favorite for meal plan $id', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to toggle favorite',
        ),
      );
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>> deleteMealPlan(
    int id,
  ) async {
    _logger.info('Deleting meal plan with id $id');
    try {
      final MealPlan? plan = await _mealPlanDao.selectOne(id);
      if (plan == null) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Meal plan not found',
          ),
        );
      }

      if (plan.createdBy == CreatedBy.system) {
        _logger.warning('Attempted to delete machine-authored meal plan $id');
        return err(
          const ServiceError(
            type: SingleErrorTypes.invalidInput,
            description: 'Cannot delete machine-authored meal plan',
          ),
        );
      }

      final deleted = await _mealPlanDao.deleteOne(id);
      if (!deleted) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Meal plan not found',
          ),
        );
      }

      _logger.info('Deleted meal plan with id $id');
      return ok(null);
    } on ServiceError<SingleErrorTypes> catch (error) {
      return err(error);
    } catch (e) {
      _logger.severe('Failed to delete meal plan with id $id', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to delete meal plan',
        ),
      );
    }
  }
}
