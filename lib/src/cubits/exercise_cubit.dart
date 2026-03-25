import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../models/common.dart';
import '../models/enums.dart';
import '../services/common/errors.dart';
import '../services/dtos/exercise_dto.dart';
import '../services/exercise_service.dart';
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
      limit: limit ?? state.exercisePagination.limit,
      offset: offset ?? state.exercisePagination.offset,
    );

    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to get exercises, error: $error');
      switch (error.type) {
        case OperationErrorTypes.invalidInput:
        case OperationErrorTypes.operationFailure:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: "Failed to get exercises",
            ),
            isLoading: false,
          ));
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

    emit(state.copyWith(
      exercises: updatedExercises,
      exercisePagination: state.exercisePagination.copyWith(
        name: name,
        muscleGroup: muscleGroup,
        difficulty: difficulty,
        isFavorite: isFavourite,
        total: paginatedData.total,
        limit: paginatedData.limit,
        offset: paginatedData.offset,
      ),
      isLoading: false,
    ));
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
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: error.description,
            ),
            isLoading: false,
          ));
          return;
        case SingleErrorTypes.operationFailure:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: "Failed to get exercise",
            ),
            isLoading: false,
          ));
          return;
      }
    }

    _logger.info('Exercise retrieved successfully');
    emit(state.copyWith(
      selectedExercise: result.value,
      isLoading: false,
    ));
  }

  Future<void> createExercise({
    required String name,
    required MuscleGroup muscleGroup,
    required Set<Muscle> primaryMuscles,
    required Set<Muscle> secondaryMuscles,
    VideoData? video,
    PictureData? picture,
    String? description,
    Set<int>? equipmentIds,
    Difficulty? difficulty,
    bool isFavorite = false,
  }) async {
    _logger.info('createExercise: creating exercise');
    emit(state.copyWith(isLoading: true));
    final result = await _exerciseService.createExercise(
      name: name,
      muscleGroup: muscleGroup,
      muscles: TargetMuscles(
        primary: primaryMuscles,
        secondary: secondaryMuscles,
      ),
      video: video,
      picture: picture,
      description: description,
      equipmentIds: equipmentIds,
      difficulty: difficulty,
      isFavorite: isFavorite,
    );

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to create exercise, error: $error");
      switch (error.type) {
        case SingleErrorTypes.notFound:
        case SingleErrorTypes.invalidInput:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: error.description,
            ),
            isLoading: false,
          ));
          return;
        case SingleErrorTypes.operationFailure:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: "Failed to create exercise",
            ),
            isLoading: false,
          ));
          return;
      }
    }

    _logger.info('Exercise created successfully');
    emit(state.copyWith(
      selectedExercise: result.value,
      isLoading: false,
    ));
  }

  Future<void> updateExercise({
    required int id,
    required Set<Muscle> primaryMuscles,
    required Set<Muscle> secondaryMuscles,
    String? name,
    String? description,
    MuscleGroup? muscleGroup,
    VideoData? video,
    PictureData? picture,
    Set<int>? equipmentIds,
    bool? isFavorite,
    Difficulty? difficulty,
  }) async {
    _logger.info('updateExercise: updating exercise by id: $id');
    emit(state.copyWith(isLoading: true));
    final result = await _exerciseService.updateExercise(
      id,
      name: name,
      description: description,
      muscleGroup: muscleGroup,
      muscles: TargetMuscles(
        primary: primaryMuscles,
        secondary: secondaryMuscles,
      ),
      video: video,
      picture: picture,
      isFavorite: isFavorite,
      difficulty: difficulty,
      equipmentIds: equipmentIds,
    );

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to update exercise, error: $error");
      switch (error.type) {
        case SingleErrorTypes.notFound:
        case SingleErrorTypes.invalidInput:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: error.description,
            ),
            isLoading: false,
          ));
          return;
        case SingleErrorTypes.operationFailure:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: "Failed to update exercise",
            ),
            isLoading: false,
          ));
          return;
      }
    }
    emit(state.copyWith(
      selectedExercise: result.value,
      isLoading: false,
    ));

    // Refresh exercises list if the updated exercise is in it
    if (state.exercises.any((e) => e.id == id)) {
      await getExercises(
        name: state.exercisePagination.name,
        muscleGroup: state.exercisePagination.muscleGroup,
        limit: state.exercisePagination.limit,
        offset: state.exercisePagination.offset,
      );
    }
  }

  Future<void> updateExerciseFavorite(int id, bool isFavorite) async {
    _logger
        .info('updateExerciseFavorite: updating exercise favorite by id: $id');
    emit(state.copyWith(isLoading: true));
    final result =
        await _exerciseService.updateExercise(id, isFavorite: isFavorite);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to update exercise favorite, error: $error");
      switch (error.type) {
        case SingleErrorTypes.notFound:
        case SingleErrorTypes.invalidInput:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: error.description,
            ),
            isLoading: false,
          ));
          return;
        case SingleErrorTypes.operationFailure:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: "Failed to update exercise favorite",
            ),
            isLoading: false,
          ));
          return;
      }
    }
    emit(state.copyWith(
      selectedExercise: result.value,
      isLoading: false,
    ));
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
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: error.description,
            ),
            isLoading: false,
          ));
          return;
        case SingleErrorTypes.operationFailure:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: "Failed to delete exercise",
            ),
            isLoading: false,
          ));
          return;
      }
    }

    // Remove from current exercises list
    final updatedExercises = state.exercises.where((e) => e.id != id).toList();
    emit(
      state.copyWith(
        exercises: updatedExercises,
        selectedExercise:
            state.selectedExercise?.id == id ? null : state.selectedExercise,
        isLoading: false,
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
      emit(state.copyWith(
        error: ErrorState(
          type: error.type.name,
          description: "Failed to fetch equipments",
        ),
        isLoading: false,
      ));
      return;
    }

    final paginatedData = result.value;
    emit(state.copyWith(
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
    ));
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
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: error.description,
            ),
            isLoading: false,
          ));
          return;
        case SingleErrorTypes.operationFailure:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: "Failed to get equipment",
            ),
            isLoading: false,
          ));
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
      emit(state.copyWith(
        error: ErrorState(
          type: error.type.name,
          description: "Failed to get exercises for equipment",
        ),
        isLoading: false,
      ));
      return;
    }

    _logger.info('Equipment retrieved successfully');
    emit(state.copyWith(
      selectedEquipment: SelectedEquipment(
        equipment: equipment,
        relatedExercises: exercisesResult.value,
      ),
      isLoading: false,
    ));
  }

  Future<void> createEquipment(String name) async {
    _logger.info('createEquipment: creating equipment');
    emit(state.copyWith(isLoading: true));

    final result = await _exerciseService.createEquipment(name: name);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to create equipment, error: $error');
      switch (error.type) {
        case OperationErrorTypes.invalidInput:
        case OperationErrorTypes.operationFailure:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: "Failed to create equipment",
            ),
            isLoading: false,
          ));
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
      emit(state.copyWith(
        error: ErrorState(
          type: error.type.name,
          description: "Failed to get equipments",
        ),
        isLoading: false,
      ));
      return;
    }

    final paginatedData = equipmentsResult.value;
    _logger.info('Equipment created successfully');
    emit(state.copyWith(
      isLoading: false,
      equipments: paginatedData.data,
      equipmentPagination: pagination.copyWith(
        name: pagination.name,
        limit: pagination.limit,
        offset: 0,
        total: paginatedData.total,
      ),
      selectedEquipment: SelectedEquipment(
        equipment: result.value,
        relatedExercises: [],
      ),
    ));
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
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: "Equipment not found",
            ),
            isLoading: false,
          ));
          return;
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.operationFailure:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: "Failed to delete equipment",
            ),
            isLoading: false,
          ));
          return;
      }
    }

    final pagination = state.equipmentPagination;
    _logger.info('Equipment deleted successfully');
    emit(state.copyWith(
      isLoading: false,
      equipments: state.equipments.where((e) => e.id != id).toList(),
      equipmentPagination: pagination.copyWith(
        total: pagination.total - 1,
      ),
    ));
  }

  Future<void> updateEquipment({
    required int id,
    required String name,
  }) async {
    _logger.info('updateEquipment: updating equipment');
    emit(state.copyWith(isLoading: true));

    final result = await _exerciseService.updateEquipment(id, name: name);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to update equipment, error: $error');
      switch (error.type) {
        case SingleErrorTypes.notFound:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: "Equipment not found",
            ),
            isLoading: false,
          ));
          return;
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.operationFailure:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: "Failed to update equipment",
            ),
            isLoading: false,
          ));
          return;
      }
    }

    final exercisesResult = await _exerciseService.getExercisesByEquipmentId(
      id,
    );
    if (exercisesResult.isErr()) {
      final error = exercisesResult.error;
      _logger.warning("Failed to get exercises for equipment, error: $error");
      emit(state.copyWith(
        error: ErrorState(
          type: error.type.name,
          description: "Failed to get exercises for equipment",
        ),
        isLoading: false,
      ));
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
      emit(state.copyWith(
        error: ErrorState(
          type: error.type.name,
          description: "Failed to get equipments",
        ),
        isLoading: false,
      ));
      return;
    }

    final paginatedData = equipmentsResult.value;
    _logger.info('Equipment updated successfully');
    emit(state.copyWith(
      isLoading: false,
      equipments: paginatedData.data,
      equipmentPagination: pagination.copyWith(
        name: pagination.name,
        limit: pagination.limit,
        offset: 0,
        total: paginatedData.total,
      ),
      selectedEquipment: SelectedEquipment(
        equipment: result.value,
        relatedExercises: exercisesResult.value,
      ),
    ));
  }

  Future<void> getSelectionEquipments() async {
    emit(state.copyWith(isLoading: true));
    final equipmentsResult = await _exerciseService.getAllEquipments();
    if (equipmentsResult.isErr()) {
      final error = equipmentsResult.error;
      _logger.warning("Failed to get equipments, error: $error");
      emit(state.copyWith(
        error: ErrorState(
          type: error.type.name,
          description: "Failed to get equipments",
        ),
        isLoading: false,
      ));
      return;
    }
    emit(state.copyWith(
      isLoading: false,
      equipmentSelection: equipmentsResult.value.fold<Map<int, String>>(
        {},
        (previousValue, element) {
          previousValue[element.id] = element.name;
          return previousValue;
        },
      ),
    ));
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
      emit(state.copyWith(
        error: ErrorState(
          type: error.type.name,
          description: "Failed to get exercises",
        ),
        isLoading: false,
      ));
      return;
    }
    emit(state.copyWith(
      isLoading: false,
      exerciseSelection: exercisesResult.value,
    ));
  }
}
