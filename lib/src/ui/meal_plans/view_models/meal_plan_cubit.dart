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

import '../../../data/repositories/meal_plans/inputs/meal_plan_input.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../../../utils/nullable.dart';
import '../../../data/utils/enums.dart';
import '../../../data/repositories/meal_plans/dtos/meal_plan_dto.dart';
import '../../../data/repositories/meal_plans/meal_plan_repository.dart';
import '../../core/view_models/states/common_state.dart';
import './states/meal_plan_state.dart';

class MealPlanCubit extends Cubit<MealPlanState> {
  final MealPlanRepository _mealPlanService;
  final Logger _logger = Logger('MealPlanCubit');
  int _mealPlansRequestId = 0;

  MealPlanCubit({required MealPlanRepository mealPlanRepository})
    : _mealPlanService = mealPlanRepository,
      super(MealPlanState.initial());

  Future<void> getMealPlans({
    String? search,
    bool? isFavorite,
    int limit = 20,
    int offset = 0,
  }) async {
    _logger.info('Getting meal plans');
    final requestId = ++_mealPlansRequestId;
    emit(state.copyWith(isLoading: true));

    final result = await _mealPlanService.getMealPlans(
      search: search,
      isFavorite: isFavorite,
      limit: limit,
      offset: offset,
    );
    if (requestId != _mealPlansRequestId) return;

    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to get meal plans', error);
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
    final List<MealPlanDto> plans = offset > 0
        ? [...state.mealPlans, ...paginated.data]
        : paginated.data;

    emit(
      state.copyWith(
        mealPlanPagination: state.mealPlanPagination.copyWith(
          limit: paginated.limit,
          offset: paginated.offset,
          total: paginated.total,
          search: Nullable(search),
          isFavorite: Nullable(isFavorite),
        ),
        mealPlans: plans,
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }

  Future<void> getMealPlan(int id, {int? version}) async {
    _logger.info('Getting meal plan $id');
    emit(state.copyWith(isLoading: true));

    final result = await _mealPlanService.getMealPlan(id, version: version);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to get meal plan $id', error);
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
        selectedMealPlan: Nullable(result.value),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }

  Future<bool> createMealPlan(
    MealPlanInput input, [
    CreatedBy createdBy = CreatedBy.user,
  ]) async {
    _logger.info('Creating meal plan ${input.name}');
    emit(state.copyWith(isLoading: true));

    final result = await _mealPlanService.createMealPlan(input, createdBy);

    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to create meal plan', error);
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

    _mealPlansRequestId++;
    final created = result.value;
    final matchesFilter = _matchesMealPlanFilter(created);
    emit(
      state.copyWith(
        selectedMealPlan: Nullable(created),
        mealPlans: matchesFilter
            ? [created, ...state.mealPlans]
            : state.mealPlans,
        mealPlanPagination: matchesFilter
            ? state.mealPlanPagination.copyWith(
                total: state.mealPlanPagination.total + 1,
              )
            : null,
        isLoading: false,
        error: const Nullable(null),
      ),
    );
    return true;
  }

  Future<bool> updateMealPlan(int id, MealPlanInput input) async {
    _logger.info('Updating meal plan $id');
    emit(state.copyWith(isLoading: true));

    final result = await _mealPlanService.updateMealPlan(id, input);

    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to update meal plan $id', error);
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

    _mealPlansRequestId++;
    final updated = result.value;
    final matchesFilter = _matchesMealPlanFilter(updated);
    final wasInList = state.mealPlans.any((p) => p.id == id);
    final updatedList = wasInList && !matchesFilter
        ? state.mealPlans.where((p) => p.id != id).toList()
        : state.mealPlans.map((p) => p.id == id ? updated : p).toList();
    final updatedTotal = wasInList && !matchesFilter
        ? (state.mealPlanPagination.total > 0
              ? state.mealPlanPagination.total - 1
              : 0)
        : state.mealPlanPagination.total;

    emit(
      state.copyWith(
        selectedMealPlan: Nullable(updated),
        mealPlans: updatedList,
        mealPlanPagination: state.mealPlanPagination.copyWith(
          total: updatedTotal,
        ),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
    return true;
  }

  Future<bool> toggleFavorite(int id) async {
    _logger.info('Toggling favorite for meal plan $id');
    final result = await _mealPlanService.toggleFavorite(id);
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

    _mealPlansRequestId++;
    final updated = result.value;
    final removeByFavoriteFilter =
        state.mealPlanPagination.isFavorite != null &&
        updated.isFavorite != state.mealPlanPagination.isFavorite;
    final updatedList = removeByFavoriteFilter
        ? state.mealPlans.where((p) => p.id != id).toList()
        : state.mealPlans.map((p) => p.id == id ? updated : p).toList();
    final updatedTotal = removeByFavoriteFilter
        ? (state.mealPlanPagination.total > 0
              ? state.mealPlanPagination.total - 1
              : 0)
        : state.mealPlanPagination.total;

    emit(
      state.copyWith(
        mealPlans: updatedList,
        mealPlanPagination: state.mealPlanPagination.copyWith(
          total: updatedTotal,
        ),
        selectedMealPlan: state.selectedMealPlan?.id == id
            ? Nullable(updated)
            : null,
        error: const Nullable(null),
      ),
    );
    return true;
  }

  bool _matchesMealPlanFilter(MealPlanDto plan) {
    final search = state.mealPlanPagination.search?.trim().toLowerCase() ?? '';
    if (search.isNotEmpty && !plan.name.toLowerCase().contains(search)) {
      return false;
    }
    final isFavoriteFilter = state.mealPlanPagination.isFavorite;
    if (isFavoriteFilter != null && plan.isFavorite != isFavoriteFilter) {
      return false;
    }
    return true;
  }

  Future<bool> deleteMealPlan(int id) async {
    _logger.info('Deleting meal plan $id');
    emit(state.copyWith(isLoading: true));

    final result = await _mealPlanService.deleteMealPlan(id);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to delete meal plan $id', error);
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

    final updated = state.mealPlans.where((p) => p.id != id).toList();
    emit(
      state.copyWith(
        mealPlanPagination: state.mealPlanPagination.copyWith(
          total: state.mealPlanPagination.total > 0
              ? state.mealPlanPagination.total - 1
              : 0,
        ),
        mealPlans: updated,
        selectedMealPlan: state.selectedMealPlan?.id == id
            ? const Nullable(null)
            : null,
        isLoading: false,
        error: const Nullable(null),
      ),
    );
    return true;
  }
}
