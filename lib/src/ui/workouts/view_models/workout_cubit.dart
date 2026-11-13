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

import '../../../data/repositories/workouts/inputs/complex_set_input.dart';
import '../../../data/repositories/workouts/inputs/standard_set_input.dart';
import '../../../data/repositories/workouts/inputs/workout_input.dart';
import '../../../data/repositories/workouts/inputs/workout_set_exercise_upsert_input.dart';
import '../../../data/repositories/workouts/inputs/workout_set_upsert_input.dart';
import '../../../data/repositories/workouts/workout_repository.dart';
import '../../../data/utils/enums.dart';
import '../../../utils/errors.dart';
import '../../../utils/nullable.dart';
import '../../core/view_models/favorite_request_serializer.dart';
import '../../core/view_models/states/common_state.dart';
import './states/workout_state.dart';

class WorkoutCubit extends Cubit<WorkoutState> with FavoriteRequestSerializer {
  final WorkoutRepository _workoutService;

  final Logger _logger = Logger('WorkoutCubit');

  WorkoutCubit({required WorkoutRepository workoutRepository})
    : _workoutService = workoutRepository,
      super(WorkoutState.initial());

  Future<void> getWorkouts({
    String? name,
    Difficulty? difficulty,
    MuscleGroup? muscleGroup,
    int? limit,
    int? offset,
    bool isFavorite = false,
    CreatedBy? createdBy,
  }) => _loadWorkouts(
    WorkoutPagination(
      name: name ?? '',
      difficulty: difficulty,
      muscleGroup: muscleGroup,
      isFavorite: isFavorite,
      createdBy: createdBy,
      limit: limit ?? state.pagination.limit,
      offset: offset ?? state.pagination.offset,
      total: 0,
    ),
  );

  Future<void> _loadWorkouts(
    WorkoutPagination query, {
    WorkoutState? afterWrite,
  }) async {
    final refresh = afterWrite != null;
    _logger.info('Getting workouts');
    final requestId = state.workoutsRequestId + 1;
    final limit = refresh ? query.offset + query.limit : query.limit;
    final offset = refresh ? 0 : query.offset;
    emit(
      (afterWrite ?? state).copyWith(
        workoutsRequestId: requestId,
        pendingWorkoutsQuery: Nullable(query),
      ),
    );

    final result = await _workoutService.getWorkouts(
      name: query.name,
      difficulty: query.difficulty,
      muscleGroup: query.muscleGroup,
      isFavorite: query.isFavorite,
      createdBy: query.createdBy,
      limit: limit,
      offset: offset,
    );
    if (isClosed || requestId != state.workoutsRequestId) return;

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to get workouts", error);

      switch (error.type) {
        case OperationErrorTypes.invalidInput:
        case OperationErrorTypes.operationFailure:
          emit(
            state.copyWith(
              error: Nullable(
                ErrorState(
                  type: error.type.name,
                  description: "Failed to get workouts",
                ),
              ),
              pendingWorkoutsQuery: const Nullable(null),
              workouts: refresh ? const [] : null,
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
        workouts: offset > 0 ? [...state.workouts, ...page.data] : page.data,
        pagination: query.copyWith(offset: page.offset, total: page.total),
        pendingWorkoutsQuery: const Nullable(null),
        error: const Nullable(null),
      ),
    );
  }

  Future<void> _refreshWorkouts(WorkoutState afterWrite) {
    // A write can shift page boundaries. Reload the prefix for the latest query.
    final query =
        state.pendingWorkoutsQuery ??
        state.pagination.copyWith(
          offset: max(0, state.workouts.length - state.pagination.limit),
        );
    return _loadWorkouts(query, afterWrite: afterWrite);
  }

  Future<void> createWorkout(WorkoutInput input) async {
    _logger.info('Creating workout');
    emit(state.copyWith(isLoading: true));

    final result = await _workoutService.createWorkout(input);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to create workout", error);

      switch (error.type) {
        case OperationErrorTypes.invalidInput:
        case OperationErrorTypes.operationFailure:
          emit(
            state.copyWith(
              error: Nullable(
                ErrorState(
                  type: error.type.name,
                  description: "Failed to create workout",
                ),
              ),
              isLoading: false,
            ),
          );
          return;
      }
    }

    _logger.info("Workout created successfully");
    final workout = result.value;
    if (isClosed) return;
    await _refreshWorkouts(
      state.copyWith(
        selectedWorkout: Nullable(workout),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }

  Future<void> getWorkout(int id, {int? version, bool refresh = false}) async {
    _logger.info('Getting workout with id $id');
    if (!refresh) {
      emit(state.copyWith(isLoading: true));
    }

    final result = await _workoutService.getWorkout(id, version: version);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to get workout", error);

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
                  description: "Failed to get workout",
                ),
              ),
              isLoading: false,
            ),
          );
          return;
      }
    }

    _logger.info("Workout got successfully");
    emit(
      state.copyWith(
        selectedWorkout: Nullable(result.value),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }

  Future<void> updateWorkout(int id, WorkoutInput input) async {
    _logger.info('Updating workout with id $id');
    emit(state.copyWith(isLoading: true));

    final result = await _workoutService.updateWorkout(id, input);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to update workout", error);

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
                  description: "Failed to update workout",
                ),
              ),
              isLoading: false,
            ),
          );
          return;
      }
    }

    _logger.info("Workout updated successfully");
    final workout = result.value.copyWith(
      sets: Nullable(
        state.selectedWorkout?.id == id
            ? state.selectedWorkout?.sets
            : result.value.sets,
      ),
    );
    if (isClosed) return;
    await _refreshWorkouts(
      state.copyWith(
        selectedWorkout: Nullable(workout),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }

  Future<void> updateWorkoutFavorite(int id, bool isFavorite) {
    return serializeFavorite(() async {
      if (isClosed) return;
      _logger.info('Updating workout favorite status with id $id');
      emit(state.copyWith(isLoading: true));

      final result = await _workoutService.updateWorkoutFavorite(
        id,
        isFavorite,
      );
      if (result.isErr()) {
        if (isClosed) return;
        final error = result.error;
        _logger.warning("Failed to update workout favorite status", error);

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
                    description: "Failed to update workout",
                  ),
                ),
                isLoading: false,
              ),
            );
            return;
        }
      }

      _logger.info("Workout favorite status updated successfully");
      final workout = result.value.copyWith(
        sets: Nullable(
          state.selectedWorkout?.id == id
              ? state.selectedWorkout?.sets
              : result.value.sets,
        ),
      );
      if (isClosed) return;
      await _refreshWorkouts(
        state.copyWith(
          selectedWorkout: state.selectedWorkout?.id == id
              ? Nullable(workout)
              : null,
          isLoading: false,
          error: const Nullable(null),
        ),
      );
    });
  }

  Future<void> deleteWorkout(int id) async {
    _logger.info("Deleting workout id: $id");
    emit(state.copyWith(isLoading: true));

    final result = await _workoutService.deleteWorkout(id);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to delete workout", error);

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
                  description: "Failed to delete workout",
                ),
              ),
              isLoading: false,
            ),
          );
          return;
      }
    }

    _logger.info("Workout deleted successfully");
    if (isClosed) return;
    await _refreshWorkouts(
      state.copyWith(
        selectedWorkout: const Nullable(null),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }

  Future<void> refreshWorkoutSets(int workoutId) async {
    _logger.info('Refreshing workout sets for workout $workoutId');

    final sets = await _workoutService.getWorkoutSets(
      workoutId,
      version: state.selectedWorkout?.version,
    );
    if (sets.isErr()) {
      final error = sets.error;
      _logger.warning("Failed to get workout sets", error);
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

    final updatedSets = sets.value;
    emit(
      state.copyWith(
        selectedWorkout: state.selectedWorkout != null
            ? Nullable(
                state.selectedWorkout!.copyWith(sets: Nullable(updatedSets)),
              )
            : null,
        error: const Nullable(null),
        isLoading: false,
      ),
    );
  }

  Future<void> batchUpsertBasicWorkoutSets({
    required int workoutId,
    required List<StandardSetInput> sets,
  }) async {
    _logger.info('Batch updating workout sets for workout $workoutId');
    emit(state.copyWith(isLoading: true));

    final List<WorkoutSetUpsertInput> setsToUpsert = [];
    for (int i = 0; i < sets.length; i++) {
      final s = sets[i];
      setsToUpsert.add(
        WorkoutSetUpsertInput(
          id: s.id,
          setType: WorkoutSetType.standard,
          minSets: s.minSets,
          maxSets: s.maxSets >= s.minSets ? s.maxSets : null,
          recommendedRestSecs: s.recommendedRestSecs,
          maxRestSecs: s.maxRestSecs,
          position: i + 1,
          exercises: [
            WorkoutSetExerciseUpsertInput(
              id: s.setExerciseId,
              position: 1,
              exerciseId: s.exerciseId,
              minReps: s.minReps,
              maxReps: s.maxReps >= s.minReps ? s.maxReps : null,
              toMaxReps: s.toMaxReps,
            ),
          ],
        ),
      );
    }

    final result = await _workoutService.batchUpsertWorkoutSets(
      workoutId: workoutId,
      inputs: setsToUpsert,
    );

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to batch upsert workout sets", error);
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

    await getWorkout(workoutId, refresh: true);
  }

  Future<void> batchUpsertComplexWorkoutSets({
    required int workoutId,
    required List<ComplexSetInput> sets,
  }) async {
    _logger.info('Batch updating complex workout sets for workout $workoutId');
    emit(state.copyWith(isLoading: true));

    if (sets.isEmpty) {
      emit(state.copyWith(isLoading: false));
      return;
    }

    final List<WorkoutSetUpsertInput> setsToUpsert = [];
    for (int i = 0; i < sets.length; i++) {
      final s = sets[i];
      final exercises = s.exercises.map((exercise) {
        return WorkoutSetExerciseUpsertInput(
          id: exercise.id,
          exerciseId: exercise.exerciseId,
          position: exercise.position,
          minReps: exercise.minReps,
          maxReps:
              exercise.maxReps != null && exercise.maxReps! >= exercise.minReps
              ? exercise.maxReps
              : null,
          toMaxReps: exercise.toMaxReps,
          difficulty: exercise.difficulty,
          alternativeExerciseIds: exercise.alternativeExerciseIds.isEmpty
              ? null
              : exercise.alternativeExerciseIds.toList(),
        );
      }).toList();

      setsToUpsert.add(
        WorkoutSetUpsertInput(
          id: s.id,
          setType: s.setType,
          minSets: s.minSets,
          maxSets: s.maxSets != null && s.maxSets! >= s.minSets
              ? s.maxSets
              : null,
          recommendedRestSecs: s.recommendedRestSecs,
          maxRestSecs: s.maxRestSecs,
          position: s.position,
          exercises: exercises,
        ),
      );
    }

    final result = await _workoutService.batchUpsertWorkoutSets(
      workoutId: workoutId,
      inputs: setsToUpsert,
    );

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to batch upsert complex workout sets", error);
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

    await getWorkout(workoutId, refresh: true);
  }

  Future<void> getSelectionWorkouts({
    MuscleGroup? muscleGroup,
    String name = "",
    bool isFavorite = false,
  }) async {
    final requestId = state.selectionWorkoutsRequestId + 1;
    emit(
      state.copyWith(selectionWorkoutsRequestId: requestId, isLoading: true),
    );

    final result = await _workoutService.getAllWorkouts(
      muscleGroup: muscleGroup,
      name: name,
      isFavorite: isFavorite,
    );
    if (isClosed || requestId != state.selectionWorkoutsRequestId) return;

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to get selection workouts", error);
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
        workoutSelection: result.value,
        error: const Nullable(null),
        isLoading: false,
      ),
    );
  }
}
