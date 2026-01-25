import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../models/common.dart';
import '../models/enums.dart';
import '../services/common/errors.dart';
import '../services/workout_service.dart';
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
  }) async {
    _logger.info('Getting workouts');
    emit(state.copyWith(isLoading: true));
    final result = await _workoutService.getWorkouts(
      name: name,
      difficulty: difficulty,
      muscleGroup: muscleGroup,
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
    emit(state.copyWith(
      workouts: paginatedData.data,
      pagination: state.pagination.copyWith(
        name: name,
        muscleGroup: muscleGroup,
        difficulty: difficulty,
        limit: paginatedData.limit,
        offset: paginatedData.offset,
        total: paginatedData.total,
      ),
      isLoading: false,
    ));
  }

  Future<void> createWorkout({
    required String name,
    required Difficulty difficulty,
    String? description,
    PictureData? picture,
    VideoData? video,
  }) async {
    _logger.info('Creating workout');
    emit(state.copyWith(isLoading: true));

    final result = await _workoutService.createWorkout(
      name: name,
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

  Future<void> getWorkout(int id) async {
    _logger.info('Getting workout with id $id');
    emit(state.copyWith(isLoading: true));

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
    final workout = result.value;
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
}
