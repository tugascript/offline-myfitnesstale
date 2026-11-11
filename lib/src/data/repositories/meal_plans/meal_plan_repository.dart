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

import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';

import '../../../utils/errors.dart';
import '../../../utils/nullable.dart';
import '../../../utils/result.dart';
import '../../models/sqlite/food_model.dart';
import '../../models/sqlite/food_portion_model.dart';
import '../../models/sqlite/meal_plan_day_model.dart';
import '../../models/sqlite/meal_plan_meal_item_model.dart';
import '../../models/sqlite/meal_plan_meal_model.dart';
import '../../models/sqlite/meal_plan_model.dart';
import '../../models/sqlite/meal_plan_week_model.dart';
import '../../models/sqlite/recipe_model.dart';
import '../../services/common.dart';
import '../../services/sqlite/dao.dart';
import '../../services/sqlite/database_helper.dart';
import '../../utils/dates.dart';
import '../../utils/enums.dart';
import '../../utils/where_builder.dart';
import '../core/dtos/paginated_dto.dart';
import '../core/repository.dart';
import '../core/repository_helpers.dart';
import './dtos/meal_plan_dto.dart';
import './inputs/meal_plan_input.dart';
import './inputs/meal_plan_week_input.dart';

typedef _PreparedPlanItem = ({
  int foodId,
  int? portionId,
  int amount,
  int totalCalories,
  int totalProtein,
  int totalCarbs,
  int totalFat,
  int? totalFiber,
  String foodName,
  String? portionName,
});

typedef _PreparedPlanMeal = ({
  int position,
  String? timeOfDay,
  MealType mealType,
  String name,
  int? recipeId,
  String? recipeName,
  int totalCalories,
  int totalProtein,
  int totalCarbs,
  int totalFat,
  int totalFiber,
  List<_PreparedPlanItem> items,
});

typedef _PreparedPlanDay = ({
  int day,
  String? name,
  int targetCalories,
  int targetProtein,
  int targetCarbs,
  int targetFat,
  int targetFiber,
  List<_PreparedPlanMeal> meals,
});

typedef _PreparedPlanWeek = ({
  int weekNumber,
  MealPlanPhase phase,
  int targetCalories,
  int targetProtein,
  int targetCarbs,
  int targetFat,
  int targetFiber,
  int totalDays,
  int totalMeals,
  List<_PreparedPlanDay> days,
});

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
    Result<
      ({
        Map<int, Recipe> recipes,
        Map<int, Food> foods,
        Map<int, FoodPortion> portions,
      }),
      ServiceError<SingleErrorTypes>
    >
  >
  _loadMealPlanReferences(List<MealPlanWeekInput> weeks) async {
    try {
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

      final (recipesResult, foodsResult, portionsResult) = await (
        selectManyInChunks(
          failureType: SingleErrorTypes.operationFailure,
          dao: _recipeDao,
          column: RecipeColumns.id,
          values: recipeIds,
        ),
        selectManyInChunks(
          failureType: SingleErrorTypes.operationFailure,
          dao: _foodDao,
          column: FoodColumns.id,
          values: foodIds,
        ),
        selectManyInChunks(
          failureType: SingleErrorTypes.operationFailure,
          dao: _foodPortionDao,
          column: FoodPortionColumns.id,
          values: portionIds,
        ),
      ).wait;
      if (recipesResult.isErr()) return err(recipesResult.error);
      if (foodsResult.isErr()) return err(foodsResult.error);
      if (portionsResult.isErr()) return err(portionsResult.error);

      final recipes = recipesResult.value;
      final foods = foodsResult.value;
      final portions = portionsResult.value;
      final recipeById = {for (final recipe in recipes) recipe.id!: recipe};
      final foodById = {for (final food in foods) food.id!: food};
      final portionById = {
        for (final portion in portions) portion.id!: portion,
      };

      for (final recipeId in recipeIds) {
        if (!recipeById.containsKey(recipeId)) {
          return err(
            ServiceError(
              type: SingleErrorTypes.notFound,
              description: 'Recipe $recipeId not found',
            ),
          );
        }
      }
      for (final week in weeks) {
        for (final day in week.days) {
          for (final meal in day.meals) {
            for (final item in meal.items) {
              if (!foodById.containsKey(item.foodId)) {
                return err(
                  ServiceError(
                    type: SingleErrorTypes.notFound,
                    description: 'Food ${item.foodId} not found',
                  ),
                );
              }
              if (item.portionId != null &&
                  portionById[item.portionId]?.foodId != item.foodId) {
                return err(
                  ServiceError(
                    type: SingleErrorTypes.notFound,
                    description:
                        'Portion ${item.portionId} not found for food ${item.foodId}',
                  ),
                );
              }
            }
          }
        }
      }

      return ok((recipes: recipeById, foods: foodById, portions: portionById));
    } catch (e) {
      _logger.severe('Failed to load meal plan references', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to load meal plan references',
        ),
      );
    }
  }

  ({List<_PreparedPlanWeek> weeks, int totalDays, int totalMeals})
  _prepareMealPlanTree(
    List<MealPlanWeekInput> weeks,
    ({
      Map<int, Recipe> recipes,
      Map<int, Food> foods,
      Map<int, FoodPortion> portions,
    })
    references,
  ) {
    int planTotalDays = 0;
    int planTotalMeals = 0;
    final preparedWeeks = <_PreparedPlanWeek>[];

    for (final wInput in weeks) {
      int weekTotalMeals = 0;
      int weekTotalCalories = 0;
      int weekTotalProtein = 0;
      int weekTotalCarbs = 0;
      int weekTotalFat = 0;
      int weekTotalFiber = 0;
      final preparedDays = <_PreparedPlanDay>[];

      for (final dInput in wInput.days) {
        int dayTotalCalories = 0;
        int dayTotalProtein = 0;
        int dayTotalCarbs = 0;
        int dayTotalFat = 0;
        int dayTotalFiber = 0;
        final preparedMeals = <_PreparedPlanMeal>[];

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

          final preparedItems = <_PreparedPlanItem>[];
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

            preparedItems.add((
              foodId: itemInput.foodId,
              portionId: itemInput.portionId,
              amount: itemInput.amount,
              totalCalories: itemCals,
              totalProtein: itemProt,
              totalCarbs: itemCarbs,
              totalFat: itemFat,
              totalFiber: itemFiber,
              foodName: food.name,
              portionName: portionName,
            ));
          }

          preparedMeals.add((
            position: mInput.position,
            timeOfDay: mInput.timeOfDay,
            mealType: mInput.mealType,
            name: mInput.name,
            recipeId: mInput.recipeId,
            recipeName: recipeName,
            totalCalories: mealCalories,
            totalProtein: mealProtein,
            totalCarbs: mealCarbs,
            totalFat: mealFat,
            totalFiber: mealFiber,
            items: preparedItems,
          ));

          dayTotalCalories += mealCalories;
          dayTotalProtein += mealProtein;
          dayTotalCarbs += mealCarbs;
          dayTotalFat += mealFat;
          dayTotalFiber += mealFiber;
        }

        preparedDays.add((
          day: dInput.day,
          name: dInput.name,
          targetCalories: dayTotalCalories,
          targetProtein: dayTotalProtein,
          targetCarbs: dayTotalCarbs,
          targetFat: dayTotalFat,
          targetFiber: dayTotalFiber,
          meals: preparedMeals,
        ));

        weekTotalMeals += dInput.meals.length;
        weekTotalCalories += dayTotalCalories;
        weekTotalProtein += dayTotalProtein;
        weekTotalCarbs += dayTotalCarbs;
        weekTotalFat += dayTotalFat;
        weekTotalFiber += dayTotalFiber;
      }

      final dayCount = wInput.days.isNotEmpty ? wInput.days.length : 1;
      preparedWeeks.add((
        weekNumber: wInput.weekNumber,
        phase: wInput.phase,
        targetCalories: (weekTotalCalories / dayCount).round(),
        targetProtein: (weekTotalProtein / dayCount).round(),
        targetCarbs: (weekTotalCarbs / dayCount).round(),
        targetFat: (weekTotalFat / dayCount).round(),
        targetFiber: (weekTotalFiber / dayCount).round(),
        totalDays: wInput.days.length,
        totalMeals: weekTotalMeals,
        days: preparedDays,
      ));

      planTotalDays += wInput.days.length;
      planTotalMeals += weekTotalMeals;
    }

    return (
      weeks: preparedWeeks,
      totalDays: planTotalDays,
      totalMeals: planTotalMeals,
    );
  }

  Future<Result<List<MealPlanWeekDto>, ServiceError<SingleErrorTypes>>>
  _insertMealPlanTree({
    required Transaction txn,
    required int mealPlanId,
    required int planVersion,
    required CreatedBy createdBy,
    required List<_PreparedPlanWeek> preparedWeeks,
  }) async {
    const failure = ServiceError(
      type: SingleErrorTypes.operationFailure,
      description: 'Failed to save meal plan schedule',
    );
    try {
      final List<MealPlanWeekDto> weekDtos = [];

      for (final w in preparedWeeks) {
        final week = MealPlanWeek.create(
          mealPlanId: mealPlanId,
          planVersion: planVersion,
          weekNumber: w.weekNumber,
          phase: w.phase,
          targetCalories: w.targetCalories,
          targetProtein: w.targetProtein,
          targetCarbs: w.targetCarbs,
          targetFat: w.targetFat,
          targetFiber: w.targetFiber,
          totalDays: w.totalDays,
          totalMeals: w.totalMeals,
          createdBy: createdBy,
        );
        final int weekId = await _weekDao.insert(week, txn);
        if (weekId <= 0) return err(failure);
        final List<MealPlanDayDto> dayDtos = [];

        for (final d in w.days) {
          final day = MealPlanDay.create(
            mealPlanId: mealPlanId,
            mealPlanWeekId: weekId,
            planVersion: planVersion,
            day: d.day,
            name: d.name,
            targetCalories: d.targetCalories,
            targetProtein: d.targetProtein,
            targetCarbs: d.targetCarbs,
            targetFat: d.targetFat,
            targetFiber: d.targetFiber,
            totalMeals: d.meals.length,
            createdBy: createdBy,
          );
          final int dayId = await _dayDao.insert(day, txn);
          if (dayId <= 0) return err(failure);
          final List<MealPlanMealDto> mealDtos = [];

          for (final m in d.meals) {
            final meal = MealPlanMeal.create(
              mealPlanId: mealPlanId,
              mealPlanWeekId: weekId,
              mealPlanDayId: dayId,
              planVersion: planVersion,
              position: m.position,
              timeOfDay: m.timeOfDay,
              mealType: m.mealType,
              name: m.name,
              recipeId: m.recipeId,
              totalCalories: m.totalCalories,
              totalProtein: m.totalProtein,
              totalCarbs: m.totalCarbs,
              totalFat: m.totalFat,
              totalFiber: m.totalFiber,
              createdBy: createdBy,
            );
            final int mealId = await _mealDao.insert(meal, txn);
            if (mealId <= 0) return err(failure);
            final List<MealPlanMealItemDto> itemDtos = [];

            for (final item in m.items) {
              final mealItem = MealPlanMealItem.create(
                mealPlanMealId: mealId,
                foodId: item.foodId,
                portionId: item.portionId,
                amount: item.amount,
                totalCalories: item.totalCalories,
                totalProtein: item.totalProtein,
                totalCarbs: item.totalCarbs,
                totalFat: item.totalFat,
                totalFiber: item.totalFiber,
              );
              final int itemId = await _itemDao.insert(mealItem, txn);
              if (itemId <= 0) return err(failure);
              itemDtos.add(
                MealPlanMealItemDto.fromModel(
                  mealItem.copyWith(id: Nullable(itemId)),
                  foodName: item.foodName,
                  portionName: item.portionName,
                ),
              );
            }

            mealDtos.add(
              MealPlanMealDto.fromModel(
                meal.copyWith(id: Nullable(mealId)),
                recipeName: m.recipeName,
                items: itemDtos,
              ),
            );
          }

          dayDtos.add(
            MealPlanDayDto.fromModel(
              day.copyWith(id: Nullable(dayId)),
              meals: mealDtos,
            ),
          );
        }

        weekDtos.add(
          MealPlanWeekDto.fromModel(
            week.copyWith(id: Nullable(weekId)),
            days: dayDtos,
          ),
        );
      }

      return ok(weekDtos);
    } catch (error, stackTrace) {
      _logger.severe('Failed to save meal plan schedule', error, stackTrace);
      return err(failure);
    }
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
      final referencesResult = await _loadMealPlanReferences(weeks);
      if (referencesResult.isErr()) {
        return err(referencesResult.error);
      }
      final prepared = _prepareMealPlanTree(weeks, referencesResult.value);

      return await _mealPlanDao.startTransaction<
        Result<MealPlanDto, ServiceError<SingleErrorTypes>>
      >((txn) async {
        final mealPlan = MealPlan.create(
          name: name,
          description: description,
          version: 1,
          totalWeeks: weeks.length,
          totalDays: prepared.totalDays,
          totalMeals: prepared.totalMeals,
          createdBy: createdBy,
        );
        final int planId = await _mealPlanDao.insert(mealPlan, txn);

        final savedChildren = await _insertMealPlanTree(
          txn: txn,
          mealPlanId: planId,
          planVersion: 1,
          createdBy: createdBy,
          preparedWeeks: prepared.weeks,
        );
        // Throw inside the transaction to roll back earlier writes.
        if (savedChildren.isErr()) throw savedChildren.error;
        final weekDtos = savedChildren.value;

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
      if (weeks.isEmpty) {
        return ok(
          MealPlanDto.fromModel(
            plan.copyWith(
              version: targetVersion,
              totalWeeks: 0,
              totalDays: 0,
              totalMeals: 0,
            ),
            weeks: const [],
          ),
        );
      }

      final weekIds = weeks.map((week) => week.id!).toList();
      final daysResult = await selectManyInChunks(
        failureType: SingleErrorTypes.operationFailure,
        dao: _dayDao,
        column: MealPlanDayColumns.mealPlanWeekId,
        values: weekIds,
        orderBy: [MealPlanDayColumns.day.orderAsc],
      );
      if (daysResult.isErr()) return err(daysResult.error);
      final days = daysResult.value;

      final dayIds = days.map((day) => day.id!).toList();
      final mealsResult = await selectManyInChunks(
        failureType: SingleErrorTypes.operationFailure,
        dao: _mealDao,
        column: MealPlanMealColumns.mealPlanDayId,
        values: dayIds,
        orderBy: [MealPlanMealColumns.position.orderAsc],
      );
      if (mealsResult.isErr()) return err(mealsResult.error);
      final meals = mealsResult.value;

      final mealIds = meals.map((meal) => meal.id!).toList();
      final itemsResult = await selectManyInChunks(
        failureType: SingleErrorTypes.operationFailure,
        dao: _itemDao,
        column: MealPlanMealItemColumns.mealPlanMealId,
        values: mealIds,
      );
      if (itemsResult.isErr()) return err(itemsResult.error);
      final items = itemsResult.value;

      final recipeIds = meals
          .map((meal) => meal.recipeId)
          .whereType<int>()
          .toSet();
      final foodIds = items.map((item) => item.foodId).toSet();
      final portionIds = items
          .map((item) => item.portionId)
          .whereType<int>()
          .toSet();

      final (recipesResult, foodsResult, portionsResult) = await (
        selectManyInChunks(
          failureType: SingleErrorTypes.operationFailure,
          dao: _recipeDao,
          column: RecipeColumns.id,
          values: recipeIds,
        ),
        selectManyInChunks(
          failureType: SingleErrorTypes.operationFailure,
          dao: _foodDao,
          column: FoodColumns.id,
          values: foodIds,
        ),
        selectManyInChunks(
          failureType: SingleErrorTypes.operationFailure,
          dao: _foodPortionDao,
          column: FoodPortionColumns.id,
          values: portionIds,
        ),
      ).wait;
      if (recipesResult.isErr()) return err(recipesResult.error);
      if (foodsResult.isErr()) return err(foodsResult.error);
      if (portionsResult.isErr()) return err(portionsResult.error);
      final recipes = recipesResult.value;
      final foods = foodsResult.value;
      final portions = portionsResult.value;

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

      final pageResult = await fetchPaginatedWithTotal(
        failureType: OperationErrorTypes.operationFailure,
        dao: _mealPlanDao,
        limit: limit,
        offset: offset,
        where: where.where,
        whereArgs: where.args,
        orderBy: [MealPlanColumns.name.orderCaseInsensitiveAsc],
      );
      if (pageResult.isErr()) return err(pageResult.error);
      final (List<MealPlan> plans, int total) = pageResult.value;

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
      final referencesResult = await _loadMealPlanReferences(weeks);
      if (referencesResult.isErr()) {
        return err(referencesResult.error);
      }
      final prepared = _prepareMealPlanTree(weeks, referencesResult.value);

      return await _mealPlanDao.startTransaction<
        Result<MealPlanDto, ServiceError<SingleErrorTypes>>
      >((txn) async {
        final MealPlan? existing = await _mealPlanDao.selectOne(id, txn);
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

        final nextVersion = existing.version + 1;
        final savedChildren = await _insertMealPlanTree(
          txn: txn,
          mealPlanId: id,
          planVersion: nextVersion,
          createdBy: existing.createdBy,
          preparedWeeks: prepared.weeks,
        );
        // Throw inside the transaction to roll back earlier writes.
        if (savedChildren.isErr()) throw savedChildren.error;
        final weekDtos = savedChildren.value;

        final updated = existing.copyWith(
          name: name,
          version: nextVersion,
          description: input.description,
          totalWeeks: weeks.length,
          totalDays: prepared.totalDays,
          totalMeals: prepared.totalMeals,
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
      return await _mealPlanDao.startTransaction<
        Result<MealPlanDto, ServiceError<SingleErrorTypes>>
      >((txn) async {
        final MealPlan? plan = await _mealPlanDao.selectOne(id, txn);
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
        await _mealPlanDao.update(updated, txn);
        return ok(MealPlanDto.fromModel(updated));
      });
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
