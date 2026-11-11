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

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../../../utils/nullable.dart';
import '../../../data/utils/enums.dart';
import '../../../data/repositories/foods/dtos/food_dto.dart';
import '../../../data/repositories/foods/food_repository.dart';
import '../../../data/repositories/foods/inputs/food_input.dart';
import '../../core/view_models/states/common_state.dart';
import './states/food_state.dart';

class FoodCubit extends Cubit<FoodState> {
  final FoodRepository _foodService;
  final Logger _logger = Logger('FoodCubit');
  int _foodsRequestId = 0;

  FoodCubit({required FoodRepository foodRepository})
    : _foodService = foodRepository,
      super(FoodState.initial());

  Future<void> getFoods({
    String? search,
    FoodCategory? category,
    bool? isFavorite,
    int limit = 20,
    int offset = 0,
  }) async {
    _logger.info('Getting foods');
    final requestId = ++_foodsRequestId;
    emit(state.copyWith(isLoading: true));

    final result = await _foodService.getFoods(
      name: search,
      category: category,
      isFavorite: isFavorite ?? false,
      limit: limit,
      offset: offset,
    );
    if (requestId != _foodsRequestId) return;

    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to get foods', error);
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

    final paginated = result.value;
    final List<FoodDto> foods = offset > 0
        ? [...state.foods, ...paginated.data]
        : paginated.data;

    emit(
      state.copyWith(
        foodPagination: state.foodPagination.copyWith(
          limit: paginated.limit,
          offset: paginated.offset,
          total: paginated.total,
          name: search ?? '',
          category: Nullable(category),
          isFavorite: isFavorite ?? false,
        ),
        foods: foods,
        isLoading: false,
        error: const Nullable(null),
      ),
    );
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

    _foodsRequestId++;
    final created = result.value;
    final matchesFilter = _matchesFoodFilter(created);
    emit(
      state.copyWith(
        selectedFood: Nullable(created),
        foods: matchesFilter ? [created, ...state.foods] : state.foods,
        foodPagination: matchesFilter
            ? state.foodPagination.copyWith(
                total: state.foodPagination.total + 1,
              )
            : null,
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

    _foodsRequestId++;
    final updated = result.value;
    final matchesFilter = _matchesFoodFilter(updated);
    final wasInList = state.foods.any((f) => f.id == id);
    final updatedList = wasInList && !matchesFilter
        ? state.foods.where((f) => f.id != id).toList()
        : state.foods.map((f) => f.id == id ? updated : f).toList();
    final updatedTotal = wasInList && !matchesFilter
        ? (state.foodPagination.total > 0 ? state.foodPagination.total - 1 : 0)
        : state.foodPagination.total;

    emit(
      state.copyWith(
        selectedFood: Nullable(updated),
        foods: updatedList,
        foodPagination: state.foodPagination.copyWith(total: updatedTotal),
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

    _foodsRequestId++;
    final updated = result.value;
    final removeFromFavoritesList =
        state.foodPagination.isFavorite && !updated.isFavorite;
    final updatedList = removeFromFavoritesList
        ? state.foods.where((f) => f.id != id).toList()
        : state.foods.map((f) => f.id == id ? updated : f).toList();
    final updatedTotal = removeFromFavoritesList
        ? (state.foodPagination.total > 0 ? state.foodPagination.total - 1 : 0)
        : state.foodPagination.total;

    emit(
      state.copyWith(
        foods: updatedList,
        foodPagination: state.foodPagination.copyWith(total: updatedTotal),
        selectedFood: state.selectedFood?.id == id ? Nullable(updated) : null,
        error: const Nullable(null),
      ),
    );
    return true;
  }

  bool _matchesFoodFilter(FoodDto food) {
    final search = state.foodPagination.name.trim().toLowerCase();
    if (search.isNotEmpty && !food.name.toLowerCase().contains(search)) {
      return false;
    }
    final category = state.foodPagination.category;
    if (category != null && food.category != category) {
      return false;
    }
    if (state.foodPagination.isFavorite && !food.isFavorite) {
      return false;
    }
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

    final updatedList = state.foods.where((f) => f.id != id).toList();
    emit(
      state.copyWith(
        foodPagination: state.foodPagination.copyWith(
          total: state.foodPagination.total > 0
              ? state.foodPagination.total - 1
              : 0,
        ),
        foods: updatedList,
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
