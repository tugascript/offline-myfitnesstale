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

import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../../../data/repositories/foods/food_repository.dart';
import '../../../data/repositories/foods/inputs/food_input.dart';
import '../../../data/utils/enums.dart';
import '../../../utils/nullable.dart';
import '../../core/view_models/states/common_state.dart';
import './states/food_state.dart';

class FoodCubit extends Cubit<FoodState> {
  final FoodRepository _foodService;
  final Logger _logger = Logger('FoodCubit');

  FoodCubit({required FoodRepository foodRepository})
    : _foodService = foodRepository,
      super(FoodState.initial());

  Future<void> getFoods({
    String? search,
    FoodCategory? category,
    bool? isFavorite,
    int limit = 20,
    int offset = 0,
  }) => _loadFoods(
    FoodPagination(
      name: search ?? '',
      category: category,
      isFavorite: isFavorite ?? false,
      limit: limit,
      offset: offset,
    ),
  );

  Future<void> _loadFoods(FoodPagination query, {FoodState? afterWrite}) async {
    final refresh = afterWrite != null;
    _logger.info('Getting foods');
    final requestId = state.foodsRequestId + 1;
    final limit = refresh ? query.offset + query.limit : query.limit;
    final offset = refresh ? 0 : query.offset;
    emit(
      (afterWrite ?? state).copyWith(
        foodsRequestId: requestId,
        pendingFoodsQuery: Nullable(query),
      ),
    );

    final result = await _foodService.getFoods(
      name: query.name,
      category: query.category,
      isFavorite: query.isFavorite,
      limit: limit,
      offset: offset,
    );
    if (isClosed || requestId != state.foodsRequestId) return;

    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to get foods', error);
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(type: error.type.name, description: error.description),
          ),
          pendingFoodsQuery: const Nullable(null),
          foods: refresh ? const [] : null,
          foodPagination: refresh
              ? state.foodPagination.copyWith(total: 0, offset: 0)
              : null,
        ),
      );
      return;
    }

    final page = result.value;
    emit(
      state.copyWith(
        foods: offset > 0 ? [...state.foods, ...page.data] : page.data,
        foodPagination: query.copyWith(offset: page.offset, total: page.total),
        pendingFoodsQuery: const Nullable(null),
        error: const Nullable(null),
      ),
    );
  }

  Future<void> _refreshFoods(FoodState afterWrite) {
    // A write can shift page boundaries. Reload the prefix for the latest query.
    final query =
        state.pendingFoodsQuery ??
        state.foodPagination.copyWith(
          offset: max(0, state.foods.length - state.foodPagination.limit),
        );
    return _loadFoods(query, afterWrite: afterWrite);
  }

  Future<void> getFood(int id) async {
    _logger.info('Getting food $id');
    emit(state.copyWith(isLoading: true));

    final result = await _foodService.getFood(id);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to get food $id', error);
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(type: error.type.name, description: error.description),
          ),
          isLoading: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        selectedFood: Nullable(result.value),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }

  Future<bool> createFood(
    FoodInput input, [
    CreatedBy createdBy = CreatedBy.user,
  ]) async {
    _logger.info('Creating food ${input.name}');
    emit(state.copyWith(isLoading: true));

    final result = await _foodService.createFood(input, createdBy);

    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to create food', error);
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(type: error.type.name, description: error.description),
          ),
          isLoading: false,
        ),
      );
      return false;
    }

    final created = result.value;
    if (isClosed) return true;
    await _refreshFoods(
      state.copyWith(
        selectedFood: Nullable(created),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
    return true;
  }

  Future<bool> updateFood(int id, FoodInput input) async {
    _logger.info('Updating food $id');
    emit(state.copyWith(isLoading: true));

    final result = await _foodService.updateFood(id, input);

    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to update food $id', error);
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(type: error.type.name, description: error.description),
          ),
          isLoading: false,
        ),
      );
      return false;
    }

    final updated = result.value;
    if (isClosed) return true;
    await _refreshFoods(
      state.copyWith(
        selectedFood: Nullable(updated),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
    return true;
  }

  Future<bool> toggleFavorite(int id) async {
    _logger.info('Toggling favorite for food $id');
    final result = await _foodService.toggleFavorite(id);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to toggle favorite', error);
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(type: error.type.name, description: error.description),
          ),
        ),
      );
      return false;
    }

    final updated = result.value;
    if (isClosed) return true;
    await _refreshFoods(
      state.copyWith(
        selectedFood: state.selectedFood?.id == id ? Nullable(updated) : null,
        error: const Nullable(null),
      ),
    );
    return true;
  }

  Future<bool> deleteFood(int id) async {
    _logger.info('Deleting food $id');
    emit(state.copyWith(isLoading: true));

    final result = await _foodService.deleteFood(id);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to delete food $id', error);
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(type: error.type.name, description: error.description),
          ),
          isLoading: false,
        ),
      );
      return false;
    }

    if (isClosed) return true;
    await _refreshFoods(
      state.copyWith(
        selectedFood: state.selectedFood?.id == id
            ? const Nullable(null)
            : null,
        isLoading: false,
        error: const Nullable(null),
      ),
    );
    return true;
  }
}
