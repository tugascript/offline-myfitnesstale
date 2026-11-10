// Copyright (C) 2026 afonsobarracha
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

import '../../models/sqlite/food_model.dart';
import '../../models/sqlite/food_portion_model.dart';
import '../../models/sqlite/recipe_item_model.dart';
import '../../models/sqlite/recipe_model.dart';
import '../../services/common.dart';
import '../../services/sqlite/database_helper.dart';
import '../../services/sqlite/dao.dart';
import '../../utils/dates.dart';
import '../../utils/enums.dart';
import '../../utils/json_data.dart';
import '../../utils/where_builder.dart';
import '../../../utils/errors.dart';
import '../../../utils/nullable.dart';
import '../../../utils/result.dart';
import '../core/dtos/paginated_dto.dart';
import './dtos/recipe_dto.dart';
import './inputs/recipe_input.dart';

class RecipeRepository {
  RecipeRepository._();

  static final RecipeRepository _instance = RecipeRepository._();

  factory RecipeRepository() => _instance;

  final Logger _logger = Logger('Recipe Service');

  final Dao<Recipe> _recipeRepository = Dao<Recipe>(
    databaseHelper: DatabaseHelper(),
    tableName: Recipe.table,
    fromMap: Recipe.fromMap,
  );

  final Dao<RecipeItem> _itemRepository = Dao<RecipeItem>(
    databaseHelper: DatabaseHelper(),
    tableName: RecipeItem.table,
    fromMap: RecipeItem.fromMap,
  );

  final Dao<Food> _foodRepository = Dao<Food>(
    databaseHelper: DatabaseHelper(),
    tableName: Food.table,
    fromMap: Food.fromMap,
  );

  final Dao<FoodPortion> _portionRepository = Dao<FoodPortion>(
    databaseHelper: DatabaseHelper(),
    tableName: FoodPortion.table,
    fromMap: FoodPortion.fromMap,
  );

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
      return await _recipeRepository.startTransaction<
        Result<RecipeDto, ServiceError<SingleErrorTypes>>
      >((txn) async {
        // Calculate item totals and recipe totals
        int totalCals = 0;
        int totalProtein = 0;
        int totalCarbs = 0;
        int totalFat = 0;
        Map<String, double> microsAcc = {};

        final List<RecipeItem> calculatedItems = [];
        final Map<int, String> foodNames = {};
        final Map<int, String> portionNames = {};

        for (final input in items) {
          final foodRows = await _foodRepository.selectMany(
            where: FoodColumns.id.equal,
            whereArgs: [input.foodId],
            limit: 1,
            trx: txn,
          );
          if (foodRows.isEmpty) {
            throw ServiceError(
              type: SingleErrorTypes.notFound,
              description: 'Food with id ${input.foodId} not found',
            );
          }
          final food = foodRows.first;
          foodNames[food.id!] = food.name;

          double effectiveGrams = input.amount.toDouble();
          if (input.portionId != null) {
            final portionWhere = WhereBuilder()
              ..and(FoodPortionColumns.id.equal, input.portionId)
              ..and(FoodPortionColumns.foodId.equal, input.foodId);
            final portionRows = await _portionRepository.selectMany(
              where: portionWhere.where,
              whereArgs: portionWhere.args,
              limit: 1,
              trx: txn,
            );
            if (portionRows.isEmpty) {
              throw ServiceError(
                type: SingleErrorTypes.notFound,
                description:
                    'Portion with id ${input.portionId} not found for food ${food.id}',
              );
            }
            final portion = portionRows.first;
            portionNames[portion.id!] = portion.portionName;
            effectiveGrams = (input.amount * portion.gramWeight).toDouble();
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
                    (microsAcc[entry.key] ?? 0.0) +
                    ((entry.value as num) * scale);
              }
            }
          }

          calculatedItems.add(
            RecipeItem.create(
              recipeId: 0,
              // placeholder, will set after recipe insert
              foodId: input.foodId,
              portionId: input.portionId,
              amount: input.amount,
              totalCalories: itemCals,
              totalProtein: itemProtein,
              totalCarbs: itemCarbs,
              totalFat: itemFat,
              totalFiber: itemFiber,
            ),
          );
        }

        final int servingCals = (totalCals / actualYield).round();
        final int servingProt = (totalProtein / actualYield).round();
        final int servingCarb = (totalCarbs / actualYield).round();
        final int servingF = (totalFat / actualYield).round();

        Micronutrients? servingMicros;
        if (microsAcc.isNotEmpty) {
          final Map<String, dynamic> servingMicrosMap = {};
          for (final entry in microsAcc.entries) {
            servingMicrosMap[entry.key] = (entry.value / actualYield).round();
          }
          servingMicros = Micronutrients.fromMap(servingMicrosMap);
        }

        final recipe = Recipe.create(
          name: name,
          description: description,
          servingsYield: actualYield,
          servingCalories: servingCals,
          servingProtein: servingProt,
          servingCarbs: servingCarb,
          servingFat: servingF,
          servingMicros: servingMicros,
          createdBy: createdBy,
        );

        final int recipeId = await _recipeRepository.insert(recipe, txn);

        final List<RecipeItemDto> itemDtos = [];
        for (final item in calculatedItems) {
          final withRecipeId = item.copyWith(recipeId: recipeId);
          final int itemId = await _itemRepository.insert(withRecipeId, txn);
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
      final Recipe? recipe = await _recipeRepository.selectOne(id);
      if (recipe == null) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Recipe not found',
          ),
        );
      }

      final List<RecipeItem> items = await _itemRepository.selectMany(
        where: RecipeItemColumns.recipeId.equal,
        whereArgs: [id],
      );

      final List<RecipeItemDto> itemDtos = [];
      for (final item in items) {
        final Food? food = await _foodRepository.selectOne(item.foodId);
        String? portionName;
        if (item.portionId != null) {
          final FoodPortion? portion = await _portionRepository.selectOne(
            item.portionId!,
          );
          portionName = portion?.portionName;
        }
        itemDtos.add(
          RecipeItemDto.fromModel(
            item,
            foodName: food?.name,
            portionName: portionName,
          ),
        );
      }

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

      final List<Recipe> recipes = await _recipeRepository.selectPaginated(
        where: where.where,
        whereArgs: where.args,
        limit: limit,
        offset: offset,
        orderBy: [RecipeColumns.name.orderAsc],
      );
      final int total = await _recipeRepository.count(
        where: where.where,
        whereArgs: where.args,
      );

      final List<RecipeDto> recipeDtos = [];
      for (final recipe in recipes) {
        recipeDtos.add(RecipeDto.fromModel(recipe));
      }

      return ok(
        PaginatedDto<RecipeDto, Recipe>(
          data: recipeDtos,
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
      final Recipe? existing = await _recipeRepository.selectOne(id);
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

      return await _recipeRepository.startTransaction<
        Result<RecipeDto, ServiceError<SingleErrorTypes>>
      >((txn) async {
        final actualYield = servingsYield < 1 ? 1 : servingsYield;

        // If items provided, re-calculate and re-insert
        List<RecipeItemDto> itemDtos = [];
        int servingCals = existing.servingCalories;
        int servingProt = existing.servingProtein;
        int servingCarb = existing.servingCarbs;
        int servingF = existing.servingFat;
        Micronutrients? servingMicros = existing.servingMicros;

        await _itemRepository.deleteMany(
          where: RecipeItemColumns.recipeId.equal,
          whereArgs: [id],
          trx: txn,
        );

        int totalCals = 0;
        int totalProtein = 0;
        int totalCarbs = 0;
        int totalFat = 0;
        Map<String, double> microsAcc = {};

        final List<RecipeItem> calculatedItems = [];
        final Map<int, String> foodNames = {};
        final Map<int, String> portionNames = {};

        for (final input in items) {
          final foodRows = await _foodRepository.selectMany(
            where: FoodColumns.id.equal,
            whereArgs: [input.foodId],
            limit: 1,
            trx: txn,
          );
          if (foodRows.isEmpty) {
            throw ServiceError(
              type: SingleErrorTypes.notFound,
              description: 'Food with id ${input.foodId} not found',
            );
          }
          final food = foodRows.first;
          foodNames[food.id!] = food.name;

          double effectiveGrams = input.amount.toDouble();
          if (input.portionId != null) {
            final portionWhere = WhereBuilder()
              ..and(FoodPortionColumns.id.equal, input.portionId)
              ..and(FoodPortionColumns.foodId.equal, input.foodId);
            final portionRows = await _portionRepository.selectMany(
              where: portionWhere.where,
              whereArgs: portionWhere.args,
              limit: 1,
              trx: txn,
            );
            if (portionRows.isEmpty) {
              throw ServiceError(
                type: SingleErrorTypes.notFound,
                description:
                    'Portion with id ${input.portionId} not found for food ${food.id}',
              );
            }
            final portion = portionRows.first;
            portionNames[portion.id!] = portion.portionName;
            effectiveGrams = (input.amount * portion.gramWeight).toDouble();
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
                    (microsAcc[entry.key] ?? 0.0) +
                    ((entry.value as num) * scale);
              }
            }
          }

          calculatedItems.add(
            RecipeItem.create(
              recipeId: id,
              foodId: input.foodId,
              portionId: input.portionId,
              amount: input.amount,
              totalCalories: itemCals,
              totalProtein: itemProtein,
              totalCarbs: itemCarbs,
              totalFat: itemFat,
              totalFiber: itemFiber,
            ),
          );
        }

        servingCals = (totalCals / actualYield).round();
        servingProt = (totalProtein / actualYield).round();
        servingCarb = (totalCarbs / actualYield).round();
        servingF = (totalFat / actualYield).round();

        if (microsAcc.isNotEmpty) {
          final Map<String, dynamic> servingMicrosMap = {};
          for (final entry in microsAcc.entries) {
            servingMicrosMap[entry.key] = (entry.value / actualYield).round();
          }
          servingMicros = Micronutrients.fromMap(servingMicrosMap);
        } else {
          servingMicros = null;
        }

        for (final item in calculatedItems) {
          final int itemId = await _itemRepository.insert(item, txn);
          itemDtos.add(
            RecipeItemDto.fromModel(
              item.copyWith(id: Nullable(itemId)),
              foodName: foodNames[item.foodId],
              portionName: item.portionId != null
                  ? portionNames[item.portionId]
                  : null,
            ),
          );
        }

        final updated = existing.copyWith(
          name: name,
          description: input.description,
          servingsYield: actualYield,
          servingCalories: servingCals,
          servingProtein: servingProt,
          servingCarbs: servingCarb,
          servingFat: servingF,
          servingMicros: Nullable(servingMicros),
          updatedAt: DateUtilities.getNowUtcUnix(),
        );

        await _recipeRepository.update(updated, txn);
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
      return await _recipeRepository.startTransaction<
        Result<RecipeDto, ServiceError<SingleErrorTypes>>
      >((txn) async {
        final Recipe? recipe = await _recipeRepository.selectOne(id, txn);
        if (recipe == null) {
          return err(
            const ServiceError(
              type: SingleErrorTypes.notFound,
              description: 'Recipe not found',
            ),
          );
        }

        final updated = recipe.copyWith(
          isFavorite: !recipe.isFavorite,
          updatedAt: DateUtilities.getNowUtcUnix(),
        );
        await _recipeRepository.update(updated, txn);

        final List<RecipeItem> items = await _itemRepository.selectMany(
          where: RecipeItemColumns.recipeId.equal,
          whereArgs: [id],
          trx: txn,
        );

        final List<RecipeItemDto> itemDtos = [];
        for (final item in items) {
          final Food? food = await _foodRepository.selectOne(item.foodId, txn);
          String? portionName;
          if (item.portionId != null) {
            final FoodPortion? portion = await _portionRepository.selectOne(
              item.portionId!,
              txn,
            );
            portionName = portion?.portionName;
          }
          itemDtos.add(
            RecipeItemDto.fromModel(
              item,
              foodName: food?.name,
              portionName: portionName,
            ),
          );
        }

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
      final Recipe? recipe = await _recipeRepository.selectOne(id);
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

      final bool deleted = await _recipeRepository.deleteOne(id);
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
}
