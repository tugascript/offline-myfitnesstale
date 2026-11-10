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

import '../../../utils/errors.dart';
import '../../../utils/nullable.dart';
import '../../../utils/result.dart';
import '../../models/sqlite/food_model.dart';
import '../../models/sqlite/food_portion_model.dart';
import '../../services/common.dart';
import '../../services/sqlite/dao.dart';
import '../../services/sqlite/database_helper.dart';
import '../../utils/dates.dart';
import '../../utils/enums.dart';
import '../../utils/where_builder.dart';
import '../core/dtos/paginated_dto.dart';
import '../core/repository.dart';
import './dtos/food_dto.dart';
import './inputs/food_input.dart';

final class FoodRepository implements Repository {
  final Dao<Food> _foodDao;
  final Dao<FoodPortion> _portionDao;

  final Logger _logger = Logger('Food Repository');

  FoodRepository({required this._foodDao, required this._portionDao});

  factory FoodRepository.create([DatabaseHelper? databaseHelper]) {
    final helper = databaseHelper ?? DatabaseHelper();
    return FoodRepository(
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

  Future<Result<FoodDto, ServiceError<SingleErrorTypes>>> createFood(
    FoodInput input, [
    CreatedBy createdBy = CreatedBy.user,
  ]) async {
    _logger.info('Creating food ${input.name}');
    try {
      final food = Food.create(
        name: input.name,
        category: input.category,
        brand: input.brand.value,
        barcode: input.barcode.value,
        servingSizeBaseGrams: input.servingSizeBaseGrams,
        caloriesBase: input.caloriesBase,
        proteinBase: input.proteinBase,
        carbsBase: input.carbsBase,
        fatBase: input.fatBase,
        fiberBase: input.fiberBase.value,
        sodiumBase: input.sodiumBase.value,
        micros: input.micros.value,
        isFavorite: input.isFavorite,
        createdBy: createdBy,
      );

      if (input.portions.isEmpty) {
        _logger.info("No portions provided, creating food without portions");
        final int foodId = await _foodDao.insert(food);
        return ok(FoodDto.fromModel(food.copyWith(id: Nullable(foodId))));
      }

      final FoodDto createdDto = await _foodDao.startTransaction((txn) async {
        final int foodId = await _foodDao.insert(food, txn);
        final List<FoodPortionDto> portionDtos = [];

        for (final portionInput in input.portions) {
          final portion = FoodPortion.create(
            foodId: foodId,
            portionName: portionInput.portionName,
            gramWeight: portionInput.gramWeight,
          );
          final int portionId = await _portionDao.insert(portion, txn);
          portionDtos.add(
            FoodPortionDto.fromModel(portion.copyWith(id: Nullable(portionId))),
          );
        }

        return FoodDto.fromModel(
          food.copyWith(id: Nullable(foodId)),
          portions: portionDtos,
        );
      });

      _logger.info('Created food with id ${createdDto.id}');
      return ok(createdDto);
    } catch (e) {
      _logger.severe('Failed to create food', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to create food',
        ),
      );
    }
  }

  Future<Result<FoodDto, ServiceError<SingleErrorTypes>>> getFood(
    int id,
  ) async {
    _logger.info('Getting food with id $id');
    try {
      final Food? food = await _foodDao.selectOne(id);
      if (food == null) {
        _logger.warning('Food not found with id $id');
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Food not found',
          ),
        );
      }

      final List<FoodPortion> portions = await _portionDao.selectMany(
        where: FoodPortionColumns.foodId.equal,
        whereArgs: [id],
        orderBy: [FoodPortionColumns.portionName.orderAsc],
      );
      final List<FoodPortionDto> portionDtos = portions
          .map((p) => FoodPortionDto.fromModel(p))
          .toList();

      return ok(FoodDto.fromModel(food, portions: portionDtos));
    } catch (e) {
      _logger.severe('Failed to get food with id $id', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to get food',
        ),
      );
    }
  }

  Future<Result<PaginatedDto<FoodDto, Food>, ServiceError<OperationErrorTypes>>>
  getFoods({
    String? name,
    FoodCategory? category,
    bool isFavorite = false,
    int limit = kDefaultLimit,
    int offset = kDefaultOffset,
  }) async {
    _logger.info('Getting foods with name: $name, category: $category');
    try {
      final where = WhereBuilder();
      if (name != null && name.trim().isNotEmpty) {
        where.and(FoodColumns.name.like, '%$name%');
      }
      if (category != null) {
        where.and(FoodColumns.category.equal, category.value);
      }
      if (isFavorite) {
        where.and(FoodColumns.isFavorite.equal, 1);
      }

      final List<Food> foods = await _foodDao.selectPaginated(
        where: where.where,
        whereArgs: where.args,
        limit: limit,
        offset: offset,
        orderBy: [FoodColumns.name.orderAsc],
      );
      final int total = await _foodDao.count(
        where: where.where,
        whereArgs: where.args,
      );

      _logger.info('Retrieved ${foods.length} foods');
      return ok(
        PaginatedDto<FoodDto, Food>(
          data: foods.map((f) => FoodDto.fromModel(f)).toList(),
          total: total,
          limit: limit,
          offset: offset,
        ),
      );
    } catch (e) {
      _logger.severe('Failed to get foods', e);
      return err(
        const ServiceError(
          type: OperationErrorTypes.operationFailure,
          description: 'Failed to get foods',
        ),
      );
    }
  }

  Future<Result<FoodDto, ServiceError<SingleErrorTypes>>> updateFood(
    int id,
    FoodInput input,
  ) async {
    _logger.info('Updating food with id $id');
    try {
      final Food? existing = await _foodDao.selectOne(id);
      if (existing == null) {
        _logger.warning('Food not found with id $id');
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Food not found',
          ),
        );
      }

      if (existing.createdBy == CreatedBy.system) {
        _logger.warning('Attempted to update machine-authored food $id');
        return err(
          const ServiceError(
            type: SingleErrorTypes.invalidInput,
            description: 'Cannot modify machine-authored food',
          ),
        );
      }

      final List<FoodPortion> currentPortions = await _portionDao.selectMany(
        where: FoodPortionColumns.foodId.equal,
        whereArgs: [id],
        orderBy: [FoodPortionColumns.portionName.orderAsc],
      );
      final Food updated = existing.copyWith(
        name: input.name,
        category: input.category,
        brand: input.brand,
        barcode: input.barcode,
        servingSizeBaseGrams: input.servingSizeBaseGrams,
        caloriesBase: input.caloriesBase,
        proteinBase: input.proteinBase,
        carbsBase: input.carbsBase,
        fatBase: input.fatBase,
        fiberBase: input.fiberBase,
        sodiumBase: input.sodiumBase,
        micros: input.micros,
        isFavorite: input.isFavorite,
        updatedAt: DateUtilities.getNowUtcUnix(),
      );

      if (_arePortionsEqual(currentPortions, input.portions)) {
        _logger.info('Portions are the same, only updating food');
        await _foodDao.update(updated);
        return ok(
          FoodDto.fromModel(
            updated,
            portions: currentPortions
                .map((p) => FoodPortionDto.fromModel(p))
                .toList(),
          ),
        );
      }

      final FoodDto updatedDto = await _foodDao.startTransaction((txn) async {
        await _foodDao.update(updated, txn);
        await _portionDao.deleteMany(
          where: FoodPortionColumns.foodId.equal,
          whereArgs: [id],
          trx: txn,
        );

        final List<FoodPortionDto> portionDtos = [];
        if (input.portions.isNotEmpty) {
          for (final portionInput in input.portions) {
            final portion = FoodPortion.create(
              foodId: id,
              portionName: portionInput.portionName,
              gramWeight: portionInput.gramWeight,
            );
            final int portionId = await _portionDao.insert(portion, txn);
            portionDtos.add(
              FoodPortionDto.fromModel(
                portion.copyWith(id: Nullable(portionId)),
              ),
            );
          }
        }

        return FoodDto.fromModel(updated, portions: portionDtos);
      });

      _logger.info('Updated food with id $id');
      return ok(updatedDto);
    } catch (e) {
      _logger.severe('Failed to update food with id $id', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to update food',
        ),
      );
    }
  }

  bool _arePortionsEqual(
    List<FoodPortion> currentPortions,
    List<FoodPortionInput> newPortions,
  ) {
    if (currentPortions.length != newPortions.length) {
      return false;
    }

    final sortedPortions = [...newPortions]
      ..sort((a, b) => a.portionName.compareTo(b.portionName));
    for (int i = 0; i < currentPortions.length; i++) {
      if (currentPortions[i].portionName != sortedPortions[i].portionName ||
          currentPortions[i].gramWeight != sortedPortions[i].gramWeight) {
        return false;
      }
    }

    return true;
  }

  Future<Result<FoodDto, ServiceError<SingleErrorTypes>>> toggleFavorite(
    int id,
  ) async {
    _logger.info('Toggling favorite for food with id $id');
    try {
      final Food? food = await _foodDao.selectOne(id);
      if (food == null) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Food not found',
          ),
        );
      }

      final updated = food.copyWith(
        isFavorite: !food.isFavorite,
        updatedAt: DateUtilities.getNowUtcUnix(),
      );
      await _foodDao.update(updated);

      final portions = await _portionDao.selectMany(
        where: FoodPortionColumns.foodId.equal,
        whereArgs: [id],
      );

      return ok(
        FoodDto.fromModel(
          updated,
          portions: portions.map((p) => FoodPortionDto.fromModel(p)).toList(),
        ),
      );
    } catch (e) {
      _logger.severe('Failed to toggle favorite for food with id $id', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to toggle favorite',
        ),
      );
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>> deleteFood(
    int id,
  ) async {
    _logger.info('Deleting food with id $id');
    try {
      final Food? food = await _foodDao.selectOne(id);
      if (food == null) {
        _logger.warning('Food not found with id $id');
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Food not found',
          ),
        );
      }

      if (food.createdBy == CreatedBy.system) {
        _logger.warning('Attempted to delete machine-authored food $id');
        return err(
          const ServiceError(
            type: SingleErrorTypes.invalidInput,
            description: 'Cannot delete machine-authored food',
          ),
        );
      }

      final bool deleted = await _foodDao.deleteOne(id);
      if (!deleted) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Food not found',
          ),
        );
      }

      _logger.info('Deleted food with id $id');
      return ok(null);
    } catch (e) {
      _logger.severe('Failed to delete food with id $id', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to delete food',
        ),
      );
    }
  }
}
