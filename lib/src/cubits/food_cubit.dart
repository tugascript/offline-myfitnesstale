import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../common/nullable.dart';
import '../models/common.dart';
import '../models/enums.dart';
import '../services/dtos/food_dto.dart';
import '../services/food_service.dart';
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
      isLoading: true,
      search: Nullable(search),
      category: Nullable(category),
      isFavorite: Nullable(isFavorite),
      limit: limit,
      offset: offset,
    ));

    final result = await _foodService.getFoods(
      search: search,
      category: category,
      isFavorite: isFavorite,
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
      foods: foods,
      total: paginated.total,
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

  Future<bool> createFood({
    required String name,
    required FoodCategory category,
    String? brand,
    String? barcode,
    int servingSizeBase = 100,
    String servingUnitBase = 'g',
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
    emit(state.copyWith(isLoading: true));

    final result = await _foodService.createFood(
      name: name,
      category: category,
      brand: brand,
      barcode: barcode,
      servingSizeBase: servingSizeBase,
      servingUnitBase: servingUnitBase,
      caloriesBase: caloriesBase,
      proteinBase: proteinBase,
      carbsBase: carbsBase,
      fatBase: fatBase,
      fiberBase: fiberBase,
      micros: micros,
      isFavorite: isFavorite,
      createdBy: createdBy,
      portions: portions,
    );

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
      search: state.search,
      category: state.category,
      isFavorite: state.isFavorite,
      limit: state.limit,
      offset: 0,
    );
    return true;
  }

  Future<bool> updateFood({
    required int id,
    String? name,
    FoodCategory? category,
    String? brand,
    String? barcode,
    int? servingSizeBase,
    String? servingUnitBase,
    int? caloriesBase,
    int? proteinBase,
    int? carbsBase,
    int? fatBase,
    int? fiberBase,
    Micronutrients? micros,
    bool? isFavorite,
    List<FoodPortionInput>? portions,
  }) async {
    _logger.info('Updating food $id');
    emit(state.copyWith(isLoading: true));

    final result = await _foodService.updateFood(
      id: id,
      name: name,
      category: category,
      brand: brand,
      barcode: barcode,
      servingSizeBase: servingSizeBase,
      servingUnitBase: servingUnitBase,
      caloriesBase: caloriesBase,
      proteinBase: proteinBase,
      carbsBase: carbsBase,
      fatBase: fatBase,
      fiberBase: fiberBase,
      micros: micros,
      isFavorite: isFavorite,
      portions: portions,
    );

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
      search: state.search,
      category: state.category,
      isFavorite: state.isFavorite,
      limit: state.limit,
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
      foods: updatedList,
      total: state.total > 0 ? state.total - 1 : 0,
      selectedFood: state.selectedFood?.id == id ? const Nullable(null) : null,
      isLoading: false,
      error: const Nullable(null),
    ));
    return true;
  }
}
