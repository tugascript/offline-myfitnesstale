import '../services/inputs/meal_plan_input.dart';
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
      mealPlanPagination: state.mealPlanPagination.copyWith(
        limit: limit,
        offset: offset,
        search: Nullable(search),
        isFavorite: Nullable(isFavorite),
      ),
      isLoading: true,
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
      mealPlanPagination: state.mealPlanPagination.copyWith(
        total: paginated.total,
      ),
      mealPlans: plans,
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

  Future<bool> createMealPlan(MealPlanInput input,
      [CreatedBy createdBy = CreatedBy.user]) async {
    _logger.info('Creating meal plan ${input.name}');
    emit(state.copyWith(isLoading: true));

    final result = await _mealPlanService.createMealPlan(input, createdBy);

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
    await getMealPlans(
        search: state.mealPlanPagination.search,
        isFavorite: state.mealPlanPagination.isFavorite,
        limit: state.mealPlanPagination.limit,
        offset: 0);
    return true;
  }

  Future<bool> updateMealPlan(int id, MealPlanInput input) async {
    _logger.info('Updating meal plan $id');
    emit(state.copyWith(isLoading: true));

    final result = await _mealPlanService.updateMealPlan(id, input);

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
    await getMealPlans(
        search: state.mealPlanPagination.search,
        isFavorite: state.mealPlanPagination.isFavorite,
        limit: state.mealPlanPagination.limit,
        offset: 0);
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
      mealPlanPagination: state.mealPlanPagination.copyWith(
        total: state.mealPlanPagination.total > 0
            ? state.mealPlanPagination.total - 1
            : 0,
      ),
      mealPlans: updated,
      selectedMealPlan:
          state.selectedMealPlan?.id == id ? const Nullable(null) : null,
      isLoading: false,
      error: const Nullable(null),
    ));
    return true;
  }
}
