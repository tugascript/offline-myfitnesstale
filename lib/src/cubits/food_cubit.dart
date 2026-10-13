import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../common/nullable.dart';
import '../models/enums.dart';
import '../services/dtos/food_dto.dart';
import '../services/food_service.dart';
import '../services/inputs/food_input.dart';
import 'states/common_state.dart';
import 'states/food_state.dart';

class FoodCubit extends Cubit<FoodState> {
  final FoodService _foodService = FoodService();
  final Logger _logger = Logger('FoodCubit');

  FoodCubit() : super(FoodState.initial());

  Future<void> getFoods({
    String? search,
    FoodCategory? category,
    bool? isFavorite,
    int limit = 20,
    int offset = 0,
  }) async {
    _logger.info('Getting foods');
    emit(state.copyWith(
      foodPagination: state.foodPagination.copyWith(
        limit: limit,
        offset: offset,
        name: search ?? '',
        category: Nullable(category),
        isFavorite: isFavorite ?? false,
      ),
      isLoading: true,
    ));

    final result = await _foodService.getFoods(
      name: search,
      category: category,
      isFavorite: isFavorite ?? false,
      limit: limit,
      offset: offset,
    );

    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to get foods', error);
      emit(state.copyWith(
        error: Nullable(ErrorState(
          type: error.type.name,
          description: error.description,
        )),
        isLoading: false,
      ));
      return;
    }

    final paginated = result.value;
    final List<FoodDto> foods =
        offset > 0 ? [...state.foods, ...paginated.data] : paginated.data;

    emit(state.copyWith(
      foodPagination: state.foodPagination.copyWith(
        total: paginated.total,
      ),
      foods: foods,
      isLoading: false,
      error: const Nullable(null),
    ));
  }

  Future<void> getFood(int id) async {
    _logger.info('Getting food $id');
    emit(state.copyWith(isLoading: true));

    final result = await _foodService.getFood(id);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to get food $id', error);
      emit(state.copyWith(
        error: Nullable(ErrorState(
          type: error.type.name,
          description: error.description,
        )),
        isLoading: false,
      ));
      return;
    }

    emit(state.copyWith(
      selectedFood: Nullable(result.value),
      isLoading: false,
      error: const Nullable(null),
    ));
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
      emit(state.copyWith(
        error: Nullable(ErrorState(
          type: error.type.name,
          description: error.description,
        )),
        isLoading: false,
      ));
      return false;
    }

    emit(state.copyWith(
      selectedFood: Nullable(result.value),
      isLoading: false,
      error: const Nullable(null),
    ));
    await getFoods(
      search: state.foodPagination.name,
      category: state.foodPagination.category,
      isFavorite: state.foodPagination.isFavorite,
      limit: state.foodPagination.limit,
      offset: 0,
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
      emit(state.copyWith(
        error: Nullable(ErrorState(
          type: error.type.name,
          description: error.description,
        )),
        isLoading: false,
      ));
      return false;
    }

    emit(state.copyWith(
      selectedFood: Nullable(result.value),
      isLoading: false,
      error: const Nullable(null),
    ));
    await getFoods(
      search: state.foodPagination.name,
      category: state.foodPagination.category,
      isFavorite: state.foodPagination.isFavorite,
      limit: state.foodPagination.limit,
      offset: 0,
    );
    return true;
  }

  Future<bool> toggleFavorite(int id) async {
    _logger.info('Toggling favorite for food $id');
    final result = await _foodService.toggleFavorite(id);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to toggle favorite', error);
      emit(state.copyWith(
        error: Nullable(ErrorState(
          type: error.type.name,
          description: error.description,
        )),
      ));
      return false;
    }

    final updated = result.value;
    final updatedList =
        state.foods.map((f) => f.id == id ? updated : f).toList();
    emit(state.copyWith(
      foods: updatedList,
      selectedFood: state.selectedFood?.id == id ? Nullable(updated) : null,
      error: const Nullable(null),
    ));
    return true;
  }

  Future<bool> deleteFood(int id) async {
    _logger.info('Deleting food $id');
    emit(state.copyWith(isLoading: true));

    final result = await _foodService.deleteFood(id);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to delete food $id', error);
      emit(state.copyWith(
        error: Nullable(ErrorState(
          type: error.type.name,
          description: error.description,
        )),
        isLoading: false,
      ));
      return false;
    }

    final updatedList = state.foods.where((f) => f.id != id).toList();
    emit(state.copyWith(
      foodPagination: state.foodPagination.copyWith(
        total:
            state.foodPagination.total > 0 ? state.foodPagination.total - 1 : 0,
      ),
      foods: updatedList,
      selectedFood: state.selectedFood?.id == id ? const Nullable(null) : null,
      isLoading: false,
      error: const Nullable(null),
    ));
    return true;
  }
}
