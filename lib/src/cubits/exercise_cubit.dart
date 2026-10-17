import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../common/nullable.dart';
import '../models/enums.dart';
import '../services/common/errors.dart';
import '../services/dtos/exercise_dto.dart';
import '../services/exercise_service.dart';
import '../services/inputs/equipment_input.dart';
import '../services/inputs/exercise_input.dart';
import 'states/common_state.dart';
import 'states/exercise_state.dart';

class ExerciseCubit extends Cubit<ExerciseState> {
  final ExerciseService _exerciseService = ExerciseService();

  final Logger _logger = Logger("ExerciseCubit");

  ExerciseCubit() : super(ExerciseState.initial());

  Future<void> getExercises({
    String? name,
    MuscleGroup? muscleGroup,
    Difficulty? difficulty,
    int? equipmentId,
    int? limit,
    int? offset,
    bool isFavourite = false,
  }) async {
    _logger.info('Getting exercises');
    final isLoadMore = (offset ?? state.exercisePagination.offset) > 0;

    emit(state.copyWith(isLoading: true));

    final result = await _exerciseService.getExercises(
      name: name,
      muscleGroup: muscleGroup,
      isFavorite: isFavourite,
      difficulty: difficulty,
      equipmentId: equipmentId,
      limit: limit ?? state.exercisePagination.limit,
      offset: offset ?? state.exercisePagination.offset,
    );

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
              isLoading: false,
            ),
          );
          return;
      }
    }

    _logger.info('Exercises retrieved successfully');
    final paginatedData = result.value;
    late final List<ExerciseDto> updatedExercises;

    if (isLoadMore) {
      updatedExercises = [...state.exercises, ...paginatedData.data];
    } else {
      updatedExercises = paginatedData.data;
    }

    emit(
      state.copyWith(
        exercises: updatedExercises,
        exercisePagination: state.exercisePagination.copyWith(
          name: name,
          muscleGroup: Nullable(muscleGroup),
          difficulty: Nullable(difficulty),
          equipmentId: Nullable(equipmentId),
          isFavorite: isFavourite,
          total: paginatedData.total,
          limit: paginatedData.limit,
          offset: paginatedData.offset,
        ),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
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
    emit(
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
    emit(
      state.copyWith(
        selectedExercise: Nullable(result.value),
        isLoading: false,
        error: const Nullable(null),
      ),
    );

    // Refresh exercises list if the updated exercise is in it
    if (state.exercises.any((e) => e.id == id)) {
      await getExercises(
        name: state.exercisePagination.name,
        muscleGroup: state.exercisePagination.muscleGroup,
        difficulty: state.exercisePagination.difficulty,
        equipmentId: state.exercisePagination.equipmentId,
        isFavourite: state.exercisePagination.isFavorite,
        limit: state.exercisePagination.limit,
        offset: state.exercisePagination.offset,
      );
    }
  }

  Future<void> updateExerciseFavorite(int id, bool isFavorite) async {
    _logger.info(
      'updateExerciseFavorite: updating exercise favorite by id: $id',
    );
    emit(state.copyWith(isLoading: true));
    final result = await _exerciseService.updateExerciseFavorite(
      id,
      isFavorite,
    );
    if (result.isErr()) {
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
    emit(
      state.copyWith(
        selectedExercise: Nullable(result.value),
        isLoading: false,
        error: const Nullable(null),
      ),
    );
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

    // Remove from current exercises list
    final updatedExercises = state.exercises.where((e) => e.id != id).toList();
    emit(
      state.copyWith(
        exercises: updatedExercises,
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
    emit(state.copyWith(isLoading: true));

    final result = await _exerciseService.getEquipments(
      name: name,
      limit: limit,
      offset: offset,
    );

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
            ? [...paginatedData.data, ...state.equipments]
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
    emit(state.copyWith(isLoading: true));
    final exercisesResult = await _exerciseService.getAllExercises(
      muscleGroup: muscleGroup,
      name: name,
      isFavorite: isFavorite,
    );
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
