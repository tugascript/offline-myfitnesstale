import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../models/common.dart';
import '../models/enums.dart';
import '../services/common/errors.dart';
import '../services/workout_service.dart';
import '../services/dtos/workout_dto.dart';
import '../models/workout_set_exercise_model.dart';
import 'states/common_state.dart';
import 'states/workout_state.dart';

class WorkoutCubit extends Cubit<WorkoutState> {
  final WorkoutService _workoutService = WorkoutService();

  final Logger _logger = Logger('WorkoutCubit');

  WorkoutCubit() : super(WorkoutState.initial());

  Future<void> getWorkouts({
    String? name,
    Difficulty? difficulty,
    MuscleGroup? muscleGroup,
    int? limit,
    int? offset,
    bool isFavorite = false,
  }) async {
    _logger.info('Getting workouts');
    final isLoadMore = (offset ?? state.pagination.offset) > 0;

    // Only set loading to true if not loading more to avoid flickering or full screen loader?
    // Usually for infinite scroll we might want a different loading state or just check isLoading in UI
    // For now let's keep it simple, but we might check this in UI to show bottom loader vs full loader
    emit(state.copyWith(isLoading: true));

    final result = await _workoutService.getWorkouts(
      name: name,
      difficulty: difficulty,
      muscleGroup: muscleGroup,
      isFavorite: isFavorite,
      limit: limit ?? state.pagination.limit,
      offset: offset ?? state.pagination.offset,
    );
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to get workouts", error);

      switch (error.type) {
        case OperationErrorTypes.invalidInput:
        case OperationErrorTypes.operationFailure:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: "Failed to get workouts",
            ),
            isLoading: false,
          ));
          return;
      }
    }

    _logger.info("Got workouts successfully");
    final paginatedData = result.value;

    late final List<WorkoutDto> updatedWorkouts;
    if (isLoadMore) {
      updatedWorkouts = [...state.workouts, ...paginatedData.data];
    } else {
      updatedWorkouts = paginatedData.data;
    }

    emit(state.copyWith(
      workouts: updatedWorkouts,
      pagination: state.pagination.copyWith(
        name: name,
        muscleGroup: muscleGroup,
        difficulty: difficulty,
        limit: paginatedData.limit,
        offset: paginatedData.offset,
        total: paginatedData.total,
        isFavorite: isFavorite,
      ),
      isLoading: false,
    ));
  }

  Future<void> createWorkout({
    required String name,
    required bool isFavorite,
    required Difficulty difficulty,
    String? description,
    PictureData? picture,
    VideoData? video,
  }) async {
    _logger.info('Creating workout');
    emit(state.copyWith(isLoading: true));

    final result = await _workoutService.createWorkout(
      name: name,
      isFavorite: isFavorite,
      difficulty: difficulty,
      description: description,
      picture: picture,
      video: video,
    );
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to create workout", error);

      switch (error.type) {
        case OperationErrorTypes.invalidInput:
        case OperationErrorTypes.operationFailure:
          emit(state.copyWith(
            error: ErrorState(
              type: error.type.name,
              description: "Failed to create workout",
            ),
            isLoading: false,
          ));
          return;
      }
    }

    _logger.info("Workout created successfully");
    final workout = result.value;
    emit(state.copyWith(
      workouts: [workout, ...state.workouts],
      pagination: state.pagination.copyWith(
        total: state.pagination.total + 1,
      ),
      isLoading: false,
    ));
  }

  Future<void> getWorkout(int id, {bool refresh = false}) async {
    _logger.info('Getting workout with id $id');
    if (!refresh) {
      emit(state.copyWith(isLoading: true));
    }

    final result = await _workoutService.getWorkout(id);
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to get workout", error);

      switch (error.type) {
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.notFound:
          emit(
            state.copyWith(
              error: ErrorState(
                type: error.type.name,
                description: error.description,
              ),
              isLoading: false,
            ),
          );
          return;
        case SingleErrorTypes.operationFailure:
          emit(
            state.copyWith(
              error: ErrorState(
                type: error.type.name,
                description: "Failed to get workout",
              ),
              isLoading: false,
            ),
          );
          return;
      }
    }

    _logger.info("Workout got successfully");
    emit(state.copyWith(
      selectedWorkout: result.value,
      isLoading: false,
    ));
  }

  Future<void> updateWorkout({
    required int id,
    String? name,
    Difficulty? difficulty,
    String? description,
    PictureData? picture,
    VideoData? video,
    bool? isFavorite,
  }) async {
    _logger.info('Updating workout with id $id');
    emit(state.copyWith(isLoading: true));

    final result = await _workoutService.updateWorkout(
      id: id,
      name: name,
      difficulty: difficulty,
      description: description,
      picture: picture,
      video: video,
      isFavorite: isFavorite,
    );
    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to update workout", error);

      switch (error.type) {
        case SingleErrorTypes.invalidInput:
        case SingleErrorTypes.notFound:
          emit(
            state.copyWith(
              error: ErrorState(
                type: error.type.name,
                description: error.description,
              ),
              isLoading: false,
            ),
          );
          return;
        case SingleErrorTypes.operationFailure:
          emit(
            state.copyWith(
              error: ErrorState(
                type: error.type.name,
                description: "Failed to update workout",
              ),
              isLoading: false,
            ),
          );
          return;
      }
    }

    _logger.info("Workout updated successfully");
    final workout = result.value.copyWith(
      sets: state.selectedWorkout?.id == id
          ? state.selectedWorkout?.sets
          : result.value.sets,
    );
    emit(state.copyWith(
      selectedWorkout: workout,
      workouts: state.workouts.map((w) => w.id == id ? workout : w).toList(),
      isLoading: false,
    ));
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
              error: ErrorState(
                type: error.type.name,
                description: error.description,
              ),
              isLoading: false,
            ),
          );
          return;
        case SingleErrorTypes.operationFailure:
          emit(
            state.copyWith(
              error: ErrorState(
                type: error.type.name,
                description: "Failed to delete workout",
              ),
              isLoading: false,
            ),
          );
          return;
      }
    }

    _logger.info("Workout deleted successfully");
    emit(state.copyWith(
      workouts: state.workouts.where((w) => w.id != id).toList(),
      pagination: state.pagination.copyWith(
        total: state.pagination.total - 1,
      ),
      isLoading: false,
    ));
  }

  Future<void> createWorkoutSet({
    required int workoutId,
    required WorkoutSetType setType,
    required int minSets,
    required int recommendedRestSecs,
    required List<WorkoutSetExerciseInput> exercises,
    int? position,
    int? maxSets,
    int? maxRestSecs,
  }) async {
    _logger.info('Creating workout set for workout $workoutId');
    emit(state.copyWith(isLoading: true));

    final result = await _workoutService.createWorkoutSet(
      workoutId: workoutId,
      setType: setType,
      minSets: minSets,
      recommendedRestSecs: recommendedRestSecs,
      exercises: exercises,
      position: position,
      maxSets: maxSets,
      maxRestSecs: maxRestSecs,
    );

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to create workout set", error);
      emit(state.copyWith(
        error: ErrorState(
          type: error.type.name,
          description: error.description,
        ),
        isLoading: false,
      ));
      return;
    }

    // Refresh workout to get updated sets
    await getWorkout(workoutId);
  }

  Future<void> updateWorkoutSet({
    required int workoutSetId,
    required int workoutId,
    WorkoutSetType? setType,
    int? minSets,
    int? recommendedRestSecs,
    int? maxSets,
    int? maxRestSecs,
  }) async {
    _logger.info('Updating workout set $workoutSetId');
    emit(state.copyWith(isLoading: true));

    final result = await _workoutService.updateWorkoutSet(
      workoutSetId: workoutSetId,
      setType: setType,
      minSets: minSets,
      recommendedRestSecs: recommendedRestSecs,
      maxSets: maxSets,
      maxRestSecs: maxRestSecs,
    );

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to update workout set", error);
      emit(state.copyWith(
        error: ErrorState(
          type: error.type.name,
          description: error.description,
        ),
        isLoading: false,
      ));
      return;
    }

    if (state.selectedWorkout != null &&
        state.selectedWorkout!.id == workoutId) {
      await refreshWorkoutSets(workoutId);
      return;
    }

    await getWorkout(workoutId, refresh: true);
  }

  Future<void> deleteWorkoutSet({
    required int workoutSetId,
    required int workoutId,
  }) async {
    _logger.info('Deleting workout set $workoutSetId');
    emit(state.copyWith(isLoading: true));

    final result = await _workoutService.deleteWorkoutSet(workoutSetId);

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to delete workout set", error);
      emit(state.copyWith(
        error: ErrorState(
          type: error.type.name,
          description: error.description,
        ),
        isLoading: false,
      ));
      return;
    }

    // Refresh workout
    await getWorkout(workoutId);
  }

  Future<void> updateWorkoutSetPosition({
    required int workoutSetId,
    required int position,
  }) async {
    _logger.info('Updating workout set $workoutSetId position to $position');
    emit(state.copyWith(isLoading: true));

    final result = await _workoutService.updateWorkoutSetPosition(
      workoutSetId: workoutSetId,
      position: position,
    );

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to update workout set position", error);
      emit(state.copyWith(
        error: ErrorState(
          type: error.type.name,
          description: error.description,
        ),
        isLoading: false,
      ));
      return;
    }

    // Refresh workout to reflect new order
    if (state.selectedWorkout != null) {
      await getWorkout(state.selectedWorkout!.id);
    } else {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> updateWorkoutSetExercise({
    required int workoutSetExerciseId,
    required int workoutId,
    int? minReps,
    int? maxReps,
    int? exerciseId,
    WorkoutSetExerciseDifficulty? difficulty,
    bool? toMaxReps,
  }) async {
    _logger.info('Updating workout set exercise $workoutSetExerciseId');
    // We don't want to show loading indicator for this as it's a small update
    // from a text field usually
    // emit(state.copyWith(isLoading: true));

    final result = await _workoutService.updateWorkoutSetExercise(
      workoutSetExerciseId: workoutSetExerciseId,
      minReps: minReps,
      maxReps: maxReps,
      exerciseId: exerciseId,
      difficulty: difficulty,
      toMaxReps: toMaxReps,
    );

    if (result.isErr()) {
      final error = result.error;
      _logger.warning("Failed to update workout set exercise", error);
      emit(state.copyWith(
        error: ErrorState(
          type: error.type.name,
          description: error.description,
        ),
        isLoading: false,
      ));
      return;
    }

    if (state.selectedWorkout != null &&
        state.selectedWorkout!.id == workoutId) {
      await refreshWorkoutSets(workoutId);
      return;
    }

    await getWorkout(workoutId, refresh: true);
  }

  Future<void> refreshWorkoutSets(int workoutId) async {
    _logger.info('Refreshing workout sets for workout $workoutId');

    final sets = await _workoutService.getWorkoutSets(workoutId);
    if (sets.isErr()) {
      final error = sets.error;
      _logger.warning("Failed to get workout sets", error);
      emit(state.copyWith(
        error: ErrorState(
          type: error.type.name,
          description: error.description,
        ),
        isLoading: false,
      ));
      return;
    }

    final updatedSets = sets.value;
    emit(state.copyWith(
      selectedWorkout: state.selectedWorkout?.copyWith(sets: updatedSets),
      isLoading: false,
    ));
  }
}
