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

import '../../../data/repositories/exercises/exercise_repository.dart';
import '../../../data/repositories/exercises/inputs/equipment_input.dart';
import '../../../data/repositories/exercises/inputs/exercise_input.dart';
import '../../../data/utils/enums.dart';
import '../../../utils/errors.dart';
import '../../../utils/nullable.dart';
import '../../core/view_models/favorite_request_serializer.dart';
import '../../core/view_models/states/common_state.dart';
import './states/exercise_state.dart';

class ExerciseCubit extends Cubit<ExerciseState>
    with FavoriteRequestSerializer {
  final ExerciseRepository _exerciseService;

  final Logger _logger = Logger("ExerciseCubit");

  ExerciseCubit({required ExerciseRepository exerciseRepository})
    : _exerciseService = exerciseRepository,
      super(ExerciseState.initial());

  Future<void> getExercises({
    String? name,
    MuscleGroup? muscleGroup,
    Difficulty? difficulty,
    int? equipmentId,
    int? limit,
    int? offset,
    bool isFavourite = false,
  }) => _loadExercises(
    ExercisePagination(
      name: name ?? '',
      muscleGroup: muscleGroup,
      difficulty: difficulty,
      equipmentId: equipmentId,
      isFavorite: isFavourite,
      limit: limit ?? state.exercisePagination.limit,
      offset: offset ?? state.exercisePagination.offset,
      total: 0,
    ),
  );

  Future<void> _loadExercises(
    ExercisePagination query, {
    ExerciseState? afterWrite,
  }) async {
    final refresh = afterWrite != null;
    _logger.info('Getting exercises');
    final requestId = state.exercisesRequestId + 1;
    final limit = refresh ? query.offset + query.limit : query.limit;
    final offset = refresh ? 0 : query.offset;
    emit(
      (afterWrite ?? state).copyWith(
        exercisesRequestId: requestId,
        pendingExercisesQuery: Nullable(query),
      ),
    );

    final result = await _exerciseService.getExercises(
      name: query.name,
      muscleGroup: query.muscleGroup,
      isFavorite: query.isFavorite,
      difficulty: query.difficulty,
      equipmentId: query.equipmentId,
      limit: limit,
      offset: offset,
    );
    if (isClosed || requestId != state.exercisesRequestId) return;

    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to get exercises, error: $error');
      switch (error.type) {
        case OperationErrorTypes.invalidInput:
        case OperationErrorTypes.operationFailure:
          emit(
            state.copyWith(
              error: Nullable(
                ErrorState(
                  type: error.type.name,
                  description: "Failed to get exercises",
                ),
              ),
              pendingExercisesQuery: const Nullable(null),
              exercises: refresh ? const [] : null,
              exercisePagination: refresh
                  ? state.exercisePagination.copyWith(total: 0, offset: 0)
                  : null,
            ),
          );
          return;
      }
    }

    final page = result.value;
    emit(
      state.copyWith(
        exercises: offset > 0 ? [...state.exercises, ...page.data] : page.data,
        exercisePagination: query.copyWith(
          offset: page.offset,
          total: page.total,
        ),
        pendingExercisesQuery: const Nullable(null),
        error: const Nullable(null),
      ),
    );
  }

  Future<void> _refreshExercises(ExerciseState afterWrite) {
    // A write can shift page boundaries. Reload the prefix for the latest query.
    final query =
        state.pendingExercisesQuery ??
        state.exercisePagination.copyWith(
          offset: max(
            0,
            state.exercises.length - state.exercisePagination.limit,
          ),
        );
    return _loadExercises(query, afterWrite: afterWrite);
  }

  Future<void> getExercise(int id) async {
    _logger.info('getExercise: getting exercise by id: $id');
    emit(state.copyWith(isLoading: true));

    final result = await _exerciseService.getExercise(id);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to get exercise, error: $error");
      switch (error.type) {
        case SingleErrorTypes.notFound:
        case SingleErrorTypes.invalidInput:
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
                  description: "Failed to get exercise",
                ),
              ),
              isLoading: false,
            ),
          );
          return;
      }
    }

    _logger.info('Exercise retrieved successfully');
    emit(
      state.copyWith(
        selectedExercise: Nullable(result.value),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }

  Future<void> createExercise(
    ExerciseInput input, [
    CreatedBy createdBy = CreatedBy.user,
  ]) async {
    _logger.info('createExercise: creating exercise');
    emit(state.copyWith(isLoading: true));
    final result = await _exerciseService.createExercise(input, createdBy);

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to create exercise, error: $error");
      switch (error.type) {
        case SingleErrorTypes.notFound:
        case SingleErrorTypes.invalidInput:
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
                  description: "Failed to create exercise",
                ),
              ),
              isLoading: false,
            ),
          );
          return;
      }
    }

    _logger.info('Exercise created successfully');
    if (isClosed) return;
    await _refreshExercises(
      state.copyWith(
        selectedExercise: Nullable(result.value),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }

  Future<void> updateExercise(int id, ExerciseInput input) async {
    _logger.info('updateExercise: updating exercise by id: $id');
    emit(state.copyWith(isLoading: true));
    final result = await _exerciseService.updateExercise(id, input);

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to update exercise, error: $error");
      switch (error.type) {
        case SingleErrorTypes.notFound:
        case SingleErrorTypes.invalidInput:
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
                  description: "Failed to update exercise",
                ),
              ),
              isLoading: false,
            ),
          );
          return;
      }
    }
    if (isClosed) return;
    await _refreshExercises(
      state.copyWith(
        selectedExercise: Nullable(result.value),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }

  Future<void> updateExerciseFavorite(int id, bool isFavorite) {
    return serializeFavorite(() async {
      if (isClosed) return;
      _logger.info(
        'updateExerciseFavorite: updating exercise favorite by id: $id',
      );
      emit(state.copyWith(isLoading: true));
      final result = await _exerciseService.updateExerciseFavorite(
        id,
        isFavorite,
      );
      if (result.isErr()) {
        if (isClosed) return;
        final error = result.error;
        _logger.warning("Failed to update exercise favorite, error: $error");
        switch (error.type) {
          case SingleErrorTypes.notFound:
          case SingleErrorTypes.invalidInput:
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
                    description: "Failed to update exercise favorite",
                  ),
                ),
                isLoading: false,
              ),
            );
            return;
        }
      }
      final updatedExercise = result.value;
      if (isClosed) return;
      await _refreshExercises(
        state.copyWith(
          selectedExercise: state.selectedExercise?.id == id
              ? Nullable(updatedExercise)
              : null,
          isLoading: false,
          error: const Nullable(null),
        ),
      );
    });
  }

  Future<void> deleteExercise(int id) async {
    _logger.info('deleteExercise: deleting exercise by id: $id');
    emit(state.copyWith(isLoading: true));
    final result = await _exerciseService.deleteExercise(id);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to delete exercise, error: $error");
      switch (error.type) {
        case SingleErrorTypes.notFound:
        case SingleErrorTypes.invalidInput:
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
                  description: "Failed to delete exercise",
                ),
              ),
              isLoading: false,
            ),
          );
          return;
      }
    }

    if (isClosed) return;
    await _refreshExercises(
      state.copyWith(
        selectedExercise: state.selectedExercise?.id == id
            ? const Nullable(null)
            : null,
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }

  Future<void> getEquipments({
    String? name,
    required int limit,
    required int offset,
  }) async {
    _logger.info('getEquipments: fetching equipments');
    final requestId = state.equipmentsRequestId + 1;
    emit(state.copyWith(equipmentsRequestId: requestId, isLoading: true));

    final result = await _exerciseService.getEquipments(
      name: name,
      limit: limit,
      offset: offset,
    );
    if (isClosed || requestId != state.equipmentsRequestId) return;

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to fetch equipments, error: $error");
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(
              type: error.type.name,
              description: "Failed to fetch equipments",
            ),
          ),
          isLoading: false,
        ),
      );
      return;
    }

    final paginatedData = result.value;
    emit(
      state.copyWith(
        equipments: offset > 0
            ? [...state.equipments, ...paginatedData.data]
            : paginatedData.data,
        equipmentPagination: state.equipmentPagination.copyWith(
          name: name,
          limit: paginatedData.limit,
          offset: paginatedData.offset,
          total: paginatedData.total,
        ),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }

  Future<void> getEquipment(int id) async {
    _logger.info('getEquipment: getting equipment by id: $id');
    emit(state.copyWith(isLoading: true));

    final result = await _exerciseService.getEquipment(id);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to get equipment, error: $error");
      switch (error.type) {
        case SingleErrorTypes.notFound:
        case SingleErrorTypes.invalidInput:
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
                  description: "Failed to get equipment",
                ),
              ),
              isLoading: false,
            ),
          );
          return;
      }
    }

    final equipment = result.value;
    final exercisesResult = await _exerciseService.getExercisesByEquipmentId(
      id,
    );
    if (exercisesResult.isErr()) {
      final error = exercisesResult.error;
      _logger.warning("Failed to get exercises for equipment, error: $error");
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(
              type: error.type.name,
              description: "Failed to get exercises for equipment",
            ),
          ),
          isLoading: false,
        ),
      );
      return;
    }

    _logger.info('Equipment retrieved successfully');
    emit(
      state.copyWith(
        selectedEquipment: Nullable(
          SelectedEquipment(
            equipment: equipment,
            relatedExercises: exercisesResult.value,
          ),
        ),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
  }

  Future<void> createEquipment(
    EquipmentInput input, [
    CreatedBy createdBy = CreatedBy.user,
  ]) async {
    _logger.info('createEquipment: creating equipment');
    emit(state.copyWith(isLoading: true));

    final result = await _exerciseService.createEquipment(input, createdBy);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to create equipment, error: $error');
      switch (error.type) {
        case OperationErrorTypes.invalidInput:
        case OperationErrorTypes.operationFailure:
          emit(
            state.copyWith(
              error: Nullable(
                ErrorState(
                  type: error.type.name,
                  description: "Failed to create equipment",
                ),
              ),
              isLoading: false,
            ),
          );
          return;
      }
    }

    final pagination = state.equipmentPagination;
    final equipmentsResult = await _exerciseService.getEquipments(
      name: pagination.name,
      limit: pagination.limit,
      offset: 0,
    );
    if (equipmentsResult.isErr()) {
      final error = equipmentsResult.error;
      _logger.warning("Failed to get equipments, error: $error");
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(
              type: error.type.name,
              description: "Failed to get equipments",
            ),
          ),
          isLoading: false,
        ),
      );
      return;
    }

    final paginatedData = equipmentsResult.value;
    _logger.info('Equipment created successfully');
    emit(
      state.copyWith(
        isLoading: false,
        equipments: paginatedData.data,
        equipmentPagination: pagination.copyWith(
          name: pagination.name,
          limit: pagination.limit,
          offset: 0,
          total: paginatedData.total,
        ),
        selectedEquipment: Nullable(
          SelectedEquipment(equipment: result.value, relatedExercises: []),
        ),
        error: const Nullable(null),
      ),
    );
  }

  Future<void> deleteEquipment(int id) async {
    _logger.info('deleteEquipment: deleting equipment');
    emit(state.copyWith(isLoading: true));

    final result = await _exerciseService.deleteEquipment(id);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to delete equipment, error: $error');
      switch (error.type) {
        case SingleErrorTypes.notFound:
          emit(
            state.copyWith(
              error: Nullable(
                ErrorState(
                  type: error.type.name,
                  description: "Equipment not found",
                ),
              ),
              isLoading: false,
            ),
          );
          return;
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.operationFailure:
          emit(
            state.copyWith(
              error: Nullable(
                ErrorState(
                  type: error.type.name,
                  description: "Failed to delete equipment",
                ),
              ),
              isLoading: false,
            ),
          );
          return;
      }
    }

    final pagination = state.equipmentPagination;
    _logger.info('Equipment deleted successfully');
    emit(
      state.copyWith(
        isLoading: false,
        equipments: state.equipments.where((e) => e.id != id).toList(),
        selectedEquipment: state.selectedEquipment?.equipment.id == id
            ? const Nullable(null)
            : null,
        equipmentPagination: pagination.copyWith(total: pagination.total - 1),
        error: const Nullable(null),
      ),
    );
  }

  Future<void> updateEquipment(int id, EquipmentInput input) async {
    _logger.info('updateEquipment: updating equipment');
    emit(state.copyWith(isLoading: true));

    final result = await _exerciseService.updateEquipment(id, input);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to update equipment, error: $error');
      switch (error.type) {
        case SingleErrorTypes.notFound:
          emit(
            state.copyWith(
              error: Nullable(
                ErrorState(
                  type: error.type.name,
                  description: "Equipment not found",
                ),
              ),
              isLoading: false,
            ),
          );
          return;
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.operationFailure:
          emit(
            state.copyWith(
              error: Nullable(
                ErrorState(
                  type: error.type.name,
                  description: "Failed to update equipment",
                ),
              ),
              isLoading: false,
            ),
          );
          return;
      }
    }

    final exercisesResult = await _exerciseService.getExercisesByEquipmentId(
      id,
    );
    if (exercisesResult.isErr()) {
      final error = exercisesResult.error;
      _logger.warning("Failed to get exercises for equipment, error: $error");
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(
              type: error.type.name,
              description: "Failed to get exercises for equipment",
            ),
          ),
          isLoading: false,
        ),
      );
      return;
    }

    final pagination = state.equipmentPagination;
    final equipmentsResult = await _exerciseService.getEquipments(
      name: pagination.name,
      limit: pagination.limit,
      offset: 0,
    );
    if (equipmentsResult.isErr()) {
      final error = equipmentsResult.error;
      _logger.warning("Failed to get equipments, error: $error");
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(
              type: error.type.name,
              description: "Failed to get equipments",
            ),
          ),
          isLoading: false,
        ),
      );
      return;
    }

    final paginatedData = equipmentsResult.value;
    _logger.info('Equipment updated successfully');
    emit(
      state.copyWith(
        isLoading: false,
        equipments: paginatedData.data,
        equipmentPagination: pagination.copyWith(
          name: pagination.name,
          limit: pagination.limit,
          offset: 0,
          total: paginatedData.total,
        ),
        selectedEquipment: Nullable(
          SelectedEquipment(
            equipment: result.value,
            relatedExercises: exercisesResult.value,
          ),
        ),
        error: const Nullable(null),
      ),
    );
  }

  Future<void> getSelectionEquipments() async {
    emit(state.copyWith(isLoading: true));
    final equipmentsResult = await _exerciseService.getAllEquipments();
    if (equipmentsResult.isErr()) {
      final error = equipmentsResult.error;
      _logger.warning("Failed to get equipments, error: $error");
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(
              type: error.type.name,
              description: "Failed to get equipments",
            ),
          ),
          isLoading: false,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        isLoading: false,
        equipmentSelection: equipmentsResult.value.fold<Map<int, String>>({}, (
          previousValue,
          element,
        ) {
          previousValue[element.id] = element.name;
          return previousValue;
        }),
        error: const Nullable(null),
      ),
    );
  }

  Future<void> getSelectionExercises({
    MuscleGroup? muscleGroup,
    String name = "",
    bool isFavorite = false,
  }) async {
    final requestId = state.selectionExercisesRequestId + 1;
    emit(
      state.copyWith(selectionExercisesRequestId: requestId, isLoading: true),
    );
    final exercisesResult = await _exerciseService.getAllExercises(
      muscleGroup: muscleGroup,
      name: name,
      isFavorite: isFavorite,
    );
    if (isClosed || requestId != state.selectionExercisesRequestId) return;
    if (exercisesResult.isErr()) {
      final error = exercisesResult.error;
      _logger.warning("Failed to get exercises, error: $error");
      emit(
        state.copyWith(
          error: Nullable(
            ErrorState(
              type: error.type.name,
              description: "Failed to get exercises",
            ),
          ),
          isLoading: false,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        isLoading: false,
        exerciseSelection: exercisesResult.value,
        error: const Nullable(null),
      ),
    );
  }
}
