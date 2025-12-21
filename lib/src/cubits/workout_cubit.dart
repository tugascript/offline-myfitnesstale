import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/enums.dart';
import '../models/muscle_group_model.dart';
import '../models/muscle_model.dart';
import '../models/workout_model.dart';
import '../services/workout_service.dart';
import 'states/workout_state.dart';

class WorkoutCubit extends Cubit<WorkoutState> {
  final WorkoutService _workoutService = WorkoutService();

  WorkoutCubit() : super(WorkoutState.initial());

  Future<void> getWorkouts({
    String? name,
    Difficulty? difficulty,
    int? limit,
    int? offset,
  }) async {
    emit(state.copyWith(isLoading: true));

    try {
      final List<Workout> workouts = await _workoutService.getWorkouts(
        name: name,
        difficulty: difficulty,
        limit: limit,
        offset: offset,
      );

      emit(state.copyWith(
        workouts: workouts,
        pagination: state.pagination.copyWith(
          name: name,
          limit: limit,
          offset: offset,
        ),
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> createWorkout({
    required String name,
    required Difficulty difficulty,
    String? description,
    String? pictureUri,
    (VideoPlatform, String)? videoData,
  }) async {
    emit(state.copyWith(isLoading: true));

    try {
      final Workout workout = await _workoutService.createWorkout(
        name: name,
        difficulty: difficulty,
        description: description,
        pictureUri: pictureUri,
        videoData: videoData,
      );

      emit(state.copyWith(
        workouts: [...state.workouts, workout],
        selectedWorkout: WorkoutWithMusclesAndGroups.create(workout),
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> getWorkout(int id) async {
    emit(state.copyWith(isLoading: true));

    try {
      final Workout? workout = await _workoutService.getWorkout(id);

      if (workout != null) {
        final List<MuscleGroup> muscleGroups =
            await _workoutService.getWorkoutMuscleGroups(id);
        final List<Muscle> muscles =
            await _workoutService.getWorkoutMuscles(id);

        emit(state.copyWith(
          selectedWorkout: WorkoutWithMusclesAndGroups(
            workout: workout,
            muscleGroups: muscleGroups,
            muscles: muscles,
          ),
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(
          error: 'Workout not found',
          isLoading: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> updateWorkout(
    int id, {
    String? name,
    Difficulty? difficulty,
    String? description,
    String? pictureUri,
    (VideoPlatform, String)? videoData,
  }) async {
    emit(state.copyWith(isLoading: true));

    try {
      final Workout? workout = await _workoutService.updateWorkout(
        id,
        name: name,
        difficulty: difficulty,
        description: description,
        pictureUri: pictureUri,
        videoData: videoData,
      );

      if (workout != null) {
        emit(state.copyWith(
          workouts: state.workouts
              .map((w) => w.id == workout.id ? workout : w)
              .toList(),
          selectedWorkout: state.selectedWorkout?.copyWith(workout: workout),
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(
          error: 'Workout not found',
          isLoading: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> deleteWorkout(int id) async {
    emit(state.copyWith(isLoading: true));

    try {
      final bool isDeleted = await _workoutService.deleteWorkout(id);

      if (isDeleted) {
        emit(state.copyWith(
          workouts: state.workouts.where((w) => w.id != id).toList(),
          selectedWorkout: null,
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(
          error: 'Workout not found',
          isLoading: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }
}
