import 'package:logging/logging.dart';

import '../models/common.dart';
import '../models/db.dart';
import '../models/enums.dart';
import '../models/food_model.dart';
import '../models/food_portion_model.dart';
import '../models/recipe_item_model.dart';
import '../models/recipe_model.dart';
import '../models/repository.dart';
import '../models/utilities.dart';
import 'common/errors.dart';
import 'common/result.dart';
import 'dtos/paginated_dto.dart';
import 'dtos/recipe_dto.dart';

class RecipeService {
  RecipeService._();

  static final RecipeService _instance = RecipeService._();

  factory RecipeService() => _instance;

  final Logger _logger = Logger('Recipe Service');

  final Repository<Recipe> _recipeRepository = Repository<Recipe>(
    databaseHelper: DatabaseHelper(),
    tableName: Recipe.table,
    fromMap: Recipe.fromMap,
  );

  final Repository<RecipeItem> _itemRepository = Repository<RecipeItem>(
    databaseHelper: DatabaseHelper(),
    tableName: RecipeItem.table,
    fromMap: RecipeItem.fromMap,
  );

  final Repository<Food> _foodRepository = Repository<Food>(
    databaseHelper: DatabaseHelper(),
    tableName: Food.table,
    fromMap: Food.fromMap,
  );

  final Repository<FoodPortion> _portionRepository = Repository<FoodPortion>(
    databaseHelper: DatabaseHelper(),
    tableName: FoodPortion.table,
    fromMap: FoodPortion.fromMap,
  );

  Future<Result<RecipeDto, ServiceError<SingleErrorTypes>>> createRecipe({
    required String name,
    String? description,
    required int servingsYield,
    CreatedBy createdBy = CreatedBy.user,
    List<RecipeItemInput> items = const [],
  }) async {
    _logger.info('Creating recipe $name');
    final actualYield = servingsYield < 1 ? 1 : servingsYield;

    try {
      final db = await DatabaseHelper().db;
      return await db
          .transaction<Result<RecipeDto, ServiceError<SingleErrorTypes>>>(
        (txn) async {
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
            final foodRows = await txn.query(
              Food.table,
              where: '${FoodColumns.id.value} = ?',
              whereArgs: [input.foodId],
              limit: 1,
            );
            if (foodRows.isEmpty) {
              return err(ServiceError(
                type: SingleErrorTypes.notFound,
                description: 'Food with id ${input.foodId} not found',
              ));
            }
            final food = Food.fromMap(foodRows.first);
            foodNames[food.id!] = food.name;

            double effectiveGrams = input.amount.toDouble();
            if (input.portionId != null) {
              final portionRows = await txn.query(
                FoodPortion.table,
                where:
                    '${FoodPortionColumns.id.value} = ? AND ${FoodPortionColumns.foodId.value} = ?',
                whereArgs: [input.portionId, input.foodId],
                limit: 1,
              );
              if (portionRows.isEmpty) {
                return err(ServiceError(
                  type: SingleErrorTypes.notFound,
                  description:
                      'Portion with id ${input.portionId} not found for food ${food.id}',
                ));
              }
              final portion = FoodPortion.fromMap(portionRows.first);
              portionNames[portion.id!] = portion.portionName;
              effectiveGrams = (input.amount * portion.gramWeight).toDouble();
            }

            final double scale = food.servingSizeBase > 0
                ? effectiveGrams / food.servingSizeBase
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
                  microsAcc[entry.key] = (microsAcc[entry.key] ?? 0.0) +
                      ((entry.value as num) * scale);
                }
              }
            }

            calculatedItems.add(RecipeItem.create(
              recipeId: 0, // placeholder, will set after recipe insert
              foodId: input.foodId,
              portionId: input.portionId,
              amount: input.amount,
              totalCalories: itemCals,
              totalProtein: itemProtein,
              totalCarbs: itemCarbs,
              totalFat: itemFat,
              totalFiber: itemFiber,
            ));
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
            itemDtos.add(RecipeItemDto.fromModel(
              withRecipeId.copyWith(id: itemId),
              foodName: foodNames[item.foodId],
              portionName:
                  item.portionId != null ? portionNames[item.portionId] : null,
            ));
          }

          _logger.info('Created recipe with id $recipeId');
          return ok(RecipeDto.fromModel(
            recipe.copyWith(id: recipeId),
            items: itemDtos,
          ));
        },
      );
    } catch (e) {
      _logger.severe('Failed to create recipe', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to create recipe',
      ));
    }
  }

  Future<Result<RecipeDto, ServiceError<SingleErrorTypes>>> getRecipe(
      int id) async {
    _logger.info('Getting recipe with id $id');
    try {
      final Recipe? recipe = await _recipeRepository.selectOne(id);
      if (recipe == null) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Recipe not found',
        ));
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
          final FoodPortion? portion =
              await _portionRepository.selectOne(item.portionId!);
          portionName = portion?.portionName;
        }
        itemDtos.add(RecipeItemDto.fromModel(
          item,
          foodName: food?.name,
          portionName: portionName,
        ));
      }

      return ok(RecipeDto.fromModel(recipe, items: itemDtos));
    } catch (e) {
      _logger.severe('Failed to get recipe with id $id', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to get recipe',
      ));
    }
  }

  Future<
      Result<PaginatedDto<RecipeDto, Recipe>,
          ServiceError<OperationErrorTypes>>> getRecipes({
    String? search,
    int limit = kDefaultLimit,
    int offset = kDefaultOffset,
  }) async {
    _logger.info('Getting recipes with search: $search');
    try {
      final where = WhereBuilder();
      if (search != null && search.trim().isNotEmpty) {
        where.and('${RecipeColumns.name.value} LIKE ?', '%${search.trim()}%');
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

      return ok(PaginatedDto<RecipeDto, Recipe>(
        data: recipeDtos,
        total: total,
        limit: limit,
        offset: offset,
      ));
    } catch (e) {
      _logger.severe('Failed to get recipes', e);
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to get recipes',
      ));
    }
  }

  Future<Result<RecipeDto, ServiceError<SingleErrorTypes>>> updateRecipe({
    required int id,
    String? name,
    String? description,
    int? servingsYield,
    List<RecipeItemInput>? items,
  }) async {
    _logger.info('Updating recipe with id $id');
    try {
      final Recipe? existing = await _recipeRepository.selectOne(id);
      if (existing == null) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Recipe not found',
        ));
      }

      if (existing.createdBy == CreatedBy.system) {
        _logger.warning('Attempted to modify machine-authored recipe $id');
        return err(const ServiceError(
          type: SingleErrorTypes.invalidInput,
          description: 'Cannot modify machine-authored recipe',
        ));
      }

      final db = await DatabaseHelper().db;
      return await db
          .transaction<Result<RecipeDto, ServiceError<SingleErrorTypes>>>(
        (txn) async {
          final actualYield = (servingsYield ?? existing.servingsYield) < 1
              ? 1
              : (servingsYield ?? existing.servingsYield);

          // If items provided, re-calculate and re-insert
          List<RecipeItemDto> itemDtos = [];
          int servingCals = existing.servingCalories;
          int servingProt = existing.servingProtein;
          int servingCarb = existing.servingCarbs;
          int servingF = existing.servingFat;
          Micronutrients? servingMicros = existing.servingMicros;

          if (items != null) {
            await txn.delete(
              RecipeItem.table,
              where: '${RecipeItemColumns.recipeId.value} = ?',
              whereArgs: [id],
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
              final foodRows = await txn.query(
                Food.table,
                where: '${FoodColumns.id.value} = ?',
                whereArgs: [input.foodId],
                limit: 1,
              );
              if (foodRows.isEmpty) {
                return err(ServiceError(
                  type: SingleErrorTypes.notFound,
                  description: 'Food with id ${input.foodId} not found',
                ));
              }
              final food = Food.fromMap(foodRows.first);
              foodNames[food.id!] = food.name;

              double effectiveGrams = input.amount.toDouble();
              if (input.portionId != null) {
                final portionRows = await txn.query(
                  FoodPortion.table,
                  where:
                      '${FoodPortionColumns.id.value} = ? AND ${FoodPortionColumns.foodId.value} = ?',
                  whereArgs: [input.portionId, input.foodId],
                  limit: 1,
                );
                if (portionRows.isEmpty) {
                  return err(ServiceError(
                    type: SingleErrorTypes.notFound,
                    description:
                        'Portion with id ${input.portionId} not found for food ${food.id}',
                  ));
                }
                final portion = FoodPortion.fromMap(portionRows.first);
                portionNames[portion.id!] = portion.portionName;
                effectiveGrams = (input.amount * portion.gramWeight).toDouble();
              }

              final double scale = food.servingSizeBase > 0
                  ? effectiveGrams / food.servingSizeBase
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
                    microsAcc[entry.key] = (microsAcc[entry.key] ?? 0.0) +
                        ((entry.value as num) * scale);
                  }
                }
              }

              calculatedItems.add(RecipeItem.create(
                recipeId: id,
                foodId: input.foodId,
                portionId: input.portionId,
                amount: input.amount,
                totalCalories: itemCals,
                totalProtein: itemProtein,
                totalCarbs: itemCarbs,
                totalFat: itemFat,
                totalFiber: itemFiber,
              ));
            }

            servingCals = (totalCals / actualYield).round();
            servingProt = (totalProtein / actualYield).round();
            servingCarb = (totalCarbs / actualYield).round();
            servingF = (totalFat / actualYield).round();

            if (microsAcc.isNotEmpty) {
              final Map<String, dynamic> servingMicrosMap = {};
              for (final entry in microsAcc.entries) {
                servingMicrosMap[entry.key] =
                    (entry.value / actualYield).round();
              }
              servingMicros = Micronutrients.fromMap(servingMicrosMap);
            } else {
              servingMicros = null;
            }

            for (final item in calculatedItems) {
              final int itemId = await _itemRepository.insert(item, txn);
              itemDtos.add(RecipeItemDto.fromModel(
                item.copyWith(id: itemId),
                foodName: foodNames[item.foodId],
                portionName: item.portionId != null
                    ? portionNames[item.portionId]
                    : null,
              ));
            }
          } else {
            // Load existing items
            final existingItems = await _itemRepository.selectMany(
              where: RecipeItemColumns.recipeId.equal,
              whereArgs: [id],
              trx: txn,
            );
            for (final item in existingItems) {
              final food = await _foodRepository.selectOne(item.foodId, txn);
              String? portionName;
              if (item.portionId != null) {
                final portion =
                    await _portionRepository.selectOne(item.portionId!, txn);
                portionName = portion?.portionName;
              }
              itemDtos.add(RecipeItemDto.fromModel(
                item,
                foodName: food?.name,
                portionName: portionName,
              ));
            }
          }

          final updated = existing.copyWith(
            name: name,
            description: description,
            servingsYield: actualYield,
            servingCalories: servingCals,
            servingProtein: servingProt,
            servingCarbs: servingCarb,
            servingFat: servingF,
            servingMicros: servingMicros,
            updatedAt: DateUtilities.getNowUtcUnix(),
          );

          await _recipeRepository.update(updated, txn);
          _logger.info('Updated recipe with id $id');
          return ok(RecipeDto.fromModel(updated, items: itemDtos));
        },
      );
    } catch (e) {
      _logger.severe('Failed to update recipe with id $id', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to update recipe',
      ));
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>> deleteRecipe(
      int id) async {
    _logger.info('Deleting recipe with id $id');
    try {
      final Recipe? recipe = await _recipeRepository.selectOne(id);
      if (recipe == null) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Recipe not found',
        ));
      }

      if (recipe.createdBy == CreatedBy.system) {
        _logger.warning('Attempted to delete machine-authored recipe $id');
        return err(const ServiceError(
          type: SingleErrorTypes.invalidInput,
          description: 'Cannot delete machine-authored recipe',
        ));
      }

      final bool deleted = await _recipeRepository.deleteOne(id);
      if (!deleted) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Recipe not found',
        ));
      }

      _logger.info('Deleted recipe with id $id');
      return ok(null);
    } catch (e) {
      _logger.severe('Failed to delete recipe with id $id', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to delete recipe',
      ));
    }
  }
}
