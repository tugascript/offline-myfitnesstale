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

import '../../../data/repositories/meal_plans/inputs/meal_plan_input.dart';
import '../../../data/repositories/meal_plans/meal_plan_repository.dart';
import '../../../data/utils/enums.dart';
import '../../../utils/nullable.dart';
import '../../core/view_models/favorite_request_serializer.dart';
import '../../core/view_models/states/common_state.dart';
import './states/meal_plan_state.dart';

class MealPlanCubit extends Cubit<MealPlanState>
    with FavoriteRequestSerializer {
  final MealPlanRepository _mealPlanService;
  final Logger _logger = Logger('MealPlanCubit');

  MealPlanCubit({required MealPlanRepository mealPlanRepository})
    : _mealPlanService = mealPlanRepository,
      super(MealPlanState.initial());

  Future<void> getMealPlans({
    String? search,
    bool? isFavorite,
    int limit = 20,
    int offset = 0,
  }) => _loadMealPlans(
    MealPlanPagination(
      search: search,
      isFavorite: isFavorite,
      limit: limit,
      offset: offset,
    ),
  );

  Future<void> _loadMealPlans(
    MealPlanPagination query, {
    MealPlanState? afterWrite,
  }) async {
    final refresh = afterWrite != null;
    _logger.info('Getting meal plans');
    final requestId = state.mealPlansRequestId + 1;
    final limit = refresh ? query.offset + query.limit : query.limit;
    final offset = refresh ? 0 : query.offset;
    emit(
      (afterWrite ?? state).copyWith(
        mealPlansRequestId: requestId,
        pendingMealPlansQuery: Nullable(query),
      ),
    );

    final result = await _mealPlanService.getMealPlans(
      search: query.search,
      isFavorite: query.isFavorite,
      limit: limit,
      offset: offset,
    );
    if (isClosed || requestId != state.mealPlansRequestId) return;

    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to get meal plans', error);
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(type: error.type.name, description: error.description),
          ),
          pendingMealPlansQuery: const Nullable(null),
          mealPlans: refresh ? const [] : null,
          mealPlanPagination: refresh
              ? state.mealPlanPagination.copyWith(total: 0, offset: 0)
              : null,
        ),
      );
      return;
    }

    final page = result.value;
    emit(
      state.copyWith(
        mealPlans: offset > 0 ? [...state.mealPlans, ...page.data] : page.data,
        mealPlanPagination: query.copyWith(
          offset: page.offset,
          total: page.total,
        ),
        pendingMealPlansQuery: const Nullable(null),
        error: const Nullable(null),
      ),
    );
  }

  Future<void> _refreshMealPlans(MealPlanState afterWrite) {
    // A write can shift page boundaries. Reload the prefix for the latest query.
    final query =
        state.pendingMealPlansQuery ??
        state.mealPlanPagination.copyWith(
          offset: max(
            0,
            state.mealPlans.length - state.mealPlanPagination.limit,
          ),
        );
    return _loadMealPlans(query, afterWrite: afterWrite);
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

    final created = result.value;
    if (isClosed) return true;
    await _refreshMealPlans(
      state.copyWith(
        selectedMealPlan: Nullable(created),
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

    final updated = result.value;
    if (isClosed) return true;
    await _refreshMealPlans(
      state.copyWith(
        selectedMealPlan: Nullable(updated),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
    return true;
  }

  Future<bool> toggleFavorite(int id) {
    return serializeFavorite(() async {
      if (isClosed) return false;
      _logger.info('Toggling favorite for meal plan $id');
      final result = await _mealPlanService.toggleFavorite(id);
      if (result.isErr()) {
        if (isClosed) return false;
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
      final selected = state.selectedMealPlan;
      await _refreshMealPlans(
        state.copyWith(
          selectedMealPlan: selected != null && selected.id == id
              ? Nullable(selected.copyWith(isFavorite: updated.isFavorite))
              : null,
          error: const Nullable(null),
        ),
      );
      return true;
    });
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

    if (isClosed) return true;
    await _refreshMealPlans(
      state.copyWith(
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
