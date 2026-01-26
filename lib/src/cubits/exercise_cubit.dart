import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../models/common.dart';
import '../models/enums.dart';
import '../models/exercise_model.dart';
import '../services/common/errors.dart';
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
    bool? isFavorite,
    int? difficulty,
    int? limit,
    int? offset,
  }) async {
    _logger.info('getExercises: getting exercises');
    emit(state.copyWith(isLoading: true));
    final result = await _exerciseService.getExercises(
      name: name,
      muscleGroup: muscleGroup,
      isFavorite: isFavorite,
      difficulty: difficulty,
      limit: limit ?? state.exercisePagination.limit,
      offset: offset ?? state.exercisePagination.offset,
    );

    if (result.isErr()) {
      final error = result.error;
      _logger.warning('Failed to get exercises, error: $error');
      switch (error.type) {
        case OperationErrorTypes.invalidInput:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: error.description,
            ),
            isLoading: false,
          ));
          return;
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

    final paginatedData = result.value;
    _logger.info('Exercises retrieved successfully');
    emit(state.copyWith(
      exercises: paginatedData.data,
      pagination: state.exercisePagination.copyWith(
        name: name,
        muscleGroup: muscleGroup,
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
      relatedExercises: [], // Clear related exercises when a new exercise is selected
      isLoading: false,
    ));
  }

  Future<void> getRelatedExercises({
    required MuscleGroup muscleGroup,
    int limit = 5,
  }) async {
    _logger.info(
        'getRelatedExercises: getting related exercises for $muscleGroup');
    // We don't set global loading here to avoid full screen spinner if we want partial loading,
    // but implies UI handles it. If UI relies on isLoading, we might flicker.
    // Assuming related exercises load quietly or with their own indicator if we added one,
    // but for now reusing isLoading is okay if we are careful, OR just don't set isLoading=true
    // if we don't want to block UI.
    // Let's set isLoading=false initially or just don't emit loading.
    // Actually, let's keep it simple: just fetch and emit.

    final result = await _exerciseService.getExercises(
      muscleGroup: muscleGroup,
      limit: limit,
      offset: 0,
    );

    if (result.isErr()) {
      _logger.warning('Failed to get related exercises', result.error);
      // We can choose to ignore error for related exercises or show snackbar.
      // For now, let's just not update the list.
      return;
    }

    final paginatedData = result.value;
    emit(state.copyWith(
      relatedExercises: paginatedData.data,
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
    List<int>? equipmentIds,
    int? difficulty,
    bool isFavorite = false,
  }) async {
    _logger.info('createExercise: creating exercise');
    emit(state.copyWith(isLoading: true));
    final result = await _exerciseService.createExercise(
      name: name,
      muscleGroup: muscleGroup,
      muscles: ExerciseMuscles(
        primaryMuscles: primaryMuscles,
        secondaryMuscles: secondaryMuscles,
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
    String? name,
    String? description,
    MuscleGroup? muscleGroup,
    ExerciseMuscles? muscles,
    VideoData? video,
    PictureData? picture,
    bool? isFavorite,
    int? difficulty,
  }) async {
    _logger.info('updateExercise: updating exercise by id: $id');
    emit(state.copyWith(isLoading: true));
    final result = await _exerciseService.updateExercise(
      id,
      name: name,
      description: description,
      muscleGroup: muscleGroup,
      muscles: muscles,
      video: video,
      picture: picture,
      isFavorite: isFavorite,
      difficulty: difficulty,
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
}
