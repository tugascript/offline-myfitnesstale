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

import '../../../data/repositories/workout_plans/inputs/workout_plan_input.dart';
import '../../../data/repositories/workout_plans/inputs/workout_plan_week_batch_create_input.dart';
import '../../../data/repositories/workout_plans/workout_plan_repository.dart';
import '../../../data/utils/enums.dart';
import '../../../utils/errors.dart';
import '../../../utils/nullable.dart';
import '../../core/view_models/states/common_state.dart';
import './states/workout_plan_state.dart';

class WorkoutPlanCubit extends Cubit<WorkoutPlanState> {
  final WorkoutPlanRepository _workoutPlanService;

  WorkoutPlanCubit({required WorkoutPlanRepository workoutPlanRepository})
    : _workoutPlanService = workoutPlanRepository,
      super(WorkoutPlanState.initial());

  final Logger _logger = Logger('WorkoutPlanCubit');

  Future<void> getWorkoutPlans({
    String? name,
    Difficulty? difficulty,
    bool isFavorite = false,
    int? limit,
    int? offset,
  }) => _loadWorkoutPlans(
    WorkoutPlanPagination(
      name: name ?? '',
      difficulty: difficulty,
      isFavorite: isFavorite,
      limit: limit ?? state.pagination.limit,
      offset: offset ?? state.pagination.offset,
      total: 0,
    ),
  );

  Future<void> _loadWorkoutPlans(
    WorkoutPlanPagination query, {
    WorkoutPlanState? afterWrite,
  }) async {
    final refresh = afterWrite != null;
    _logger.info('Getting workout plans');
    final requestId = state.plansRequestId + 1;
    final limit = refresh ? query.offset + query.limit : query.limit;
    final offset = refresh ? 0 : query.offset;
    emit(
      (afterWrite ?? state).copyWith(
        plansRequestId: requestId,
        pendingWorkoutPlansQuery: Nullable(query),
      ),
    );

    final result = await _workoutPlanService.getWorkoutPlans(
      name: query.name,
      difficulty: query.difficulty,
      isFavorite: query.isFavorite,
      limit: limit,
      offset: offset,
    );
    if (isClosed || requestId != state.plansRequestId) return;

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to get workout plans", error);
      switch (error.type) {
        case OperationErrorTypes.invalidInput:
        case OperationErrorTypes.operationFailure:
          emit(
            state.copyWith(
              error: Nullable(
                ErrorState(
                  type: error.type.name,
                  description: "Failed to get workout plans",
                ),
              ),
              pendingWorkoutPlansQuery: const Nullable(null),
              workoutPlans: refresh ? const [] : null,
              pagination: refresh
                  ? state.pagination.copyWith(total: 0, offset: 0)
                  : null,
            ),
          );
          return;
      }
    }

    final page = result.value;
    emit(
      state.copyWith(
        workoutPlans: offset > 0
            ? [...state.workoutPlans, ...page.data]
            : page.data,
        pagination: query.copyWith(offset: page.offset, total: page.total),
        pendingWorkoutPlansQuery: const Nullable(null),
        error: const Nullable(null),
      ),
    );
  }

  Future<void> _refreshWorkoutPlans(WorkoutPlanState afterWrite) {
    // A write can shift page boundaries. Reload the prefix for the latest query.
    final query =
        state.pendingWorkoutPlansQuery ??
        state.pagination.copyWith(
          offset: max(0, state.workoutPlans.length - state.pagination.limit),
        );
    return _loadWorkoutPlans(query, afterWrite: afterWrite);
  }

  Future<void> getWorkoutPlan(int id, {bool isRefresh = false}) async {
    _logger.info('Getting workout plan $id');
    if (!isRefresh) {
      emit(state.copyWith(isLoading: true));
    }

    final result = await _workoutPlanService.getWorkoutPlan(id);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to get workout plan $id", error);

      switch (error.type) {
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.notFound:
          emit(
            state.copyWith(
              error: Nullable(
                ErrorState(
                  type: error.type.name,
                  description: error.description,
                ),
              ),
              isLoading: false,
            ),
          );
          return;
        case SingleErrorTypes.operationFailure:
          emit(
            state.copyWith(
              error: Nullable(
                ErrorState(
                  type: error.type.name,
                  description: error.description,
                ),
              ),
              isLoading: false,
            ),
          );
          return;
      }
    }

    _logger.info('Workout plan $id retrieved successfully');
    emit(
      state.copyWith(
        selectedWorkoutPlan: Nullable(result.value),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }

  Future<void> createWorkoutPlanVersionWithWeeks({
    required int workoutPlanId,
    required List<WorkoutPlanWeekBatchCreateInput> weeks,
  }) async {
    _logger.info('Creating workout plan version for plan $workoutPlanId');
    emit(state.copyWith(isLoading: true));

    final result = await _workoutPlanService.createWorkoutPlanVersionWithWeeks(
      workoutPlanId: workoutPlanId,
      weeks: weeks,
    );

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to create workout plan version", error);
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

    final updatedPlan = result.value;
    if (isClosed) return;
    await _refreshWorkoutPlans(
      state.copyWith(
        selectedWorkoutPlan: Nullable(updatedPlan),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }

  Future<void> createWorkoutPlan(WorkoutPlanInput input) async {
    _logger.info('Creating workout plan');
    emit(state.copyWith(isLoading: true));

    final result = await _workoutPlanService.createWorkoutPlan(input);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to create workout plan", error);
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

    _logger.info('Workout plan created successfully');
    final newPlan = result.value;
    if (isClosed) return;
    await _refreshWorkoutPlans(
      state.copyWith(
        selectedWorkoutPlan: Nullable(newPlan),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }

  Future<void> updateWorkoutPlan(int id, WorkoutPlanInput input) async {
    _logger.info('Updating workout plan $id');
    emit(state.copyWith(isLoading: true));

    final result = await _workoutPlanService.updateWorkoutPlan(id, input);

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to update workout plan $id", error);
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

    _logger.info('Workout plan $id updated successfully');
    final updatedPlan = result.value.copyWith(
      weeks: Nullable(
        state.selectedWorkoutPlan?.id == id
            ? state.selectedWorkoutPlan?.weeks
            : result.value.weeks,
      ),
    );
    if (isClosed) return;
    await _refreshWorkoutPlans(
      state.copyWith(
        selectedWorkoutPlan: Nullable(updatedPlan),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }

  Future<void> updateWorkoutPlanFavorite(int id, bool isFavorite) async {
    _logger.info('Updating workout plan favorite $id');
    emit(state.copyWith(isLoading: true));

    final result = await _workoutPlanService.updateWorkoutPlanFavorite(
      id,
      isFavorite,
    );

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to update workout plan favorite $id", error);
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

    _logger.info('Workout plan favorite $id updated successfully');
    final updatedPlan = result.value.copyWith(
      weeks: Nullable(
        state.selectedWorkoutPlan?.id == id
            ? state.selectedWorkoutPlan?.weeks
            : result.value.weeks,
      ),
    );
    if (isClosed) return;
    await _refreshWorkoutPlans(
      state.copyWith(
        selectedWorkoutPlan: state.selectedWorkoutPlan?.id == id
            ? Nullable(updatedPlan)
            : null,
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }

  Future<void> deleteWorkoutPlan(int id) async {
    _logger.info('Deleting workout plan $id');
    emit(state.copyWith(isLoading: true));

    final result = await _workoutPlanService.deleteWorkoutPlan(id);

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to delete workout plan $id", error);
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

    _logger.info('Workout plan $id deleted successfully');
    if (isClosed) return;
    await _refreshWorkoutPlans(
      state.copyWith(
        selectedWorkoutPlan: state.selectedWorkoutPlan?.id == id
            ? const Nullable(null)
            : null,
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }
}
