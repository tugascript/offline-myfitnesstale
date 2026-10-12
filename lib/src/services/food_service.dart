import 'package:logging/logging.dart';

import '../models/common.dart';
import '../models/db.dart';
import '../models/enums.dart';
import '../models/food_model.dart';
import '../models/food_portion_model.dart';
import '../models/repository.dart';
import '../models/utilities.dart';
import 'common/errors.dart';
import 'common/result.dart';
import 'dtos/food_dto.dart';
import 'dtos/paginated_dto.dart';

class FoodService {
  FoodService._();

  static final FoodService _instance = FoodService._();

  factory FoodService() => _instance;

  final Logger _logger = Logger('Food Service');

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

  Future<Result<FoodDto, ServiceError<SingleErrorTypes>>> createFood({
    required String name,
    required FoodCategory category,
    String? brand,
    String? barcode,
    required int servingSizeBaseGrams,
    required int caloriesBase,
    required int proteinBase,
    required int carbsBase,
    required int fatBase,
    int? fiberBase,
    Micronutrients? micros,
    bool isFavorite = false,
    CreatedBy createdBy = CreatedBy.user,
    List<FoodPortionInput> portions = const [],
  }) async {
    _logger.info('Creating food $name');
    try {
      final Food food = Food.create(
        name: name,
        category: category,
        brand: brand,
        barcode: barcode,
        servingSizeBaseGrams: servingSizeBaseGrams,
        caloriesBase: caloriesBase,
        proteinBase: proteinBase,
        carbsBase: carbsBase,
        fatBase: fatBase,
        fiberBase: fiberBase,
        micros: micros,
        isFavorite: isFavorite,
        createdBy: createdBy,
      );

      final FoodDto createdDto =
          await _foodRepository.startTransaction((txn) async {
        final int foodId = await _foodRepository.insert(food, txn);
        final List<FoodPortionDto> portionDtos = [];

        for (final portionInput in portions) {
          final portion = FoodPortion.create(
            foodId: foodId,
            portionName: portionInput.portionName,
            gramWeight: portionInput.gramWeight,
          );
          final int portionId = await _portionRepository.insert(portion, txn);
          portionDtos
              .add(FoodPortionDto.fromModel(portion.copyWith(id: portionId)));
        }

        return FoodDto.fromModel(food.copyWith(id: foodId),
            portions: portionDtos);
      });

      _logger.info('Created food with id ${createdDto.id}');
      return ok(createdDto);
    } catch (e) {
      _logger.severe('Failed to create food', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to create food',
      ));
    }
  }

  Future<Result<FoodDto, ServiceError<SingleErrorTypes>>> getFood(
      int id) async {
    _logger.info('Getting food with id $id');
    try {
      final Food? food = await _foodRepository.selectOne(id);
      if (food == null) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Food not found',
        ));
      }

      final List<FoodPortion> portions = await _portionRepository.selectMany(
        where: FoodPortionColumns.foodId.equal,
        whereArgs: [id],
        orderBy: [FoodPortionColumns.portionName.orderAsc],
      );

      final List<FoodPortionDto> portionDtos =
          portions.map((p) => FoodPortionDto.fromModel(p)).toList();

      return ok(FoodDto.fromModel(food, portions: portionDtos));
    } catch (e) {
      _logger.severe('Failed to get food with id $id', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to get food',
      ));
    }
  }

  Future<Result<PaginatedDto<FoodDto, Food>, ServiceError<OperationErrorTypes>>>
      getFoods({
    String? search,
    FoodCategory? category,
    bool? isFavorite,
    int limit = kDefaultLimit,
    int offset = kDefaultOffset,
  }) async {
    _logger.info('Getting foods with search: $search, category: $category');
    try {
      final where = WhereBuilder();
      if (search != null && search.trim().isNotEmpty) {
        where.and('${FoodColumns.name.value} LIKE ?', '%${search.trim()}%');
      }
      if (category != null) {
        where.and(FoodColumns.category.equal, category.value);
      }
      if (isFavorite != null) {
        where.and(FoodColumns.isFavorite.equal, isFavorite ? 1 : 0);
      }

      final List<Food> foods = await _foodRepository.selectPaginated(
        where: where.where,
        whereArgs: where.args,
        limit: limit,
        offset: offset,
        orderBy: [FoodColumns.name.orderAsc],
      );
      final int total = await _foodRepository.count(
        where: where.where,
        whereArgs: where.args,
      );

      // Load portions for the returned foods
      final List<FoodDto> foodDtos = [];
      if (foods.isNotEmpty) {
        final List<int> foodIds = foods.map((f) => f.id!).toList();
        final placeholders = List.filled(foodIds.length, '?').join(', ');
        final List<FoodPortion> allPortions =
            await _portionRepository.selectMany(
          where: '${FoodPortionColumns.foodId.value} IN ($placeholders)',
          whereArgs: foodIds,
          orderBy: [FoodPortionColumns.portionName.orderAsc],
        );

        final Map<int, List<FoodPortionDto>> portionsByFoodId = {};
        for (final p in allPortions) {
          portionsByFoodId
              .putIfAbsent(p.foodId, () => [])
              .add(FoodPortionDto.fromModel(p));
        }

        for (final food in foods) {
          foodDtos.add(FoodDto.fromModel(
            food,
            portions: portionsByFoodId[food.id!] ?? const [],
          ));
        }
      }

      _logger.info('Retrieved ${foodDtos.length} foods');
      return ok(PaginatedDto<FoodDto, Food>(
        data: foodDtos,
        total: total,
        limit: limit,
        offset: offset,
      ));
    } catch (e) {
      _logger.severe('Failed to get foods', e);
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to get foods',
      ));
    }
  }

  Future<Result<FoodDto, ServiceError<SingleErrorTypes>>> updateFood({
    required int id,
    String? name,
    FoodCategory? category,
    String? brand,
    String? barcode,
    int? servingSizeBaseGrams,
    int? caloriesBase,
    int? proteinBase,
    int? carbsBase,
    int? fatBase,
    int? fiberBase,
    Micronutrients? micros,
    bool? isFavorite,
    List<FoodPortionInput>? portions,
  }) async {
    _logger.info('Updating food with id $id');
    try {
      final Food? existing = await _foodRepository.selectOne(id);
      if (existing == null) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Food not found',
        ));
      }

      if (existing.createdBy == CreatedBy.system) {
        _logger.warning('Attempted to update machine-authored food $id');
        return err(const ServiceError(
          type: SingleErrorTypes.invalidInput,
          description: 'Cannot modify machine-authored food',
        ));
      }

      final Food updated = existing.copyWith(
        name: name,
        category: category,
        brand: brand,
        barcode: barcode,
        servingSizeBaseGrams: servingSizeBaseGrams,
        caloriesBase: caloriesBase,
        proteinBase: proteinBase,
        carbsBase: carbsBase,
        fatBase: fatBase,
        fiberBase: fiberBase,
        micros: micros,
        isFavorite: isFavorite,
        updatedAt: DateUtilities.getNowUtcUnix(),
      );

      final FoodDto updatedDto =
          await _foodRepository.startTransaction((txn) async {
        await _foodRepository.update(updated, txn);

        List<FoodPortionDto> portionDtos = [];
        if (portions != null) {
          await txn.delete(
            FoodPortion.table,
            where: '${FoodPortionColumns.foodId.value} = ?',
            whereArgs: [id],
          );

          for (final portionInput in portions) {
            final portion = FoodPortion.create(
              foodId: id,
              portionName: portionInput.portionName,
              gramWeight: portionInput.gramWeight,
            );
            final int portionId = await _portionRepository.insert(portion, txn);
            portionDtos
                .add(FoodPortionDto.fromModel(portion.copyWith(id: portionId)));
          }
        } else {
          final existingPortions = await _portionRepository.selectMany(
            where: FoodPortionColumns.foodId.equal,
            whereArgs: [id],
            trx: txn,
          );
          portionDtos =
              existingPortions.map((p) => FoodPortionDto.fromModel(p)).toList();
        }

        return FoodDto.fromModel(updated, portions: portionDtos);
      });

      _logger.info('Updated food with id $id');
      return ok(updatedDto);
    } catch (e) {
      _logger.severe('Failed to update food with id $id', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to update food',
      ));
    }
  }

  Future<Result<FoodDto, ServiceError<SingleErrorTypes>>> toggleFavorite(
    int id,
  ) async {
    _logger.info('Toggling favorite for food with id $id');
    try {
      final Food? food = await _foodRepository.selectOne(id);
      if (food == null) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Food not found',
        ));
      }

      final updated = food.copyWith(
        isFavorite: !food.isFavorite,
        updatedAt: DateUtilities.getNowUtcUnix(),
      );
      await _foodRepository.update(updated);

      final portions = await _portionRepository.selectMany(
        where: FoodPortionColumns.foodId.equal,
        whereArgs: [id],
      );

      return ok(FoodDto.fromModel(
        updated,
        portions: portions.map((p) => FoodPortionDto.fromModel(p)).toList(),
      ));
    } catch (e) {
      _logger.severe('Failed to toggle favorite for food with id $id', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to toggle favorite',
      ));
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>> deleteFood(
      int id) async {
    _logger.info('Deleting food with id $id');
    try {
      final Food? food = await _foodRepository.selectOne(id);
      if (food == null) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Food not found',
        ));
      }

      if (food.createdBy == CreatedBy.system) {
        _logger.warning('Attempted to delete machine-authored food $id');
        return err(const ServiceError(
          type: SingleErrorTypes.invalidInput,
          description: 'Cannot delete machine-authored food',
        ));
      }

      final bool deleted = await _foodRepository.deleteOne(id);
      if (!deleted) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Food not found',
        ));
      }

      _logger.info('Deleted food with id $id');
      return ok(null);
    } catch (e) {
      _logger.severe('Failed to delete food with id $id', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to delete food',
      ));
    }
  }
}
