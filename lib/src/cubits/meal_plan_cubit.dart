import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../common/nullable.dart';
import '../models/enums.dart';
import '../services/dtos/meal_plan_dto.dart';
import '../services/meal_plan_service.dart';
import 'states/common_state.dart';
import 'states/meal_plan_state.dart';

class MealPlanCubit extends Cubit<MealPlanState> {
  final MealPlanService _mealPlanService = MealPlanService();
  final Logger _logger = Logger('MealPlanCubit');

  MealPlanCubit() : super(MealPlanState.initial());

  Future<void> getMealPlans({
    String? search,
    bool? isFavorite,
    int limit = 20,
    int offset = 0,
  }) async {
    _logger.info('Getting meal plans');
    emit(state.copyWith(
      isLoading: true,
      search: Nullable(search),
      isFavorite: Nullable(isFavorite),
      limit: limit,
      offset: offset,
    ));

    final result = await _mealPlanService.getMealPlans(
      search: search,
      isFavorite: isFavorite,
      limit: limit,
      offset: offset,
    );

    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to get meal plans', error);
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
    final List<MealPlanDto> plans =
        offset > 0 ? [...state.mealPlans, ...paginated.data] : paginated.data;

    emit(state.copyWith(
      mealPlans: plans,
      total: paginated.total,
      isLoading: false,
      error: const Nullable(null),
    ));
  }

  Future<void> getMealPlan(int id, {int? version}) async {
    _logger.info('Getting meal plan $id');
    emit(state.copyWith(isLoading: true));

    final result = await _mealPlanService.getMealPlan(id, version: version);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to get meal plan $id', error);
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
      selectedMealPlan: Nullable(result.value),
      isLoading: false,
      error: const Nullable(null),
    ));
  }

  Future<bool> createMealPlan({
    required String name,
    String? description,
    CreatedBy createdBy = CreatedBy.user,
    List<MealPlanWeekInput> weeks = const [],
  }) async {
    _logger.info('Creating meal plan $name');
    emit(state.copyWith(isLoading: true));

    final result = await _mealPlanService.createMealPlan(
      name: name,
      description: description,
      createdBy: createdBy,
      weeks: weeks,
    );

    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to create meal plan', error);
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
      selectedMealPlan: Nullable(result.value),
      isLoading: false,
      error: const Nullable(null),
    ));
    await getMealPlans(search: state.search, limit: state.limit, offset: 0);
    return true;
  }

  Future<bool> updateMealPlan({
    required int id,
    String? name,
    String? description,
    List<MealPlanWeekInput>? weeks,
  }) async {
    _logger.info('Updating meal plan $id');
    emit(state.copyWith(isLoading: true));

    final result = await _mealPlanService.updateMealPlan(
      id: id,
      name: name,
      description: description,
      weeks: weeks,
    );

    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to update meal plan $id', error);
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
      selectedMealPlan: Nullable(result.value),
      isLoading: false,
      error: const Nullable(null),
    ));
    await getMealPlans(search: state.search, limit: state.limit, offset: 0);
    return true;
  }

  Future<bool> toggleFavorite(int id) async {
    _logger.info('Toggling favorite for meal plan $id');
    final result = await _mealPlanService.toggleFavorite(id);
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
        state.mealPlans.map((p) => p.id == id ? updated : p).toList();
    emit(state.copyWith(
      mealPlans: updatedList,
      selectedMealPlan:
          state.selectedMealPlan?.id == id ? Nullable(updated) : null,
      error: const Nullable(null),
    ));
    return true;
  }

  Future<bool> deleteMealPlan(int id) async {
    _logger.info('Deleting meal plan $id');
    emit(state.copyWith(isLoading: true));

    final result = await _mealPlanService.deleteMealPlan(id);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to delete meal plan $id', error);
      emit(state.copyWith(
        error: Nullable(ErrorState(
          type: error.type.name,
          description: error.description,
        )),
        isLoading: false,
      ));
      return false;
    }

    final updated = state.mealPlans.where((p) => p.id != id).toList();
    emit(state.copyWith(
      mealPlans: updated,
      total: state.total > 0 ? state.total - 1 : 0,
      selectedMealPlan:
          state.selectedMealPlan?.id == id ? const Nullable(null) : null,
      isLoading: false,
      error: const Nullable(null),
    ));
    return true;
  }
}
