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
import '../../models/sqlite/recipe_item_model.dart';
import '../../models/sqlite/recipe_model.dart';
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
import './dtos/recipe_dto.dart';
import './inputs/recipe_input.dart';
import './inputs/recipe_item_input.dart';

final class RecipeRepository implements Repository {
  final Dao<Recipe> _recipeDao;
  final Dao<RecipeItem> _itemDao;
  final Dao<Food> _foodDao;
  final Dao<FoodPortion> _portionDao;

  final Logger _logger = Logger('Recipe Repository');

  RecipeRepository({
    required this._recipeDao,
    required this._itemDao,
    required this._foodDao,
    required this._portionDao,
  });

  factory RecipeRepository.create([DatabaseHelper? databaseHelper]) {
    final helper = databaseHelper ?? DatabaseHelper();
    return RecipeRepository(
      recipeDao: Dao<Recipe>(
        databaseHelper: helper,
        tableName: Recipe.table,
        fromMap: Recipe.fromMap,
      ),
      itemDao: Dao<RecipeItem>(
        databaseHelper: helper,
        tableName: RecipeItem.table,
        fromMap: RecipeItem.fromMap,
      ),
      foodDao: Dao<Food>(
        databaseHelper: helper,
        tableName: Food.table,
        fromMap: Food.fromMap,
      ),
      portionDao: Dao<FoodPortion>(
        databaseHelper: helper,
        tableName: FoodPortion.table,
        fromMap: FoodPortion.fromMap,
      ),
    );
  }

  Future<Result<RecipeDto, ServiceError<SingleErrorTypes>>> createRecipe(
    RecipeInput input, [
    CreatedBy createdBy = CreatedBy.user,
  ]) async {
    final name = input.name;
    final description = input.description.value;
    final servingsYield = input.servingsYield;
    final items = input.items;

    _logger.info('Creating recipe $name');
    final actualYield = servingsYield < 1 ? 1 : servingsYield;

    try {
      final preparedResult = await _prepareRecipeData(
        items: items,
        actualYield: actualYield,
      );
      if (preparedResult.isErr()) {
        return err(preparedResult.error);
      }
      final prepared = preparedResult.value;

      return await _recipeDao
          .startTransaction<Result<RecipeDto, ServiceError<SingleErrorTypes>>>((
            txn,
          ) async {
            final recipe = Recipe.create(
              name: name,
              description: description,
              servingsYield: actualYield,
              servingCalories: prepared.servingCalories,
              servingProtein: prepared.servingProtein,
              servingCarbs: prepared.servingCarbs,
              servingFat: prepared.servingFat,
              servingMicros: prepared.servingMicros,
              createdBy: createdBy,
            );

            final int recipeId = await _recipeDao.insert(recipe, txn);
            final savedChildren = await _insertRecipeItems(
              recipeId: recipeId,
              items: prepared.calculatedItems,
              foodNames: prepared.foodNames,
              portionNames: prepared.portionNames,
              txn: txn,
            );
            // Throw inside the transaction to roll back earlier writes.
            if (savedChildren.isErr()) throw savedChildren.error;
            final itemDtos = savedChildren.value;

            _logger.info('Created recipe with id $recipeId');
            return ok(
              RecipeDto.fromModel(
                recipe.copyWith(id: Nullable(recipeId)),
                items: itemDtos,
              ),
            );
          });
    } on ServiceError<SingleErrorTypes> catch (error) {
      return err(error);
    } catch (e) {
      _logger.severe('Failed to create recipe', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to create recipe',
        ),
      );
    }
  }

  Future<Result<RecipeDto, ServiceError<SingleErrorTypes>>> getRecipe(
    int id,
  ) async {
    _logger.info('Getting recipe with id $id');
    try {
      final Recipe? recipe = await _recipeDao.selectOne(id);
      if (recipe == null) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Recipe not found',
          ),
        );
      }

      final itemsResult = await _loadRecipeItemDtos(id);
      if (itemsResult.isErr()) return err(itemsResult.error);
      final itemDtos = itemsResult.value;
      return ok(RecipeDto.fromModel(recipe, items: itemDtos));
    } on ServiceError<SingleErrorTypes> catch (error) {
      return err(error);
    } catch (e) {
      _logger.severe('Failed to get recipe with id $id', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to get recipe',
        ),
      );
    }
  }

  Future<
    Result<PaginatedDto<RecipeDto, Recipe>, ServiceError<OperationErrorTypes>>
  >
  getRecipes({
    String? search,
    bool isFavorite = false,
    int limit = kDefaultLimit,
    int offset = kDefaultOffset,
  }) async {
    _logger.info(
      'Getting recipes with search: $search, isFavorite: $isFavorite',
    );
    try {
      final where = WhereBuilder();
      if (search != null && search.trim().isNotEmpty) {
        where.and(RecipeColumns.name.like, '%${search.trim()}%');
      }
      if (isFavorite) {
        where.and(RecipeColumns.isFavorite.equal, 1);
      }

      final pageResult = await fetchPaginatedWithTotal(
        failureType: OperationErrorTypes.operationFailure,
        dao: _recipeDao,
        limit: limit,
        offset: offset,
        where: where.where,
        whereArgs: where.args,
        orderBy: [RecipeColumns.name.orderCaseInsensitiveAsc],
      );
      if (pageResult.isErr()) return err(pageResult.error);
      final (List<Recipe> recipes, int total) = pageResult.value;

      return ok(
        PaginatedDto<RecipeDto, Recipe>.mapData(
          data: recipes,
          mapper: RecipeDto.fromModel,
          total: total,
          limit: limit,
          offset: offset,
        ),
      );
    } catch (e) {
      _logger.severe('Failed to get recipes', e);
      return err(
        const ServiceError(
          type: OperationErrorTypes.operationFailure,
          description: 'Failed to get recipes',
        ),
      );
    }
  }

  Future<Result<RecipeDto, ServiceError<SingleErrorTypes>>> updateRecipe(
    int id,
    RecipeInput input,
  ) async {
    final name = input.name;
    final servingsYield = input.servingsYield;
    final items = input.items;

    _logger.info('Updating recipe with id $id');
    try {
      final Recipe? existing = await _recipeDao.selectOne(id);
      if (existing == null) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Recipe not found',
          ),
        );
      }

      if (existing.createdBy == CreatedBy.system) {
        _logger.warning('Attempted to modify machine-authored recipe $id');
        return err(
          const ServiceError(
            type: SingleErrorTypes.invalidInput,
            description: 'Cannot modify machine-authored recipe',
          ),
        );
      }

      final actualYield = servingsYield < 1 ? 1 : servingsYield;
      final preparedResult = await _prepareRecipeData(
        items: items,
        actualYield: actualYield,
      );
      if (preparedResult.isErr()) {
        return err(preparedResult.error);
      }
      final prepared = preparedResult.value;

      return await _recipeDao
          .startTransaction<Result<RecipeDto, ServiceError<SingleErrorTypes>>>((
            txn,
          ) async {
            await _itemDao.deleteMany(
              where: RecipeItemColumns.recipeId.equal,
              whereArgs: [id],
              trx: txn,
            );

            final savedChildren = await _insertRecipeItems(
              recipeId: id,
              items: prepared.calculatedItems,
              foodNames: prepared.foodNames,
              portionNames: prepared.portionNames,
              txn: txn,
            );
            // Throw inside the transaction to roll back earlier writes.
            if (savedChildren.isErr()) throw savedChildren.error;
            final itemDtos = savedChildren.value;

            final updated = existing.copyWith(
              name: name,
              description: input.description,
              servingsYield: actualYield,
              servingCalories: prepared.servingCalories,
              servingProtein: prepared.servingProtein,
              servingCarbs: prepared.servingCarbs,
              servingFat: prepared.servingFat,
              servingMicros: Nullable(prepared.servingMicros),
              updatedAt: DateUtilities.getNowUtcUnix(),
            );

            await _recipeDao.update(updated, txn);
            _logger.info('Updated recipe with id $id');
            return ok(RecipeDto.fromModel(updated, items: itemDtos));
          });
    } on ServiceError<SingleErrorTypes> catch (error) {
      return err(error);
    } catch (e) {
      _logger.severe('Failed to update recipe with id $id', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to update recipe',
        ),
      );
    }
  }

  Future<Result<RecipeDto, ServiceError<SingleErrorTypes>>> toggleFavorite(
    int id,
  ) async {
    _logger.info('Toggling favorite for recipe with id $id');
    try {
      return await _recipeDao.startTransaction<
        Result<RecipeDto, ServiceError<SingleErrorTypes>>
      >((txn) async {
        final Recipe? recipe = await _recipeDao.selectOne(id, txn);
        if (recipe == null) {
          return err(
            const ServiceError(
              type: SingleErrorTypes.notFound,
              description: 'Recipe not found',
            ),
          );
        }

        final itemsResult = await _loadRecipeItemDtos(id, trx: txn);
        if (itemsResult.isErr()) return err(itemsResult.error);
        final itemDtos = itemsResult.value;

        final updated = recipe.copyWith(
          isFavorite: !recipe.isFavorite,
          updatedAt: DateUtilities.getNowUtcUnix(),
        );
        await _recipeDao.update(updated, txn);

        _logger.info(
          'Toggled favorite for recipe with id $id to ${updated.isFavorite}',
        );
        return ok(RecipeDto.fromModel(updated, items: itemDtos));
      });
    } catch (e) {
      _logger.severe('Failed to toggle favorite for recipe with id $id', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to toggle favorite',
        ),
      );
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>> deleteRecipe(
    int id,
  ) async {
    _logger.info('Deleting recipe with id $id');
    try {
      final Recipe? recipe = await _recipeDao.selectOne(id);
      if (recipe == null) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Recipe not found',
          ),
        );
      }

      if (recipe.createdBy == CreatedBy.system) {
        _logger.warning('Attempted to delete machine-authored recipe $id');
        return err(
          const ServiceError(
            type: SingleErrorTypes.invalidInput,
            description: 'Cannot delete machine-authored recipe',
          ),
        );
      }

      final bool deleted = await _recipeDao.deleteOne(id);
      if (!deleted) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Recipe not found',
          ),
        );
      }

      _logger.info('Deleted recipe with id $id');
      return ok(null);
    } on ServiceError<SingleErrorTypes> catch (error) {
      return err(error);
    } catch (e) {
      _logger.severe('Failed to delete recipe with id $id', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to delete recipe',
        ),
      );
    }
  }

  Future<
    Result<
      ({
        List<RecipeItem> calculatedItems,
        int servingCalories,
        int servingProtein,
        int servingCarbs,
        int servingFat,
        Micronutrients? servingMicros,
        Map<int, String> foodNames,
        Map<int, String> portionNames,
      }),
      ServiceError<SingleErrorTypes>
    >
  >
  _prepareRecipeData({
    required List<RecipeItemInput> items,
    required int actualYield,
  }) async {
    final foodIds = items.map((item) => item.foodId).toSet();
    final portionIds = items
        .map((item) => item.portionId)
        .whereType<int>()
        .toSet();

    final (foods, portions) = await (
      selectManyInChunks(
        failureType: SingleErrorTypes.operationFailure,
        dao: _foodDao,
        column: FoodColumns.id,
        values: foodIds,
      ),
      selectManyInChunks(
        failureType: SingleErrorTypes.operationFailure,
        dao: _portionDao,
        column: FoodPortionColumns.id,
        values: portionIds,
      ),
    ).wait;
    if (foods.isErr()) return err(foods.error);
    if (portions.isErr()) return err(portions.error);
    final foodById = <int, Food>{
      for (final food in foods.value) food.id!: food,
    };
    final portionById = <int, FoodPortion>{
      for (final portion in portions.value) portion.id!: portion,
    };

    int totalCals = 0;
    int totalProtein = 0;
    int totalCarbs = 0;
    int totalFat = 0;
    final Map<String, double> microsAcc = {};
    final List<RecipeItem> calculatedItems = [];
    final Map<int, String> foodNames = {};
    final Map<int, String> portionNames = {};

    for (final itemInput in items) {
      final food = foodById[itemInput.foodId];
      if (food == null) {
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Food with id ${itemInput.foodId} not found',
          ),
        );
      }
      foodNames[food.id!] = food.name;

      double effectiveGrams = itemInput.amount.toDouble();
      if (itemInput.portionId != null) {
        final portion = portionById[itemInput.portionId];
        if (portion == null || portion.foodId != itemInput.foodId) {
          return err(
            ServiceError(
              type: SingleErrorTypes.notFound,
              description:
                  'Portion with id ${itemInput.portionId} not found for food ${food.id}',
            ),
          );
        }
        portionNames[portion.id!] = portion.portionName;
        effectiveGrams = (itemInput.amount * portion.gramWeight).toDouble();
      }

      final double scale = food.servingSizeBaseGrams > 0
          ? effectiveGrams / food.servingSizeBaseGrams
          : 1.0;

      final int itemCals = (food.caloriesBase * scale).round();
      final int itemProtein = (food.proteinBase * scale).round();
      final int itemCarbs = (food.carbsBase * scale).round();
      final int itemFat = (food.fatBase * scale).round();
      final int? itemFiber = food.fiberBase != null
          ? (food.fiberBase! * scale).round()
          : null;

      totalCals += itemCals;
      totalProtein += itemProtein;
      totalCarbs += itemCarbs;
      totalFat += itemFat;

      if (food.micros != null) {
        final m = food.micros!.toMap();
        for (final entry in m.entries) {
          if (entry.value is num) {
            microsAcc[entry.key] =
                (microsAcc[entry.key] ?? 0.0) + ((entry.value as num) * scale);
          }
        }
      }

      calculatedItems.add(
        RecipeItem.create(
          recipeId: 0,
          foodId: itemInput.foodId,
          portionId: itemInput.portionId,
          amount: itemInput.amount,
          totalCalories: itemCals,
          totalProtein: itemProtein,
          totalCarbs: itemCarbs,
          totalFat: itemFat,
          totalFiber: itemFiber,
        ),
      );
    }

    Micronutrients? servingMicros;
    if (microsAcc.isNotEmpty) {
      final Map<String, dynamic> servingMicrosMap = {};
      for (final entry in microsAcc.entries) {
        servingMicrosMap[entry.key] = (entry.value / actualYield).round();
      }
      servingMicros = Micronutrients.fromMap(servingMicrosMap);
    }

    return ok((
      calculatedItems: calculatedItems,
      servingCalories: (totalCals / actualYield).round(),
      servingProtein: (totalProtein / actualYield).round(),
      servingCarbs: (totalCarbs / actualYield).round(),
      servingFat: (totalFat / actualYield).round(),
      servingMicros: servingMicros,
      foodNames: foodNames,
      portionNames: portionNames,
    ));
  }

  Future<Result<List<RecipeItemDto>, ServiceError<SingleErrorTypes>>>
  _insertRecipeItems({
    required int recipeId,
    required List<RecipeItem> items,
    required Map<int, String> foodNames,
    required Map<int, String> portionNames,
    required Transaction txn,
  }) async {
    const failure = ServiceError(
      type: SingleErrorTypes.operationFailure,
      description: 'Failed to save recipe items',
    );
    try {
      final List<RecipeItemDto> itemDtos = [];
      for (final item in items) {
        final withRecipeId = item.copyWith(recipeId: recipeId);
        final int itemId = await _itemDao.insert(withRecipeId, txn);
        if (itemId <= 0) return err(failure);
        itemDtos.add(
          RecipeItemDto.fromModel(
            withRecipeId.copyWith(id: Nullable(itemId)),
            foodName: foodNames[item.foodId],
            portionName: item.portionId != null
                ? portionNames[item.portionId]
                : null,
          ),
        );
      }
      return ok(itemDtos);
    } catch (error, stackTrace) {
      _logger.severe('Failed to save recipe items', error, stackTrace);
      return err(failure);
    }
  }

  Future<Result<List<RecipeItemDto>, ServiceError<SingleErrorTypes>>>
  _loadRecipeItemDtos(int recipeId, {Transaction? trx}) async {
    try {
      final List<RecipeItem> items = await _itemDao.selectMany(
        where: RecipeItemColumns.recipeId.equal,
        whereArgs: [recipeId],
        trx: trx,
      );
      if (items.isEmpty) {
        return ok([]);
      }

      final foodIds = items.map((item) => item.foodId).toSet();
      final portionIds = items
          .map((item) => item.portionId)
          .whereType<int>()
          .toSet();
      final (foods, portions) = await (
        selectManyInChunks(
          failureType: SingleErrorTypes.operationFailure,
          dao: _foodDao,
          column: FoodColumns.id,
          values: foodIds,
          trx: trx,
        ),
        selectManyInChunks(
          failureType: SingleErrorTypes.operationFailure,
          dao: _portionDao,
          column: FoodPortionColumns.id,
          values: portionIds,
          trx: trx,
        ),
      ).wait;
      if (foods.isErr()) return err(foods.error);
      if (portions.isErr()) return err(portions.error);

      final foodNames = <int, String>{
        for (final food in foods.value) food.id!: food.name,
      };
      final portionNames = <int, String>{
        for (final portion in portions.value) portion.id!: portion.portionName,
      };

      return ok(
        items
            .map(
              (item) => RecipeItemDto.fromModel(
                item,
                foodName: foodNames[item.foodId],
                portionName: item.portionId != null
                    ? portionNames[item.portionId]
                    : null,
              ),
            )
            .toList(),
      );
    } catch (error, stackTrace) {
      _logger.severe('Failed to load recipe items', error, stackTrace);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to load recipe items',
        ),
      );
    }
  }
}
