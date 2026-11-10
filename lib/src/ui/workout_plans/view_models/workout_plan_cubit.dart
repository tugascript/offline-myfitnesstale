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
import '../../../utils/errors.dart';
import '../../../data/repositories/workout_plans/workout_plan_repository.dart';
import '../../core/view_models/states/common_state.dart';
import './states/workout_plan_state.dart';

export '../../../data/repositories/workout_plans/inputs/workout_plan_input.dart';

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
  }) async {
    _logger.info('Getting workout plans');
    final resolvedOffset = offset ?? state.pagination.offset;
    final isLoadMore = resolvedOffset > 0;
    emit(state.copyWith(isLoading: true));

    final result = await _workoutPlanService.getWorkoutPlans(
      name: name,
      difficulty: difficulty,
      isFavorite: isFavorite,
      limit: limit ?? state.pagination.limit,
      offset: resolvedOffset,
    );
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
              isLoading: false,
            ),
          );
          return;
      }
    }

    _logger.info('Workout plans retrieved successfully');
    final paginatedData = result.value;
    emit(
      state.copyWith(
        workoutPlans: isLoadMore
            ? [...state.workoutPlans, ...paginatedData.data]
            : paginatedData.data,
        pagination: state.pagination.copyWith(
          name: name,
          difficulty: Nullable(difficulty),
          isFavorite: isFavorite,
          limit: paginatedData.limit,
          offset: paginatedData.offset,
          total: paginatedData.total,
        ),
        isLoading: false,
      ),
    );
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

    await getWorkoutPlan(workoutPlanId, isRefresh: true);
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
    emit(
      state.copyWith(
        workoutPlans: [newPlan, ...state.workoutPlans],
        pagination: state.pagination.copyWith(
          total: state.pagination.total + 1,
        ),
        selectedWorkoutPlan: Nullable(newPlan),
        isLoading: false,
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
    await getWorkoutPlan(id, isRefresh: true);
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
    await getWorkoutPlan(id, isRefresh: true);
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
    emit(
      state.copyWith(
        workoutPlans: state.workoutPlans.where((p) => p.id != id).toList(),
        selectedWorkoutPlan: state.selectedWorkoutPlan?.id == id
            ? const Nullable(null)
            : null,
        pagination: state.pagination.copyWith(
          total: state.pagination.total - 1,
        ),
        isLoading: false,
      ),
    );
  }
}
