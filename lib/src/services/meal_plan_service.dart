import '../models/food_portion_model.dart';
import '../models/recipe_model.dart';
import '../models/food_model.dart';
import 'inputs/meal_plan_input.dart';

import 'package:logging/logging.dart';

import '../common/nullable.dart';
import '../models/db.dart';
import '../models/enums.dart';
import '../models/meal_plan_day_model.dart';
import '../models/meal_plan_meal_item_model.dart';
import '../models/meal_plan_meal_model.dart';
import '../models/meal_plan_model.dart';
import '../models/meal_plan_week_model.dart';
import '../models/repository.dart';
import '../models/utilities.dart';
import 'common/errors.dart';
import 'common/result.dart';
import 'dtos/meal_plan_dto.dart';
import 'dtos/paginated_dto.dart';

class MealPlanService {
  MealPlanService._();

  static final MealPlanService _instance = MealPlanService._();

  factory MealPlanService() => _instance;

  final Repository<Food> _foodRepository = Repository<Food>(
    databaseHelper: DatabaseHelper(),
    tableName: Food.table,
    fromMap: Food.fromMap,
  );

  final Repository<Recipe> _recipeRepository = Repository<Recipe>(
    databaseHelper: DatabaseHelper(),
    tableName: Recipe.table,
    fromMap: Recipe.fromMap,
  );

  final Repository<FoodPortion> _foodPortionRepository =
      Repository<FoodPortion>(
        databaseHelper: DatabaseHelper(),
        tableName: FoodPortion.table,
        fromMap: FoodPortion.fromMap,
      );

  final Logger _logger = Logger('Meal Plan Service');

  final Repository<MealPlan> _mealPlanRepository = Repository<MealPlan>(
    databaseHelper: DatabaseHelper(),
    tableName: MealPlan.table,
    fromMap: MealPlan.fromMap,
  );

  final Repository<MealPlanWeek> _weekRepository = Repository<MealPlanWeek>(
    databaseHelper: DatabaseHelper(),
    tableName: MealPlanWeek.table,
    fromMap: MealPlanWeek.fromMap,
  );

  final Repository<MealPlanDay> _dayRepository = Repository<MealPlanDay>(
    databaseHelper: DatabaseHelper(),
    tableName: MealPlanDay.table,
    fromMap: MealPlanDay.fromMap,
  );

  final Repository<MealPlanMeal> _mealRepository = Repository<MealPlanMeal>(
    databaseHelper: DatabaseHelper(),
    tableName: MealPlanMeal.table,
    fromMap: MealPlanMeal.fromMap,
  );

  final Repository<MealPlanMealItem> _itemRepository =
      Repository<MealPlanMealItem>(
        databaseHelper: DatabaseHelper(),
        tableName: MealPlanMealItem.table,
        fromMap: MealPlanMealItem.fromMap,
      );

  Future<Result<MealPlanDto, ServiceError<SingleErrorTypes>>> createMealPlan(
    MealPlanInput input, [
    CreatedBy createdBy = CreatedBy.user,
  ]) async {
    final name = input.name;
    final description = input.description.value;
    final weeks = input.weeks;

    _logger.info('Creating meal plan: $name');
    try {
      return await _mealPlanRepository.startTransaction<
        Result<MealPlanDto, ServiceError<SingleErrorTypes>>
      >((txn) async {
        // Pre-validate all referenced foods, portions, recipes
        for (final w in weeks) {
          for (final d in w.days) {
            for (final m in d.meals) {
              if (m.recipeId != null) {
                final rRows = await _recipeRepository.selectMany(
                  where: '${RecipeColumns.id.value} = ?',
                  whereArgs: [m.recipeId],
                  limit: 1,
                  trx: txn,
                );
                if (rRows.isEmpty) {
                  throw ServiceError(
                    type: SingleErrorTypes.notFound,
                    description: 'Recipe ${m.recipeId} not found',
                  );
                }
              }
              for (final item in m.items) {
                final fRows = await _foodRepository.selectMany(
                  where: '${FoodColumns.id.value} = ?',
                  whereArgs: [item.foodId],
                  limit: 1,
                  trx: txn,
                );
                if (fRows.isEmpty) {
                  throw ServiceError(
                    type: SingleErrorTypes.notFound,
                    description: 'Food ${item.foodId} not found',
                  );
                }
                if (item.portionId != null) {
                  final pRows = await _foodPortionRepository.selectMany(
                    where:
                        '${FoodPortionColumns.id.value} = ? AND ${FoodPortionColumns.foodId.value} = ?',
                    whereArgs: [item.portionId, item.foodId],
                    limit: 1,
                    trx: txn,
                  );
                  if (pRows.isEmpty) {
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
        }

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
        final int planId = await _mealPlanRepository.insert(mealPlan, txn);

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
          final int weekId = await _weekRepository.insert(tempWeek, txn);

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
            final int dayId = await _dayRepository.insert(tempDay, txn);

            for (final mInput in dInput.meals) {
              int mealCalories = 0;
              int mealProtein = 0;
              int mealCarbs = 0;
              int mealFat = 0;
              int mealFiber = 0;
              String? recipeName;

              if (mInput.recipeId != null) {
                final rRows = await _recipeRepository.selectMany(
                  where: '${RecipeColumns.id.value} = ?',
                  whereArgs: [mInput.recipeId],
                  limit: 1,
                  trx: txn,
                );
                if (rRows.isNotEmpty) {
                  final r = rRows.first;
                  recipeName = r.name;
                  mealCalories += r.servingCalories;
                  mealProtein += r.servingProtein;
                  mealCarbs += r.servingCarbs;
                  mealFat += r.servingFat;
                }
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
              final int mealId = await _mealRepository.insert(tempMeal, txn);

              for (final itemInput in mInput.items) {
                final fRows = await _foodRepository.selectMany(
                  where: '${FoodColumns.id.value} = ?',
                  whereArgs: [itemInput.foodId],
                  limit: 1,
                  trx: txn,
                );
                final food = fRows.first;

                double effectiveGrams = itemInput.amount.toDouble();
                String? portionName;
                if (itemInput.portionId != null) {
                  final pRows = await _foodPortionRepository.selectMany(
                    where: '${FoodPortionColumns.id.value} = ?',
                    whereArgs: [itemInput.portionId],
                    limit: 1,
                    trx: txn,
                  );
                  if (pRows.isNotEmpty) {
                    final p = pRows.first;
                    portionName = p.portionName;
                    effectiveGrams = (itemInput.amount * p.gramWeight)
                        .toDouble();
                  }
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
                final int itemId = await _itemRepository.insert(mealItem, txn);
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
              await _mealRepository.update(updatedMeal, txn);
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
            await _dayRepository.update(updatedDay, txn);
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
          await _weekRepository.update(updatedWeek, txn);
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
      final MealPlan? plan = await _mealPlanRepository.selectOne(id);
      if (plan == null) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Meal plan not found',
          ),
        );
      }

      final targetVersion = version ?? plan.version;

      final weeks = await _weekRepository.selectMany(
        where:
            '${MealPlanWeekColumns.mealPlanId.value} = ? AND ${MealPlanWeekColumns.planVersion.value} = ?',
        whereArgs: [id, targetVersion],
        orderBy: [MealPlanWeekColumns.weekNumber.orderAsc],
      );

      final List<MealPlanWeekDto> weekDtos = [];

      for (final w in weeks) {
        final days = await _dayRepository.selectMany(
          where: '${MealPlanDayColumns.mealPlanWeekId.value} = ?',
          whereArgs: [w.id!],
          orderBy: [MealPlanDayColumns.day.orderAsc],
        );

        final List<MealPlanDayDto> dayDtos = [];
        for (final d in days) {
          final meals = await _mealRepository.selectMany(
            where: '${MealPlanMealColumns.mealPlanDayId.value} = ?',
            whereArgs: [d.id!],
            orderBy: [MealPlanMealColumns.position.orderAsc],
          );

          final List<MealPlanMealDto> mealDtos = [];
          for (final m in meals) {
            String? recipeName;
            if (m.recipeId != null) {
              final r = await _recipeRepository.selectMany(
                where: '${RecipeColumns.id.value} = ?',
                whereArgs: [m.recipeId],
                limit: 1,
              );
              if (r.isNotEmpty) {
                recipeName = r.first.name;
              }
            }

            final items = await _itemRepository.selectMany(
              where: '${MealPlanMealItemColumns.mealPlanMealId.value} = ?',
              whereArgs: [m.id!],
            );

            final List<MealPlanMealItemDto> itemDtos = [];
            for (final it in items) {
              final fRows = await _foodRepository.selectMany(
                where: '${FoodColumns.id.value} = ?',
                whereArgs: [it.foodId],
                limit: 1,
              );
              final foodName = fRows.isNotEmpty ? fRows.first.name : null;

              String? portionName;
              if (it.portionId != null) {
                final pRows = await _foodPortionRepository.selectMany(
                  where: '${FoodPortionColumns.id.value} = ?',
                  whereArgs: [it.portionId],
                  limit: 1,
                );
                portionName = pRows.isNotEmpty ? pRows.first.portionName : null;
              }

              itemDtos.add(
                MealPlanMealItemDto.fromModel(
                  it,
                  foodName: foodName,
                  portionName: portionName,
                ),
              );
            }

            mealDtos.add(
              MealPlanMealDto.fromModel(
                m,
                recipeName: recipeName,
                items: itemDtos,
              ),
            );
          }

          dayDtos.add(MealPlanDayDto.fromModel(d, meals: mealDtos));
        }

        weekDtos.add(MealPlanWeekDto.fromModel(w, days: dayDtos));
      }

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
        where.and('${MealPlanColumns.name.value} LIKE ?', '%${search.trim()}%');
      }
      if (isFavorite != null) {
        where.and(MealPlanColumns.isFavorite.equal, isFavorite ? 1 : 0);
      }

      final List<MealPlan> plans = await _mealPlanRepository.selectPaginated(
        where: where.where,
        whereArgs: where.args,
        limit: limit,
        offset: offset,
        orderBy: [MealPlanColumns.name.orderAsc],
      );
      final int total = await _mealPlanRepository.count(
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
      final MealPlan? existing = await _mealPlanRepository.selectOne(id);
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

      return await _mealPlanRepository.startTransaction<
        Result<MealPlanDto, ServiceError<SingleErrorTypes>>
      >((txn) async {
        // Pre-validate all referenced foods, portions, recipes
        for (final w in weeks) {
          for (final d in w.days) {
            for (final m in d.meals) {
              if (m.recipeId != null) {
                final rRows = await _recipeRepository.selectMany(
                  where: '${RecipeColumns.id.value} = ?',
                  whereArgs: [m.recipeId],
                  limit: 1,
                  trx: txn,
                );
                if (rRows.isEmpty) {
                  throw ServiceError(
                    type: SingleErrorTypes.notFound,
                    description: 'Recipe ${m.recipeId} not found',
                  );
                }
              }
              for (final item in m.items) {
                final fRows = await _foodRepository.selectMany(
                  where: '${FoodColumns.id.value} = ?',
                  whereArgs: [item.foodId],
                  limit: 1,
                  trx: txn,
                );
                if (fRows.isEmpty) {
                  throw ServiceError(
                    type: SingleErrorTypes.notFound,
                    description: 'Food ${item.foodId} not found',
                  );
                }
                if (item.portionId != null) {
                  final pRows = await _foodPortionRepository.selectMany(
                    where:
                        '${FoodPortionColumns.id.value} = ? AND ${FoodPortionColumns.foodId.value} = ?',
                    whereArgs: [item.portionId, item.foodId],
                    limit: 1,
                    trx: txn,
                  );
                  if (pRows.isEmpty) {
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
        }

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
          final int weekId = await _weekRepository.insert(tempWeek, txn);

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
            final int dayId = await _dayRepository.insert(tempDay, txn);

            for (final mInput in dInput.meals) {
              int mealCalories = 0;
              int mealProtein = 0;
              int mealCarbs = 0;
              int mealFat = 0;
              int mealFiber = 0;
              String? recipeName;

              if (mInput.recipeId != null) {
                final rRows = await _recipeRepository.selectMany(
                  where: '${RecipeColumns.id.value} = ?',
                  whereArgs: [mInput.recipeId],
                  limit: 1,
                  trx: txn,
                );
                if (rRows.isNotEmpty) {
                  final r = rRows.first;
                  recipeName = r.name;
                  mealCalories += r.servingCalories;
                  mealProtein += r.servingProtein;
                  mealCarbs += r.servingCarbs;
                  mealFat += r.servingFat;
                }
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
              final int mealId = await _mealRepository.insert(tempMeal, txn);

              for (final itemInput in mInput.items) {
                final fRows = await _foodRepository.selectMany(
                  where: '${FoodColumns.id.value} = ?',
                  whereArgs: [itemInput.foodId],
                  limit: 1,
                  trx: txn,
                );
                final food = fRows.first;

                double effectiveGrams = itemInput.amount.toDouble();
                String? portionName;
                if (itemInput.portionId != null) {
                  final pRows = await _foodPortionRepository.selectMany(
                    where: '${FoodPortionColumns.id.value} = ?',
                    whereArgs: [itemInput.portionId],
                    limit: 1,
                    trx: txn,
                  );
                  if (pRows.isNotEmpty) {
                    final p = pRows.first;
                    portionName = p.portionName;
                    effectiveGrams = (itemInput.amount * p.gramWeight)
                        .toDouble();
                  }
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
                final int itemId = await _itemRepository.insert(mealItem, txn);
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
              await _mealRepository.update(updatedMeal, txn);
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
            await _dayRepository.update(updatedDay, txn);
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
          await _weekRepository.update(updatedWeek, txn);
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

        await _mealPlanRepository.update(updated, txn);
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
      final MealPlan? plan = await _mealPlanRepository.selectOne(id);
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
      await _mealPlanRepository.update(updated);
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
      final MealPlan? plan = await _mealPlanRepository.selectOne(id);
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

      final deleted = await _mealPlanRepository.deleteOne(id);
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
