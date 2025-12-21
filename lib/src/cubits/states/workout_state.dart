import 'package:equatable/equatable.dart';

import '../../models/muscle_group_model.dart';
import '../../models/muscle_model.dart';
import '../../models/workout_model.dart';
import '../../models/workout_set_exercise_model.dart';
import '../../models/workout_set_model.dart';

final class WorkoutPagination extends Equatable {
  final String? name;
  final int limit;
  final int offset;

  const WorkoutPagination({
    this.name,
    required this.limit,
    required this.offset,
  });

  factory WorkoutPagination.initial() {
    return const WorkoutPagination(
      limit: 10,
      offset: 0,
    );
  }

  WorkoutPagination copyWith({
    String? name,
    int? limit,
    int? offset,
  }) {
    return WorkoutPagination(
      name: name ?? this.name,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  @override
  List<Object?> get props => [name, limit, offset];
}

final class SelectedWorkoutSets extends Equatable {
  final WorkoutSet workoutSet;
  final List<WorkoutSetExercise> exercises;

  const SelectedWorkoutSets({
    required this.workoutSet,
    required this.exercises,
  });

  SelectedWorkoutSets copyWith({
    WorkoutSet? workoutSet,
    List<WorkoutSetExercise>? exercises,
  }) {
    return SelectedWorkoutSets(
      workoutSet: workoutSet ?? this.workoutSet,
      exercises: exercises ?? this.exercises,
    );
  }

  @override
  List<Object?> get props => [
        workoutSet.id,
        workoutSet.createdAt,
        workoutSet.updatedAt,
        exercises.length,
      ];
}

final class WorkoutWithMusclesAndGroups extends Equatable {
  final Workout workout;
  final List<MuscleGroup> muscleGroups;
  final List<Muscle> muscles;

  const WorkoutWithMusclesAndGroups({
    required this.workout,
    required this.muscleGroups,
    required this.muscles,
  });

  factory WorkoutWithMusclesAndGroups.create(Workout workout) {
    return WorkoutWithMusclesAndGroups(
      workout: workout,
      muscleGroups: const [],
      muscles: const [],
    );
  }

  WorkoutWithMusclesAndGroups copyWith({
    Workout? workout,
    List<MuscleGroup>? muscleGroups,
    List<Muscle>? muscles,
  }) {
    return WorkoutWithMusclesAndGroups(
      workout: workout ?? this.workout,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      muscles: muscles ?? this.muscles,
    );
  }

  @override
  List<Object?> get props => [
        workout.id,
        workout.createdAt,
        workout.updatedAt,
        muscles.length,
      ];
}

final class WorkoutState extends Equatable {
  final List<Workout> workouts;
  final WorkoutPagination pagination;
  final WorkoutWithMusclesAndGroups? selectedWorkout;
  final bool isLoading;
  final String? error;

  const WorkoutState({
    required this.workouts,
    required this.pagination,
    this.selectedWorkout,
    required this.isLoading,
    this.error,
  });

  factory WorkoutState.initial() {
    return WorkoutState(
      workouts: const [],
      pagination: WorkoutPagination.initial(),
      isLoading: false,
    );
  }

  WorkoutState copyWith({
    List<Workout>? workouts,
    WorkoutPagination? pagination,
    WorkoutWithMusclesAndGroups? selectedWorkout,
    bool? isLoading,
    String? error,
  }) {
    return WorkoutState(
      workouts: workouts ?? this.workouts,
      pagination: pagination ?? this.pagination,
      selectedWorkout: selectedWorkout ?? this.selectedWorkout,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        workouts.length,
        pagination,
        selectedWorkout,
        isLoading,
        error,
      ];
}
